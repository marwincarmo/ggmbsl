# Project start
library(BDgraph)
library(qgraph)
library(igraph)

################################################################################
# BD-A (Mohammadi et al., 2023)
################################################################################

get_deg <- function(x, empirical = TRUE) {

  if (empirical == TRUE) {
    K = x$K
    G = x$G
  } else {
    K = x$K_hat
    G = x$last_graph
  }
  p = ncol(K)

  partial_cor = -K / (outer(diag(K), diag(K)))
  diag(partial_cor) = 0

  w = partial_cor * G

  strenght_list = colSums(abs(w))

  return(strenght_list)
}

p <- 20

conditions_grid <- expand.grid(
  p = p,
  n = 2*p,
  sparsity = 0.5,
  g_prior = 0.5, # sparsity prior
  eff_size = 0.3,
  dist = "scale-free",
  b_true = 3,
  b_prior = 3 # GWishart degrees of freedom prior
  )

for (i in 1:nrow(conditions_grid)) {

  params <- conditions_grid[i, ]
  print(params)

  for (rep in 1:reps) {
    cat(".")
    data  <-  bdgraph.sim(
      p = params$p,
      graph = params$dist,
      n = params$n,
      type = "Gaussian",
      prob = params$sparsity,
      mean = 0,
      b = params$b_true
    )

    G_true <- sim_output$G
    response <- G_true[upper.tri(G_true)]
    strength_true <- get_deg(data)

    #obtain amount of observations and variables
    n = nrow(data$data)
    p = ncol(data$data)
    density = data$density
    graph = data$graph
    rep = data$rep
    algorithm_name = "BDA"

    # run the algorithm
    sample_bd <- bdgraph(
      data = data$data,
      algorithm = "bdmcmc",
      g.prior = params$g_prior,
      df.prior = params$b_prior
      )

    strength_estimated  <- get_deg(sample_bd, FALSE)

  }
}

data_sim <-

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
