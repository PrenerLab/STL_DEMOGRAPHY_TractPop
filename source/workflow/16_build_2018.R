# build 2018 estimates ####

# download data ####
### total population
get_acs(geography = "tract", variable = "B01003_001", year = 2018, state = 29, county = c(189, 510), geometry = FALSE) %>%
  select(GEOID, NAME, estimate) %>%
  rename(
    geoid = GEOID,
    pop = estimate
  ) %>%
  mutate(
    year = 2018,
    county = ifelse(str_detect(string = NAME, pattern = "city") == TRUE, "St. Louis City", "St. Louis"),
    countyfp = ifelse(str_detect(string = NAME, pattern = "city") == TRUE, "510", "189")
  ) %>%
  select(year, geoid, countyfp, county, pop) -> pop_18

### race
#### white population
get_acs(geography = "tract", variables = "B02001_002", year = 2018, state = 29, county = c(510, 189), geometry = FALSE) %>%
  select(GEOID, NAME, estimate) %>%
  rename(
    geoid = GEOID,
    white = estimate
  ) %>%
  mutate(
    year = 2018,
    county = ifelse(str_detect(string = NAME, pattern = "city") == TRUE, "St. Louis City", "St. Louis"),
    countyfp = ifelse(str_detect(string = NAME, pattern = "city") == TRUE, "510", "189")
  ) %>%
  select(year, geoid, countyfp, county, white) -> white

#### black population
get_acs(geography = "tract", variables = "B02001_003", year = 2018, state = 29, county = c(510, 189), geometry = FALSE) %>%
  select(GEOID, estimate) %>%
  rename(
    geoid = GEOID,
    black = estimate
  ) -> black

#### join
race_18 <- left_join(white, black, by = "geoid") %>%
  select(year, geoid, countyfp, county, white, black)

#### clean-up
rm(white, black)
