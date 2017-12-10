# Dashboard UI
library(shinydashboard)

shinyUI(dashboardPage(
  skin = 'blue',

  # # # # # header & navbar
  dashboardHeader(
    title = 'Risk System',
    tags$li(
      class = 'dropdown',
      tags$a(href = 'mailto:cd2904@columbia.edu, yyy@columbia.edu', icon('envelope'))
    )
  ),

  # # # # # sidebar
  dashboardSidebar(
    sidebarMenu(id="tabs",
                menuItem("Plot", tabName="plot", icon=icon("line-chart"), selected=TRUE),
                menuItem("Table", tabName = "table", icon=icon("table")),
                menuItem("ReadMe", tabName = "readme", icon=icon("mortar-board")),
                menuItem("About", tabName = "about", icon = icon("question"))
    )
  ),

  # # # # # main panel
  dashboardBody(
    tabItems(
      tabItem(tabName = "plot",
              fluidRow(
                column(width = 4, 
                       tabBox( width = NULL,
                               tabPanel(h5("Portfolio"),
                                dateRangeInput("dates", label = h4("Investment period")),
                                fileInput("file", label = h4("File input"))
                                ),
                               tabPanel(h5("Parameters"),
                                sliderInput("windowLen", 
                                  label = h4("Historical window length (in years)"),
                                  min = 1, max = 10, value = 5),
                                sliderInput("horizonDays", label = h4("Horizon (in days)"),
                                  min = 1, max = 10, value = 5),
                                numericInput("text1", 
                                  label = h4("Probobility for calculating VaR"), value = 0.99),
                                numericInput("text2", 
                                  label = h4("Probobility for calculating ES"), value = 0.975),
                                selectInput("method", "Methods:", c(
                                  "Parametric - equally weighted", 
                                  "Parametric - exponentially weighted",
                                  "Historical Simulation", 
                                  "Monte Carlo Simulation"), 
                                selected = NULL, multiple = TRUE, selectize = TRUE),
                                selectInput("measure", "Measure:", 
                                  c("VaR", "ES"), selected = NULL, multiple = TRUE, selectize = TRUE)
                               )
                       )),
                column(width = 8,
                       box(  width = NULL, plotOutput("plot",height="500px"), collapsible = TRUE,
                             title = "Plot", status = "primary", solidHeader = TRUE)
                ))
      ),
      tabItem(tabName = "table",
              box( width = NULL, status = "primary", solidHeader = TRUE, title="Table",                
                   downloadButton('downloadTable', 'Download'),
                   br(),br(),
                   tableOutput("table")
              )
      )
    )
  )
))





