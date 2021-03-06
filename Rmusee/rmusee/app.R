library(shiny)
library(leaflet)
library(RColorBrewer)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
)

server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(musee) %>% addTiles() %>%
      fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    
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