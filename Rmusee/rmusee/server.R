#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(rAmCharts)
library(leaflet)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    output$histo <- renderAmCharts({
        
        # generate bins based on input$bins from ui.R
        col.annee = paste('total.',as.numeric(input$annee), sep = '')
        x  <- musee[musee$region == as.character(input$region),]
        x <- x %>% group_by(departement) %>% summarise(somme = sum(.data[[col.annee]]))
        
        # draw the histogram with the specified number of bins
        amBarplot(x = 'departement', y = 'somme', data = x, col = '#26C4EC',
               zoom = T, labelRotation = 45, main = paste("Nombre de visiteurs en", input$region,' en ', input$annee))
        
    })
    output$table <- renderDT({datatable(musee[musee$departement == input$dpt, c(7,11,19)],
                                        colnames = c('Nom', 'Ville', '2018') ,
                                        options = list(info = F,
                                                       paging = F,
                                                       searching = T,
                                                       stripeClasses = F, 
                                                       lengthChange = F,
                                                       scrollY = '300px',
                                                       scrollCollapse = T),
                                        rownames = F)})
    output$graph <- renderAmCharts({
        x <- musee %>% group_by(region) %>% summarise(sum(total.2013),
                                                      sum(total.2014),
                                                      sum(total.2015),
                                                      sum(total.2016),
                                                      sum(total.2017),
                                                      sum(total.2018))
        
        amPlot(as.character(c(2013:2018)),
               as.numeric(x[x$region == input$region,c(2,3,4,5,6,7)]), 
               type = 'l', sep = '', 
               zoom = T, 
               main = paste('Evolution de la fréquentation des musées en',input$region),
               ylab = 'Nombre de visites',
               xlab = 'Année',
               lwd = 2)})
    #Leaflet 
    selectmusee <- reactive({
        if(input$visite[2]==1000000){musee[musee$total.2018 >= input$visite[1],]}else{
            musee[musee$total.2018 >= input$visite[1] & musee$total.2018 <= input$visite[2],]
            
        }
    })
    
    ladresse <- eventReactive(input$button, {input$zoom})
    
    output$map <- renderLeaflet({
        leaflet(musee) %>% addTiles() %>%
            fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat)) %>% 
            addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions(),
                       clusterId = "cluster", popup = ~apply(musee, 1, fpopup),
                       icon = icons(iconUrl = "museum.svg",
                                    iconWidth = 20, iconHeight = 95), layerId = ~ref_musee)
    })
    
    observe({
        remove <- if(input$regioncarte!="") as.vector(t(musee[musee$region != input$regioncarte, "ref_musee"])) else ""
        if (nrow(selectmusee())!=0){
            leafletProxy("map", data = selectmusee()) %>% clearMarkerClusters() %>%
                addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions(),
                           clusterId = "cluster", popup = ~apply(selectmusee(), 1, fpopup),
                           icon = icons(iconUrl = "museum.svg",
                                        iconWidth = 20, iconHeight = 95), layerId = ~ref_musee) %>% 
                removeMarkerFromCluster(remove, 'cluster')
        }else{leafletProxy("map", data = musee) %>% clearMarkerClusters()}
        if(ladresse()!=""){
            geo = mygeocode(ladresse())
            leafletProxy("map", data = musee) %>% setView(geo[1],geo[2], 12)
        }
    })
})




