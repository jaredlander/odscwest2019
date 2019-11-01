library(shiny)
library(shinythemes)

countryPanel <- tabPanel(
    title='Country Info',
    selectInput(
        inputId='CountrySelector',
        label='Choose a Country',
        choices=list(
            'USA', 'Canada', 'Ghana', 
            'South Africa', 'Brazil',
            'Nigeria', 'India', 'Ukraine'
        )
    ),
    textOutput(
        outputId='DisplayCountry'
    )
)

plotPanel <- tabPanel(
    title='Simple Plot',
    fluidRow(
        column(
            width=3,
            selectInput(
                inputId='CarColumn',
                label='Please choose a column',
                choices=names(mtcars)
            ),
            sliderInput(
                inputId='CarBins',
                label='Choose Number of Bins',
                min=3, max=100, value=30
            )
        ),
        column(
            width=9,
            plotOutput(
                outputId='CarHist'
            )
        )
    )
)

pizzaStuff <- tabPanel(
    title='Pizza',
    fluidRow(
        column(
            width=6,
            DT::dataTableOutput(
                outputId='PizzaTable'
            )
        ),
        column(
            width=6,
            leaflet::leafletOutput(
                outputId='PizzaMap'
            )
        )
    )
)

navbarPage(
    title='Flight of the Nvigator',
    selected='Pizza',
    # theme=shinytheme('cerulean'),
    themeSelector(),
    tabPanel(
        title='The World',
        'Hello'
    ),
    tabPanel(
        title='Second Page',
        'Your quest begins here'
    ),
    countryPanel,
    plotPanel,
    pizzaStuff
)
