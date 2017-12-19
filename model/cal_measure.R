# price: current position
# s0: initial position
# windowLen: window length (in year). Default: 5 year window
# (windowLenDays <- windowLen * 252)
# horizonDays (in day). Default: 5 day horizon
# (horizon <- horizonDays / 252)



# CALIBRATION
# window
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

# exponential
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
  
  windowLen <- ceiling(log(0.01) / log(lambda))
  if (windowLen > 5000) {windowLen = 5000}

  coef <- lambda ** seq(0, windowLen-1)
  weights <- coef / sum(coef)
  
  sigmu <- NULL
  if (l < windowLen) {return(NULL)}
  for (i in 1:(l - windowLen + 1)){
      mubar <- sum(weights * logreturn[i:(i + windowLen - 1)])
      varbar <- sum(weights * (logreturn[i:(i + windowLen - 1)]) ** 2) - mubar ** 2
      sigbar <- sqrt(varbar)
      sig <- sigbar / sqrt(horizon)
      mu <- mubar / horizon + sig ** 2/2
      temp <- c(sig, mu)
      sigmu <- rbind(sigmu, temp)
  }
   
  df <- list(mu = sigmu[,2], sigma = sigmu[,1])
  return(df)
}

# PARAMETRIC MEASURE
gbmVaR <- function(s0, mu, sigma, horizon, VaRp) {
  gbm <- s0 - s0 * exp(sigma * sqrt(horizon) * 
    qnorm(1 - VaRp) + (mu - sigma^2/2) * horizon)
  return(gbm)
}


gbmES <- function(s0, mu, sigma, horizon, ESp) {
  es <- s0 * (1 - exp(mu * horizon)/(1 - ESp) *
    pnorm(qnorm(1 - ESp) - sqrt(horizon) * sigma))
  return(es)
}

# HISTORIC SIMULATION
historical_VaR <- function(price, s0, windowLenDays, VaRp, horizonDays) {
  rtn <- -diff(log(price), horizonDays)
  mtm <- s0 * exp(rtn)
  pnl <- s0 - mtm

  VaR <- NULL
  if (length(mtm) < windowLenDays) {return(NULL)}
  for (i in 1:(length(mtm) - windowLenDays)){
    VaR[i] <- quantile(pnl[i:(i + windowLenDays)], VaRp, na.rm = TRUE)
  }
  return(VaR)
}

historical_ES <- function(price, s0, windowLenDays, ESp, horizonDays){
  rtn <- -diff(log(price), horizonDays)
  mtm <- s0 * exp(rtn)

  ES <- NULL
  if (length(mtm) < windowLenDays) {return(NULL)}
  for (i in 1:(length(mtm) - windowLenDays + 1)){
    Extreme <- quantile(mtm[i:(i + windowLenDays - 1)], 1 - ESp, na.rm = T)
    set <- mtm[i:(i + windowLenDays - 1)]
    ES[i] <- s0 - mean(set[set <= Extreme])
  }
  return(ES)
}

# MONTE CARLO
Monte_VaR <- function(s0, mu, sigma, VaRp, horizon, npaths){
  MCVaR <- vector()
  l <- length(mu)
  
  for (j in 1:l){
    pnl <- NULL
    for (i in 1:npaths){
      c <- rnorm(1,0,sqrt(horizon))
      temp <- s0 * exp((mu[j] - sigma[j] ** 2 / 2) * horizon + sigma[j] * c)
      pnl <- c(pnl, s0 - temp)
    }
    MCVaR <- c(MCVaR, quantile(pnl, VaRp, na.rm = T))
  }
  return(MCVaR)
}

Monte_ES <- function(s0, mu, sigma, ESp, horizon, npaths){
  MCES <- vector()
  l <- length(mu)
  
  for (j in 1:l){
    pnl <- NULL
    for (i in 1:npaths){
      c <- rnorm(1,0,sqrt(horizon))
      temp <- s0 * exp((mu[j] - sigma[j] ** 2 / 2) * horizon + sigma[j] * c)
      pnl <- c(pnl, s0 - temp)
    }
    temp <- pnl[pnl > quantile(pnl, ESp, na.rm = T)]
    ESvalue <- mean(temp)
    MCES <- c(MCES, ESvalue)
  }
  return(MCES)  
}

# CALCULATION
cal_measure <- function(s0, price, windowLen, horizonDays, 
  method, measure, npaths, VaRp, ESp, data) {
  windowLenDays <- windowLen * 252
  horizon <- horizonDays / 252

  # Choose method
  ## Parametric - equally weighted
  if (method == "Parametric - equally weighted") {
    if (measure == "VaR") {
      return(gbmVaR(s0, data$WindowMean, data$WindowSD, horizon, VaRp))
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
      return(historical_VaR(price,s0,windowLenDays,VaRp,horizonDays))
    }
    else {
      if (measure == "ES") {
        return(historical_ES(price,s0,windowLenDays,ESp,horizonDays))
      }
    }
  }

  ## Monte Carlo Simulation
  else if (method == "Monte Carlo Simulation") {
    if (measure == "VaR") {
      return(Monte_VaR(s0, data$WindowMean, data$WindowSD, VaRp, horizon, npaths))
    }
    else {
      if (measure == "ES") {
        return(Monte_ES(s0, data$WindowMean, data$WindowSD, ESp, horizon, npaths))
      }
    }
  }
}
