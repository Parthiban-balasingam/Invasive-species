#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Load packages 
library(shiny)
library(DT)
library(dplyr)
library(readr)
library(leaflet)
library(shinyWidgets)
library(htmltools)
library(scales)
library(plotly)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    #In put dataset
    raw_data <- reactive({
        raw_data <- df
    })
    
    
   
    output$mytable1 = DT::renderDataTable({
        DT::datatable(raw_data())
    })
    
    output$name_choices <- renderUI(
        selectizeInput(inputId = "speciesName", 
                       label = "Select Vernacular or Scientific Name",
                       selected = c("Tamarindus indica", "Cosmos bipinnatus"),
                       choices = c(raw_data()["scientificName"], raw_data()["vernacularName"]),
                       multiple = T,
                       options = list(
                           `actions-box` = TRUE,
                           `live-search` = TRUE,
                           `live-search-placeholder` = "Search",
                           `none-selected-text` = "Select Fields",
                           `tick-icon` = "",
                           `virtual-scroll` = 10,
                           `size` = 6
                       )
                       
                     )
                       
    )
    
    # output$name <- ({
    #     names <- renderText(input$speciesName)
    #     names
    # })
    
    # # Filter the dataset by scientificName or vernacularName
    filter_data <- eventReactive(input$speciesName, {
        validate(
            need(input$speciesName, "Please select a Scientific or Vernacular name")
        )
      
        filter_data <- dplyr::filter(raw_data(),raw_data()$scientificName %in% input$speciesName | 
                                       raw_data()$vernacularName %in% input$speciesName)
        }, ignoreNULL = FALSE)
    
    
    # Module Leaflet Server
    leafletServer("main_map", filter_data)
    
    kingdomCountServer("plotly_kingdomCount", filter_data)
    
    # Module timeLine Server
    timelineServer("plotly_timeline", filter_data)
    
})
