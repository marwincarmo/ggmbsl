## Libraries

library(dplyr)
library(ggplot2)

## 1.1 Load in results

bda_df <- readRDS("out/df_624.rds")

bggm_df <- readRDS("out/df_bggm_fix.rds")

# bggm_df |> 
#   dplyr::left_join(dplyr::select(conditions_grid, c(graph_prob, condition_id)), 
#                    by = "condition_id") |> 
#   dplyr::select(condition_id:graph_type, graph_prob, dplyr::everything()) |> 
#   saveRDS("out/df_bggm_fix.rds")

rj_df <- readRDS("out/df_rj_648")

sssl_df <-  readRDS("out/results_df_sssl.rds") |>
  dplyr::select(rep, dplyr::everything())

## 1.2 Summarise results
get_summary <- function(df) {
  df |>
  tidyr::pivot_longer(cols = p_plus:relative_strength_mae) |>
  dplyr::group_by(dplyr::across(c(p:name))) |>
  dplyr::summarise(value = mean(value)) |>
  tidyr::pivot_wider(names_from = name, values_from = value)
}

names(bda_df)
names(bggm_df)

s_bda <- get_summary(bda_df)
s_sssl <- get_summary(sssl_df)
s_bggm <- get_summary(bggm_df)
s_rj <- get_summary(rj_df)


## Plots
### Graph priors

s_rj |>
  dplyr::filter(b_prior == b_true) |>
  dplyr::mutate(g_condition =
                  dplyr::case_when(
                         g_prior == 0.2 & g_true == 0.2 ~ "p_prior = 0.2, p_true = 0.2",
                         g_prior == 0.5 & g_true == 0.2 ~ "p_prior = 0.5, p_true = 0.2",
                         g_prior == 0.8 & g_true == 0.2 ~ "p_prior = 0.8, p_true = 0.2",
                         g_prior == 0.2 & g_true == 0.5 ~ "p_prior = 0.2, p_true = 0.5",
                         g_prior == 0.5 & g_true == 0.5 ~ "p_prior = 0.5, p_true = 0.5",
                         g_prior == 0.8 & g_true == 0.5 ~ "p_prior = 0.8, p_true = 0.8",
                         g_prior == 0.2 & g_true == 0.8 ~ "p_prior = 0.2, p_true = 0.8",
                         g_prior == 0.5 & g_true == 0.8 ~ "p_prior = 0.5, p_true = 0.8",
                         g_prior == 0.8 & g_true == 0.8 ~ "p_prior = 0.8, p_true = 0.8"),
                p = factor(p), n = factor(n)
                ) |>
  ggplot(aes(x = n, y = specificity, color = p)) +
  geom_boxplot() +
  facet_grid(g_prior ~ g_true)
