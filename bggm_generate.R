# --- 1. Load Required Libraries ---
# Make sure you have these packages installed:
# install.packages(c("igraph", "BDgraph", "MCMCpack", "MASS", "ggplot2", "reshape2"))

library(igraph)   # For generating graph structures
library(BDgraph)  # For sampling from the G-Wishart distribution
library(MCMCpack) # For sampling from the Inverse-Wishart distribution (riwish)
library(MASS)     # For sampling from the multivariate normal distribution (mvrnorm)

# --- 2. Define the Main Simulation Function ---

#' Generate GGM data from a Matrix-F prior
#'
#' @param n_obs Integer. The number of observations to simulate.
#' @param p_nodes Integer. The number of nodes (variables) in the graph.
#' @param delta Numeric. The hyperparameter for the scaled beta distribution
#'              of partial correlations. Smaller delta leads to more dispersed
#'              partial correlations (away from zero). delta = 2 is uniform.
#' @param graph_prob Numeric. The probability of an edge between any two nodes
#'                   for a random graph.
#'
#' @return A list containing the simulated data, the true precision and
#'         covariance matrices, the adjacency matrix, and the true partial
#'         correlation matrix.
bggm_generate <- function(n_obs, p_nodes, delta, graph_prob = 0.2) {

  # --- Step 1: Generate a Graph Structure ---
  # We'll create a random graph using igraph.
  # You could also use other structures like "scale-free".
  cat("1. Generating random graph structure...\n")
  graph <- generate_graph

  # --- Step 2: Set Matrix-F Hyperparameters ---
  # As recommended in the paper (Sec 3.3.2) for the encompassing prior,
  # we set epsilon to a small value.
  cat("2. Setting Matrix-F hyperparameters...\n")
  epsilon <- 1e-05
  nu <- 1 / epsilon         # First degrees of freedom for Matrix-F
  B <- diag(p_nodes) * epsilon # Scale matrix for Matrix-F

  # --- Step 3: Sample Auxiliary Matrix Psi from Inverse-Wishart ---
  # This is the first step in the hierarchical definition of the Matrix-F prior.
  # Psi ~ IW(delta + p - 1, B)
  cat("3. Sampling auxiliary matrix Psi from Inverse-Wishart distribution...\n")
  df_iw <- delta + p_nodes - 1
  Psi <- MCMCpack::riwish(v = df_iw, S = B)

  # --- Step 4: Sample Precision Matrix Theta from G-Wishart ---
  # This is the crucial step. We sample from the G-Wishart distribution,
  # which is a Wishart distribution constrained to the graph structure.
  # This ensures Theta is positive definite AND has the correct sparsity pattern.
  # Theta ~ G-Wishart(nu, Psi)
  cat("4. Sampling true precision matrix Theta from G-Wishart distribution...\n")
  # BDgraph::rgwish requires the degrees of freedom (b) and scale matrix (D)
  # and the adjacency matrix (adj) of the graph.
  Theta_true <- BDgraph::rgwish(n = 1, b = nu, D = Psi, adj = adj_matrix)
  #Theta_true <- Theta_true_list[[1]] # rgwish returns a list of matrices

  # --- Step 5: Compute Covariance and Partial Correlation Matrices ---
  cat("5. Computing true covariance and partial correlation matrices...\n")
  # The covariance matrix is the inverse of the precision matrix.
  Sigma_true <- solve(Theta_true)

  # The partial correlation matrix can be computed from the precision matrix.
  Pcor_true <- -cov2cor(Theta_true)
  diag(Pcor_true) <- 1

  # --- Step 6: Generate Data from Multivariate Normal Distribution ---
  cat("6. Generating data from Multivariate Normal distribution...\n")
  # Y ~ MVN(mu = 0, Sigma = Sigma_true)
  Y_data <- MASS::mvrnorm(n = n_obs, mu = rep(0, p_nodes), Sigma = Sigma_true)
  colnames(Y_data) <- paste0("V", 1:p_nodes)


  cat("Simulation complete.\n")
  return(list(
    data = as.data.frame(Y_data),
    adj_matrix = adj_matrix,
    true_precision = Theta_true,
    true_covariance = Sigma_true,
    true_pcor = Pcor_true
  ))
}
