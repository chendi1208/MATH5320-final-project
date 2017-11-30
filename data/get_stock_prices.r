# fetch stock prices and save to local sqlite database
# faster I/O speed for system and avoid real-time connections

library(quantmod)
library(RSQLite)
library(foreach)
library(doParallel)

universe <- stockSymbols()$Symbol

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
  df$Date <- row.names(df)
  return(df)
}

# fetch stock prices by ticker
print(paste('Start to fetch prices:', Sys.time()))
stock_prices <- foreach(ticker = universe, .combine = rbind, .packages='quantmod') %dopar% {
  tryCatch({
    get_data(ticker)
  }, error = function(e) {})
}

stock_prices <- stock_prices[!is.na(row.names(stock_prices)), ]
stopCluster(cl)
print(paste('Data fetched:         ', Sys.time()))

# write to database
print(paste('Writing to database:  ', Sys.time()))
con <- dbConnect(RSQLite::SQLite(), dbname = 'stock_prices.sqlite')
dbWriteTable(con, 'stock_prices', stock_prices, overwrite = T, row.names = NA)
dbDisconnect(con)
print(paste('Finished           :  ', Sys.time()))
