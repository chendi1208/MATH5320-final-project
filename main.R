library(ggplot2)
library(reshape2)
library(quantmod)

source("portfolio.R")
source("winEstGBM.R")
source("gbmVaR.R")
source("gbmES.R")
portfolio <- data.frame(as.Date(components[, 1]))
winEstGBM_2yr <- winEstGBM(components$Portfolio, 252*2)
winEstGBM_5yr <- winEstGBM(components$Portfolio, 252*5)
winEstGBM_10yr <- winEstGBM(components$Portfolio, 252*10)
portfolio <- data.frame(as.Date(components[, 1]), 
                        gbmVaR(s0, 5/252, 0.99, winEstGBM_2yr$mu, winEstGBM_2yr$sigma),
                        gbmVaR(s0, 5/252, 0.99, winEstGBM_5yr$mu, winEstGBM_5yr$sigma),
                        gbmES(s0, 5/252, 0.975, winEstGBM_2yr$mu, winEstGBM_2yr$sigma),
                        gbmES(s0, 5/252, 0.975, winEstGBM_5yr$mu, winEstGBM_5yr$sigma))


ggplot(melt(portfolio[1:(dim(portfolio)[1]-252*5),], 
            id.vars = "as.Date.components...1.."), 
       aes(x=as.Date(as.Date.components...1..), y = value, group = variable)) + 
  geom_line(aes(color=variable)) + 
  scale_color_discrete('', labels = c('2 yr window VaR', '5 yr window VaR', 
                                      '2 yr window ES', '5 yr window ES')) +
  labs(title = 'VaR and ES with lognormal assumption, windowed data', x = '', y = '') +
  theme_bw()
  
