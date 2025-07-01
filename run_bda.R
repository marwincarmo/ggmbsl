# Project start
library(BDgraph)
library(igraph)
library(pROC)

# Source helper file
source("generate_graph.R")


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

p <- c(10, 25, 100)

# Edge density
g <- c(0.2, 0.5, 0.8)

# GWishart prior degrees of freedom
b <- c(3, p[1])              # Diffuse vs. Strict

conditions_grid <- expand.grid(
  p = rep(p, each=3),
  n = NA,
  true_g = NA,
  prior_g = NA,
  true_b = b,
  prior_b =b,
  graph_type = c("random", "small-world")
  )

conditions_grid$n  <- conditions_grid$p * c(1, 5, 20)

idx <- rep(seq(nrow(conditions_grid)), each = 9)

expanded_grid <- conditions_grid[idx, ]

expanded_grid$true_g <- rep(g, each = 3, times = 72)
expanded_grid$prior_g <- rep(g,  length.out = nrow(expanded_grid))

rownames(expanded_grid) <- seq(nrow(expanded_grid))

reps <- 25 # Number of simulation repetitions
mcmc_iter <- 5000
burnin <- 2000
results_df <- data.frame()

# --- 2. MAIN SIMULATION LOOP ---
for (i in 1:nrow(expanded_grid)) {

  params <- expanded_grid[i, ]
  print(params)

  for (rep in 1:reps) {

    cat(paste("\nCondition", i, "| Repetition", rep, "of", reps, "\n"))

    if (params$graph_type == "random") {

      data  <-  bdgraph.sim(
        p = params$p,
        graph = params$graph_type,
        n = params$n,
        type = "Gaussian",
        prob = params$true_g,
        b = params$true_b
    )

      G_true <- data$G
      K_true <- data$K


    } else {

      G_true <- generate_graph(p = params$p,
                               target_density = params$true_g,
                               graph_type = params$graph_type,
                               max_iter = 100)

      K_true <- rgwish(n = 1, adj = G_true, b = params$true_b, D = diag(params$p))
      sigma <-  solve(K_true)

      data <- BDgraph::rmvnorm(n = params$n, mean = 0, sigma = sigma)

    }

    ## # --- 2.2. Calculate the Empirical "True G" for This Graph ---
    ## p_val <- params$p
    ## num_edges <- sum(G_true[upper.tri(G_true)])
    ## possible_edges <- p_val * (p_val - 1) / 2
    ## empirical_g_true <- num_edges / possible_edges
    ## empirical_g_true
    ## plot(data)

    # --- 2.2. Run the BDMCMC Algorithm ---

    sample_bd <- bdgraph(
      data = data,
      algorithm = "bdmcmc",
      g.prior = params$prior_g,
      df.prior = params$prior_b,
      cores = 12,
      iter = mcmc_iter,
      save = TRUE
    )

    summary_bd <- summary(sample_bd, vis = FALSE)

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
    # AUC
    roc_obj <- pROC::roc(response = true_vec, predictor = prob_vec, quiet = TRUE)
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

    p_plus <- ifelse(sum(true_vec) == 0, 0, mean(prob_vec[true_vec == 1]))
    p_minus <- ifelse(sum(true_vec == 0) == 0, 0, mean(prob_vec[true_vec == 0]))

    # --- 3.5. Calculate Interpretable, Normalized Metrics ---

                                        # -- For the Precision Matrix --
                                        # Calculate the overall magnitude of the true matrix
    k_true_frobenius_norm <- norm(K_true, type = "F")
    k_true_mean_abs <- mean(abs(K_true))

                                        # Normalize the errors
    relative_frobenius <- frobenius_norm / k_true_frobenius_norm
    relative_rmse <- rmse / k_true_mean_abs

                                        # -- For Node Strength --
                                        # Calculate the overall magnitude of the true strengths
    strength_true_mean_abs <- mean(abs(strength_true))

                                        # Normalize the error
    relative_strength_mae <- ifelse(strength_true_mean_abs == 0, 0, strength_mae / strength_true_mean_abs)

    # --- 4. STORE RESULTS ---
    current_run_results <- data.frame(
      condition_id = i, rep = rep, p = params$p,
      n = params$n, graph_type = params$graph_type,
      g_prior = params$prior_g, g_true = params$true_g,
      b_prior = params$prior_b, b_true = params$true_b,
      p_plus = p_plus, p_minus = p_minus,
      sensitivity = sensitivity, specificity = specificity,
      precision = precision, f1_score = f1_score, auc = auc_val,
      frobenius_norm = frobenius_norm, relative_frobenius,
      spectral_norm = spectral_norm,
      rmse = rmse, relative_rmse, strength_mae = strength_mae,
      relative_strength_mae
    )

    results_df <- rbind(results_df, current_run_results)
    cat("\n")

    if (i %% 24 == 0) saveRDS(results_df, paste0("out/df_", i))
  }
}

print("Simulation Complete!")
