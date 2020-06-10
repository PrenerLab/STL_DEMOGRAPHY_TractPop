# dependencies
library(DBI)      # database management
library(dplyr)    # data wrangling
library(purrr)
library(here)     # file path management
library(janitor)  # data wrangling
library(readxl)   # read excel files
library(stringr)  # string wrangling
library(tidyr)    # data wrangling
library(tigris)   # download placenames
library(sf)       # spatial tools

# connect to database
con <- dbConnect(RSQLite::SQLite(), "data/STL_CITY_COUNTY_Database.sqlite")

# write population table
copy_to(con, stl_population, "population",
        temporary = FALSE,
        overwrite = TRUE,
        indexes = list(
          "year", 
          "GEOID",
          "estimate"
        )
)      

# write race table
copy_to(con, stl_race, "race",
        temporary = FALSE,
        overwrite = TRUE,
        indexes = list(
          "year", 
          "GEOID",
          "value",
          "estimate"
        )
)     

# disconnect from database
dbDisconnect(con)
 rm(con)