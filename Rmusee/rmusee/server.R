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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$histo <- renderPlot({

        # generate bins based on input$bins from ui.R
        col.annee = paste('total.',as.numeric(input$annee), sep = '')
        print(col.annee)
        x  <- musee[musee$region == as.character(input$region),col.annee]
        print(x[[col.annee]])

        # draw the histogram with the specified number of bins
        hist(x[[col.annee]], col = 'darkgray', border = 'white')

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

})
