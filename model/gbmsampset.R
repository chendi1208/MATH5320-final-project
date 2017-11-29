gbmsampset <- function(n, dt, s0, mu, sigma, k) {
  tv <- seq(0, (dt*n), by = dt)
  return(s0 * exp(t(sigma * t(bmsampset(n, dt, k)) + (mu - sigma^2/2) * rep(tv,k))))
}
