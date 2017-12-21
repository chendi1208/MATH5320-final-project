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
        tags$a(href = 'mailto:cd2904@columbia.edu, zs2331@columbia.edu', icon('envelope'))
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
          menuSubItem("Measure output", tabName = "measuret", icon = icon("angle-right")),
          menuSubItem("Exceptions", tabName = "exct", icon = icon("angle-right"))),
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
                  dateRangeInput("dates", start = "1992-09-24", label = h4("Investment period")),
                  hr(),
                  checkboxInput("checkfile", 
                    label = "Choice 1: upload file with close prices and volatility", value = TRUE),
                  fileInput("portfolio", h4("Position input")),
                  fileInput("investment", h4("Initial investment input")),
                  hr(),
                  checkboxInput("checkticker", 
                    label = "Choice 2: upload ticker name (available for stock only portfolio)", 
                    value = FALSE),
                  fileInput("tickerfile", h4("Ticker and investment input"))
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
                    c("VaR", "ES"), selected = "VaR", multiple = TRUE, selectize = TRUE),
                  selectInput("method", "Methods:", c(
                    "Parametric - equally weighted", 
                    "Parametric - exponentially weighted",
                    "Historical Simulation", 
                    "Monte Carlo Simulation"), 
                  selected = "Parametric - equally weighted", multiple = TRUE, selectize = TRUE),
                  numericInput("npaths", label = h4("npaths"), value = 300),
                  submitButton("Submit")
                )
              )
            ),
            column(width = 8,
              box(width = NULL, plotOutput("measDataplot",height="500px"), collapsible = TRUE,
                title = "Plot", status = "primary", solidHeader = TRUE),
              p("The following", strong("hints"), "may be helpful if you encounter the error message:"),
              p(span("Error: 'file' must be a character string or connection", style = "color:red"),
                ": Check if input files are not blank, 
                and the format is the same as the sample input."),
              p(span("Error: 'names' attribute [1] must be the same length as the vector [0]", 
                style = "color:red"),
                ": The effective investment period must be greater than 0 day, 
                so change the investment period to see if it works."),
              p(span("Error: object 'variable' not found", 
                style = "color:red"),
                ": Check that method and measure input are not blank."),
              p(span("No plot output: ", 
                style = "color:red"),
                "Check if you have click the ", strong("submit "), "button.")
            )
          )
        ),
        # Page 2-3
        tabItem(tabName = "cali",
          box(width = NULL, plotOutput("caliDataplot1",height="500px"), collapsible = TRUE,
            title = "Mean Calibration Plot", status = "primary", solidHeader = TRUE),
          box(width = NULL, plotOutput("caliDataplot2",height="500px"), collapsible = TRUE,
            title = "Standard Calibration Plot", status = "primary", solidHeader = TRUE)
        ), 
        # Page 2-2
        tabItem(tabName = "bt",
          box(width = NULL, plotOutput("excDataplot1",height="500px"), collapsible = TRUE,
            title = "Exceptions Per Year", status = "primary", solidHeader = TRUE),
          box(width = NULL, plotOutput("excDataplot2",height="500px"), collapsible = TRUE,
            title = "VaR vs Realized Losses", status = "primary", solidHeader = TRUE)
        ), 
        # Page 3-1
        tabItem(tabName = "sourcet",
          box(width = NULL, status = "primary", solidHeader = TRUE, title="Source",  
            downloadButton('download_source', 'Download'), br(), br(),
            DT::dataTableOutput("ptfDatatable")
          )
        ),
        tabItem(tabName = "readme", includeMarkdown("../README.md")),
        # Page 3-2
        tabItem(tabName = "calit",
          box( width = NULL, status = "primary", solidHeader = TRUE, title="Calibration",
            downloadButton('download_cali', 'Download'), br(), br(),
            DT::dataTableOutput("caliDatatable")
          )
        ),
        # Page 3-3
        tabItem(tabName = "measuret",
          box(width = NULL, status = "primary", solidHeader = TRUE, title="Measurement", 
            downloadButton('download_measure', 'Download'), br(), br(),
            DT::dataTableOutput("measDatatable")
          )
        ),
        # Page 3-4
        tabItem(tabName = "exct",
          box(width = NULL, status = "primary", solidHeader = TRUE, title="Exceptions Per Year", 
            downloadButton('download_ex', 'Download'), br(), br(),
            DT::dataTableOutput("excDatatable")
          )
        )
      )
    )
  )
)
