# Dashboard Server
library(ggplot2)
library(dygraphs)


# user defined modules
source('../model/portfolio.R')




stock_prices <- get_all_prices()

# server function
shinyServer(function(input, output) {
  # output$test <- renderTable({
  #   print('Updating')
  #   position <- read.csv(input$file$datapath)
  #   # position <- data.frame(ticker = 'MCD', amount = 100)
  #   date_range <- c(as.Date(input$dates[1]), as.Date(input$dates[2]))
  #   prices <- format_prices(stock_prices, position, date_range)
  # 
  #   # handle exception if no available data to form portfolio
  #   if (nrow(prices) == 0) {
  #     return(data.frame())
  #   }
  # 
  #   ptf <- format_portfolio(prices, position, date_range)
  #   ptf
  # })
  
  output$plots <- renderPlot({
    
    position <- read.csv(input$file$datapath)
    date_range <- c(as.Date(input$dates[1]), as.Date(input$dates[2]))
    prices <- format_prices(stock_prices, position, date_range)
    if (nrow(prices) == 0) {
      return(data.frame())
    }
    ptf <- format_portfolio(prices, position, date_range)
    s0 <- ptf$Portfolio[dim(ptf)[1]]
    
    source("../model/parameterSetup.R")
    source("../model/gbmVaRs.R")
    source("../model/winEstGBM.R")
    source("../model/expEstGBM.R")
    source("../model/plots.R")
    
  
    fig <- ggplot() + theme_bw() +
      labs(title = 'VaR and ES with your choice', x = '', y = '') + 
      scale_color_continuous(guide=FALSE)
    for (i in 1:3) {
      fig <- fig + plotwinvar(s0, ptf, input$lines_winvar[i])
      fig <- fig + plotwines(s0, ptf, input$lines_wines[i])
      fig <- fig + plotexpvar(s0, ptf, input$lines_expvar[i])
      fig <- fig + plotexpes(s0, ptf, input$lines_expes[i])
    }
    print(fig)
  })
})
