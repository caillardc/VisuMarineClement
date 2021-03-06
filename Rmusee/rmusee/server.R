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
        print(col.annee)
        x  <- musee[musee$region == as.character(input$region),col.annee]
        # draw the histogram with the specified number of bins
        amHist(x[[col.annee]], freq = T, col = '#26C4EC', 
               main = paste('Histogramme de la fréquentation des musées en',input$annee), xlab = 'Nombre de visites',
               zoom = T)
        
    })
    output$table <- renderDT({datatable(musee[musee$departement == input$dpt, c(7,11,19)],
                                        options = list(info = F,
                                                       paging = F,
                                                       searching = T,
                                                       stripeClasses = F, 
                                                       lengthChange = F,
                                                       scrollY = '300px',
                                                       scrollCollapse = T),
                                        rownames = F)})
    output$graph <- renderAmCharts({
        x <- musee %>% group_by(region) %>% summarise(mean(total.2013),
                                                      mean(total.2014),
                                                      mean(total.2015),
                                                      mean(total.2016),
                                                      mean(total.2017),
                                                      mean(total.2018))
        
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
    
    output$map <- renderLeaflet({
        leaflet(musee) %>% addTiles() %>%
            fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat)) %>% 
            addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions(),
                       clusterId = "cluster", popup = ~apply(musee, 1, fpopup),
                       icon = icons(iconUrl = "https://www.flaticon.com/svg/vstatic/svg/1825/1825814.svg?token=exp=1615029914~hmac=c363db1013f7d8ccd0c2d96a62886711",
                                    iconWidth = 20, iconHeight = 95), layerId = ~ref_musee)
    })
    
    observe({
        remove <- if(input$regioncarte!="") as.vector(t(musee[musee$region != input$regioncarte, "ref_musee"])) else ""
        if (!is.null(selectmusee())){
            leafletProxy("map", data = selectmusee()) %>% clearMarkerClusters() %>%
                addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions(),
                           clusterId = "cluster", popup = ~apply(selectmusee(), 1, fpopup),
                           icon = icons(iconUrl = "https://www.flaticon.com/svg/vstatic/svg/1825/1825814.svg?token=exp=1615029914~hmac=c363db1013f7d8ccd0c2d96a62886711",
                                        iconWidth = 20, iconHeight = 95), layerId = ~ref_musee) %>% 
                removeMarkerFromCluster(remove, 'cluster')
            }
        if(input$zoom!=""){
            geo = mygeocode(input$zoom)
            leafletProxy("map", data = musee) %>% setView(geo[1],geo[2], 12)
        }
    })
    observe({
        if(input$regioncarte!=""){
            print(input$regioncarte)
            leafletProxy("map", data = musee)
        }
    })
})
