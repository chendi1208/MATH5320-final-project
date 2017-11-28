# run Shiny app
library(shiny)
runApp(
	'dashboard', launch.browser = FALSE,
	host = '127.0.0.1', port = 5000,   # listen on all local network
)
