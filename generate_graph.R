# Load igraph library
library(igraph)

#' Generate a graph with a specific target density using current igraph functions
#'
#' This function iteratively adjusts the key parameter of igraph's graph
#' generation functions until the resulting graph's density is at least
#' as high as the target density.
#'
#' @param p The number of nodes in the graph.
#' @param target_density A numeric value between 0 and 1 for the desired graph density.
#' @param graph_type A character string, either "scale-free" or "small-world".
#' @param max_iter The maximum number of iterations to prevent infinite loops.
#' @return An adjacency matrix (class 'matrix') of the generated graph.

generate_graph <- function(p, target_density, graph_type, max_iter = 100) {

  # The parameter we will tune to adjust density
  tuning_param <- 1

  for (i in 1:max_iter) {

    if (graph_type == "scale-free") {
      # For scale-free, we tune 'm', the number of edges to add at each step.
      # It cannot be larger than 'p'.
      if (tuning_param >= p) {
        warning("Could not reach target density for scale-free graph; m reached p. Returning densest possible graph.")
        break
      }
      # CORRECTED FUNCTION: Using sample_pa()
      g <- igraph::sample_pa(n = p, m = tuning_param, power = 1, directed = FALSE)

    } else if (graph_type == "small-world") {
      # For small-world, we tune 'nei', the neighborhood size.
      # It cannot be larger than (p-1)/2
      if (tuning_param >= (p - 1) / 2) {
        warning("Could not reach target density for small-world graph; 'nei' is too large. Returning densest possible graph.")
        break
      }
      # CORRECTED FUNCTION: Using sample_smallworld()
      g <- igraph::sample_smallworld(dim = 1, size = p, nei = tuning_param, p = 0.05)

    } else {
      stop("Unsupported graph_type. Please use 'scale-free' or 'small-world'.")
    }

    # Calculate the density of the generated graph
    current_density <- igraph::edge_density(g)

    # Check if we have met or exceeded the target
    if (current_density >= target_density) {
      break
    }

    # If not, increment the tuning parameter for the next iteration
    tuning_param <- tuning_param + 1
  }

  # Return the final graph as a standard R matrix
  return(as.matrix(igraph::as_adjacency_matrix(g)))
  #return(g)
}
