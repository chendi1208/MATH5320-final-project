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


# Calibration
## window
window_calibrate <- function(price, windowLen, horizonDays) {
  horizon <- horizonDays / 252
  windowLenDays <- windowLen * 252
  logreturn <- -diff(log(price), horizonDays)
  
  result <- NULL
  samplemu <- rollapply(logreturn, windowLenDays, mean)
  samplesig <- rollapply(logreturn, windowLenDays, sd)
  sig <- samplesig / sqrt(horizon)
  mu <- samplemu / horizon + sig ** 2/2

  df <- list(mu = mu, sigma = sig)
  return(df)
}

## exponential
solve_lambda <- function(windowLenDays){
  result <- uniroot(function(o) {
    2 * (2 * o**(windowLenDays + 1) + o**(windowLenDays + 2) + o**windowLenDays - o)
  }, c(.5, 1))
  return(result$root)
}
weighted_calibrate <- function(price, windowLenDays, horizonDays){
  lambda <- solve_lambda(windowLenDays)
  horizon <- horizonDays / 252
  logreturn <- -diff(log(price), horizonDays)
  l <- length(logreturn)
  
  coef <- lambda ** seq(0, 101-1)
  weights <- coef / sum(coef)
  
  sigmu <- NULL
  if (l < 101) {return(NULL)}
  for (i in 1:(l - 101 + 1)){
      mubar <- sum(weights * logreturn[i:(i + 101 - 1)])
      varbar <- sum(weights * (logreturn[i:(i + 101 - 1)]) ** 2) - mubar ** 2
      sigbar <- sqrt(varbar)
      sig <- sigbar / sqrt(horizon)
      mu <- mubar / horizon + sig ** 2/2
      temp <- c(sig, mu)
      sigmu <- rbind(sigmu, temp)
  }
   
  df <- list(mu = sigmu[,2], sigma = sigmu[,1])
  return(df)
}



  # method 3
historical_rel_VaR <- function(price, s0, windowLenDays, VaRp, horizonDays) {
  l <- length(price)
  if (l < horizonDays) {
    return(NULL)
  }

  logreturn <- log(price[1:(l - horizonDays)]) - log(price[(1 + horizonDays):l])
  PortfolioRes <- s0 * exp(logreturn)
  l <- length(PortfolioRes)
  loss <- s0 - PortfolioRes
  VaR <- NULL
  if (l < windowLenDays) {return(NULL)}
  for (i in 1:(l-windowLenDays)){
    VaR[i] <- quantile(loss[i:(i + windowLenDays)], VaRp, na.rm = TRUE)
  }
  return(VaR)
}

  # method 4
Monte_VaR <- function(price, s0, windowLen, VaRp, horizon, npaths){
  parameter <- winEstGBM(price, windowLen)
  sigma <- parameter$sigma
  mu <- parameter$mu
  MCVaR <- vector()

  l <- length(sigma)
  
  for (j in 1:l){
    loss <- NULL
    for (i in 1:npaths){
      c <- rnorm(1, 0, sqrt(horizon))
      temp <- s0*exp((mu[j] - sigma[j]^2/2)*horizon + sigma[j] * c)
      loss <- c(loss, s0 - temp)
    }
    MCVaR <- c(MCVaR,quantile(loss, VaRp, na.rm = T))
  }
  return(MCVaR)
}


# Common measure to use

gbmVaR <- function(s0, mu, sigma, horizon, VaRp) {
  gbm <- s0 - s0 * exp(sigma * sqrt(horizon) * 
    qnorm(1 - VaRp) + (mu - sigma^2/2) * horizon)
  return(gbm)
}

# GBM_VaR <- function(price, s0, horizonDays, VaRp, windowLen){
#   horizon <- horizonDays / 252
#   sigmu <- window_calibrate(price, windowLen, 1)
#   GBM_VaR <- vector()

#   GBM_VaR <- s0-s0*exp(sigmu$sigma*sqrt(horizon)*qnorm(1-VaRp)+(sigmu$mu-sigmu$sigma^2/2)*horizon)
#   return(GBM_VaR)
# }

# weighted_GBM_VaR <- function(price,s0,horizonDays,VaRp, windowLen){
#   windowLenDays <- windowLen * 252
#   horizon <- horizonDays / 252
#   sigmu <- weighted_calibrate(price, windowLenDays, horizonDays)
#   GBM_VaR <- vector()
  
#   l <- lengths(sigmu)[[1]]
#   for (i in 1:l){
#     u <- sigmu$mu
#     d<- sigmu$sigma
#     GBM_VaR[i] <- s0-s0*exp(d[i]*sqrt(horizon)*qnorm(1-VaRp)+(u[i]-d[i]^2/2)*horizon)
#   }
  
#   return(GBM_VaR)
# }

gbmES <- function(s0, mu, sigma, horizon, ESp) {
  es <- s0 * (1 - exp(mu * horizon)/(1 - ESp) *
    pnorm(qnorm(1 - ESp) - sqrt(horizon) * sigma))
  return(es)
}



cal_measure <- function(s0, price, windowLen, horizonDays, 
  method, measure, npaths, VaRp, ESp, data) {
  windowLenDays <- windowLen * 252
  horizon <- horizonDays / 252

  # Choose method
  ## Parametric - equally weighted
  if (method == "Parametric - equally weighted") {
    if (measure == "VaR") {
      return(gbmVaR(s0, data$WindowMean, data$WindowSD , horizon, VaRp))
    }
    else {
      if (measure == "ES") {
        return(gbmES(s0, data$WindowMean, data$WindowSD, horizon, ESp))
      }
    }
  }

  ## Parametric - exponentially weighted
  else if (method == "Parametric - exponentially weighted") {
    if (measure == "VaR") {
      return(gbmVaR(s0, data$ExponentialMean, data$ExponentialSD , horizon, VaRp))
    }
    else {
      if (measure == "ES") {
        return(gbmES(s0, data$ExponentialMean, data$ExponentialSD, horizon, ESp))}
    }
  }

  ## Historical Simulation
  else if (method == "Historical Simulation") {
    if (measure == "VaR") {
      return(historical_rel_VaR(price,s0,windowLenDays,VaRp,horizonDays))
    }
    else {
      if (measure == "VaR") {
        return(NULL)
      }
    }
  }

  ## Monte Carlo Simulation
  else if (method == "Monte Carlo Simulation") {
    if (measure == "VaR") {
      return(Monte_VaR(price,s0,windowLen,VaRp,horizon,npaths))
    }
    else {
      if (measure == "VaR") {
        return(NULL)
      }
    }
  }
}
