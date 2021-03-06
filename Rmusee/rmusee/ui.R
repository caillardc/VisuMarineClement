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
library(DT)
library(rAmCharts)
library(shinyWidgets)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(bootstrapPage(
  navbarPage(
    title = img(src = 'musee.jpg', height ='40px', align ="right", alt ='image'),
    tabPanel(title = 'Présentation',
             fluidRow(
               tags$div(class = 'structure',
                        tags$div(class = 'class1',
                                 tags$h1("Bienvenue sur notre application shiny"),
                                 tags$p("Elle nous permet de visualiser des données sur les musées de France que nous avons receuillies dans une base.")
                        ),
                        tags$div(class = 'class2',
                                 tags$h2('Représentation carthographique'),
                                 tags$p('Chaque musée est représenté sur une carte interactive.')
                        ),
                        tags$div(class = 'class3',
                                 tags$h2("Représentation graphique"),
                                 tags$p("Nous avons également représenté les données avec des graphiques. 
                                      Pour chaque région et département nous représentons la fréquentation dans les musées."),
                                 img(src = 'graphe.PNG', height = '340px'))
                        
                        
               )
               
             )),
    tabPanel(title = 'Cartographie',
             'here carte des musées de France'),
    tabPanel(title = 'Statistique descriptive',
             fluidRow(column(width = 4,
                             wellPanel(style = "background-color: #fff; border-color: #2c3e50",
                                       sliderInput("annee",
                                                   "Année :",
                                                   min = 2013,
                                                   max = 2018,
                                                   value = 2018,
                                                   step = 1,
                                                   sep = ''),
                                       selectInput(inputId = "region", 
                                                   label = "Sélectionner une région :", 
                                                   choices = musee %>% group_by(region) %>% summarise(region = unique(region)))
                             ),
                             fluidRow(column(12,
                                             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 525px",
                                                       chooseSliderSkin('Flat', color = '#26C4EC'),
                                                       selectInput(inputId = "dpt", 
                                                                   label = "Sélectionner un département :", 
                                                                   choices = musee %>% group_by(departement) %>% summarise(departement = unique(departement)),
                                                                   selected = 'PARIS'),
                                                       DTOutput(outputId = "table")
                                             )))
             ),
             column(8,
                    amChartsOutput(outputId = 'histo'),
                    amChartsOutput(outputId = 'graph'))),
    )
    
    
    
  )
)

)
