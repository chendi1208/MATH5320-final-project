# Dashboard Server
library(ggplot2)
library(dygraphs)
library(rowr)
library(DT)
library(zoo)
library(reshape2)


# user defined modules
# source('../model/portfolio.R')
source("../model/cal_measure.R")


# stock_prices <- get_all_prices()

# server function
shinyServer(
  function(input, output) {
    # Datasets
    ## ptfData
    # ptfData <- reactive({
    #   position <- read.csv(input$file$datapath)
    #   # position <- data.frame(ticker = 'MCD', amount = 100)
    #   date_range <- c(as.Date(input$dates[1]), as.Date(input$dates[2]))
    #   prices <- format_prices(stock_prices, position, date_range)
    
    #   # handle exception if no available data to form portfolio
    #   if (nrow(prices) == 0) {
    #     return(data.frame())
    #   }
    
    #   ptf <- format_portfolio(prices, position, date_range)
    #   ptf
    # })

    # REACTIVES
    # ptfData: customize csv
    ptfData <- reactive({
      prices <- read.csv(input$portfolio$datapath)
      investment <- read.csv(input$investment$datapath)

      prices$Date <- as.Date(prices$Date, "%m/%d/%y")
      date_range <- c(as.Date(input$dates[1]), as.Date(input$dates[2]))
      start_date <- date_range[1]
      end_date <- date_range[2]
      prices <- prices[(prices$Date >= start_date) & (prices$Date <= end_date), ]
      init_prices <- prices[dim(prices)[1], ][-1]

      shares <- unlist(investment$amount / init_prices)
      portfolio <- 0
      for (i in 1:length(shares)) {
        portfolio <- portfolio + shares[i] * prices[, i+1]
      }
      prices$Portfolio <- portfolio
      prices$Date <- format(prices$Date)
      return(prices)
      })

    # caliData: calibration of parametric mu and sigma 
    caliData <- reactive({
      ptf <- ptfData()
      price <- ptf$Portfolio
      windowLen <- input$windowLen
      windowLenDays <- windowLen * 252
      horizonDays <- input$horizonDays

      wincal <- window_calibrate(price, windowLen, horizonDays)
      expcal <- weighted_calibrate(price, windowLenDays, horizonDays)

      caliData <- cbind.fill(ptf$Date, wincal$mu, expcal$mu,
        wincal$sigma, expcal$sigma, fill = NA)
      names(caliData) <- c("Date", "WindowMean", "ExponentialMean", 
        "WindowSD", "ExponentialSD")
      caliData
      })

    # measData: gather all measures
    measData <- reactive({
      ptf <- ptfData()
      s0 <- ptf$Portfolio[dim(ptf)[1]]
      price <- ptf$Portfolio
      windowLen <- input$windowLen
      horizonDays <- input$horizonDays
      VaRp <- input$text1
      ESp <- input$text2
      method <- input$method
      measure <- input$measure
      npaths <- input$npaths
      caliData <- caliData()

      measData <- data.frame(Date = ptf$Date)
      names <- c()
      for (i in method) {
        for (j in measure) {
          measData <- cbind.fill(measData, 
            cal_measure(s0, price, windowLen, horizonDays, i, j, npaths, VaRp, ESp, caliData), fill = NA)
          names <- c(names, paste(i, j))
        }
      }
      names(measData) <- c("Date", names)
      measData
      })

    # excData: backtesting exceptions
    excData <- reactive({
      ptf <- ptfData()
      s0 <- ptf$Portfolio[dim(ptf)[1]]
      price <- ptf$Portfolio
      horizonDays <- input$horizonDays
      horizon <- horizonDays / 252
      nrows <- length(price)
      if (nrows < 252) {return(NULL)}

      ShareChange <- c(price[1:(nrows-horizonDays)] / price[(1+horizonDays):nrows], 
    rep(NA, horizonDays))

      measData <- measData()

      comparison <- data.frame(Date = ptf$Date)
      comparison <- cbind.fill(comparison, (s0 - ShareChange * s0), fill = NA)
      names(comparison) <- c("Date", "daysLoss")

      for (i in 2:(dim(measData)[2])) {
        measuredata <- measData[,i]
        exception <- c()
        for (i in 1:(nrows-252)) {
          exception <- c(exception, sum(comparison$daysLoss[i:(252+i-1)] >= measuredata[i]))
        }
        comparison <- cbind.fill(comparison, exception, fill = NA)
      }
      names(comparison) <- c("Date", "daysLoss", names(measData)[-1])
      comparison
    })

    # TABLES & DOWNLOADS
    # ptfData
    output$ptfDatatable <- DT::renderDataTable({
      df <- ptfData()
      for (i in names(df)[-1]) {
        df[,i] <- round(df[,i], 2)
      }
      DT::datatable(df, options = list(pageLength = 20))
    })
    output$download_source <- downloadHandler(
        filename = "source.csv",
        content = function(file) {write.csv(ptfData(), file, row.names = FALSE)}
    )

    # caliData
    output$caliDatatable <- DT::renderDataTable({
      df <- caliData()
      names(df) <- c("Date", "Window Mean", "Exponential Mean",
        "Window Standard Deviation", "Exponential Standard Deviation")
      for (i in names(df)[-1]) {
        df[,i] <- round(df[,i], 2)
      }
      DT::datatable(df, options = list(pageLength = 20))
    })

    output$download_cali <- downloadHandler(
        filename = "calibration.csv",
        content = function(file) {write.csv(caliData(), file, row.names = FALSE)}
    )

    # measData
    output$measDatatable <- renderDataTable({
      df <- measData()
      for (i in names(df)[-1]) {
        df[,i] <- round(df[,i], 2)
      }
      DT::datatable(df, options = list(pageLength = 20))
    })
    output$download_measure <- downloadHandler(
        filename = "measure.csv",
        content = function(file) {write.csv(measData(), file, row.names = FALSE)}
    )

    # excData
    output$excDatatable <- renderDataTable({
      df <- excData()
      for (i in names(df)[-1]) {
        df[,i] <- round(df[,i])
      }
      DT::datatable(df, options = list(pageLength = 20))
    })
    output$download_ex <- downloadHandler(
        filename = "exception.csv",
        content = function(file) {write.csv(excData(), file, row.names = FALSE)}
    )

    # PLOTS
    # caliData
    output$caliDataplot1 <- renderPlot({
      caliData <- caliData()[,1:3]
      # remove rows that have all NAs
      caliData <- caliData[!rowSums(!is.na(caliData[,-1])) == 0,]
      caliDataplot1 <- ggplot(melt(caliData, id.vars = "Date"), 
        aes(x = as.Date(Date), y = value, group = variable)) + 
        geom_line(aes(color = variable)) + 
        scale_color_discrete('', labels = c(
          "Window Mean", 
          "Exponential Mean")) +
        labs(title = '', x = 'Time', y = 'Mean calibration') +
        theme_bw() +
        theme(legend.position = c(0.9, 0.9), legend.background = element_blank())
        return(caliDataplot1)
    })
    output$caliDataplot2 <- renderPlot({
      caliData <- caliData()[,c(1,4,5)]
      # remove rows that have all NAs
      caliData <- caliData[!rowSums(!is.na(caliData[,-1])) == 0,]
      caliDataplot2 <- ggplot(melt(caliData, id.vars = "Date"), 
        aes(x = as.Date(Date), y = value, group = variable)) + 
        geom_line(aes(color = variable)) + 
        scale_color_discrete('', labels = c(
          "Window Standard Deviation", 
          "Exponential Standard Deviation")) +
        labs(title = '', x = 'Time', y = 'Standard deviation calibration') +
        theme_bw() +
        theme(legend.position = c(0.9, 0.9), legend.background = element_blank())
      return(caliDataplot2)
    })

    # measData
    output$measDataplot <- renderPlot({
      measData <- measData()
      # remove rows that have all NAs or NULLs
      measData <- measData[!rowSums(!is.na(measData[,-1])) == 0,]
      measDataplot <- ggplot(melt(measData, 
                  id.vars = "Date"), aes(x = as.Date(Date),
                                         y = value, group = variable)) + 
        geom_line(aes(color = variable)) + 
        scale_color_discrete('', labels = names(measData)[-1]) +
        labs(title = '', x = 'Time', y = 'Measure') +
        theme_bw() +
        theme(legend.position = c(0.8, 0.9), legend.background = element_blank())
      return(measDataplot)
    })

    # excData
    output$excDataplot1 <- renderPlot({
      comparison <- excData()
      # remove rows that have all NAs
      comparison <- comparison[!rowSums(!is.na(comparison[,-c(1,2)])) == 0,]

      excDataplot1 <- ggplot(melt(comparison[,-2], 
                  id.vars = "Date"), aes(x = as.Date(Date),
                                         y = value, group = variable)) + 
        geom_line(aes(color = variable)) + 
        scale_color_discrete('', labels = names(comparison)[-c(1,2)]) +
        labs(title = '', x = 'Time', y = 'Exceptions') +
        theme_bw() +
        theme(legend.position = c(0.8, 0.9), legend.background = element_blank())
      return(excDataplot1)
    })   
})
