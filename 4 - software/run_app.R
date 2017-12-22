# run Shiny app
library(shiny)
runApp(
	'dashboard', launch.browser = FALSE,
	host = '0.0.0.0', port = 5000,   # listen on all local network
)

# in order to run in this way, first make sure you set your current workind directory
# the one of "software"
# e.g. setwd("~/Documents/Columbia/Courseworks/MATH 5320 Financial Risk Management and Regulation/project/software")
# Then type "http://0.0.0.0:5000" in your own Chrome or other Browser