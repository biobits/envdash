
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinydashboard)

ui<- dashboardPage(
  
  dashboardHeader(title = "EnvDash"),
  
  dashboardSidebar(
    uiOutput("choose_loc"),
    sliderInput("time_adjust", label = "Zeitraum (Tage)",
                               min = 1, max = 60, value = 1, step = 1)
  ),
  dashboardBody(
    fluidRow(
      valueBoxOutput("dateBox"),
      valueBoxOutput("temp1Box"),
      valueBoxOutput("hum1Box")
      
    ),
    fluidRow(
      #column(width = 12,
             box(plotOutput("plot_temp1", height = 450),width = 12)
      #)
      
    )
  )
)