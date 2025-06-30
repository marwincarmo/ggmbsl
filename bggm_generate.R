# Load libraries
library(corpcor) # For converting partial correlations to a precision matrix

# --- Function to generate data where the Matrix-F is the "ground truth" ---

p=10
n=100
graph_type="scale_free"
prob=0.2
delta_truth=3

generate_matrix_f_world <- function(p, n, graph_type, prob, delta_truth) {

  # --- Step 1: Define the Graph Structure (G_true) ---
  if (graph_type == "scale-free") {
    G <- as.matrix(igraph::as_adjacency_matrix(igraph::barabasi.game(p, power = 1, m = 2)))
  } else {
    G <- as.matrix(igraph::as_adjacency_matrix(igraph::erdos.renyi.game(p, p.or.m = prob, type = "gnp")))
  }

  # --- Step 2: Generate Partial Correlations from a Scaled Beta Distribution ---
  # This mimics the marginal prior from a Matrix-F(v, delta, I) distribution

  # The shape parameters of the Beta distribution are delta/2
  shape_param <- delta_truth / 2

  # Create the partial correlation matrix P
  P <- matrix(0, nrow = p, ncol = p)
  num_edges <- sum(G[lower.tri(G)])

  # Sample values from a Beta(shape, shape) distribution, then scale to [-1, 1]
  beta_samples <- rbeta(num_edges, shape1 = shape_param, shape2 = shape_param)
  scaled_beta_samples <- (beta_samples - 0.5) * 2 # Scale from [0,1] to [-1,1]

  # Populate the matrix
  P[lower.tri(P) & G == 1] <- scaled_beta_samples
  P <- P + t(P)
  diag(P) <- 1

  # --- Step 3: Reconstruct the Precision Matrix (K_true) ---
  # Convert the partial correlation matrix to a precision matrix
  # This function requires the matrix to be positive definite
  if (!is.positive.definite(P) ) {
    # If not positive definite, find the nearest positive definite matrix
    # This can happen by chance with random sampling
    P <- as.matrix(Matrix::nearPD(P, corr = TRUE)$mat)
  }

  K_true <- corpcor::cor2pcor(P) # Note: this converts correlation to partial, so we need to reverse
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
