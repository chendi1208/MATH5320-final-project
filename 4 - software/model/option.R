library(MASS)
library(OptionPricing)

rhocalculate <- function(Data, w, date){
  m <- dim(Data)[2]-1
  windowsize <- w*252
  logreturn1 <- NULL
  
  for (i in 1:m){
    temp <- -diff(log(Data[,i+1]))
    logreturn1 <- cbind(logreturn1, temp)
  }
  
  rhomat <- matrix(NA,nrow = m, ncol = m)
  for (i in 1:m){
    for(j in 1:m){
      rho <- cor(logreturn1[date:(date+windowsize-1),i], logreturn1[date:(date+windowsize-1),j])
      rhomat[i,j] <- rho
    }
  }
  
  return(rhomat)
  
}

combined_VaR <- function(Stockpricedata, callvoldata, putvoldata, callindex, putindex, stockinvest, callinvest, putinvest, callmature, putmature, callstrike, putstrike, r, date, VaRp, horizon, w, npaths){
  m <- dim(Stockpricedata)[2]-1 
  calibration <- NULL
  for (i in 1:m){
    temp <- window_calibrate(Stockpricedata[,(i+1)],w,horizon)
    sigma <- temp$sigma[date]
    mu <- temp$mu[date]
    calibration <- rbind(calibration, c(mu, sigma))
  }
  
  rhomat <- rhocalculate(Stockpricedata, w, date)
  d <- dim(rhomat)[1]
  covmat <- matrix(NA,d,d )
  for (i in 1:d){
    for(j in 1:d){
      covmat[i,j] <- rhomat[i,j]*calibration[i,2]*calibration[j,2]
    }
  }
  
  Stockmovement  <-  mvrnorm(npaths, calibration[,1], covmat )
  St <- NULL
  for (i in 1:npaths){
    scenario <- Stockpricedata[date,2:(m+1)]*exp((calibration[,1]-calibration[,2]^2/2)*horizon/252+ calibration[,2]*Stockmovement[i,])
    St <- rbind(St,scenario)
  }
  
  Stockshares <-  stockinvest/Stockpricedata[date,2:(m+1)]
  Stockloss <- vector()
  for (i in 1:npaths){
    temp <-  sum(Stockshares*(Stockpricedata[date,2:(m+1)]-St[i,]))
    Stockloss[i] <- temp
  }
  
  
  
  calllength <- length(callindex)
  callS0 <- vector()
  calllose <- NULL
  if (calllength>=1){
    for (i in 1:calllength){
      callS0[i] <- BS_EC(callmature[i], callstrike[i], r, callvoldata[date,i+1], Stockpricedata[date, callindex[i]+1])[1]
    }
    callshares <- callinvest/callS0
    callSt <- matrix(NA,nrow = npaths, ncol = calllength )
    for (j in 1:calllength){
      for (i in 1:npaths){
        temp <- St[i, callindex[j]]
        tempstrike <- callstrike[j]
        tempvol <- callvoldata[date, j+1]
        callSt[i,j] <- BS_EC(callmature[j]-horizon/252, tempstrike, r, tempvol, St[i, callindex[j]] )[1]
      }
    }
    
    for (i in 1:npaths){
      calllose[i] <- -callshares*callSt[i,] + callinvest
    }
  }
  else(calllose <- 0)
  
  
  putlength <- length(putindex)
  putS0 <- vector()
  putlose <- NULL
  if(putlength>=1){
    for (i in 1:putlength){
      putS0[i] <- BS_EP(putmature[i], putstrike[i], r, putvoldata[date,i+1], Stockpricedata[date, putindex[i]+1])[1]
    }
    putshares <- putinvest/putS0
    putSt <- matrix(NA,nrow = npaths, ncol = putlength )
    for (j in 1:putlength){
      for (i in 1:npaths){
        temp <- St[i, putindex[j]]
        tempstrike <- putstrike[j]
        tempvol <- putvoldata[date, j+1]
        putSt[i,j] <- BS_EP(putmature[j]-horizon/252, tempstrike, r, tempvol, St[i, putindex[j]] )[1]
      }
    }
    
    for (i in 1:npaths){
      putlose[i] <- -putshares*putSt[i,] + putinvest
    }
  }
  else(putlose <-0)
  
  totallose <- Stockloss + calllose + putlose
  VaR <- quantile(totallose, VaRp, na.rm = T)
  return(VaR)
}
