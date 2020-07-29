# build 2010 estimates ####

# download data ####
### total population
get_decennial(geography = "tract", variable = "P001001", year = 2010, state = 29, county = c(189, 510), geometry = FALSE) %>%
  select(GEOID, NAME, value) %>%
  rename(
    geoid = GEOID,
    pop = value
  ) %>%
  mutate(
    year = 2010,
    county = ifelse(str_detect(string = NAME, pattern = "city") == TRUE, "St. Louis City", "St. Louis"),
    countyfp = ifelse(str_detect(string = NAME, pattern = "city") == TRUE, "510", "189")
  ) %>%
  select(year, geoid, countyfp, county, pop) -> pop_10

### race
#### white population
get_decennial(geography = "tract", variables = "P003002", year = 2010, state = 29, county = c(510, 189), geometry = FALSE) %>%
  select(GEOID, NAME, value) %>%
  rename(
    geoid = GEOID,
    white = value
  ) %>%
  mutate(
    year = 2010,
    county = ifelse(str_detect(string = NAME, pattern = "city") == TRUE, "St. Louis City", "St. Louis"),
    countyfp = ifelse(str_detect(string = NAME, pattern = "city") == TRUE, "510", "189")
  ) %>%
  select(year, geoid, countyfp, county, white) -> white

#### black population
get_decennial(geography = "tract", variables = "P003003", year = 2010, state = 29, county = c(510, 189), geometry = FALSE) %>%
  select(GEOID, value) %>%
  rename(
    geoid = GEOID,
    black = value
  ) -> black

#### join
race_10 <- left_join(white, black, by = "geoid") %>%
  select(year, geoid, countyfp, county, white, black)

#### clean-up
rm(white, black)
