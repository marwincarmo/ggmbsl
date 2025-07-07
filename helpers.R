# Load required libraries
library(igraph)   # For generating graph structures
library(BDgraph)  # For sampling from the G-Wishart distribution
library(MCMCpack) # For sampling from the Inverse-Wishart distribution (riwish)
library(MASS)     # For sampling from the multivariate normal distribution (mvrnorm)


# generate_graph() ------------------------------------------------------------------

#' Generate a graph with a specific target density using current igraph functions
#'
#' This function iteratively adjusts the key parameter of igraph's graph
#' generation functions until the resulting graph's density is at least
#' as high as the target density.
#'
#' @param p The number of nodes in the graph.
#' @param target_density A numeric value between 0 and 1 for the desired graph density.
#' @param graph_type A character string, either "random", "scale-free" or "small-world".
#' @param max_iter The maximum number of iterations to prevent infinite loops.
#' @return An adjacency matrix (class 'matrix') of the generated graph.

generate_graph <- function(p, target_density, graph_type, max_iter = 100) {

  if (graph_type == "random") {

    # The 'p' argument in sample_gnp is the edge probability, which is the density.
    g <- igraph::sample_gnp(n = p, p = target_density, directed = FALSE)

  } else {
  # The parameter we will tune to adjust density
  tuning_param <- 1

  for (i in 1:max_iter) {

    if (graph_type == "scale-free") {
      # For scale-free, we tune 'm', the number of edges to add at each step.
      # It cannot be larger than 'p'.
      if (tuning_param >= p) {
        warning("Could not reach target density for scale-free graph; m reached p. Returning densest possible graph.")
        break
      }
      # CORRECTED FUNCTION: Using sample_pa()
      g <- igraph::sample_pa(n = p, m = tuning_param, power = 1, directed = FALSE)

    } else if (graph_type == "small-world") {
      # For small-world, we tune 'nei', the neighborhood size.
      # It cannot be larger than (p-1)/2
      if (tuning_param >= (p - 1) / 2) {
        warning("Could not reach target density for small-world graph; 'nei' is too large. Returning densest possible graph.")
        break
      }
      # CORRECTED FUNCTION: Using sample_smallworld()
      g <- igraph::sample_smallworld(dim = 1, size = p, nei = tuning_param, p = 0.05)

    } else {
      stop("Unsupported graph_type. Please use 'random', 'scale-free' or 'small-world'.")
    }

    # Calculate the density of the generated graph
    current_density <- igraph::edge_density(g)

    # Check if we have met or exceeded the target
    if (current_density >= target_density) {
      break
    }

    # If not, increment the tuning parameter for the next iteration
    tuning_param <- tuning_param + 1
  }
  }
  # Return the final graph as a standard R matrix
  return(as.matrix(igraph::as_adjacency_matrix(g)))
}

# get_strenght() --------------------------------------------------------------------

#' Custom function to compute node strenght
#'
#' @param graph_matrix A symmetric adjecency matrix with 0 and 1, where 1 represents the presence of an edge
#' @param precision_matrix A symmetric positive definite matrix representing the inverse of the covariance matrix.
#' @return A vector of node strenghts.
#'

get_strength <- function(graph_matrix, matrix_input, input_type = "precision") {

  # Check if the input type is valid
  if (!input_type %in% c("precision", "pcor")) {
    stop("input_type must be either 'precision' or 'pcor'")
  }
  # Convert to partial correlation matrix ONLY if the input is a precision matrix
  if (input_type == "precision") {
    p_cors <- -cov2cor(matrix_input)
  } else {
    # If input_type is "pcor", the matrix is already what we need
    p_cors <- matrix_input
  }
  diag(p_cors) <- 0
  # Apply the graph structure (set non-edges to zero)
  weighted_adj_matrix <- p_cors * graph_matrix
  # Calculate strength for each node
  node_strengths <- colSums(abs(weighted_adj_matrix))

  return(node_strengths)
}

# bggm_generate() -------------------------------------------------------------------

