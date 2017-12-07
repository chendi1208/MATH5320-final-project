# Dashboard UI
library(shinydashboard)


shinyUI(dashboardPage(
  skin = 'blue',

  # # # # # header & navbar
  dashboardHeader(
    title = 'title',
    tags$li(
      class = 'dropdown',
      tags$a(href = 'mailto:xxx@columbia.edu, yyy@columbia.edu', icon('envelope'))
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
      submitButton(text = "Apply Changes"),
      tableOutput('test')
    ),

    tabItem(tabName = 'about-who',
      h1('Test who')
    )
  ))
))
