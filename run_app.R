# run Shiny app
library(shiny)
runApp(
	'dashboard', launch.browser = FALSE,
	host = '0.0.0.0', port = 5000,   # listen on all local network
)
