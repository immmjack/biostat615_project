# FISTA implementation file

# Input:
# X: design matrix (n x p)
# y: response vector (n x 1)
# lambda: regularization parameter
# max_iter: maximum number of iterations
# tol: tolerance for convergence

# Output:
# beta: estimated coefficients
# iter: number of iterations performed
# convergence: boolean indicating whether convergence was achieved

FISTA_lassosolve <- function(X, y, lambda, max_iter = 1000, tol = 1e-6) {

  n <- nrow(X)
  p <- ncol(X)

  # Precompute X'X and X'y
  XtX <- crossprod(X)
  Xty <- crossprod(X, y)

  # Lipschitz constant (L = max eigenvalue of XtX / n)
  L <- max(eigen(XtX / n)$values)

  # Initialize beta and auxiliary variables
  beta <- rep(0, p)            # β^(0)
  beta_prev <- beta            # β^(k-1), starts equal to β^(0)
  t <- 1                       # t_1
  alpha <- beta                # α^(1), initialized to β^(0)

  # Soft-thresholding function
  soft_threshold <- function(z, gamma) {
    sign(z) * pmax(0, abs(z) - gamma)
  }

  # FISTA Iterations
  for (iter in 1:max_iter) {
    # Gradient step with momentum
    gradient <- (XtX %*% alpha - Xty) / n
    beta_new <- soft_threshold(alpha - (1 / L) * gradient, lambda / L)

    # Check convergence
    if (sqrt(sum((beta_new - beta)^2)) < tol) {
      return(list(beta = beta_new, iter = iter, convergence = TRUE))
    }

    # Momentum update
    t_new <- (1 + sqrt(1 + 4 * t^2)) / 2
    alpha <- beta_new + ((t - 1) / t_new) * (beta_new - beta)

    # Update variables for the next iteration
    beta <- beta_new
    t <- t_new
  }

  # Return results
  return(list(beta = beta, iter = max_iter, convergence = FALSE))
}

# # Example usage
# set.seed(123)
# n <- 100
# p <- 10
# X <- matrix(rnorm(n * p), n, p)
# beta_true <- c(1, -1, rep(0, p - 2))
# y <- X %*% beta_true + rnorm(n)
# lambda <- 0.1
#
# result <- FISTA_lassosolve(X, y, lambda)
# print(result)
