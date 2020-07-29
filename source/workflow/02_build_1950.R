# build 1950 estimates ####

# load data ####
pop <- read_csv(here("data", "raw", "IPUMS", "population", "nhgis0013_ds82_1950_tract.csv"))
race <- read_csv(here("data", "raw", "IPUMS", "race", "nhgis0030_ds82_1950_tract.csv"))
stl_tracts <- st_read(here("data", "spatial", "STL_DEMOGRAPHICS_tracts50", "STL_BOUNDARY_1950_tracts.geojson"),
                 stringsAsFactors = FALSE) %>%
  st_transform(crs = 26915) %>%
  select(GISJOIN)

# wrangle population ####
## clean up raw data
pop %>%
  filter(STATE == "Missouri") %>%
  filter(COUNTY == "St Louis" | COUNTY == "St Louis City") %>%
  rename(
    year = YEAR,
    county = COUNTY,
    pop = BZ8001
  ) %>%
  select(year, GISJOIN, county, pop) -> pop

## join to geometric data
left_join(stl_tracts, pop, by = "GISJOIN") %>%
  select(year, GISJOIN, county, pop) %>%
  rename(geoid = GISJOIN) -> pop

# interpolate population ####
## interpolate
stl_tract10 %>%
  st_transform(crs = 26915) %>%
  aw_interpolate(tid = geoid, source = pop, sid = geoid,
                 weight = "sum", output = "tibble", 
                 extensive = "pop") %>%
  mutate(year = 1950) %>%
  select(year, everything()) -> est_pop_50

## unit test
expect_equal(sum(pop$pop, na.rm = TRUE), sum(est_pop_50$pop, na.rm = TRUE))

## clean-up
rm(pop)

# wrangle population ####
## clean up raw data
race %>%
  filter(STATE == "Missouri") %>%
  filter(COUNTY == "St Louis" | COUNTY == "St Louis City") %>%
  rename(
    year = YEAR,
    county = COUNTY,
    white = B0J001,
    black = B0J002
  ) %>%
  select(year, GISJOIN, county, white, black) -> race

## join to geometric data
left_join(stl_tracts, race, by = "GISJOIN") %>%
  select(year, GISJOIN, county, white, black) %>%
  rename(geoid = GISJOIN) -> race

# interpolate race ####
## interpolate
stl_tract10 %>%
  st_transform(crs = 26915) %>%
  aw_interpolate(tid = geoid, source = race, sid = geoid,
                 weight = "sum", output = "tibble", 
                 extensive = c("white", "black")) %>%
  mutate(year = 1950) %>%
  select(year, everything()) -> est_race_50

## unit test
expect_equal(sum(race$white, na.rm = TRUE), sum(est_race_50$white, na.rm = TRUE))
expect_equal(sum(race$black, na.rm = TRUE), sum(est_race_50$black, na.rm = TRUE))
expect_lte(sum(race$black, na.rm = TRUE) + sum(est_race_50$black, na.rm = TRUE),
           sum(est_pop_50$pop, na.rm = TRUE))

## clean-up
rm(stl_tracts, race)