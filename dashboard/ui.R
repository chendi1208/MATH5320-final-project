# Dashboard UI
library(shinydashboard)


shinyUI(dashboardPage(
  skin = 'blue',

  # # # # # header & navbar
  dashboardHeader(
    title = 'Risk Calculation System',
    tags$li(
      class = 'dropdown',
      tags$a(href = 'mailto:cd2904@columbia.edu, yyy@columbia.edu', icon('envelope'))
    )
  ),

  # # # # # sidebar
  dashboardSidebar(
    sidebarMenu(
      menuItem('About', icon = icon('question-circle'),
        menuItem('How', icon = icon('caret-right'), tabName = 'about-how'),
        menuItem('Who', icon = icon('caret-right'), tabName = 'about-who'))
    ),
    sidebarMenu(
      menuItem('About', icon = icon('question-circle'),
        menuItem('What', icon = icon('caret-right'), tabName = 'about-test'),
        menuItem('How', icon = icon('caret-right'), tabName = 'about-test'),
        menuItem('Who', icon = icon('caret-right'), tabName = 'about-test',
          menuItem('What', icon = icon('caret-right'), tabName = 'about-test'),
          menuItem('What', icon = icon('caret-right'), tabName = 'about-test')))
    )
  ),

  # # # # # main panel
  dashboardBody(tabItems(
    tabItem(tabName = 'about-how',
      h1('Test how'),
      dateRangeInput("dates", label = h4("Investment period")),
      fileInput("file", label = h4("File input")),
      # submitButton(text = "Apply Changes"),
      #tableOutput('test'),
      br(),
      br(),
      h3("Select your prefered methods and horizon"),
      br(),
      fluidRow(
        column(6, sliderInput("slider1", label = h4("Historical window length (in years)"), 
        min = 1, max = 10, value = 5)),
        column(6, sliderInput("slider2", label = h4("Horizon (in days)"), 
        min = 1, max = 10, value = 5))
        ),
      fluidRow(
        column(6, textInput("text", label = h4("Probobility for calculating VaR"), value = "0.99")),
        column(6, textInput("text", label = h4("Probobility for calculating ES"), value = "0.975"))
        ),
      br(),
      h3("Method"),
      fluidRow(
        column(2, selectInput("variable", "Variable:", 
          c("VaR", "ES"), selected = NULL, multiple = TRUE, selectize = TRUE)),

        column(10, selectInput("variable", "Variable:", c(
        "Parametric  - equally weighted", 
        "Parametric  - exponentially weighted",
        "Historical Simulation", 
        "Monte Carlo Simulation"), selected = NULL, multiple = TRUE, selectize = TRUE, width = "80%"))
        ),



      plotOutput("plots")
    ),

    tabItem(tabName = 'about-who',
      h1('Test who')
    )
  ))
))
