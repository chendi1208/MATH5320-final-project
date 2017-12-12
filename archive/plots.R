


plotwin <- function(s0, ptf, horizonDays) {
  if (is.na(horizonDays)) {return(NULL)} else {
    horizonDays <- as.integer(horizonDays)
    winestimate <- winEstGBM(ptf$Portfolio, horizonDays * 252)
    Data1 <- na.omit(data.frame(
      date = ptf$Date, value = gbmVaR(s0, winestimate[[2]], winestimate[[3]], VaRp, horizon)))
    fig1 <- geom_line(data=Data1, aes(x=as.Date(date), y=value, color = rnorm(1)))
    return(fig1)
  }
}

plotwines <- function(s0, ptf, horizonDays) {
  if (is.na(horizonDays)) {return(NULL)} else {
    horizonDays <- as.integer(horizonDays)
    winestimate <- winEstGBM(ptf$Portfolio, horizonDays * 252)
    Data1 <- na.omit(data.frame(
      date = ptf$Date, value = gbmES(s0, winestimate[[2]], winestimate[[3]], ESp, horizon)))
    fig2 <- geom_line(data=Data1, aes(x=as.Date(date), y=value, color = rnorm(1)))
    return(fig2)
  }
}

plotexpvar <- function(s0, ptf, horizonDays) {
  if (is.na(horizonDays)) {return(NULL)} else {
    horizonDays <- as.integer(horizonDays)
    expestimate <- expEstGBM(ptf$Portfolio, lambda = 0.99)
    Data1 <- na.omit(data.frame(
      date = ptf$Date, value = gbmVaR(s0, winestimate[[2]], winestimate[[3]], VaRp, horizon)))
    fig2 <- geom_line(data=Data1, aes(x=as.Date(date), y=value, color = rnorm(1)))
    return(fig2)
  }
}

plotexpes  <- function(s0, ptf, horizonDays) {
  if (is.na(horizonDays)) {return(NULL)} else {
    horizonDays <- as.integer(horizonDays)
    expestimate <- expEstGBM(ptf$Portfolio, lambda = 0.99)
    Data1 <- na.omit(data.frame(
      date = ptf$Date, value = gbmES(s0, winestimate[[2]], winestimate[[3]], ESp, horizon)))
    fig2 <- geom_line(data=Data1, aes(x=as.Date(date), y=value, color = rnorm(1)))
    return(fig2)
  }
}
