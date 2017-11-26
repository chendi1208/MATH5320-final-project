# VaR & ES formula
varformula <- function(v0, t, p, mu, sigma){
  v <- v0 - v0 * exp(sigma * sqrt(t) * qnorm(1-p) + (mu - sigma^2/2)*t)
  return(v)
}

esformula <- function(v0, t, p, mu, sigma){
  x <- v0 - varformula(v0, t, p, mu, sigma)
  d1 <- (log(v0/x)+(mu+(sigma**2)/2)*t)/(sigma*sqrt(t))
  es <- v0 - (exp(mu * t) * v0 * (1 - pnorm(d1)))/(1-p)
  return(es)
}