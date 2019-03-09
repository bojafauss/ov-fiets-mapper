# retrieve trains
get_trains_raw <- function(station.id, type, run.time){
  Sys.sleep(1)
  df <- GET(
    url = glue('https://ns-api.nl/reisinfo/api/v2/{type}'),
    add_headers("x-api-key" = credentials$api.key),
    query = list(
      "dateTime" = run.time,
      "maxJourneys" = 20,
      "lang" = "nl",
      "station" = station.id
    )
  )

  #if(df$status_code != 200){return("Failed to retrieve data")}

  df <- df %>%
    content('text') %>%
    fromJSON() %$%
    payload %>%
    .[[type]] %>%
    flatten() %>%
    mutate(
      station.code = station.id,
      call.type = type)

  return(df)
}

get_trains <- function(...){
  df <- tryCatch(get_trains_raw(...),
    error = function(e) tibble()
  )
}
