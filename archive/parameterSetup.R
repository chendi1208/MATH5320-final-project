# Estimation parameters
windowLen <- 5
horizonDays <- 5
windowLenDays <- windowLen * 252

# Set up for computing VaR & ES
horizon <- horizonDays / 252
VaRp <- 0.99
ESp <- 0.975
