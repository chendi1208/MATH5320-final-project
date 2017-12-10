library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "My Dashboard",
                  dropdownMenuOutput("messageMenu")),
  dashboardSidebar(),
  dashboardBody()
)

server <- function(input, output) {
  output$messageMenu <- renderMenu({
    # Code to generate each of the messageItems here, in a list. This assumes
    # that messageData is a data frame with two columns, 'from' and 'message'.
    msgs <- apply(messageData, 1, function(row) {
      messageItem(from = row[["from"]], message = row[["message"]])
    })
    
    # This is equivalent to calling:
    #   dropdownMenu(type="messages", msgs[[1]], msgs[[2]], ...)
    dropdownMenu(type = "messages", .list = msgs)
  })
}

shinyApp(ui, server)