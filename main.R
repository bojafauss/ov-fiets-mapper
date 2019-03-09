library(tidyverse)
library(httr)
library(yaml)
library(jsonlite)
library(glue)
library(magrittr)
library(RSQLite)

# setup
credentials <- read_yaml('config/credentials.yml')
config <- read_yaml('config/config.yml')
source('lib/api.R')
combinations <- crossing(config$stations, c('arrivals', 'departures')) %>%
  set_names(c('stations', 'type'))
query.time <- Sys.time() %>% as.character()
db <- dbConnect(SQLite(), config$database)

# retrieve data data
df.trains <-  map2_df(combinations$stations, combinations$type, get_trains, query.time) %>%
  select(
    trainCode = name, #passed to remove duplicates during analysis
    trainCategory,
    cancelled, #curious about how many trains get cancelled per day
    plannedDateTime,
    actualDateTime,
    operator = product.operatorCode,
    stationCode = station.code,
    callType = call.type,
    callTime = call.time) %T>%
  add_to_db(db, 'traintable')

# retrieve bike data
df.ov <- map_df(config$stations, get_ov_fiets, query.time) %>%
  select(
    stationCode = code,
    availableBikes = bikes,
    callTime = call.time) %T>%
  add_to_db(db, 'biketable')

# disconnect from database
dbDisconnect(db)
