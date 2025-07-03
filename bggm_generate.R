# Load libraries
library(corpcor) # For converting partial correlations to a precision matrix

#' Generate GGM Data Manually
#'
#' @param p Number of nodes (variables).
#' @param n Number of observations.
#' @param graph_type The structure of the true graph, e.g., "scale-free", "cluster".
#' @param prob The probability parameter for the graph generation.
#' @param effect_range A numeric vector of length 2 specifying the min and max for non-zero partial correlations.
#'
#' @return A list containing the true graph (G), true precision matrix (K),
#'         true covariance matrix (Sigma), and the generated data.


# --- Function to generate data where the Matrix-F is the "ground truth" ---

p=10
n=100
graph_type="scale-free"
prob=0.2
delta_truth=3

as.matrix(igraph::as_adjacency_matrix(g))

bggm_generate <- function(p, n, graph_type, prob, delta_truth) {

  # --- Step 1: Define the Graph Structure (G_true) ---

  G <- generate_graph(p = p, target_density = prob, graph_type = graph_type)

  # --- Step 2: Create a Base Precision Matrix (K_base) ---
  # This matrix will have the correct sparse structure but may not be positive definite yet.

  K_base <- matrix(0, nrow = p, ncol = p)
  shape_param <- delta_truth / 2
  num_edges <- sum(G_true[upper.tri(G_true)])

  # Sample partial correlation values from a scaled Beta distribution
  beta_samples <- rbeta(num_edges, shape1 = shape_param, shape2 = shape_param)
  # NOTE: We directly populate the K matrix with these values. They are not
  # exactly partial correlations anymore, but 'potentials' that define the edges.
  # We scale them to be in a reasonable range, e.g., [-0.8, -0.3] U [0.3, 0.8]
  effect_sizes <- (beta_samples - 0.5) * 1.0 + sign(beta_samples - 0.5) * 0.3

  K_base[upper.tri(K_base) & G_true == 1] <- effect_sizes
  K_base <- K_base + t(K_base) # Make symmetric
  diag(K_base) <- 0 # Ensure diagonal is zero before the next step

  ## # --- Step 2: Generate Partial Correlations from a Scaled Beta Distribution ---
  ## # This mimics the marginal prior from a Matrix-F(v, delta, I) distribution

  ## # The shape parameters of the Beta distribution are delta/2
  ## shape_param <- delta_truth / 2

  ## # Create the partial correlation matrix P
  ## P <- matrix(0, nrow = p, ncol = p)
  ## num_edges <- sum(G[lower.tri(G)])

  ## # Sample from a Beta(shape, shape) distribution, then scale to [-1, 1]
  ## beta_samples <- rbeta(num_edges, shape1 = shape_param, shape2 = shape_param)
  ## scaled_beta_samples <- (beta_samples - 0.5) * 2 # Scale from [0,1] to [-1,1]

  ## # Populate the matrix
  ## P[lower.tri(P) & G == 1] <- scaled_beta_samples
  ## P <- P + t(P)
  ## diag(P) <- 1

  # --- Step 3: Reconstruct the Precision Matrix (K_true) ---
  # Convert the partial correlation matrix to a precision matrix
  # This function requires the matrix to be positive definite
  if (!is.positive.definite(P) ) {
    # If not positive definite, find the nearest positive definite matrix
    # This can happen by chance with random sampling
    P <- as.matrix(Matrix::nearPD(P, corr = TRUE)$mat)
  }

  R <- corpcor::cor2pcor(P) # Note: this converts correlation to partial, so we need to reverse
  K_true <- corpcor::pcor2cor(P) # This is pcor2PRECISION, but named cor

  # Let's use the more fundamental conversion for clarity
  Sigma_from_P <- solve(P) # Inverse of correlation matrix
  # For simplicity, assume unit variances for the precision matrix diagonals
  # K_true = diag(sqrt(diag(Sigma_from_P))) %*% Sigma_from_P %*% diag(sqrt(diag(Sigma_from_P)))
  # A simpler way is to use the pcor2prec function from other packages or build it.
  # For now, let's use a simpler build-up method that is guaranteed to work and reflects BGGM's assumptions.

  # We will use the direct precision matrix construction from my previous response,
  # but populate it with draws from a scaled Beta to mimic the Matrix-F property.
  K <- matrix(0, nrow = p, ncol = p)
  K[lower.tri(K) & G == 1] <- scaled_beta_samples * 0.5 # scale to reasonable values
  K <- K + t(K)
  diag(K) <- 1 # Set unit variances for simplicity

  # Ensure positive definiteness
  if(!is.positive.definite(K) ){
      lambda_min <- min(eigen(K)$values)
      diag(K) <- diag(K) + abs(lambda_min) + 0.1
  }

  # --- Step 4: Generate Data ---
  Sigma <- solve(K)
  data <- MASS::mvrnorm(n = n, mu = rep(0, p), Sigma = Sigma)

  return(list(data = data, G = G, K = K))
}


# --- Example Usage ---
# Create a world based on a Matrix-F distribution with delta = 5
# This implies an expectation of moderately sized partial correlations
matrix_f_world_data <- generate_matrix_f_world(p = 50, n = 100,
                                               graph_type = "cluster", prob = 0.2,
                                               delta_truth = 5)

# In your simulation, you would now test all algorithms on this data.
# BGGM, when its delta prior is also set to 5, will have a correctly specified prior.
# BDgraph, with its G-Wishart prior, will have a misspecified prior.
