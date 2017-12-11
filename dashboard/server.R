# Dashboard Server
library(ggplot2)
library(dygraphs)
library(rowr)
library(DT)


# user defined modules
source('../model/portfolio.R')
source("../model/cal_measure.R")


stock_prices <- get_all_prices()

# server function
shinyServer(function(input, output) {
  
  ptfData <- reactive({
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

  output$table1 <- DT::renderDataTable({
    DT::datatable(ptfData(), options = list(pageLength = 20))
  })

  combined <- reactive({
    ptf <- ptfData()
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
    combined
    })
  
  output$plot <- renderPlot({
    combined <- combined()
    fig <- ggplot(melt(combined, 
                id.vars = "Date"), aes(x = as.Date(Date),
                                       y = value, group = variable)) + 
      geom_line(aes(color = variable)) + 
      scale_color_discrete('', labels = names(combined)[-1]) +
      labs(title = '', x = 'Time', y = 'Measure') +
      theme_bw() +
      theme(legend.position = c(0.8, 0.9), legend.background = element_blank())
    return(fig)
  })

  output$table3 <- renderDataTable({
    df <- combined()
    for (i in names(df)[-1]) {
      df[,i] <- round(df[,i])
    }
    DT::datatable(df, options = list(pageLength = 20))
  })

  # output$downloadTable <- downloadHandler(
  #   filename = "table.csv",
  #   content = function(file) {
  #     write.csv(rr(), file)
  #   }
  # )
})



