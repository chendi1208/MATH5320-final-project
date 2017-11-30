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
        menuItem('What', icon = icon('caret-right'), tabName = 'about-what'),
        menuItem('How', icon = icon('caret-right'), tabName = 'about-how'),
        menuItem('Who', icon = icon('caret-right'), tabName = 'about-who',
          menuItem('What', icon = icon('caret-right'), tabName = 'about-what'),
          menuItem('What', icon = icon('caret-right'), tabName = 'about-what')))
    ),
    sidebarMenu(
      menuItem('About', icon = icon('question-circle'),
        menuItem('What', icon = icon('caret-right'), tabName = 'about-what'),
        menuItem('How', icon = icon('caret-right'), tabName = 'about-how'),
        menuItem('Who', icon = icon('caret-right'), tabName = 'about-who',
          menuItem('What', icon = icon('caret-right'), tabName = 'about-what'),
          menuItem('What', icon = icon('caret-right'), tabName = 'about-what')))
    )
  ),

  # # # # # main panel
  dashboardBody(
    tableOutput('test')),
))
