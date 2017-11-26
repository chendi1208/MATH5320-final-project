bmsampset <- function(n, dt, k) {
  return(cbind(0, apply(sqrt(dt)*matrix(rnorm(k*n), nrow = k), 1, cumsum)))
}

gbmsampset <- function(n, dt, s0, mu, sigma, k) {
  tv <- seq(0, (dt*n), by = dt)
  return(s0 * exp(t(sigma * t(bmsampset(n, dt, k)) + (mu - sigma^2/2) * rep(tv,k))))
}
