library(tidyverse)
library(httr)
library(yaml)
library(jsonlite)
library(glue)
library(magrittr)

# setup
credentials <- read_yaml('config/credentials.yml')
config <- read_yaml('config/config.yml')
source('lib/api.R')

# retrieve train data
combinations <- crossing(config$stations, c('arrivals', 'departures')) %>%
  set_names(c('stations', 'type'))
query.time <- Sys.Date() %>% as.character()
df <-  map2_df(combinations$stations, combinations$type, get_trains, query.time)
