# Load libraries
library(BGGM)
library(pROC)
library(corpcor)
library(tidyr)
library(dplyr)

# Source helper file
source("helpers.R")


################################################################################
# BGGM-H (Williams and Moulder, 2020)
################################################################################

# --- 1. SIMULATION SETUP ---
# Define levels for each factor
p_levels <- c(10, 25, 100)
n_mult_levels <- c(1, 5, 20)
graph_type_levels <- c("random", "small-world")
graph_prob_levels <- c(0.2, 0.5, 0.8) # Sparse vs. Dense target

# Define levels for the key hyperparameter: SD of partial correlations
# sd_pcor < 0.3 means a strong prior concentrating effects near zero
# sd_pcor > 0.4 means a weak prior allowing for large effects
sd_pcor_levels <- c(0.2, 0.5)

conditions_grid <- tidyr::crossing(
  p = p_levels,
  n_multiplier = n_mult_levels,
  graph_type = graph_type_levels,
  graph_prob = graph_prob_levels,
  true_sd_pcor = sd_pcor_levels,
  prior_sd_pcor = sd_pcor_levels
  ) |>
  dplyr::mutate(n = p * n_multiplier) |>
  dplyr::select(-n_multiplier)

reps <- 25
results_df <- data.frame()

# --- 2. MAIN SIMULATION LOOP ---
for (i in 144:nrow(conditions_grid)) {
  params <- conditions_grid[i, ]

  for (rep in 1:reps) {

    max_retries <- 100
    retry_count <- 0
    fit_explore <- NULL
    run_succeeded <- FALSE # Flag to track success

    cat(paste("\n--- Condition:", i, "| Rep:", rep, "---\n"))
    print(params)

    # --- 2.1. Generate Data from a "Matrix-F World" ---

    repeat {

      true_data <- bggm_generate(
        n_obs = params$n + 1,
        p_nodes = params$p,
        sd_pcor = params$true_sd_pcor,
        graph_type = params$graph_type,
        graph_prob = params$graph_prob
      )

      fit_explore <- try(
        BGGM::explore(true_data$data, prior_sd = params$prior_sd_pcor),
        silent = TRUE
      )

      if (!inherits(fit_explore, "try-error")) {
    # Success! Set the flag and break the repeat loop
        run_succeeded <- TRUE
        break
      }

      retry_count <- retry_count + 1
      if (retry_count >= max_retries) {
    # Failure after all retries. Print a warning and break the repeat loop.
        warning(paste("Condition", i, "Rep", rep, "failed after", max_retries, "attempts. Skipping."))
        break
      }
    }

    # --- Check if the run succeeded before calculating metrics ---
    # If the run failed, 'next' will skip the rest of the code in this
    # iteration of the 'for (rep in 1:reps)' loop.
    if (!run_succeeded) {
      next
    }

    G_true <- true_data$adj_matrix
    K_true <- true_data$true_precision
    P_true <- true_data$true_pcor

    # --- 2.2. Run the BGGM Algorithm ---
    #fit_explore <- BGGM::explore(true_data$data, prior_sd = params$prior_sd_pcor)
    fit_select <- BGGM::select(fit_explore)
    # BF_10 is the Bayes Factor for H1 (edge exists) vs H0 (no edge)
    bf_matrix <- fit_select$BF_10

    # Convert Bayes Factors to Posterior Inclusion Probabilities (for AUC)
    # This assumes prior P(H1) = P(H0) = 0.5
    pip_edge <- bf_matrix / (bf_matrix + 1)

    # Estimated adjecency matrix
    G_est <- fit_select$Adj_10

    # Posterior mean of the partial correlations
    P_est <- fit_select$pcor_mat
    diag(P_est) <- 1


    # --- 3. PERFORMANCE METRICS ---
    # (This section is identical to the BDA script, just with BGGM inputs)
    true_vec <- G_true[upper.tri(G_true)]
    est_vec <- G_est[upper.tri(G_est)]
    prob_vec <- pip_edge[upper.tri(pip_edge)]

    TP <- sum(est_vec == 1 & true_vec == 1); FP <- sum(est_vec == 1 & true_vec == 0)
    TN <- sum(est_vec == 0 & true_vec == 0); FN <- sum(est_vec == 0 & true_vec == 1)

    p_plus <- ifelse(sum(true_vec) == 0, 0, mean(prob_vec[true_vec == 1]))
    p_minus <- ifelse(sum(true_vec == 0) == 0, 0, mean(prob_vec[true_vec == 0]))

    sensitivity <- TP / (TP + FN)
    specificity <- TN / (TN + FP)
    precision   <- TP / (TP + FP)
    f1_score <- 2 * (precision * sensitivity) / (precision + sensitivity)

    # Handle cases where metrics are NaN
    sensitivity[is.nan(sensitivity)] <- 0; specificity[is.nan(specificity)] <- 0
    precision[is.nan(precision)] <- 0; f1_score[is.nan(f1_score)] <- 0

    roc_obj <- pROC::roc(response = true_vec, predictor = prob_vec, quiet = TRUE)
    auc_val <- as.numeric(roc_obj$auc)

    # -- 3.2. Partial Correlation Matrix Estimation Metrics (NEW) --
    diff_P <- P_est - P_true
    frobenius_norm <- norm(diff_P, type = "F")
    spectral_norm <- norm(diff_P, type = "2")
    rmse <- sqrt(mean(diff_P^2))

    ## diff_K <- K_est - K_true
    ## frobenius_norm <- norm(diff_K, type = "F"); spectral_norm <- norm(diff_K, type = "2")
    ## rmse <- sqrt(mean(diff_K^2))

    strength_true <- get_strength(G_true, P_true, "pcor")
    strength_est <- get_strength(G_est, P_est, "pcor")
    strength_mae <- mean(abs(strength_est - strength_true))
    strength_true_mean_abs <- mean(abs(strength_true))
    relative_strength_mae <- ifelse(strength_true_mean_abs == 0, 0, strength_mae / strength_true_mean_abs)


    pcor_true_frobenius_norm <- norm(P_true, type = "F")
    pcor_true_mean_abs <- mean(abs(P_true))
    relative_frobenius <- frobenius_norm / pcor_true_frobenius_norm
    relative_rmse <- rmse / pcor_true_mean_abs

    # --- 4. STORE RESULTS ---
    current_run_results <- data.frame(
      # Condition Info
      condition_id = i, rep = rep,
      p = params$p, n = params$n, graph_type = params$graph_type,
      true_sd_pcor = params$true_sd_pcor, prior_sd_pcor = params$prior_sd_pcor,
      # Metrics
      p_plus, p_minus,
      sensitivity, specificity, precision, f1_score, auc_val,
      frobenius_norm, relative_frobenius,
      spectral_norm, rmse, relative_rmse, strength_mae,
      relative_strength_mae
    )
    results_df <- rbind(results_df, current_run_results)
  }
}

saveRDS(results_df, paste0("out/df_bggm_", i, ".rds"))
# --- 5. FINAL RESULTS ---1
print("BGGM Simulation Complete!")
print(head(results_df))
