# Dashboard UI
library(shinydashboard)

shinyUI(
  dashboardPage(
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
        menuItem("ReadMe", tabName = "readme", icon=icon("mortar-board")),
        menuItem("Plot", tabName="plot", icon=icon("line-chart"),
          menuSubItem("Risk Measure", tabName = "rm", icon = icon("angle-right"), selected=TRUE),
          menuSubItem("Back Testing", tabName = "bt", icon = icon("angle-right")),
          menuSubItem("Calibration", tabName = "cali", icon = icon("angle-right"))),
        menuItem("Table", tabName = "table", icon=icon("table"),
          menuSubItem("Source data", tabName = "sourcet", icon = icon("angle-right")),
          menuSubItem("Calibration", tabName = "calit", icon = icon("angle-right")),
          menuSubItem("Measure output", tabName = "measuret", icon = icon("angle-right"))),
        menuItem("About", tabName = "about", icon = icon("question"))
      )
    ),

    # # # # # main panel
    dashboardBody(
      tabItems(
        # Page 2-1
        tabItem(tabName = "rm",
          fluidRow(
            column(width = 4, 
              tabBox(width = NULL,
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
                  selectInput("measure", "Measure:", 
                    c("VaR", "ES"), selected = NULL, multiple = TRUE, selectize = TRUE),
                  selectInput("method", "Methods:", c(
                    "Parametric - equally weighted", 
                    "Parametric - exponentially weighted",
                    "Historical Simulation", 
                    "Monte Carlo Simulation"), 
                  selected = NULL, multiple = TRUE, selectize = TRUE),
                  numericInput("npaths", label = h4("npaths"), value = 100)
                )
              )
            ),
            column(width = 8,
              box(width = NULL, plotOutput("plot",height="500px"), collapsible = TRUE,
                title = "Plot", status = "primary", solidHeader = TRUE)
            )
          )
        ),
        # Page 3-1
        tabItem(tabName = "sourcet",
          box(width = NULL, status = "primary", solidHeader = TRUE, title="Source",  
            downloadButton('download_source', 'Download'), br(), br(),
            DT::dataTableOutput("table1")
          )
        ),
        tabItem(tabName = "readme", includeMarkdown("../README.md")),
        # Page 3-2
        tabItem(tabName = "calit",
          box( width = NULL, status = "primary", solidHeader = TRUE, title="Calibration",
            downloadButton('download_cali', 'Download'), br(), br(),
            DT::dataTableOutput("table2")
          )
        ),
        # Page 3-3
        tabItem(tabName = "measuret",
          box(width = NULL, status = "primary", solidHeader = TRUE, title="Measurement", 
            downloadButton('download_measure', 'Download'), br(), br(),
            DT::dataTableOutput("table3")
          )
        )
      )
    )
  )
)

