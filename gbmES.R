gbmES <- function(v0, t, p, mu, sigma){
  x <- v0 - gbmVaR(v0, t, p, mu, sigma)
  d1 <- (log(v0/x)+(mu+(sigma**2)/2)*t)/(sigma*sqrt(t))
  es <- v0 - (exp(mu * t) * v0 * (1 - pnorm(d1)))/(1-p)
  return(es)
}