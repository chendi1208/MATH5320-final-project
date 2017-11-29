# Dashboard Server
library(ggplot2)
library(reshape2)
library(dygraphs)
library(xts)


# user defined modules
source('../model/gbmES.R')


# server function
shinyServer(function(input, output) {
  output$table <- renderTable({
    df <- data.frame(x = rnorm(100))
    df
  })
})
