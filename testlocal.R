library(rowr)
setwd("~/Documents/Columbia/Courseworks/MATH 5320 Financial Risk Management and Regulation/Assignments/Assignments/hw11")
source("loadPrices.R")
ptf <- data.frame(Portfolio = date_price$AAP * 1000L,
                  Date = date_price$Date)
remove(date_price)
remove(stocks)
remove(startDate)
remove(nrows)
s0 <- ptf$Portfolio[dim(ptf)[1]]
price <- ptf$Portfolio
windowLen <- 5
horizonDays <- 5
VaRp <- .99
ESp <- .95
method <- c("Parametric - equally weighted")
measure <- "VaR"



combined <- data.frame(Date = ptf$Date)
names <- c()
for (i in method) {
  for (j in measure) {
    combined <- cbind.fill(combined, 
                           cal_measure(s0, price, windowLen, horizonDays, i, j, 100, VaRp, ESp), fill = NA)
    names <- c(names, paste(i, j))
  }
}
names(combined) <- c("Date", names)

ggplot(melt(combined, 
            id.vars = "Date"), aes(x= Date,
                                   y = value, group = variable)) + 
  geom_line(aes(color=variable)) + 
  scale_color_discrete('', labels = names)  +
  #labs(title = 'Portfolio variance (in dollars)', x = 'Time', y = 'Variance') +
  theme_bw() +
  theme(legend.position = c(0.85, 0.9), legend.background = element_blank())



ptf <- ptfData()
s0 <- ptf$Portfolio[dim(ptf)[1]]
price <- ptf$Portfolio
horizonDays <- input$horizonDays
horizon <- horizonDays / 252
nrows <- length(price)
if (nrows < 252) {return(NULL)}

ShareChange <- c(price[1:(nrows-horizonDays)] / price[(1+horizonDays):nrows], 
                 rep(NA, horizonDays))

combined <- combined()

comparison <- data.frame(Date = ptf$Date)
comparison <- cbind.fill(comparison, (s0 - ShareChange * s0), fill = NA)
name <- c("Date", "daysLoss")
names(comparison) <- name
for (i in 2:(dim(combined)[2])) {
  measuredata <- combined[,i]
  exception <- c()
  for (i in 1:(nrows-252)) {
    exception <- c(exception, sum(comparison$daysLoss[i:(252+i-1)] >= measuredata[i]))
  }
  comparison <- cbind.fill(comparison, exception, fill = NA)
}
names(comparison) <- name
