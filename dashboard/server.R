# Dashboard Server
library(ggplot2)
library(dygraphs)
library(rowr)
library(DT)
library(zoo)


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

    # customize csv
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

    ## for table and download
    output$table1 <- DT::renderDataTable({
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

    ## Calibration: parametric mu and sigma ##
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

    ## for table and download
    output$table2 <- DT::renderDataTable({
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
    ###########################################

    ## combined
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
      npaths <- input$npaths
      caliData <- caliData()

      combined <- data.frame(Date = ptf$Date)
      names <- c()
      for (i in method) {
        for (j in measure) {
          combined <- cbind.fill(combined, 
            cal_measure(s0, price, windowLen, horizonDays, i, j, npaths, VaRp, ESp, caliData), fill = NA)
          names <- c(names, paste(i, j))
        }
      }
      names(combined) <- c("Date", names)
      combined
      })
    ## for table and download
    output$table3 <- renderDataTable({
      df <- combined()
      for (i in names(df)[-1]) {
        df[,i] <- round(df[,i], 2)
      }
      DT::datatable(df, options = list(pageLength = 20))
    })
    output$download_measure <- downloadHandler(
        filename = "measure.csv",
        content = function(file) {write.csv(combined(), file, row.names = FALSE)}
    )

    # plot 1
    output$plot <- renderPlot({
      combined <- combined()
      plot <- ggplot(melt(combined, 
                  id.vars = "Date"), aes(x = as.Date(Date),
                                         y = value, group = variable)) + 
        geom_line(aes(color = variable)) + 
        scale_color_discrete('', labels = names(combined)[-1]) +
        labs(title = '', x = 'Time', y = 'Measure') +
        theme_bw() +
        theme(legend.position = c(0.8, 0.9), legend.background = element_blank())
      return(plot)
    })


    backt <- reactive({
      ptf <- ptfData()
      s0 <- ptf$Portfolio[dim(ptf)[1]]
      price <- ptf$Portfolio
      horizonDays <- input$horizonDays
      horizon <- horizonDays / 252
      nrows <- length(price)
      if (nrows < 252) {return(NULL)}

      ShareChange <- c(price[1:(nrows-horizonDays)] / price[(1+horizonDays):nrows], 
    rep(NA, horizonDays))

      combined <- combined()

      comparison <- data.frame(Date = ptf$Date)
      comparison <- cbind.fill(comparison, (s0 - ShareChange * s0), fill = NA)
      names(comparison) <- c("Date", "daysLoss")

      for (i in 2:(dim(combined)[2])) {
        measuredata <- combined[,i]
        exception <- c()
        for (i in 1:(nrows-252)) {
          exception <- c(exception, sum(comparison$daysLoss[i:(252+i-1)] >= measuredata[i]))
        }
        comparison <- cbind.fill(comparison, exception, fill = NA)
      }
      names(comparison) <- c("Date", "daysLoss", names(combined)[-1])
      comparison
    })
    output$bt1 <- renderPlot({
      comparison <- backt()
      bt <- ggplot(melt(comparison[,-2], 
                  id.vars = "Date"), aes(x = as.Date(Date),
                                         y = value, group = variable)) + 
        geom_line(aes(color = variable)) + 
        scale_color_discrete('', labels = names(comparison)[-c(1,2)]) +
        labs(title = '', x = 'Time', y = 'Exceptions') +
        theme_bw() +
        theme(legend.position = c(0.8, 0.9), legend.background = element_blank())
      return(bt)
    })
    output$excepTable <- renderDataTable({
      df <- comparison()
      for (i in names(df)[-1]) {
        df[,i] <- round(df[,i])
      }
      DT::datatable(df, options = list(pageLength = 20))
    })
    output$download_measure <- downloadHandler(
        filename = "exception.csv",
        content = function(file) {write.csv(comparison(), file, row.names = FALSE)}
    )


    # plot Calibration
    output$plotcali1 <- renderPlot({
      caliData <- caliData()[,1:3]
      plotcali1 <- ggplot(melt(caliData, id.vars = "Date"), 
        aes(x = as.Date(Date), y = value, group = variable)) + 
        geom_line(aes(color = variable)) + 
        scale_color_discrete('', labels = c(
          "Window Mean", 
          "Exponential Mean")) +
        labs(title = '', x = 'Time', y = 'Mean calibration') +
        theme_bw() +
        theme(legend.position = c(0.9, 0.9), legend.background = element_blank())
        return(plotcali1)
    })
    output$plotcali2 <- renderPlot({
      caliData <- caliData()[,c(1,4,5)]
      plotcali2 <- ggplot(melt(caliData, id.vars = "Date"), 
        aes(x = as.Date(Date), y = value, group = variable)) + 
        geom_line(aes(color = variable)) + 
        scale_color_discrete('', labels = c(
          "Window Standard Deviation", 
          "Exponential Standard Deviation")) +
        labs(title = '', x = 'Time', y = 'Standard deviation calibration') +
        theme_bw() +
        theme(legend.position = c(0.9, 0.9), legend.background = element_blank())
      return(plotcali2)
    })

    # # backtest plot
    # comparison <- reactive({
    #   ptf <- ptfData()
    #   s0 <- ptf$Portfolio[dim(ptf)[1]]
    #   price <- ptf$Portfolio
    #   horizon <- input$horizonDays / 252
    #   VaRp <- input$text1
    #   direction <- "Long"
    #   caliData <- caliData()
    #   WindowMean <- caliData$WindowMean
    #   ExponentialMean <- caliData$ExponentialMean
    #   WindowSD <- caliData$WindowSD
    #   ExponentialSD <- caliData$ExponentialSD


    #   winback <- winBacktest(price, s0, WindowMean, WindowSD, VaRp, horizon, direction)
    #   expback <- expBacktest(price, s0, ExponentialMean, ExponentialSD, VaRp, horizon, direction)

    #   comparison <- cbind.fill(ptf$Date, winback$exception, expback$exception, 
    #     winback$Loss, winback$gbmVaR, expback$gbmVaR, fill = NA)
    #   names(comparison) <- c("Date", "winexception", "expexception", "actloss", "winvar", "expvar")
    #   comparison
    # })
    # ## for table and download
    # output$table4 <- renderDataTable({
    #   df <- comparison()[,1:3]
    #   for (i in names(df)[-1]) {
    #     df[,i] <- round(df[,i])
    #   }
    #   names(df) <- c("Date", "Window Exception", "Exponential Equivalent Exception")
    #   DT::datatable(df, options = list(pageLength = 20))
    # })
    # output$download_ex <- downloadHandler(
    #     filename = "exception_loss_var.csv",
    #     content = function(file) {write.csv(comparison(), file, row.names = FALSE)}
    # )

    # output$bt1 <- renderPlot({
    #   df <- comparison()[,1:3]
    #   bt1 <- ggplot(melt(df, id.vars = "Date"), 
    #     aes(x = as.Date(Date), y = value, group = variable)) + 
    #     geom_line(aes(color = variable)) + 
    #     scale_color_discrete('', labels = c(
    #       "Window Exception", 
    #       "Exponential Equivalent Exception")) +
    #     labs(title = paste("(Horizon =", input$horizonDays, "days, Window =",
    #   input$windowLen, "years) Exceptions Per Year"), x = 'Time', y = 'Number') +
    #     theme_bw() +
    #     theme(legend.position = c(0.9, 0.9), legend.background = element_blank())
    #     return(bt1)
    # })
    # output$bt2 <- renderPlot({
    #   df <- comparison()[,c(1,4,5,6)]
    #   bt2 <- ggplot(melt(df, id.vars = "Date"), 
    #     aes(x = as.Date(Date), y = value, group = variable)) + 
    #     geom_line(aes(color = variable)) + 
    #     scale_color_discrete('', labels = c(
    #       "Losses",
    #       "Window VaR", 
    #       "Exponential Equivalent VaR")) +
    #     labs(title = paste("(Horizon =", input$horizonDays, 
    #   "days,", input$windowLen, "years) VaR vs Realized Losses"), x = 'Time', y = 'Measure') +
    #     theme_bw() +
    #     theme(legend.position = c(0.9, 0.9), legend.background = element_blank())
    #     return(bt2)
    # })

})
