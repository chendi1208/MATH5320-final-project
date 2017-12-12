## Estimate parameters from history assuming process is GBM, windowed estimation.

# prices: Vector of daily historical prices, from newest to oldest.
# windowLen: Length of window to use in estimation (in days).

winEstGBM <- function(prices, windowLen){
  rtn <- c(-diff(log(prices)), NA) # log returns
  mubar <- c(rollapply(rtn, windowLen, mean), rep(NA, windowLen-1))
  rtnsq <- rtn * rtn
  x2bar <- c(rollapply(rtnsq, windowLen, mean), rep(NA, windowLen-1))
  var <- x2bar - mubar ** 2
  sigmabar = sqrt(var)
  sigma <- sigmabar/sqrt(1/252)
  mu <- mubar/(1/252) + (sigma ** 2)/2
  return(list(rtn = rtn, mu = mu, sigma = sigma, 
              mubar = mubar, sigmabar = sigmabar))
}