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
library(shinythemes)


# Define UI for application that draws a histogram
shinyUI(bootstrapPage(
  tags$head(HTML("<title>Musée en France</title><link rel='icon' type='image/gif/png' href='musee.jpg'>")),
  theme = shinytheme("sandstone"),
  tags$style(type = "text/css", ".navbar-brand{padding: 12px 10px;}"),
  navbarPage(
    title = img(src = 'musee.jpg', height ='40px', align ="right", alt ='image'),
    tabPanel(title = 'Présentation',  includeCSS("www/presentation.css"),
             fluidRow(
               div(class="structure",
                   div(class = "container",
                       
                       div(id = 'welcome',
                           tags$h1("Bienvenue sur notre application shiny"),
                           tags$p("Elle nous permet de visualiser des données sur les musées de France que nous avons receuillies dans une base.")
                       )),
                   div(class = "container", id ="carte",
                       div(class = "bloctxt", div(id = 'cartetxt',
                                                  h2('Représentation cartographique'),
                                                  p('Chaque musée est représenté sur une carte interactive.'))),
                       div(class= "img", img(src = 'carte.PNG'))
                   ),
                   div(class = "container",
                       div(class="img", img(src = 'graphe.PNG')),
                       div(id = 'laimg',
                           h2("Représentation graphique"),
                           p("Nous avons également représenté les données avec des graphiques. 
                                      Pour chaque région et département nous représentons la fréquentation dans les musées."))
                       ),
                   
                   div(class="footer",
                       p("© Application shiny réalisée par Marine Hamelin et Clément Caillard")
                      )
               ))),
    tabPanel(title = 'Cartographie',
             div(class = 'outer',  
                 tags$style(type = "text/css", "div.outer {position: fixed; top: 55px; left: 0; right: 0; bottom: 0;}"),
                 tags$style(type = "text/css", "#controls {background-color: rgba(255,255,255,0.8); padding: 20px; border-radius: 8px}"),
                 tags$style(type = "text/css", "label {font-weight: 400;}"),
                 
                 leafletOutput(outputId = "map", width="100%", height="100%"),
                 absolutePanel(id = "controls", bottom = 100, right = 55, width = 250, fixed=TRUE, height = "auto",
                               sliderInput("visite", "Visiteurs en 2018 de 0 à plus de 1M", min(musee$total.2018), 1000000,
                                           value = c(min(musee$total.2018), 1000000), step = 100),
                               textInput('zoom', "Zoom sur une adresse", value = ""),
                               actionButton("button", "Recherche"),
                               p(""),
                               selectInput(inputId = "regioncarte", 
                                           label = "Sélectionner une région :", 
                                           choices = c('', musee %>% group_by(region) %>% summarise(region = unique(region))))
                               
                 )
             )
    ),
    tabPanel(title = 'Graphiques',
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