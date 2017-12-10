# In one function
# Common use input: 
  # price: current position
  # windowLen: window length (in year)
    # windowLenDays <- windowLen * 252
  # s0: initial position
  # horizonDays (in day)
    # horizon <- horizonDays / 252
  # method: "winestimate", "expestimate"
  # VaRp
  # ESp



cal_measure <- function(s0, price, windowLen, horizonDays, 
  method, measure, VaRp = 0.99, ESp = 0.975) {
  windowLenDays <- windowLen * 252
  horizon <- horizonDays / 252

  # function for methods
  # method 1
  winEstGBM <- function(price, windowLen){
    rtn <- c(-diff(log(price)), NA) # log returns
    mubar <- c(rollapply(rtn, windowLen, mean), rep(NA, windowLen - 1))
    rtnsq <- rtn * rtn
    x2bar <- c(rollapply(rtnsq, windowLen, mean), rep(NA, windowLen - 1))
    var <- x2bar - mubar ** 2
    sigmabar = sqrt(var)
    sigma <- sigmabar/sqrt(1/252)
    mu <- mubar/(1/252) + (sigma ** 2)/2
    return(list(rtn = rtn, mu = mu, sigma = sigma, 
                mubar = mubar, sigmabar = sigmabar))
  }

  # method 2


  expEstGBM <- function(price, windowLenDays){
    
    solve_lambda <- function(windowLenDays){
      result <- uniroot(function(o) {
        2*(2*o^(windowLenDays+1)+o^(windowLenDays+2)+o^windowLenDays-o)
        },c(.5,1))
      return(result$root)
    }
    lambda <- solve_lambda(windowLenDays)
    rtn <- c(-diff(log(price)),NA)
    windowLen_exp <- ceiling(log(0.01) / log(as.numeric(lambda)))
    if (windowLen_exp > 5000) {windowLen_exp = 5000}
    w <- as.numeric(lambda) ** (1:windowLen_exp)
    w <- w / sum(w)
    mubar <- c(rollapply(rtn, windowLen_exp, function(o){o %*% w}), rep(NA, windowLen_exp-1))
    rtnsq <- rtn * rtn
    x2bar <- c(rollapply(rtnsq, windowLen_exp, function(o){o %*% w}), rep(NA, windowLen_exp-1))
    var <- x2bar - mubar ** 2
    sigmabar = sqrt(var)
    sigma <- sigmabar/sqrt(1/252)
    mu <- mubar/(1/252) + (sigma ** 2)/2
    return(list(rtn = rtn, mu = mu, sigma = sigma, 
                mubar = mubar, sigmabar = sigmabar))
  }

  # Choose method
  if (method == "Parametric - equally weighted") {
    parameter <- winEstGBM(price, windowLen)
  } else if (method == "Parametric - exponentially weighted") {
    parameter <- expEstGBM(price, windowLen)
  }
  gbm <- s0 - s0 * exp(parameter$sigma * sqrt(horizon) * 
    qnorm(1 - VaRp) + (parameter$mu - parameter$sigma^2/2) * horizon)
  ES <- 1
  if (measure == "VaR") {
    return(gbm)
  } else if (measure == "ES") {
    return(NULL)
  }
}





# historical_rel_VaR <- function(price,s0,windowLen,VaRp,horizonDays){
#   l <- length(price)
#   logreturn <- log(price[1:(l-horizonDays)]) - log(price[(1+horizonDays):l])
#   PortfolioRes <- s0*exp(logreturn)
#   l <- length(PortfolioRes)
#   loss <- s0 - PortfolioRes
#   VaR <- NULL
#   for (i in 1:(l-windowLenDays)){
#     VaR[i] <- quantile(loss[i:(i+windowLenDays)],VaRp)
#   }
#   return(VaR)
# }
# return(historical_rel_VaR(price,s0,windowLen,VaRp,horizonDays))










# read prices, lambda, return rtn, mu, sigma, mubar, sigmabar
