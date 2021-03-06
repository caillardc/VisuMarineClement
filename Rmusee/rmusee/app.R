library(shiny)
library(leaflet)
library(RColorBrewer)


ui <- 
  bootstrapPage(
    navbarPage('qsdiohd', collapsible = TRUE,
               tabPanel(title = 'dfert',
                        div(
                          class = 'outer',  
                          tags$style(type = "text/css", "div.outer {position: fixed; top: 50px; left: 0; right: 0; bottom: 0;}"),
                          leafletOutput(outputId = "map", width="100%", height="100%"),
                        )
               ),
               tabPanel(title = 'dsdze'))
  )

server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
    
    leaflet(musee) %>% addTiles() %>%
      fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat))
  })
  observe({
    leafletProxy("map", data = musee) %>%
      addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions(),
                 clusterId = as.character(~region), popup = ~apply(musee, 1, fpopup),
                 icon = icons(iconUrl = "https://www.flaticon.com/svg/vstatic/svg/1825/1825814.svg?token=exp=1614959202~hmac=7d5cc095f2d18eb057af69c77cd24f3e",
                              iconWidth = 20, iconHeight = 95))
  })
  
  # Use a separate observer to recreate the legend as needed.
  # observe({
  #   proxy <- leafletProxy("map", data = quakes)
  
  # Remove any existing legend, and only if the legend is
  # enabled, create a new one.
  # proxy %>% clearControls()
  # if (input$legend) {
  #   pal <- colorpal()
  #   proxy %>% addLegend(position = "bottomright",
  #                       pal = pal, values = ~mag
  #       )
  #     }
  #   })
}

shinyApp(ui, server)