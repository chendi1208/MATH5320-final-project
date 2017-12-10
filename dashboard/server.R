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
    method <- input$method
    VaRp <- input$text1
    ESp <- input$text2


    

    source("../model/expEstGBM.R")
    
  
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

#####################

shinyServer(function(input, output){
  r <- reactive({ 
    p <- c(ka=input$ka, Tk0=input$Tk0, alpha=input$alpha, 
           F0=input$F0, Vm=input$Vm,  Km=input$Km, V=1, k=input$k)
    
    t.value=seq(0,24,length.out=241)
    out <- list(name=c("C1", "C2", "C3", "C4", "C5", "C6"), time=t.value)
    
    t1=input$tfd
    t2=input$ii*(input$nd-1)+t1
    if (t2>=t1){
      t.dose=seq(t1,t2,by=input$ii)
      adm <- list(time=t.dose, amount=input$amt)
    }else{
      adm <- list(time=t1, amount=0)
    }
    #----------------------------------------------------  
    res <- simulx(model     = "absorptionModel.txt", 
                  parameter = p, 
                  output    = out, 
                  treatment = adm)
    #----------------------------------------------------    
    return(res)
  })
   
  gg_color_hue <- function(n) {
    hues = seq(15, 375, length=n+1)
    hcl(h=hues, l=65, c=100)[1:n]}

  vc=gg_color_hue(6)[c(1,4,2,3,6,5)]
  names(vc)=letters[1:6]
  lc <- c("first order", "zero order", "alpha order",
          "sequential 0-1", "simultaneous 0-1", "saturated")
  names(vc)=letters[1:6]
    
  output$plot <- renderPlot({
    r <- r()
    npl <- 0
    vdisp <- rep(FALSE,6)
    pl=ggplotmlx()
    if (input$first==TRUE){
      pl=pl + geom_line(data=r$C1, aes(x=time, y=C1, colour="a"), size=1)  
      vdisp[1] <- TRUE}
    if (input$zero==TRUE){
      pl=pl + geom_line(data=r$C2, aes(x=time, y=C2, colour="b"), size=1) 
      vdisp[2] <- TRUE}
    if (input$al==TRUE){
      pl=pl + geom_line(data=r$C3, aes(x=time, y=C3, colour="c"), size=1)  
      vdisp[3] <- TRUE}
    if (input$sequential==TRUE){
      pl=pl + geom_line(data=r$C4, aes(x=time, y=C4, colour="d"), size=1)  
      vdisp[4] <- TRUE}
    if (input$mixed==TRUE){
      pl=pl + geom_line(data=r$C5, aes(x=time, y=C5, colour="e"), size=1)  
      vdisp[5] <- TRUE}
    if (input$saturated==TRUE){
      pl=pl + geom_line(data=r$C6, aes(x=time, y=C6, colour="f"), size=1)  
      vdisp[6] <- TRUE}
    pl <- pl + ylab("Amount = Concentration (V=1)") 
    pl <- pl + scale_colour_manual(values=vc[vdisp], labels=lc[vdisp])
    if (input$legend==TRUE){
      pl <- pl + theme(legend.position=c(.65, 0.95), legend.justification=c(0,1), legend.title=element_blank())
    }else{
      pl <- pl + theme(legend.position="none")
    }   
    if (input$nd==1)
      pl <- pl +ylim(c(0,input$amt))
    print(pl)
  }) 
    
  rr <- reactive({
    r <- r()
  rr <- r[[1]]
  for (k in (2:6))
    rr <- merge(rr, r[[k]])
  return(rr)
  })
  
  output$table <- renderTable({ 
    rr()
  })
  
  output$downloadTable <- downloadHandler(
    filename = "table.csv",
    content = function(file) {
      write.csv(rr(), file)
    }
  )
  
})