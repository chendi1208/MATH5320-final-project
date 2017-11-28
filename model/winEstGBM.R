# Read prices, windowLen. Return rtn, mu, sigma, mubar, sigmabar
winEstGBM <- function(prices, windowLen){
  rtn <- c(-diff(log(prices)),NA)
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