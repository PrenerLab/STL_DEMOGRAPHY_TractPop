# build sql database ####

# dependencies ####
## tidyverse packages
library(dplyr)         # data wrangling
library(readr)         # working with csv data
library(stringr)       # work with strings
library(tidyr)         # data wrangling

## spatial packages
library(areal)         # interpolation
library(sf)            # working with spatial data
library(tidycensus)    # census api access
library(tigris)        # tiger/line api access

## other packages
library(DBI)           # database connections
library(here)          # file path management
library(testthat)      # unit testing

# load data ####
## read in 2010 census tract
stl_tract10 <- tracts(29, county = c(510, 189), year = 2010, class = "sf") %>%
  st_transform(crs = 26915) %>%
  select(COUNTYFP10, GEOID10) %>%
  rename(
    countyfp = COUNTYFP10,
    geoid = GEOID10,
    ) %>%
  mutate(county = ifelse(countyfp == "189", "St. Louis", "St. Louis City")) %>%
  select(geoid, countyfp, county)

# create estimates ####
source(here("source", "workflow", "01_build_1940.R"))
source(here("source", "workflow", "02_build_1950.R"))
source(here("source", "workflow", "03_build_1960.R"))
source(here("source", "workflow", "04_build_1970.R"))
source(here("source", "workflow", "05_build_1980.R"))
source(here("source", "workflow", "06_build_1990.R"))
source(here("source", "workflow", "07_build_2000.R"))
source(here("source", "workflow", "08_build_2010.R"))

source(here("source", "workflow", "16_build_2018.R"))

## clean-up
rm(stl_tract10)

# bind estimates ####
## total population
pop <- bind_rows(est_pop_40, est_pop_50, est_pop_60, est_pop_70, est_pop_80,
                 est_pop_90, est_pop_00, pop_10, pop_18)

## race
race <- bind_rows(est_race_40, est_race_50, est_race_60, est_race_70, est_race_80,
                  est_race_90, est_race_00, race_10, race_18)

## clean-up
rm(est_pop_40, est_pop_50, est_pop_60, est_pop_70, est_pop_80, 
   est_pop_90, est_pop_00, pop_10, pop_18)
rm(est_race_40, est_race_50, est_race_60, est_race_70, est_race_80,
   est_race_90, est_race_00, race_10, race_18)

# prepare data for writing ####
## total population
pop <- rename(pop, value = pop)

## race
race <- pivot_longer(race, cols = c("white", "black"), names_to = "category", values_to = "value")

# write sql ####
## connect to database
con <- dbConnect(RSQLite::SQLite(), "data/STL_CITY_COUNTY_Database.sqlite")

## write population table
copy_to(con, pop, "population",
        temporary = FALSE,
        overwrite = TRUE,
        indexes = list(
          "year", 
          "geoid",
          "county",
          "countyfp"
        )
)      

## write race table
copy_to(con, race, "race",
        temporary = FALSE,
        overwrite = TRUE,
        indexes = list(
          "year", 
          "GEOID",
          "county",
          "countyfp",
          "category"
        )
)     

## disconnect from database
dbDisconnect(con)

## clean-up
rm(con, pop, race)
