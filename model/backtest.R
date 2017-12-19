backtesting <- function(gbmdata, s0) {
  horizon <- horizonDays / 252
  nrows <- length(price)
  if (nrows < 252) {return(NULL)}
  comparison <- data.frame(Date = rep(NA, nrows))
  ShareChange <- c(price[1:(nrows-horizonDays)] / price[(1+horizonDays):nrows], 
    rep(NA, horizonDays))
}





winBacktest <- function(price, s0, mu, sigma, VaRp, horizonDays, direction) {
  horizon <- horizonDays / 252
  nrows <- length(price)
  if (nrows < 252) {return(NULL)}
  comparison <- data.frame(Date = rep(NA, nrows))
  ShareChange <- c(price[1:(nrows-horizonDays)] / price[(1+horizonDays):nrows], 
    rep(NA, horizonDays))
  if (direction == "Long") {
    comparison$Loss <- s0 - ShareChange*s0
    comparison$gbmVaR <- gbmVaR(s0, mu, sigma, horizon, VaRp) # 5 day VaR
  } 


  exception <- c()
  for (i in 1:(nrows-252)) {
    exception <- c(exception, sum(comparison$Loss[i:(252+i-1)] >= comparison$gbmVaR[i]))
  }
  comparison$exception <- c(exception, rep(NA, 252))

  return(comparison)
}  



expBacktest <- function(price, s0, mu, sigma, VaRp, horizon, direction) {
  horizon <- horizonDays / 252

  nrows <- length(price)
  if (nrows < 252) {return(NULL)}
  comparison <- data.frame(Date = rep(NA, nrows))
  ShareChange <- c(price[1:(nrows-5)] / price[6:nrows], rep(NA, 5))
  if (direction == "Long") {
    comparison$Loss <- s0 - ShareChange*s0
    comparison$gbmVaR <- gbmVaR(s0, mu, sigma, horizon, VaRp) # 5 day VaR
  } else {
    comparison$Loss <- ShareChange*s0 - s0
    comparison$gbmVaR <- -gbmVaR(s0, mu, sigma, horizon, (1-VaRp))
  }
  exception <- c()
  for (i in 1:(nrows-252)) {
    exception <- c(exception, sum(comparison$Loss[i:(252+i-1)] >= comparison$gbmVaR[i]))
  }
  comparison$exception <- c(exception, rep(NA, 252))
  
  return(comparison)
}



  MSFTexceptioncount <- vector()
  w <- 1
  for (i in 1:(l-w*252)){
    count <- 0
    for(j in 1:(w*252)){
      if ((MSFT_5day_loss[i+j-1,2] * investment/MSFT$Adj.Close[i+5+j-1]) > (MSFT_GBM_VaR[i+j-1,2])){count <- count+1}
    }
    MSFTexceptioncount <- c(MSFTexceptioncount, count)
  }
  
  MSFTexceptioncount <- data.frame(Date[1:(l-w*252)],MSFTexceptioncount)
  names(MSFTexceptioncount) <- c("Date", "Exception")
  library(ggplot2)
  jpeg("shortMSFTExceptioncount.jpg")
  ggplot(data = MSFTexceptioncount, mapping = aes(x = Date, y = Exception,group = 1)) + geom_line()
  dev.off()
  
  l <- dim(MSFTexceptioncount)[1]
  MSFT_5day_VaR <- investment*MSFT_5day_loss[1:l,2]/MSFT$Adj.Close[6:(l+5)]
  Date <- MSFTexceptioncount$Date
  
  
  Date_to_plot <- rep(Date,2)
  data_to_plot <- c(MSFT_5day_VaR, MSFT_GBM_VaR[1:l,2])
  Method <- c(rep("realized loss", l), rep("GBM_VaR", l))
  df_to_plot <- data.frame(Date_to_plot, data_to_plot, Method)
  names(df_to_plot) <- c("Date", "comparison", "method")
  
  jpeg("shortMSFTcomparison,jpg")
  ggplot(data = df_to_plot, mapping = aes(x = Date, y = comparison, group = method, color = method)) + geom_line()
  dev.off()
  
  
