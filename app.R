#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readr) 
library(tidyverse) 
library(shinyWidgets)

# load data ---------------------------
# url <- "https://gender-pay-gap.service.gov.uk/viewing/download-data/2020"
# download.file(url, dest = "pay-gap-202021.csv")

raw <- read_csv(here::here("pay-gap-202021.csv")) %>% 
    janitor::clean_names() %>% 
    select(employer_name,
           diff_mean_hourly_percent,
           diff_median_hourly_percent
    )


convert <- raw %>% 
    mutate(year = as.Date('2020-01-01'),
           median_year_per = round(diff_median_hourly_percent / 100 * 365),
           median_year_not_paid = round(365 - median_year_per),
           median_yday = year + (median_year_not_paid - 1),
           median_day   = lubridate::day(median_yday),
           median_month = lubridate::month(median_yday, label = TRUE, abbr = FALSE),
           mean_year_per = round(diff_mean_hourly_percent / 100 * 365),
           mean_year_not_paid = round(365 - mean_year_per),
           mean_yday = year + (mean_year_not_paid - 1),
           mean_day   = lubridate::day(mean_yday),
           mean_month = lubridate::month(mean_yday, label = TRUE, abbr = FALSE)
    )

orgs <- convert %>% 
    select(employer_name) %>% 
    unique()

ui <- fluidPage(
        
        pickerInput(
            inputId = "organisation",
            label = "", 
            choices = orgs,
            options = list(
                `live-search` = TRUE)
        ),
        
        radioGroupButtons(
            inputId = "average",
            label = "Average",
            choices = c("Mean", 
                        "Median"),
            justified = TRUE
        ),
        
        HTML("<br><br><br>"),
        textOutput("sentence"),
        )
#     )
# )
server <- function(input, output, session) {
    
    org_name <- reactive({
        df <- convert %>% 
            filter(employer_name == input$organisation) 
    })
    
    output$sentence <- renderText({ 
        org_name() %>% 
            mutate(formatting = case_when(input$average == "Median" & diff_median_hourly_percent > 0 ~
                                              paste0("effectively stops paying women on ",
                                                     median_day, " ", median_month, ", a pay gap of ",
                                                     diff_median_hourly_percent, "%"),
                                          input$average == "Median" & diff_median_hourly_percent <= 0 ~ 
                                              paste0("pays women for the full 12 months, women outearn men by ",
                                                        abs(diff_median_hourly_percent), "%"),
                                          input$average == "Mean" & diff_mean_hourly_percent > 0 ~
                                              paste0("effectively stops paying women on ",
                                                     mean_day, " ", mean_month, ", a pay gap of ",
                                                     diff_mean_hourly_percent, "%"),
                                          input$average == "Mean" & diff_mean_hourly_percent <= 0 ~ 
                                              paste0("pays women for the full 12 months, women outearn men by ",
                                                     abs(diff_mean_hourly_percent), "%"),
                                          TRUE ~ NA_character_)) %>% 
            pull(formatting)
    })
    
}

shinyApp(ui, server)