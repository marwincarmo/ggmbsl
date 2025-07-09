# --- 0. LOAD LIBRARIES ---
# Make sure you have these packages installed: install.packages(c("future", "furrr", "dplyr", "tidyr", "pROC"))

library(future)
library(furrr)
library(dplyr)
library(tidyr)
library(ssgraph)
library(pROC)
library(MASS)
library(progressr)
# It's good practice to also load any other packages your helper functions
# (like simulate_ggm_sssl) depend on.
# library(your_package_here)

source("helpers.R")

# --- 1. SIMULATION SETUP ---
# Define levels for each factor (same as your original code)
p_levels        <- c(10, 25, 100)
n_mult_levels   <- c(1, 5, 20)
pi_levels       <- c(0.2, 0.5, 0.8)
v0_levels       <- c(0.02, 0.1)
h_levels        <- c(10, 50)

# Create the full factorial design grid
conditions_grid <- tidyr::crossing(
  p = p_levels,
  n_multiplier = n_mult_levels,
  graph_type = c("random", "small-world"),
  true_pi = pi_levels,
  true_v0 = 0.02,
  true_h = 0.5,
  prior_pi = pi_levels,
  prior_v0 = v0_levels,
  prior_h = h_levels
) |>
  dplyr::mutate(n = p * n_multiplier) |>
  dplyr::select(-n_multiplier)

reps <- 25 # Increase for full study

nrow(conditions_grid)

# --- 2. DEFINE THE SIMULATION WORKER FUNCTION ---
# This function encapsulates the logic for ONE condition (including all its repetitions).
# It takes the parameters for a single row of `conditions_grid` as its input.

run_and_save_condition <- function(i) {

  # Define the output file path for this specific condition
  output_file <- file.path("out/sssl/", paste0("df_sssl_", i, ".rds"))

  # --- Check if result already exists ---
  # If the file is already there, we skip this condition entirely.
  if (file.exists(output_file)) {
    # The progress bar still needs to be ticked, so we signal a progression
    # without doing any work.
    p <- progressor(steps = 1)
    p()
    return(NULL)
  }

  # Get the parameters for the current condition
  params <- conditions_grid[i, ]

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
    fit_sssl <- ssgraph(
      data = true_data$data,
      g.prior = params$prior_pi,
      var1 = params$prior_v0,
      var2 = params$prior_v0 * params$prior_h,
      iter = 5000,
      cores = 1
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

    auc_val <- tryCatch({
      roc_obj <- pROC::roc(response = true_vec, predictor = prob_vec, quiet = TRUE)
      as.numeric(roc_obj$auc)
    }, error = function(e) {
      return(NA)
    })

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
    repetition_results_list[[rep]] <- data.frame(
        rep = rep, p_plus = p_plus, p_minus = p_minus, sensitivity = sensitivity,
        specificity = specificity, precision = precision, f1_score = f1_score,
        auc = auc_val, frobenius_norm = frobenius_norm, relative_frobenius = relative_frobenius,
        spectral_norm = spectral_norm, rmse = rmse, relative_rmse = relative_rmse,
        strength_mae = strength_mae, relative_strength_mae = relative_strength_mae
    )
  }

  # Combine all repetition results for this one condition
  results_for_condition <- dplyr::bind_rows(repetition_results_list)

  # Combine the parameters with the results
  final_df_for_condition <- dplyr::bind_cols(params, results_for_condition)

  # --- Save the result to a file ---
  # This is the key step for saving progress.

  saveRDS(final_df_for_condition, file = output_file)

  return(NULL)
}


# --- 5. EXECUTE THE SIMULATION IN PARALLEL ---

# Set the parallel execution plan. `multisession` is a robust choice that
# runs R sessions in the background. It automatically uses almost all available cores.
# You can specify a number of workers: plan(multisession, workers = 10)
plan(multisession)

with_progress({
  # We use future_walk because we are calling the function for its side effect (saving a file),
  # not for its return value.
  future_walk(
    1:nrow(conditions_grid),
    ~ run_and_save_condition(.x),
    .options = furrr_options(seed = TRUE)
  )
})


# --- 6. COMBINE ALL SAVED RESULTS ---
cat("\n--- Simulation Complete ---\n")
cat("Combining all saved result files...\n")

# List all the .rds files in the results directory
result_files <- list.files("results", pattern = "\\.rds$", full.names = TRUE)

# Read each file and row-bind them into a single data frame
results_df <- purrr::map_dfr(result_files, readRDS)


# --- 7. VIEW FINAL RESULTS ---
# The simulation is complete. Shut down the parallel workers.
plan(sequential)

print(head(results_df))
cat(paste("\nTotal rows in final results:", nrow(results_df), "\n"))
cat(paste("Total conditions completed:", length(result_files), "out of", nrow(conditions_grid), "\n"))


df = readRDS("out/sssl/df_sssl_622.rds")
