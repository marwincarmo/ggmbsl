# --- 0. LOAD LIBRARIES ---
# Make sure you have these packages installed: install.packages(c("future", "furrr", "dplyr", "tidyr", "pROC"))

library(future)
library(furrr)
library(dplyr)
library(tidyr)
library(ssgraph)
library(pROC)
library(MASS)

# It's good practice to also load any other packages your helper functions
# (like simulate_ggm_sssl) depend on.
# library(your_package_here)

source("helpers.R")

# --- 1. SIMULATION SETUP ---
# Define levels for each factor (same as your original code)
p_levels        <- c(10, 25, 100)
n_mult_levels   <- c(1, 5, 20)
pi_levels       <- c(0.2, 0.5)
v0_levels       <- c(0.02, 0.1)
h_levels        <- c(10, 50)

# Create the full factorial design grid
conditions_grid <- tidyr::crossing(
  p = p_levels,
  n_multiplier = n_mult_levels,
  graph_type = c("random", "small-world"),
  true_pi = pi_levels,
  true_v0 = v0_levels,
  true_h = h_levels,
  prior_pi = pi_levels,
  prior_v0 = v0_levels,
  prior_h = h_levels
) |>
  dplyr::mutate(n = p * n_multiplier) |>
  dplyr::select(-n_multiplier)

nrow(conditions_grid)

reps <- 25 # Increase for full study

# --- 2. DEFINE THE SIMULATION WORKER FUNCTION ---
# This function encapsulates the logic for ONE condition (including all its repetitions).
# It takes the parameters for a single row of `conditions_grid` as its input.

run_simulation_condition <- function(params, reps) {

  # This list will store the data frames from each repetition
  repetition_results_list <- vector("list", reps)

  for (rep in 1:reps) {
    # --- 2.1. Generate Data ---
    true_data <- simulate_ggm_sssl(
      n_obs = params$n, p_nodes = params$p,
      v0 = params$true_v0, h = params$true_h,
      pi = params$true_pi
    )
    G_true <- true_data$adj_matrix
    K_true <- true_data$true_precision

    # --- 2.2. Run ssgraph ---
    # IMPORTANT: When parallelizing across conditions, each worker should only use ONE core
    # for the model fitting itself to avoid nested parallelism, which is inefficient.
    fit_sssl <- ssgraph(
      data = true_data$data,
      g.prior = params$prior_pi,
      var1 = params$prior_v0,
      var2 = params$prior_v0 * params$prior_h,
      iter = 5000,
      cores = 1 # Set to 1 for the worker
    )
    summary_sssl <- summary.ssgraph(fit_sssl, vis = FALSE)
    pip_edge <- summary_sssl$p_links
    G_est <- summary_sssl$selected_g
    K_est <- summary_sssl$K_hat

    # --- 3. PERFORMANCE METRICS ---
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
    f1_score    <- ifelse((precision + sensitivity) == 0, 0, 2 * (precision * sensitivity) / (precision + sensitivity))
    roc_obj     <- pROC::roc(response = true_vec, predictor = prob_vec, quiet = TRUE)
    auc_val     <- as.numeric(roc_obj$auc)

    diff_K <- K_est - K_true
    frobenius_norm <- norm(diff_K, type = "F")
    spectral_norm  <- norm(diff_K, type = "2")
    rmse <- sqrt(mean(diff_K^2))

    strength_true <- get_strength(G_true, K_true)
    strength_est  <- get_strength(G_est, K_est)
    strength_mae <- mean(abs(strength_est - strength_true))

    p_plus <- ifelse(sum(true_vec) == 0, 0, mean(prob_vec[true_vec == 1]))
    p_minus <- ifelse(sum(true_vec == 0) == 0, 0, mean(prob_vec[true_vec == 0]))

    k_true_frobenius_norm <- norm(K_true, type = "F")
    k_true_mean_abs <- mean(abs(K_true))
    relative_frobenius <- frobenius_norm / k_true_frobenius_norm
    relative_rmse <- rmse / k_true_mean_abs

    strength_true_mean_abs <- mean(abs(strength_true))
    relative_strength_mae <- ifelse(strength_true_mean_abs == 0, 0, strength_mae / strength_true_mean_abs)

    # --- 4. STORE RESULTS for this repetition ---
    # We combine the parameters and results into a single tibble row
    repetition_results_list[[rep]] <- dplyr::bind_cols(
        params,
        data.frame(
            rep = rep,
            p_plus = p_plus, p_minus = p_minus,
            sensitivity = sensitivity, specificity = specificity,
            precision = precision, f1_score = f1_score, auc = auc_val,
            frobenius_norm = frobenius_norm, relative_frobenius = relative_frobenius,
            spectral_norm = spectral_norm,
            rmse = rmse, relative_rmse = relative_rmse,
            strength_mae = strength_mae, relative_strength_mae = relative_strength_mae
        )
    )
  }

  # Combine all repetition results for this one condition into a single data frame
  return(dplyr::bind_rows(repetition_results_list))
}


# --- 5. EXECUTE THE SIMULATION IN PARALLEL ---

# Set the parallel execution plan. `multisession` is a robust choice that
# runs R sessions in the background. It automatically uses almost all available cores.
# You can specify a number of workers: plan(multisession, workers = 10)
plan(multisession)

# `future_map_dfr` applies the function to each row of `conditions_grid` in parallel
# and row-binds the resulting data frames into one final result (`_dfr`).
# We use `purrr::pmap` to pass the columns of `conditions_grid` as named arguments to our function.
# The `.options` argument is crucial for making your random number generation reproducible.

# Split the conditions_grid into a list of rows to iterate over
conditions_list <- purrr::transpose(conditions_grid)

# Run the simulation in parallel
# The `future_map_dfr` will show a progress bar automatically if the 'progressr' package is installed.
results_df <- future_map_dfr(
  conditions_list,
  ~ run_simulation_condition(params = .x, reps = reps),
  .options = furrr_options(seed = TRUE),
  .progress = TRUE
)


# --- 6. VIEW RESULTS ---
# The simulation is complete. Shut down the parallel workers.
plan(sequential)

cat("\n--- Simulation Complete ---\n")
print(head(results_df))
saveRDS(results_df, "out/df_sssl.rds")
cat(paste("\nTotal rows in final results:", nrow(results_df), "\n"))
