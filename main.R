# Project start
library(BDgraph)
library(qgraph)
library(pROC)

################################################################################
# BD-A (Mohammadi et al., 2023)
################################################################################

## Calculate node strenght

get_strength <- function(graph_matrix, precision_matrix) {
  # Convert precision matrix to partial correlation matrix
  p_cors <- -cov2cor(precision_matrix)
  diag(p_cors) <- 0

  # Apply the graph structure (set non-edges to zero)
  weighted_adj_matrix <- p_cors * graph_matrix

  # Calculate strength for each node
  node_strengths <- colSums(abs(weighted_adj_matrix))

  return(node_strengths)
}

# --- 1. SIMULATION SETUP ---

p <- c(10, 25, 50, 100)

dgp_rho <- c(2 / (p[1] - 1), 0.5)     # Sparse vs. Dense
dgp_b <- c(3, p[1])              # Diffuse vs. Strict

# Define the "Prior" parameters for model fitting
model_g <- c(2 / (p[1] - 1), 0.5)
model_b <- c(3, p[1])

conditions_grid <- expand.grid(
  p = rep(p, each=3),
  n = NA,
  true_g = NA,
  prior_g = NA,
  #true_rho = dgp_rho, # sparsity prior
  #prior_g = model_g,
  true_b = dgp_b,
  prior_b = model_b,
  graph_type = c("scale-free", "random", "cluster")
  )

conditions_grid$n  <- conditions_grid$p * c(1,2,5)

# Define the true edge probabilities
row_indices3 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
expanded_grid3 <- conditions_grid[row_indices3, ]

prob_vector <- unlist(lapply(conditions_grid$p, function(p_val) {
  # The vector of two probability values to be created for each p
  c( 0.8, 0.5, 2 / (p_val - 1)) } ) )

conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid3)
conditions_grid$true_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, NA)

# Define the misspecified prior edge probabilities
row_indices2 <- rep(which(conditions_grid$graph_type == "random"), each = 3)
expanded_grid2 <- conditions_grid[row_indices2, ]

conditions_grid <- rbind(conditions_grid[conditions_grid$graph_type != 'random',], expanded_grid2)
conditions_grid$prior_g <- ifelse(conditions_grid$graph_type == "random", prob_vector, NA)

# Define the number of clusters
conditions_grid$clusters <- ifelse(conditions_grid$graph_type == "cluster",
                                   pmax(2, floor(conditions_grid$p/10)), NA)

# Fixing the row names
rownames(conditions_grid) <- seq(nrow(conditions_grid))

reps <- 5 # Number of simulation repetitions
mcmc_iter <- 5000
burnin <- 2000
num_chains <- 4 # Number of chains for convergence diagnostics

results_df <- data.frame()

# --- 2. MAIN SIMULATION LOOP ---

for (i in 1:nrow(conditions_grid)) {

  params <- conditions_grid[i, ]
  print(params)

  for (rep in 1:reps) {

    cat(paste("\nCondition", i, "| Repetition", rep, "of", reps, "\n"))

    data  <-  bdgraph.sim(
      p = params$p,
      graph = params$graph_type,
      n = params$n,
      type = "Gaussian",
      prob = 0.9,#params$true_g,
      b = params$true_b,
      class = params$clusters
    )

    G_true <- data$G
    K_true <- data$K


    # --- 2.2. Run the BDMCMC Algorithm ---
    sample_bd <- bdgraph(
      data = data$data,
      algorithm = "bdmcmc",
      iter = 5000,
      g.prior = params$g_prior,
      df.prior = params$b_prior,
      save = TRUE
    )
    summary_bd <- summary(sample_bd)

    # Extract estimated G and K
    pip_edge <- summary_bd$p_links
    G_est <- summary_bd$selected_g
    K_est <- summary_bd$K_hat

    # --- 3. PERFORMANCE METRICS ---

    # -- 3.1. Graph Structure Recovery Metrics --
    true_vec <- G_true[upper.tri(G_true)]
    est_vec <- G_est[upper.tri(G_est)]
    prob_vec <- pip_edge[upper.tri(pip_edge)]

    TP <- sum(est_vec == 1 & true_vec == 1)
    FP <- sum(est_vec == 1 & true_vec == 0)
    TN <- sum(est_vec == 0 & true_vec == 0)
    FN <- sum(est_vec == 0 & true_vec == 1)

    sensitivity <- ifelse((TP + FN) == 0, 0, TP / (TP + FN))
    specificity <- ifelse((TN + FP) == 0, 0, TN / (TN + FP))
    precision   <- ifelse((TP + FP) == 0, 0, TP / (TP + FP))
    f1_score    <- ifelse((precision + sensitivity) == 0, 0,
                          2 * (precision * sensitivity) / (precision + sensitivity))

    roc_obj <- BDgraph::roc(pred = sample_bd, actual = data, auc = TRUE)
    auc_val <- as.numeric(roc_obj$auc)

    # -- 3.2. Precision Matrix Estimation Metrics --
    diff_K <- K_est - K_true
    frobenius_norm <- norm(diff_K, type = "F")
    spectral_norm  <- norm(diff_K, type = "2")
    rmse <- sqrt(mean(diff_K^2))

    # -- 3.3. Node Strength Difference Metric --
    strength_true <- get_strength(G_true, K_true)
    strength_est  <- get_strength(G_est, K_est)
    strength_mae <- mean(abs(strength_est - strength_true))

    # --- 4. STORE RESULTS ---
    current_run_results <- data.frame(
      condition_id = i, rep = rep, p = params$p,
      n = params$n, graph_type = params$graph_type, g_prior = params$g_prior,
      sensitivity = sensitivity, specificity = specificity,
      precision = precision, f1_score = f1_score, auc = auc_val,
      frobenius_norm = frobenius_norm, spectral_norm = spectral_norm,
      rmse = rmse, strength_mae = strength_mae
    )

    results_df <- rbind(results_df, current_run_results)

    cat("\n")

  }
}



