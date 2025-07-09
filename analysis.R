## Libraries

library(dplyr)

## 1.1 Load in results

bda_df <- readRDS("out/df_624.rds")
bggm_df <- rbind(
  readRDS("out/df_bggm_143.rds"),
  readRDS("out/df_bggm_216.rds"))
rj_df <- readRDS("out/df_rj_528")

## 1.2 Summarise results
get_summary <- function(df) {
  df |>
  tidyr::pivot_longer(cols = p_plus:relative_strength_mae) |>
  dplyr::group_by(dplyr::across(c(condition_id, p:name))) |>
  dplyr::summarise(value = mean(value)) |>
  tidyr::pivot_wider(names_from = name, values_from = value)
}
names(bda_df)
names(bggm_df)
s_bda <- get_summary(bda_df)

s_bggm <- get_summary(bggm_df)
s_rj <- get_summary(rj_df)
