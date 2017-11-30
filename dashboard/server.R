# Dashboard Server
library(ggplot2)
library(dygraphs)


# user defined modules
source('../model/portfolio.R')
source('../model/gbm.R')

stock_prices <- get_all_prices()


# server function
shinyServer(function(input, output) {
  output$table <- renderTable({
    df <- data.frame(x = rnorm(100))
    df
  })
})
