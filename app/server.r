library(shiny)
library(ggplot2)
library(magrittr)
library(leaflet)
library(crosstalk)

pizza <- jsonlite::fromJSON(
    'FavoriteSpots.json') %>% 
    tidyr::unnest()

pizza_shared <- SharedData$new(pizza, key=~Name)

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
        pizza_shared
    }, rownames=FALSE, server=FALSE
    )
    
    output$PizzaMap <- renderLeaflet({
        leaflet(data=pizza_shared) %>% 
            addTiles() %>% 
            addMarkers(
                lng = ~ longitude,
                lat = ~ latitude,
                popup = ~ Name
            )
    })
})
