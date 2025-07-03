library(dplyr)

d <- readRDS("out/df_72.rds")
d

d %>%
  tidyr::pivot_longer(cols = p_plus:relative_strength_mae) |>
  dplyr::group_by(dplyr::across(c(condition_id, p:name))) |>
  dplyr::summarise(value = mean(value)) |>
  tidyr::pivot_wider(names_from = name, values_from = value) |>
  dplyr::filter( p == 100) |>
  print(n = Inf)
