## Libraries

library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(latex2exp)
library(purrr)

my_theme <- function(){
  theme_bw() + 
    theme(
      legend.position = "bottom"
      , legend.title = element_text(face = "bold", size = rel(1.2))
      , legend.text = element_text(face = "italic", size = rel(1.2))
      , axis.text = element_text(face = "bold", size = rel(1.3), color = "black")
      , axis.title = element_text(face = "bold", size = rel(1.3))
      , plot.title = element_text(face = "bold", size = rel(1.6), hjust = .5)
      , plot.subtitle = element_text(face = "italic", size = rel(1.2), hjust = .5)
      , strip.text = element_text(face = "bold", size = rel(1.3), color = "black")
      , strip.background = element_rect(fill = "white")
    )
}

cbsafe_pal <- tribble(
  ~name, ~rgb
  , "black", c(0, 0, 0)
  , "sky blue", c(86, 180, 233)
  , "bluish green", c(0, 158, 115)
  , "yellow", c(240, 228, 66)
  , "orange", c(230, 159, 0)
  , "blue", c(0, 114, 178)
  , "vermillion", c(213, 94, 0)
  , "reddish purple", c(204, 121, 167)
) %>%
  mutate(hex = map_chr(rgb, function(x) rgb(x[1], x[2], x[3], maxColorValue = 255)))


## 1.1 Load in results

bda_df <- readRDS("out/df_624.rds")

bggm_df <- readRDS("out/df_bggm_fix.rds")

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

## 1. G-Wishart approach: BDMCMC vs RJWWA

## 1.1. Prior on G
## 
## Show comparative F1 score for G priors
## For K priors, show comparative relative_rmse, including both correctly 
## and misspecified g.priors

g_df <- dplyr::bind_rows(list(BDA = bda_df, RJ = rj_df), .id = "model")

## F1-score/AUC/sensitivity/specificity
g_df |>
  dplyr::filter(b_prior == b_true,
                #b_true == 3,
                #relative_rmse < 6,
                p == 25,) |>
  dplyr::mutate(g_prior = factor(g_prior), g_true = factor(g_true),
                n = factor(n),
                g_true_labeled = factor(g_true, labels = 
                                          c("True Graph: Sparse (0.2)", 
                                            "True Graph: Medium (0.5)", 
                                            "True Graph: Dense (0.8)")),
                n_labeled = factor(n, labels = c("n = 25 (n = p)", 
                                                 "n = 125 (n > p)", 
                                                 "n = 500 (n >> p)"))) |>
  ggplot(aes(x = g_prior, y = f1_score, color = model, fill = model)) +
  #geom_jitter( alpha = .2) +
  geom_boxplot(alpha = .5) + 
  scale_color_manual(
    values = c("cornflowerblue", "coral")
    , labels = c("BDMCMC", "RJ-WWA")
  ) + 
  scale_fill_manual(
    values = c("cornflowerblue", "coral")
    , labels = c("BDMCMC", "RJ-WWA")
  ) + 
  facet_grid(n_labeled ~ g_true_labeled) +
  my_theme() +
  labs(y = "F1-score", x = "Edge prior", fill = "Method", color = "Method",
       title = "BDMCMC and RJ-WWA are relatively robust to density misspecification",
       subtitle = "Comparison of F1-Score in ideal prior conditions (p=25)")

ggsave("img/pf1G.pdf", width = 11, height = 7)


