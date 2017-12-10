# Dashboard Server
library(ggplot2)
library(dygraphs)
library(rowr)


# user defined modules
source('../model/portfolio.R')
source("../model/expEstGBM.R")


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
  
  output$plot <- renderPlot({
    
    position <- read.csv(input$file$datapath)
    date_range <- c(as.Date(input$dates[1]), as.Date(input$dates[2]))
    prices <- format_prices(stock_prices, position, date_range)
    if (nrow(prices) == 0) {
      return(data.frame())
    }
    ptf <- format_portfolio(prices, position, date_range)
    s0 <- ptf$Portfolio[dim(ptf)[1]]
    price <- ptf$Portfolio
    windowLen <- input$windowLen
    horizonDays <- input$horizonDays
    VaRp <- input$text1
    ESp <- input$text2
    method <- input$method
    measure <- input$measure


    combined <- data.frame(Date = ptf$Date)
    names <- c()
    for (i in method) {
      for (j in measure) {
        combined <- cbind.fill(combined, 
          cal_measure(s0, price, windowLen, horizonDays, i, j, VaRp, ESp), fill = NA)
        names <- c(names, paste(i, j))
      }
    }
    names(combined) <- c("Date", names)

    fig <- ggplot(melt(combined, 
                id.vars = "Date"), aes(x = as.Date(Date),
                                       y = value, group = variable)) + 
      geom_line(aes(color=variable)) + 
      scale_color_discrete('', labels = names) +
      labs(title = 'Portfolio variance (in dollars)', x = 'Time', y = 'Variance') +
      theme_bw()
    return(fig)

    # fig <- ggplot() + theme_bw() +
    #   labs(title = 'VaR and ES with your choice', x = '', y = '') + 
    #   scale_color_continuous(guide=FALSE)
    # for (i in 1:3) {
    #   fig <- fig + plotwinvar(s0, ptf, input$lines_winvar[i])
    #   fig <- fig + plotwines(s0, ptf, input$lines_wines[i])
    #   fig <- fig + plotexpvar(s0, ptf, input$lines_expvar[i])
    #   fig <- fig + plotexpes(s0, ptf, input$lines_expes[i])
    # }
    # print(fig)
  })
})
