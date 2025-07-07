# ===================================================================
#
# R Code to Simulate Data from a Gaussian Graphical Model (GGM)
# using the Stochastic Search Structure Learning (SSSL) Prior
#
# Based on the generative model in:
# Wang, H. (2015). Scaling it up: Stochastic search structure learning
# in graphical models. Bayesian analysis, 10(2), 351-377.
#
# ===================================================================

library(ssgraph)
library(pROC)
library(dplyr)
library(tidyr)
library(MASS)

source("helpers.R")

# --- 1. SIMULATION SETUP ---
# Define levels for each factor
p_levels       <- c(10, 25, 100)
n_mult_levels  <- c(1, 5, 20)

# Define levels for SSSL hyperparameters
pi_levels <- c(0.2, 0.5)  # Sparse vs. Dense
v0_levels <- c(0.0004, 0.02, 0.1) # Sharp vs. Diffuse spike
h_levels  <- c(10, 50, 100)   # Small vs. Large slab separation

# Create the full factorial design
conditions_grid <- tidyr::crossing(
  p = p_levels,
  n_multiplier = n_mult_levels,
  graph_type = c("random", "small-world"),
  true_pi = pi_levels,
  true_v0 = 0.2,
  true_h = 50,
  prior_pi = pi_levels,
  prior_v0 = v0_levels,
  prior_h = h_levels) |>
  dplyr::mutate(n = p * n_multiplier) |>
  dplyr::select(-n_multiplier)

reps <- 5 # Increase for full study
results_df <- data.frame()


# --- 2. Define the Main Simulation Function ---

for (i in 1:nrow(expanded_grid)) {

  params <- conditions_grid[i, ]
  print(params)

  for (rep in 1:reps) {

    cat(paste("\nCondition", i, "| Repetition", rep, "of", reps, "\n"))

    # --- 2.1. Generate Data
    true_data <- simulate_ggm_sssl(
      n_obs = params$n, p_nodes = params$p,
      v0 = params$true_v0, h = params$true_h,
      pi = params$true_pi
    )

    G_true <- true_data$adj_matrix
    K_true <- true_data$true_precision

    # --- 2.2. Run ssgraph

    fit_sssl <- ssgraph(
        data = true_data$data,
        g.prior = params$prior_pi,
        var1 = params$prior_v0,
        var2 = params$prior_v0 * params$prior_h, # Calculate v1 from v0 and h
        iter = 5000,
        cores = 1
    )

    summary_sssl <- summary(fit_sssl, vis = FALSE)

    # Extract estimated G and K
    pip_edge <- summary_sssl$p_links
    G_est <- summary_sssl$selected_g
    K_est <- summary_sssl$K_hat

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
      true_pi = params$true_pi, prior_pi = params$prior_pi,
      true_v0 = params$true_v0, prior_v0 = params$prior_v0,
      true_h = params$true_h, prior_h = params$prior_h,
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

    if (i %% 24 == 0) saveRDS(results_df, paste0("out/df_bda_", i))
  }
}