## Relative RMSE
g_df |>
  dplyr::filter(g_prior == g_true,
                p == 25) |>
  dplyr::mutate(g_prior = factor(g_prior), g_true = factor(g_true),
                n = factor(n),
                b_spec = case_when(
                  b_prior == 3 & b_true == 10 ~ 0, #TeX("$\\delta_1$"),
                  b_prior == 10 & b_true == 3 ~ 2, #"b_prior > b_true",
                  b_prior == b_true ~ 1#"b_prior = b_true"
                ),
                b_spec = factor(b_spec,
                                labels = c(`0` = TeX("$\\delta_{true} > \\delta_{prior}$")
                                         , `1` = TeX("$\\delta_{true} = \\delta_{prior}$"),
                                           `2` = TeX("$\\delta_{true} < \\delta_{prior}$"))),
                # n_labeled = factor(n, labels = c(TeX("$n = 25~(n = p)$"),
                #                                  TeX("$n = 125~(n > p)$"),
                #                                  TeX("$n = 500~(n \\gg p)$"))
                n_labeled = factor(n, labels = c(
                  "n = 25 (n = p)",
                  "n = 125  (n > p)",
                  "n = 500  (n >> p)"  # <-- CORRECTED LINE
                ))
                ) |>
  ggplot(aes(x = g_true, y = relative_rmse, color = model, fill = model)) +
  geom_boxplot(alpha = .5) + 
  scale_color_manual(
    values = c("cornflowerblue", "coral")
    , labels = c("BDMCMC", "RJ-WWA")
  ) + 
  scale_fill_manual(
    values = c("cornflowerblue", "coral")
    , labels = c("BDMCMC", "RJ-WWA")
  ) + 
  facet_grid(n_labeled ~ b_spec, scales = "free_y", labeller = labeller(n_labeled = label_value, 
                                                             b_spec = label_parsed)) +
  labs(x = "Edge prior", y = "Relative RMSE",
       title = "BDMCMC Advantage Extends to Precision Matrix Estimation",
       subtitle = "Relative RMSE for a Medium-Density Graph (p=25)",
       fill = "Method", color = "Method") +
  my_theme()

ggsave("img/p_gwish_K.pdf", width = 11, height = 7)

## 2 Matrix-F: BGGM
## 
## Performance is similar across all graph probabilities
## It decreases when the prior is set to 0.5, even when data was generated
## from this value.

bggm_df |>
  dplyr::filter(#p != 25
    n > p
  ) |> 
  dplyr::mutate(graph_prob = factor(graph_prob),
                n = factor(n, levels = 10:2000),
                p = factor(p),
                sd_spec = case_when(
                  true_sd_pcor == .2 & prior_sd_pcor == .2 ~ 
                    1,
                  true_sd_pcor == .5 & prior_sd_pcor == .2 ~ 
                    2,
                  true_sd_pcor == .5 & prior_sd_pcor == .5 ~ 
                    3,
                  true_sd_pcor == .2 & prior_sd_pcor == .5 ~ 
                    4
                ),
                g_true_labeled = factor(graph_prob, labels = 
                                          c("True Graph: Sparse (0.2)", 
                                            "True Graph: Medium (0.5)", 
                                            "True Graph: Dense (0.8)")),
                sd_spec = factor(sd_spec, levels = 1:4,
                                 labels = c(TeX("$s_{pr} = s_{tr}$ = 0.2"),
                                            TeX("$s_{pr} = 0.2,~s_{tr}$ = 0.5"),
                                            TeX("$s_{pr} = s_{tr}$ = 0.5"),
                                            TeX("$s_{pr} = 0.5,~s_{tr}$ = 0.2"))
                )) |>
  ggplot(aes(x = n, y = f1_score, color = p, fill = p)) +
  geom_boxplot(alpha = 0.5) +
  scale_color_manual(values = cbsafe_pal$hex[5:8])+
  scale_fill_manual(values = cbsafe_pal$hex[5:8])+
  scale_y_continuous(breaks = c(0, .25, .5, .75, 1)) +
  facet_grid(sd_spec ~ g_true_labeled, labeller = labeller(g_true_labeled = label_value, 
                                                           sd_spec = label_parsed)) +
  labs(x = "Sample size", y = "F1-score",
       title = "BGGM Performance is Robust to Graph Density",
       subtitle = "F1-score remains stable as true sparsity changes (p=25)",
       color = "Number of nodes", fill = "Number of nodes") +
  my_theme()

ggsave("img/p_bggm_f1.pdf", width = 11, height = 9)


## BGGM relative RMSE

