library(shiny)
library(ggplot2)
library(magrittr)

pizza <- jsonlite::fromJSON(
    'FavoriteSpots.json') %>% 
    tidyr::unnest()

shinyServer(function(input, output, session){

    output$DisplayCountry <- renderText(
        input$CountrySelector
    )
    
    output$CarHist <- renderPlot(
        ggplot(mtcars, 
               aes_string(x=input$CarColumn)
        ) + 
            geom_histogram(bins=input$CarBins)
    )
    
    output$PizzaTable <- DT::renderDataTable({
        pizza
    }, rownames=FALSE
    )
})
