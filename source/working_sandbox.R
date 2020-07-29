# build 1940 estimates ####

# load data ####
pop40 <- read_csv(here("data", "raw", "IPUMS", "population", "nhgis0012_ds76_1940_tract.csv"))
race40 <- read_csv(here("data", "raw", "IPUMS", "race", "nhgis0030_ds76_1940_tract.csv"))

# wrangle population ####
## clean up raw data
pop40 %>%
  filter(STATE == "Missouri") %>%
  filter(COUNTY == "St Louis" | COUNTY == "St Louis City") %>%
  select(-STATE, -STATEA, -PRETRACTA, -AREANAME, -BUQ001, -BUQ002) %>%
  # mutate(tractID = ifelse(
  #  is.na(POSTTRCTA) == TRUE, 
  #  paste0(COUNTYA, "-", TRACTA),
  #  paste0(COUNTYA, "-", TRACTA, POSTTRCTA)
  # )) %>%
  rename(
    year = YEAR,
    county = COUNTY,
    pop40 = BUB001
  ) %>%
  select(year, GISJOIN, county, pop40) -> pop40

## join to geometric data
### read in census tract shapefile
stl40 <- st_read(here("data", "spatial", "STL_DEMOGRAPHICS_tracts40", "STL_BOUNDARY_1940_tracts.geojson"),
                 stringsAsFactors = FALSE) %>%
  st_transform(crs = 26915) %>%
  select(GISJOIN)

### join data to census tract shapefile
left_join(stl40, pop40, by = "GISJOIN") %>%
  select(year, GISJOIN, county, pop40) %>%
  rename(geoid = GISJOIN) -> pop40
