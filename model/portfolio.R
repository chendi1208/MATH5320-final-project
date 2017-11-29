# utilitiy functions

library(reshape2)
library(dplyr)

format_prices <- function(stock_prices, universe, date_range) {
  # reshape melted stock prices data
  start_date <- date_range[1]
  end_date <- date_range[2]

  # get valid universe
  universe_valid <- universe[universe %in% stock_prices$Ticker]
  universe_uncovered <- universe[!(universe %in% stock_prices$Ticker)]
  
  if (length(universe_uncovered) > 0) {
    print(paste(
      'Tickers not covered:',
      paste(universe_uncovered, collapse = ', ')
    ))}
  
  # reshape close prices
  df <- stock_prices[stock_prices$Ticker %in% universe_valid, c('Date', 'Ticker', 'Close')]
  df$Date <- as.Date(df$Date)
  df <- dcast(df, Date ~ Ticker, value.var = 'Close')
  df <- na.locf(df, fromLast = T)
  
  # reverse time index
  df <- df[rev(row.names(df)), ]
  df <- df[(df$Date >= start_date) & (df$Date <= end_date), ]
  return(df)
}


format_portfolio <- function(prices, position, date_range) {
  start_date <- date_range[1]
  end_date <- date_range[2]
}
