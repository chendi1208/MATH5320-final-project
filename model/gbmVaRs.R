## Compute a portfolio that follows GBM.
# t: Horizon at which to compute VaR (in years).

gbmVaR <- function(v0, mu, sigma, p, t){
  v <- v0 - v0 * exp(sigma * sqrt(t) * qnorm(1-p) + (mu - sigma^2/2)*t)
  return(v)
}
gbmES <- function(v0, mu, sigma, p, t) {
  return(v0*(1-exp(mu*t)/(1-p) * pnorm(qnorm(1-p)-sqrt(t)*sigma)))
}
gbmESShort <- function(v0, mu, sigma, p, t) {
  (-gbmES(v0, mu, sigma, 0.0, t) + p * gbmES(v0, mu, sigma, 1-p, t))/(1-p)
}