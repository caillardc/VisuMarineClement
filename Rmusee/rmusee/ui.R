#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  navbarPage(
    title = img(src = 'musee.jpg', height ='40px', align ="right", alt ='image'),
    tabPanel(title = 'Présentation',
             fluidRow(
               column(3),
               column(6,
                      HTML("
                        <h1> Première section de la présentation</h1>")
                      
               )
               
             )),
    tabPanel(title = 'Cartographie',
             'here carte des musée de France'),
    tabPanel(title = 'Statistique descriptive',
             fluidRow(column(width = 4,
                    wellPanel(style = "background-color: #fff; border-color: #2c3e50;",
                              sliderInput("annee",
                                          "Années :",
                                          min = 2013,
                                          max = 2018,
                                          value = 2018,
                                          step = 1,
                                          sep = ''),
                              selectInput(inputId = "region", 
                                          label = "Sélectionner une région :", 
                                          choices = musee %>% group_by(region) %>% summarise(region = unique(region)))
                    )),
             column(6,
                    plotOutput(outputId = 'histo'))),
             fluidRow(column(4,
                    wellPanel(style = "background-color: #fff; border-color: #2c3e50;",
                              selectInput(inputId = "département", 
                                          label = "Sélectionner un département :", 
                                          choices = musee %>% group_by(departement) %>% summarise(departement = unique(departement)))
                    )
             ))
             
             
             
    )
  )
  
))
