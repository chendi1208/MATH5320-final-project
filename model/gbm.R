# GBM functions module

bm_sampling <- function(n_steps, dt, n_paths) {
  # generate BM samples
  # output matrix dimension: n_paths * (n_steps + 1)

  return(cbind(0, t(apply(
    sqrt(dt) * matrix(rnorm(n_steps * n_paths), nrow = n_paths),
    1, cumsum))))
}


gbm_sampling <- function(n_paths, dt, n_steps, s0, mu, sigma) {
  # generate GBM samples
  # output matrix dimension: n_paths * (n_steps + 1)

  bm_samples <- bm_sampling(n_steps, dt, n_paths)
  tv <- seq(0, (dt * n_steps), by = dt)
  mat_tv <- matrix(rep(tv, n_paths), nrow = n_paths, byrow = T)
  return(s0 * exp(sigma * bm_samples + (mu - sigma**2 / 2) * mat_tv))
}


gbm_VaR <- function(v0, horizon, prob, mu, sigma){
  v <- v0 - v0 * exp(
    sigma * sqrt(horizon) * qnorm(1 - prob) + (mu - sigma**2 / 2) * horizon)
  return(v)
}


gbm_ES <- function(v0, horizon, prob, mu, sigma){
  var_value <- v0 - gbm_VaR(v0, horizon, prob, mu, sigma)
  d1 <- (log(v0 / var_value) + (mu + sigma**2 / 2) * horizon) / (sigma * sqrt(horizon))
  es <- v0 - v0 * exp(mu * horizon) * (1 - pnorm(d1)) / (1 - prob)
  return(es)
}


gbm_calibrate <- function(prices, windowLen){
  rtn <- c(-diff(log(prices)), NA)
  mubar <- c(rollapply(rtn, windowLen, mean), rep(NA, windowLen - 1))
  rtnsq <- rtn * rtn
  x2bar <- c(rollapply(rtnsq, windowLen, mean), rep(NA, windowLen - 1))
  var_val <- x2bar - mubar ** 2
  sigmabar = sqrt(var_val)
  sigma <- sigmabar/sqrt(1/252)
  mu <- mubar/(1/252) + (sigma ** 2)/2
  return(list(
    rtn = rtn, mu = mu, sigma = sigma, 
    mubar = mubar, sigmabar = sigmabar))
}
