# Dashboard Server
library(ggplot2)
library(dygraphs)


# user defined modules
source('../model/portfolio.R')
source('../model/gbm.R')

stock_prices <- get_all_prices()


# server function
shinyServer(function(input, output) {
  output$test <- renderTable({
    position <- data.frame(ticker = 'MCD', amount = 100)
    date_range <- c(as.Date('2016-01-01'), as.Date('2017-01-31'))
    prices <- format_prices(stock_prices, position, date_range)

    # handle exception if no available data to form portfolio
    if (nrow(prices) == 0) {
      return(data.frame())
    }

    ptf <- format_portfolio(prices, position, date_range)
    ptf
  })
})
