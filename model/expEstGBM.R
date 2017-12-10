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


  expEstGBM <- function(price, windowLen){
    
    solve_lambda <- function(windowLen){
      result <- uniroot(function(o) {
        2*(2*o^(windowLen+1)+o^(windowLen+2)+o^windowLen-o)
        },c(.5,1))
      return(result$root)
    }
    lambda <- solve_lambda(windowLen)
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
  ## Parametric - equally weighted
  if (method == "Parametric - equally weighted") {
    parameter <- winEstGBM(price, windowLen)
    if (measure == "VaR") {
      var <- s0 - s0 * exp(parameter$sigma * sqrt(horizon) * 
        qnorm(1 - VaRp) + (parameter$mu - parameter$sigma^2/2) * horizon)
      return(var)
    }
    else {
      if (measure == "ES") {
        es <- s0 * (1 - exp(parameter$mu * horizon)/(1 - ESp) *
          pnorm(qnorm(1 - ESp) - sqrt(horizon) * parameter$sigma))
        return(es)
      }
    }
  }

  ## Parametric - exponentially weighted
  else {
    if (method == "Parametric - exponentially weighted") {
      parameter <- expEstGBM(price, windowLen)
      if (measure == "VaR") {
        var <- s0 - s0 * exp(parameter$sigma * sqrt(horizon) * 
          qnorm(1 - VaRp) + (parameter$mu - parameter$sigma^2/2) * horizon)
        return(var)
      }
      else {
        if (measure == "ES") {
          es <- s0 * (1 - exp(parameter$mu * horizon)/(1 - ESp) * 
            pnorm(qnorm(1 - ESp) - sqrt(horizon) * parameter$sigma))
          return(es)}
      }
    }

    ## Historical Simulation
    else {
      if (method == "Historical Simulation") {
        if (measure == "VaR") {
          PortfolioRes <- s0 * exp(-diff(log(price)))
          histloss <- s0 - PortfolioRes
          historical_rel_VaR <- NULL
          for (i in 1:(length(PortfolioRes) - windowLenDays)) {
            historical_rel_VaR[i] <- quantile(histloss[i:(i + windowLenDays)],VaRp)
          }
          return(historical_rel_VaR)
        }
        else {
          if (measure == "VaR") {
            return(NULL)
          }
        }
      }

      ## Monte Carlo Simulation
      else{
        if (method == "Monte Carlo Simulation") {
          return(NULL)
        }
      }
    }
  }
}


# MONTECARLO_VaR <- function(S,S0,w,p,day,npaths){
#   t <- day/252
#   windowsize <- w*252
#   sigmu <- c_t(S,w,1)
#   MCVaR <- vector()

#   l <- dim(sigmu)[1]
  
#   for (j in 1:l){
#     loss <- NULL
#     for (i in 1:npaths){
#       c <- rnorm(1,0,sqrt(day/252))
#       temp <- S0*exp((sigmu[j,2]- sigmu[j,1]^2/2)*day/252 + sigmu[j,1]*c)
#       loss <- c(loss, S0 - temp)
#     }
#     MCVaR <- c(MCVaR,quantile(loss, p))
#   }
  
#   MCVaR <- data.frame(S$Date[1:length(MCVaR)],MCVaR)
#   names(MCVaR) <- c("Date", "MCVaR")
#   return(MCVaR)
# }