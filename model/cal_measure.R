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


# Function used in methods
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
solve_lambda <- function(windowLen){
  result <- uniroot(function(o) {
    2*(2*o^(windowLen+1)+o^(windowLen+2)+o^windowLen-o)
    },c(.5,1))
  return(result$root)
}

expEstGBM <- function(price, windowLen){
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

  # method 3
historical_rel_VaR <- function(price,s0,windowLenDays,VaRp,horizonDays){
  l <- length(price)
  if (l < horizonDays) {return(NULL)}
  logreturn <- log(price[1:(l-horizonDays)]) - log(price[(1+horizonDays):l])
  PortfolioRes <- s0*exp(logreturn)
  l <- length(PortfolioRes)
  loss <- s0 - PortfolioRes
  VaR <- NULL
  if (l < windowLenDays) {return(NULL)}
  for (i in 1:(l-windowLenDays)){
    VaR[i] <- quantile(loss[i:(i+windowLenDays)],VaRp, na.rm = TRUE)
  }
  return(VaR)
}

  # method 4
Monte_VaR <- function(price,s0,windowLen,VaRp,horizon,npaths){
  parameter <- winEstGBM(price, windowLen)
  sigma <- parameter$sigma
  mu <- parameter$mu
  MCVaR <- vector()

  l <- length(sigma)
  
  for (j in 1:l){
    loss <- NULL
    for (i in 1:npaths){
      c <- rnorm(1,0,sqrt(horizon))
      temp <- s0*exp((mu[j]- sigma[j]^2/2)*horizon + sigma[j]*c)
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

gbmES <- function(s0, mu, sigma, horizon, ESp) {
  es <- s0 * (1 - exp(mu * horizon)/(1 - ESp) *
    pnorm(qnorm(1 - ESp) - sqrt(horizon) * sigma))
  return(es)
}



cal_measure <- function(s0, price, windowLen, horizonDays, 
  method, measure, npaths, VaRp, ESp) {
  windowLenDays <- windowLen * 252
  horizon <- horizonDays / 252

  # Choose method
  ## Parametric - equally weighted
  if (method == "Parametric - equally weighted") {
    parameter1 <- winEstGBM(price, windowLen)
    if (measure == "VaR") {
      return(gbmVaR(s0, parameter1$mu, parameter1$sigma, horizon, VaRp))
    }
    else {
      if (measure == "ES") {
        return(gbmES(s0, parameter1$mu, parameter1$sigma, horizon, ESp))
      }
    }
  }

  ## Parametric - exponentially weighted
  else if (method == "Parametric - exponentially weighted") {
    parameter2 <- expEstGBM(price, windowLen)
    if (measure == "VaR") {
      return(gbmVaR(s0, parameter2$mu, parameter2$sigma, horizon, VaRp))
    }
    else {
      if (measure == "ES") {
        return(gbmES(s0, parameter2$mu, parameter2$sigma, horizon, ESp))}
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