bggm_df |>
  # Focus on a single problem size and medium graph density
  dplyr::filter(p == 25) |>
  dplyr::mutate(
    n = factor(n),
    prior_labeled = factor(prior_sd_pcor, labels = c("Strong Shrinkage\n(Prior SD = 0.20)", "Weak Shrinkage\n(Prior SD = 0.50)")),
    true_labeled = factor(true_sd_pcor, labels = c("True Effects: Weak", "True Effects: Strong"))
  ) |>
  ggplot(aes(x = prior_labeled, y = relative_rmse, fill = n, color =n)) + # Changed aes: use fill = n
  geom_boxplot(position = position_dodge(preserve = "single"), alpha = 0.5)  + # Added position_dodge()
  scale_color_manual(values = cbsafe_pal$hex[6:8])+
  scale_fill_manual(values = cbsafe_pal$hex[6:8])+
  facet_grid(graph_prob~true_labeled) +
  labs(
    title = "A More Conservative Prior Can Improve Performance",
    subtitle = "Comparing weak vs. strong shrinkage priors (p=25)",
    x = NULL,
    y = "Relative RMSE", # Corrected this to match the data
    fill = "Sample Size",
    color = "Sample Size"
  ) +
  my_theme()

ggsave("img/p_bggm_rmse.pdf", width = 11, height = 7)

## 3 SSSL

sssl_df |> 
  dplyr::filter(p == 25,
                true_v0 == 0.02,
                true_h == prior_h) |> 
  dplyr::mutate(true_pi = factor(true_pi),
                prior_pi = factor(prior_pi),
                true_v0 = factor(true_v0),
                prior_v0 = factor(prior_v0),
                n = factor(n)) |> 
  ggplot(aes(x = n, y = f1_score, color = prior_v0)) +
  geom_boxplot() +
  facet_grid(prior_pi ~ true_pi)

################################### G-WISHART #############################################################

# Assumes you have a combined dataframe 'g_df' with a 'model' column
# This plot shows the "best case" scenario for priors
g_df |>
  dplyr::mutate(
    n = factor(n, levels = c("10", "25", "50", "100", "125", "200", "500", "2000")),
    p = factor(p, labels = c("p = 10", "p = 25", "p = 100"))
  ) |>
  # Filter for correctly specified priors for a clear baseline comparison
  dplyr::filter(b_prior == b_true,
                g_prior == g_true) |>
  # Summarise to get mean and se for clean lines
  dplyr::summarise(
    mean_f1 = mean(f1_score),
    se_f1 = sd(f1_score) / sqrt(dplyr::n()),
    .by = c(n, p, model)
  ) |>
  ggplot(aes(x = n, y = mean_f1, group = model, color = model)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = mean_f1 - se_f1, ymax = mean_f1 + se_f1),
    width = 0.2
  ) +
  facet_wrap(~p) +
  labs(
    title = "Performance Improves Dramatically with Sample Size",
    subtitle = "Comparison of F1-Score in ideal prior conditions",
    x = "Sample Size (n)",
    y = "Mean F1-Score",
    color = "Algorithm"
  ) +
  theme_bw()

