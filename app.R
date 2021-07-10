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

# Also recode greater than -100% to 100% for conversion to date percentages

raw <- read_csv(here::here("pay-gap-202021.csv")) %>% 
    janitor::clean_names() %>% 
    select(employer_name,
           diff_mean_hourly_percent,
           diff_median_hourly_percent) %>% 
    mutate(diff_mean_hourly_percent = case_when(diff_mean_hourly_percent < -100 ~ -100,
                                                TRUE ~ diff_mean_hourly_percent),
           diff_median_hourly_percent = case_when(diff_median_hourly_percent < -100 ~ -100,
                                                TRUE ~ diff_median_hourly_percent)
           )

equal_pay_date <- function(name, gender){
    
    avg_name <- paste0("diff_", name, "_hourly_percent")
    
    average_df <- raw %>%
        mutate(year = as.Date('2020-01-01'),
               yday = year + (round(365 - round(abs(.data[[avg_name]])/ 100 * 365)) - 1),
               avg_day   = lubridate::day(yday),
               avg_month = lubridate::month(yday, label = TRUE, abbr = FALSE)
        ) %>% 
        select(employer_name,
               !!paste0(gender, "_", name, "_test") := yday,
               !!paste0(gender, "_", name, "_day") := avg_day,
               !!paste0(gender, "_", name, "_month") := avg_month,
               diff_mean_hourly_percent,
               diff_median_hourly_percent
               
        )
    
        return(average_df)
}

female_median <- equal_pay_date("median", "female")
female_mean <- equal_pay_date("mean", "female")
male_median <- equal_pay_date("median", "male")
male_mean <- equal_pay_date("mean", "male")

convert <- female_mean %>% 
    left_join(female_median) %>% 
    left_join(male_mean) %>% 
    left_join(male_median)

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
            mutate(formatting = case_when(input$average == "Median" & 
                                              diff_median_hourly_percent > 0 ~
                                              paste0("effectively stops paying women on ",
                                                     female_median_day, " ", 
                                                     female_median_month, ", a pay gap of ",
                                                     diff_median_hourly_percent, 
                                                     "%"),
                                          input$average == "Median" & 
                                              diff_median_hourly_percent <= 0 ~ 
                                              paste0("pays women for the full 12 months, and effectively stops paying men on ",
                                                     male_median_day, " ",
                                                     male_median_month, ", a pay gap of ",
                                                     abs(diff_median_hourly_percent), 
                                                     "%"),
                                          input$average == "Mean" & 
                                              diff_mean_hourly_percent > 0 ~
                                              paste0("effectively stops paying women on ",
                                                     female_mean_day, " ", 
                                                     female_mean_month, 
                                                     ", a pay gap of ",
                                                     diff_mean_hourly_percent, 
                                                     "%"),
                                          input$average == "Mean" & diff_mean_hourly_percent <= 0 ~ 
                                              paste0("pays women for the full 12 months, and effectively stops paying men on ",
                                                     male_mean_day, " ",
                                                     male_mean_month, ", a pay gap of ",
                                                     abs(diff_mean_hourly_percent), 
                                                     "%"),
                                          TRUE ~ NA_character_)) %>% 
            pull(formatting)
    })
    
}

shinyApp(ui, server)