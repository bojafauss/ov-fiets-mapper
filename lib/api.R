# retrieve trains (core function)
get_trains_raw <- function(station.id, type, run.time){
  Sys.sleep(1) # prevent hammering the server above usage terms
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

  df <- df %>%
    content('text') %>%
    fromJSON() %$%
    payload %>%
    .[[type]] %>%
    flatten() %>%
    mutate(
      station.code = station.id,
      call.type = type,
      call.time = run.time)

  return(df)
}

# retrieve trains (error handling wrapper)
get_trains <- function(...){
  df <- tryCatch(get_trains_raw(...),
    error = function(e) tibble()
  )
}

# retrieve ov fiets availability (core function)
get_ov_fiets_raw <- function(station.id, run.time){
  Sys.sleep(1)
  df <- GET(
    url = 'https://ns-api.nl/places/api/v2/ovfiets',
    add_headers("x-api-key" = credentials$api.key),
    query = list(
      "station_code" = station.id
    )
  )
  
  df <- df %>%
    content('text') %>%
    fromJSON() %>%
    .$payload %>%
    .$locations %>%
    map(function(x) x$extra$rentalBikes) #locations contains a list of bike points
  
  df <- tibble(code = station.id, bikes = unlist(df)) %>%
    mutate(call.time = run.time) # passed for further joining
  return(df)
}

# retrieve ovfiets (error handling wrapper)
get_ov_fiets <- function(...){
  df <- tryCatch(get_ov_fiets_raw(...),
    error = function(e) tibble()
  )
}

# add to db (auto append if table exists)
add_to_db <- function(data, connection, tablename){
  dbWriteTable(
    connection,
    tablename,
    data,
    append = tablename %in% dbListTables(connection)
  )
}
