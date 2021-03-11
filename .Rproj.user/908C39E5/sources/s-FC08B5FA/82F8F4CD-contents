#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(rAmCharts)

# Define UI for application that draws a histogram
ui <- fluidPage(
  tags$head(
    tags$style(HTML("h1{color: #1E90FF;}"))
  ),
  
  # Application title
  titlePanel("Old Faithful Geyser Data"),
  
  # Sidebar with a slider input for number of bins 
  navbarPage(title = "My First App",
             tabPanel(title = "Data",
                      navlistPanel("Summary + table",
                                   tabPanel("Summary", verbatimTextOutput("summary")),
                                   tabPanel("Table", HTML("<h1> Tableau </h1>"),
                                     dataTableOutput(outputId = "table")))),
             tabPanel(title = "Visualisation", 
                      fluidRow(
                        column(width = 3,
                               wellPanel(
                                 sliderInput("bins",
                                             "Number of bins:",
                                             min = 1,
                                             max = 50,
                                             value = 30),
                                 selectInput(inputId = "color", label = "Couleur :", choices = c("Rouge" = "red", "Vert" = "green", "Bleu" = "blue")),
                                 textInput(inputId = "title", label = "Choisissez un titre", value = ""),
                                 radioButtons(inputId = "Queen", label = "Choisissez une colonne", choices = colnames(faithful), selected = colnames(faithful)[1]),
                                 actionButton("gograph", "Mise a jour")
                               )
                        ),
                        # Show a plot of the generated distribution
                        column(width = 9,
                               tabsetPanel(id = "graphiques",
                                 tabPanel("Histogramme", amChartsOutput("distPlot")),
                                 tabPanel("Boxplot", amChartsOutput("boxplot"))
                               )
                        )
                      )
             ),
             tabPanel(title = "A propos de nous",
                      HTML("<p> Coucou on fait caca des papillons ! 
                           <img src = 'Papillon.jpg' alt = 'Papillon'>
                           </p>"))
  )
)
# Define server logic required to draw a histogram
server <- function(input, output, session) {
  x <- reactive({
    faithful[, input$Queen]})
    output$distPlot <- renderAmCharts({
      input$gograph
    isolate({
      #req(input$Queen)
      # generate bins based on input$bins from ui.R
      #x    <- faithful[, input$Queen]
      #browser()
      bins <- round(seq(min(x()), max(x()), length.out = input$bins + 1), 2)
      
      # draw the histogram with the specified number of bins
      amHist(x(), control_hist = list(breaks = bins), col = input$color, border = 'white', main = input$title, export = TRUE, zoom = TRUE)
    })
  })
  output$summary <- renderPrint({summary(faithful)})
  output$table <- renderDataTable({faithful})
  output$boxplot <- renderAmCharts({
    input$gograph
    isolate({
      #req(input$Queen)
      #x <- faithful[, input$Queen]
      amBoxplot(x(), col = input$color, main = input$title)})
  })
  observeEvent(input$gograph, {
    updateTabsetPanel(session, inputId = "graphiques", selected = "Histogramme")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
