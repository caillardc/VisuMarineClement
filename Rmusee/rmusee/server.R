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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
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
    
})