g_df |>
    dplyr::filter(p == 25,
                #b_prior == 3,
                b_true == b_prior#= 3
                ) |>
  dplyr::mutate(
    g_prior_factor = factor(g_prior),
    g_true_labeled = factor(g_true, labels = c("True Graph: Sparse (0.2)", "True Graph: Medium (0.5)", "True Graph: Dense (0.8)")),
    n_labeled = factor(n, labels = c("n = 25 (p > n)", "n = 125 (n > p)", "n = 500 (n >> p)"))
    ) |>
  # Focus on a single problem size and the non-informative G-Wishart prior
  dplyr::summarise(
    mean_f1 = mean(f1_score),
    .by = c(g_prior_factor, g_true_labeled, n_labeled, model)
  ) |>
  ggplot(aes(x = g_prior_factor, y = mean_f1, group = model, color = model)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_grid(n_labeled ~ g_true_labeled) +
  labs(
    title = "Robustness to Misspecified Graph Density Prior",
    subtitle = "Plot shows F1-Score for p = 25",
    x = "Assumed Prior Density (g_prior)",
    y = "Mean F1-Score",
    color = "Algorithm"
  ) +
  theme_bw() 
  # Add a vertical line to show where the prior is correct
  #+ geom_vline(
  #  data = . %>% dplyr::filter(as.numeric(as.character(g_prior_factor)) == g_true),
  #  aes(xintercept = g_prior_factor), linetype = "dashed", color = "gray40"
  #  )

# Assumes you have a combined dataframe 'g_df' with a 'model' column
g_df |>
    # Focus on a single problem size and a moderately dense graph
  dplyr::filter(p == 25,
                g_prior == 0.5,
                g_true == 0.5) |>
  dplyr::mutate(
    b_prior_labeled = factor(b_prior, labels = c("Weak (3)", "Strong (10)")),
    b_true_labeled = factor(b_true, labels = c("True Effects: Strong (b=3)", "True Effects: Weak (b=10)")),
    n_labeled = factor(n, labels = c("n = 25", "n = 125", "n = 500"))
  ) |>
  dplyr::summarise(
    mean_f1 = mean(relative_rmse),
    .by = c(b_prior_labeled, b_true_labeled, n_labeled, model)
  ) |>
  ggplot(aes(x = b_prior_labeled, y = mean_f1, group = model, color = model)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_grid(n_labeled ~ b_true_labeled, scales = "free_y") +
  labs(
    title = "Effect of Shrinkage Prior on Precision Matrix is Data-Dependent",
    subtitle = "F1-Score for a Medium-Density Graph (p=25)",
    x = "Chosen Prior for G-Wishart (b_prior)",
    y = "Mean F1-Score",
    color = "Algorithm"
  ) +
  theme_bw()

################################### BGGM #############################################################

# Plot 1: BGGM's Immunity to Graph Density
# Assumes 'bggm_df' is your data frame for the BGGM results
bggm_df |>
    # Focus on a single problem size and the conservative prior
  dplyr::filter(p == 25,
                prior_sd_pcor == 0.20) |>
  dplyr::mutate(
    n_labeled = factor(n, labels = c("n = 125", "n = 500"))
  ) |>
  dplyr::summarise(
    mean_f1 = mean(f1_score),
    .by = c(graph_prob, n_labeled, true_sd_pcor)
    ) |>
  ggplot(aes(x = graph_prob, y = mean_f1, group = n_labeled, color = n_labeled)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_wrap(~ true_sd_pcor, labeller = labeller(true_sd_pcor = c(`0.2` = "Weak True Effects", `0.5` = "Strong True Effects"))) +
  labs(
    title = "BGGM Performance is Robust to Graph Density",
    subtitle = "F1-score remains stable as true sparsity changes (p=25)",
    x = "True Graph Density (Edge Probability)",
    y = "Mean F1-Score",
    color = "Sample Size"
  ) +
  theme_bw() +
  coord_cartesian(ylim = c(0, 1)) # Keep y-axis consistent

# Plot 2: The Benefit of a Conservative Prior
bggm_df |>
    # Focus on a single problem size and medium graph density
  dplyr::filter(p == 25,
                graph_prob == 0.5) |>
  dplyr::mutate(
    prior_labeled = factor(prior_sd_pcor, labels = c("Strong Shrinkage\n(Prior SD = 0.20)", "Weak Shrinkage\n(Prior SD = 0.50)")),
    true_labeled = factor(true_sd_pcor, labels = c("True Effects: Weak", "True Effects: Strong"))
  ) |>
  dplyr::summarise(
    mean_f1 = mean(relative_rmse),
    .by = c(prior_labeled, true_labeled, n)
  ) |>
  ggplot(aes(x = prior_labeled, y = mean_f1, group = n, color = as.factor(n))) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_wrap(~true_labeled) +
  labs(
    title = "A More Conservative Prior Can Improve Performance",
    subtitle = "Comparing weak vs. strong shrinkage priors (p=25)",
    x = "Chosen Prior on Partial Correlation Scale",
    y = "Mean F1-Score",
    color = "Sample Size (n)"
  ) +
  theme_bw() +
  coord_cartesian(ylim = c(0, 1))

################################### SSSL #############################################################

# Plot 1: The "Achilles' Heel" - Vulnerability to the Spike Prior

# The most dramatic finding for SSSL is its catastrophic failure when the spike variance prior (prior_v0) is misspecified. A plot that shows this is essential because it serves as a strong warning and a key point of comparison against the other, more robust algorithms.

# Assumes 'sssl_df' is your data frame for the SSSL results
sssl_df |>
    # Filter for a single problem size and correctly specified sparsity/slab priors
  dplyr::filter(p == 25,
                prior_pi == true_pi,
                prior_h == 50) |>
  dplyr::mutate(
    
    n_labeled = factor(n, labels = c("n = 25 (p = n)", "n = 125 (n > p)", "n = 500 (n >> p)")),
    prior_v0_labeled = factor(prior_v0, labels = c("Spike: \n Correct (0.02)", "Spike: \n Misspecified (0.10)")),
    true_pi_labeled = factor(true_pi, labels = c("True Graph: Sparse (0.2)", "True Graph: Medium (0.5)", "True Graph: Dense (0.8)"))
  ) |>
  ggplot(aes(x = prior_v0_labeled, y = f1_score, group = prior_v0_labeled, 
             color = prior_v0_labeled, fill = prior_v0_labeled)) +
  geom_boxplot(alpha = .5) +
  scale_color_manual(
    values = c("cornflowerblue", "coral")
  ) + 
  scale_fill_manual(
    values = c("cornflowerblue", "coral")
  ) +
  facet_grid(n_labeled~true_pi_labeled) +
  labs(
    title = "SSSL is Sensitive to Spike Prior Specification",
    subtitle = "A misspecified spike variance (v0) leads to significant bias (p=25)",
    x = NULL,
    y = "Mean F1-Score",
  ) +
  my_theme() +
  theme(legend.position = "none") +
  coord_cartesian(ylim = c(0, 1))

ggsave("img/p_sssl_f1.pdf", width = 11.5, height = 7)

# Plot 2: The "Sparsity Hunter" - Deconstructing Performance by Density

# The second major finding is that SSSL is specialized for sparse graphs and performs poorly on dense ones, even when its priors are correct. Plotting F1-score alone can be misleading here, so it's more insightful to show sensitivity and specificity separately.

sssl_df |>
    # Filter for the "best case" priors to see the algorithm's core behavior
  dplyr::filter(p == 25,
                prior_pi == true_pi,
                prior_v0 == 0.02,
                prior_h == 50) |>
  # Pivot to plot both sensitivity and specificity on the same plot
  tidyr::pivot_longer(
    cols = c(sensitivity, specificity),
    names_to = "metric",
    values_to = "value"
  ) |>
  dplyr::summarise(
    mean_value = mean(value),
    .by = c(true_pi, n, metric)
  ) |>
  ggplot(aes(x = true_pi, y = mean_value, group = n, color = as.factor(n))) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_wrap(~metric) +
  labs(
    title = "SSSL Is a 'Sparsity Hunter': It Excels at Sparse, Fails at Dense",
    subtitle = "Performance tradeoff shown with ideal priors (p=25)",
    x = "True Graph Density",
    y = "Metric Value",
    color = "Sample Size (n)"
  ) +
  theme_bw() +
  coord_cartesian(ylim = c(0, 1.0))

## The Specificity Collapse: In the specificity panel, the lines will start near 1.0 for sparse graphs and then crash towards 0 for dense graphs. SSSL loses its ability to avoid false positives in dense networks.

## The Sensitivity Illusion: In the sensitivity panel, the lines will rocket towards 1.0 for dense graphs.

## The Full Story: By showing both plots, you can explain that the high F1-score for dense graphs is an artifact. The model is simply guessing "edge" for almost every connection, which gives it high sensitivity by default but makes it practically useless for discovering the true structure. This clearly defines its niche: it is a tool for sparse graphs only.
##

sssl_df |> 
  dplyr::filter(p == 25,
                n == 125,
                prior_h == 50) |>
  dplyr::mutate(#true_pi = factor(true_pi),
                prior_pi_labeled = factor(prior_pi, labels = c("Prior: Sparse (0.2)", "Prior: Average (0.5)", "Prior: Dense (0.8)")),
                prior_v0_labeled = 
                  factor(prior_v0,
                         labels = c("Spike: \n Correct (0.02)", 
                                    "Spike: \n Misspecified (0.10)")),
                prior_v0_labeled = factor(prior_v0, labels = c("Spike: \n Correct (0.02)", "Spike: \n Misspecified (0.10)")),
                true_pi_labeled = factor(true_pi, labels = c("True Graph: Sparse (0.2)", "True Graph: Medium (0.5)", "True Graph: Dense (0.8)"))
                ) |> 
  ggplot(aes(x = prior_v0_labeled, y = f1_score, color =prior_v0_labeled)) +
  geom_boxplot(position = position_dodge(preserve = "single"), alpha = 0.5)  +
  facet_grid(prior_pi_labeled~true_pi_labeled)