################################################################################
# RJ-WWA (van Den Boom et al., 2022)
################################################################################

# Uses MCMC with a G-Wishart prior
# Vary the degrees of freedom (delta) and scale matrix (D)
# of the precision matrix K prior: K ~ W_g(delta, D)
# For the graph prior p(G) we vary the edge inclusion probability



p <- 30 #Dimensionality
graph <- "scale-free" #Graph type
n <- 2*p #Sample size
type <- "Gaussian"
prob <- 0.01 # Probability that a pair of nodes has an edge
size  <- NULL # Number of edges. Overwrites prob
mean <- 0.3 # Effect size
class <- NULL # number of classes if it is a cluster
cut <- NULL # number of categories for categorical variables
b <- 3 # G-Wishart degrees of freedom
D <- diag(p) # Scale matrix for the G-Wishart

g <- bdgraph.sim(p=p, graph=graph, n=n, type=type, prob = prob
            ,b=b, size = 4, vis = TRUE#size = 1
            )
plot(g)
#BDgraph::bdgraph

res <- bdgraph(g$data, g.prior = 0.01)
plot(res)
response = g$G[upper.tri(g$G)]
resp


# Creating our Graph
set.seed(72951)
leng = 4
vertices = c(paste0("V_A", 1:leng), paste0("V_B", 1:leng))
card.V = length(vertices)
A = matrix(0, card.V, card.V,
           dimnames = list(vertices, vertices))
# Positive connections within each group
for(links in list(1:leng, (leng+1):(leng*2))){
  temp =  matrix(0, leng, leng)
  temp[upper.tri(temp)] = runif(2*leng, 0.5, 0.7)
  A[links, links] = temp + t(temp)
}
# Polarized Final Node
A[2*leng, 1:leng] = A[1:leng, 2*leng] = -A[2*leng, (leng+1):(2*leng)]

# Graph to igraph
g = graph_from_adjacency_matrix(A, mode = "undirected", weighted = TRUE)
round(E(g)$weight, 2)

     # Generating multivariate normal data from a 'random' graph
     data.sim <- bdgraph.sim( n = 50, p = 6, size = 7, vis = TRUE )

     # Running sampling algorithm based on GGMs
     sample.ggm <- bdgraph( data = data.sim, method = "ggm", iter = 10000 )

     # Comparing the results
     compare( list(sample.ggm), data.sim)


data  <-  bdgraph.sim(
      p = 15,
      graph = "scale-free",
      n = params$n,
      type = "Gaussian",
     prob = 0.01,
      b = params$true_b,
      #class = params$clusters
    )
plot(data)

library(igraph)
igraph::sample_smallworld(dim = 1, size = p, nei = round(size/p),     p = rewire)

ba.1 = sample_pa(n = 15, power = 1, directed = FALSE)
plot(ba.1, layout = co)
co=igraph::layout_with_fr(ba.1)

degree(ba.1)

get_strength(data$G, data$K)
get_strength()
strength(ba.1)

library(poweRlaw)

g.pl = sample_pa(n = 20, power = 1, directed = FALSE)
plot(g.pl)
