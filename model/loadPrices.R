# Form portfolio
stocks <- merge(read.csv("AAPL-yahoo.csv"), read.csv("MSFT-yahoo.csv"), by = "Date")
stocks$Date <- as.Date(stocks$Date, "%Y-%m-%d")

date_price <- data.frame(Date = rev(stocks$Date),
                         AAPL = rev(stocks$Adj.Close.x),
                         MSFT = rev(stocks$Adj.Close.y))
startDate <- "1992-09-24"
nrows <- which(date_price$Date == startDate)
date_price <- date_price[(1:nrows),]

shares <- c(round((s0/2) / date_price[nrows, 2]),
            round((s0/2) / date_price[nrows, 3]))

date_price$Portfolio <- shares[1] * date_price$AAPL + shares[2] * date_price$MSFT

remove("stocks")

# for project
ptf <- data.frame(Portfolio = date_price$Portfolio,
                  Date = date_price$Date)
remove("date_price")

# stock1 <- read.csv("AAPL-yahoo.csv")
# stock2 <- read.csv("MSFT-yahoo.csv")
# stock1$Date <- as.Date(stock1$Date, "%Y-%m-%d")
# stock2$Date <- as.Date(stock2$Date, "%Y-%m-%d")


# stock1Shares <- 3019
# stock2Shares <- 1994
# 
# startDate <- "1992-09-24"
# nrows <- which(stock1$Date == startDate)
# 
# stock1Dt <- stock1[stock1$Date >= startDate, ]$Date
# stock1 <- stock1[stock1$Date >= startDate, ]$Adj.Close
# 
# stock2 <- stock2[stock2$Date >= startDate, ]$Adj.Close
# stock2Dt <- stock1Dt
# 
# portValue <- stock1Shares * stock1 + stock2Shares * stock2
# portDt <- stock1Dt