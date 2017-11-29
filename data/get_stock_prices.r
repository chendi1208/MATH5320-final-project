# fetch stock prices and save to local sqlite database
# faster I/O speed for system and avoid real-time connections

library(quantmod)
library(RSQLite)
library(foreach)
library(doParallel)

universe <- na.omit(stockSymbols())
universe <- universe[(universe$IPOyear <= 2015) & (universe$Exchange != 'AMEX'), 'Symbol']

# initialize parallel computation pool
cores <- detectCores()
cl <- makeCluster(cores[1] - 1)
registerDoParallel(cl)

# define function
get_data <- function(ticker) {
  print(paste('Fetching stock price', ticker))
  df <- as.data.frame(getSymbols(ticker, src = 'google', env = NULL))
  names(df) <- sapply(strsplit(names(df), '\\.'), '[[', 2)
  df$Ticker <- ticker
  df$Date <- as.Date(row.names(df))
  return(df)
}

# fetch stock prices by ticker
print('Start to fetch prices')
stock_prices <- foreach(ticker = universe, .combine = rbind, .packages='quantmod') %dopar% {
  tryCatch({
    get_data(ticker)
  }, error = function(e) {})
}

stock_prices <- stock_prices[!is.na(row.names(stock_prices)), ]
stopCluster(cl)

# write to database
print('Writing to database')
con <- dbConnect(RSQLite::SQLite(), dbname = 'stock_prices.sqlite')
dbWriteTable(con, 'stock_prices', stock_prices, overwrite = T, row.names = NA)
dbDisconnect(con)