#' Generate GGM data from a Matrix-F prior
#'
#' @param n_obs Integer. The number of observations to simulate.
#' @param p_nodes Integer. The number of nodes (variables) in the graph.
#' @param delta Numeric. The hyperparameter for the scaled beta distribution
#'              of partial correlations. Smaller delta leads to more dispersed
#'              partial correlations (away from zero). delta = 2 is uniform.
#' @param graph_prob Numeric. The probability of an edge between any two nodes
#'                   for a random graph.
#' @param graph_type A character string, either "random", "scale-free" or  "small-world".
#' @return A list containing the simulated data, the true precision and
#'         covariance matrices, the adjacency matrix, and the true partial
#'         correlation matrix.
bggm_generate <- function(n_obs, p_nodes, sd_pcor, graph_type, graph_prob = 0.2) {

  # --- Step 1: Generate a Graph Structure ---
  adj_matrix <- generate_graph(p = p_nodes, target_density = graph_prob, graph_type = graph_type)

  # --- Step 2: Set Matrix-F Hyperparameters ---
  # As recommended in the paper (Sec 3.3.2) for the encompassing prior,
  # we set epsilon to a small value.
  epsilon <- 1e-05
  nu <- 1 / epsilon         # First degrees of freedom for Matrix-F
  B <- diag(p_nodes) * epsilon # Scale matrix for Matrix-F

    # --- Step 2a: Derive delta from the partial correlation SD ---
  # The variance of a scaled beta(-1, 1) distribution with shape parameters
  # delta/2 is 1 / (delta + 1). The standard deviation is sqrt(1 / (delta + 1)).
  # We can solve for delta: delta = (1 / sd_pcor^2) - 1.
  if (sd_pcor <= 0 || sd_pcor >= 1) {
    stop("sd_pcor must be between 0 and 1.")
  }
  delta <- (1 / sd_pcor^2) - 1

  # --- Step 3: Sample Auxiliary Matrix Psi from Inverse-Wishart ---

  # Initialize Theta to NULL
  Theta <- NULL

  # Use a repeat loop for rejection sampling
  for (i in 1:50) { # max tries = 50

    # Sample Auxiliary Matrix Psi from Inverse-Wishart
    # Psi ~ IW(delta + p - 1, B)
    df_iw <- delta + p_nodes - 1
    Psi <- MCMCpack::riwish(v = df_iw, S = B)

  # --- Step 4: Sample Precision Matrix Theta from G-Wishart ---
    # Attempt to sample Theta from G-Wishart
    # Theta ~ G-Wishart(nu, Psi)
    # The try() function will catch the error without stopping the script
    Theta_candidate <- try(
      BDgraph::rgwish(n = 1, b = nu, D = Psi, adj = adj_matrix),
      silent = TRUE
    )

    # Check if the attempt was successful
    if (!inherits(Theta_candidate, "try-error")) {
      # Success! Assign the result and break the loop
      Theta <- Theta_candidate
      break
    }
  }

  # --- Step 5: Compute Covariance and Partial Correlation Matrices ---
  # The covariance matrix is the inverse of the precision matrix.
  Sigma <- solve(Theta)

  # The partial correlation matrix can be computed from the precision matrix.
  Pcor <- -cov2cor(Theta)
  diag(Pcor) <- 1

  # --- Step 6: Generate Data from Multivariate Normal Distribution ---
  # Y ~ MVN(mu = 0, Sigma = Sigma_true)
  Y <- MASS::mvrnorm(n = n_obs, mu = rep(0, p_nodes), Sigma = Sigma)
  colnames(Y) <- paste0("V", 1:p_nodes)

  return(list(
    data = as.data.frame(Y),
    adj_matrix = adj_matrix,
    true_precision = Theta,
    true_covariance = Sigma,
    true_pcor = Pcor
  ))
}

# ===================================================================
#
# R Code to Simulate Data from a Gaussian Graphical Model (GGM)
# using the Stochastic Search Structure Learning (SSSL) Prior
# (Refined version using the latent Z variables for ground truth)
#
# Based on the generative model in:
# Wang, H. (2015). Scaling it up: Stochastic search structure learning
# in graphical models. Bayesian analysis, 10(2), 351-377.
#
# ===================================================================

#' Generate GGM data from the SSSL prior for a concentration graph
#'
#' @param n_obs Integer. Number of observations to simulate.
#' @param p_nodes Integer. Number of nodes (variables) in the graph.
#' @param v0 Numeric. The "spike" standard deviation (a small value).
#' @param h Numeric. The ratio of slab to spike variance (v1 = v0 * h).
#' @param pi Numeric. The prior probability of including an edge.
#' @param lambda Numeric. The rate parameter for the exponential prior on diagonals.
#' @param burnin Integer. Number of burn-in iterations for the generative sampler.
#'
#' @return A list containing the data, true graph, and true matrices.
simulate_ggm_sssl <- function(n_obs, p_nodes, v0 = 0.02, h = 50, pi = 0.1, lambda = 1, graph_type = "random", burnin = 10) {

  cat("1. Initializing...\n")
  # Set slab variance
  v1 <- v0 * h

   #  Generate a Graph Structure
  adj_matrix <- generate_graph(p = p_nodes, target_density = pi, graph_type = graph_type)

  # Initialize Omega as an identity matrix
  Omega_true <- diag(p_nodes)

  # --- Step B: Generative Gibbs Sampler Loop ---
  cat(paste("2. Running generative sampler for", burnin, "iterations...\n"))
  for (iter in 1:burnin) {
    for (j in 1:p_nodes) {
      j_minus <- setdiff(1:p_nodes, j)
      Omega_11 <- Omega_true[j_minus, j_minus]
      p_minus_1 <- p_nodes - 1

      # Determine spike/slab from the fixed adjacency matrix
      z_col <- adj_matrix[j, j_minus]
      v_z <- ifelse(z_col == 1, v1, v0)

      # Sample the column from its conditional prior
      Omega_11_inv <- solve(Omega_11)
      C_inv <- (lambda * Omega_11_inv) + diag(1 / v_z^2)
      C <- solve(C_inv)
      u_col <- MASS::mvrnorm(1, mu = rep(0, p_minus_1), Sigma = C)
      v_diag <- rgamma(1, shape = 1, rate = lambda / 2)
      omega_22_new <- v_diag + t(u_col) %*% Omega_11_inv %*% u_col

      # Update Omega
      Omega_true[j, j_minus] <- u_col
      Omega_true[j_minus, j] <- u_col
      Omega_true[j, j] <- omega_22_new
    }
  }

  cat("3. Finalizing matrices and generating data...\n")
  # Final covariance and partial correlation matrices
  Sigma_true <- solve(Omega_true)
  Pcor_true <- -cov2cor(Omega_true)
  diag(Pcor_true) <- 1

  # Generate Data
  Y_data <- MASS::mvrnorm(n = n_obs, mu = rep(0, p_nodes), Sigma = Sigma_true)
  colnames(Y_data) <- paste0("V", 1:p_nodes)

  cat("Simulation complete.\n")
  return(list(
    data = as.data.frame(Y_data),
    adj_matrix = adj_matrix,
    true_precision = Omega_true,
    true_covariance = Sigma_true,
    true_pcor = Pcor_true
  ))
}
