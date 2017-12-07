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
    print('Updating')
    position <- read.csv(input$file$datapath)
    # position <- data.frame(ticker = 'MCD', amount = 100)
    date_range <- c(as.Date(input$dates[1]), as.Date(input$dates[2]))
    prices <- format_prices(stock_prices, position, date_range)

    # handle exception if no available data to form portfolio
    if (nrow(prices) == 0) {
      return(data.frame())
    }

    ptf <- format_portfolio(prices, position, date_range)
    ptf
  })
})
