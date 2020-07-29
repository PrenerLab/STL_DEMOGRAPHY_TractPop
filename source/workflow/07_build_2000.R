# build 2000 estimates ####

# download data ####
### total population
get_decennial(geography = "tract", variable = "P001001", year = 2000, state = 29, county = c(189, 510), geometry = TRUE) %>%
  st_transform(crs = 26915) %>%
  select(GEOID, value) %>%
  rename(
    geoid = GEOID,
    pop = value
  ) -> pop

### race
#### white population
get_decennial(geography = "tract", variables = "P003003", year = 2000, state = 29, county = c(510, 189), geometry = TRUE) %>%
  st_transform(crs = 26915) %>%
  select(GEOID, value) %>%
  rename(
    geoid = GEOID,
    white = value
  ) -> white

#### black population
get_decennial(geography = "tract", variables = "P003004", year = 2000, state = 29, county = c(510, 189), geometry = FALSE) %>%
  select(GEOID, value) %>%
  rename(
    geoid = GEOID,
    black = value
  ) -> black

#### join
race <- left_join(white, black, by = "geoid") %>%
  select(geoid, white, black)

#### clean-up
rm(white, black)

# interpolate population ####
## interpolate
stl_tract10 %>%
  st_transform(crs = 26915) %>%
  aw_interpolate(tid = geoid, source = pop, sid = geoid,
                 weight = "sum", output = "tibble", 
                 extensive = "pop") %>%
  mutate(year = 2000) %>%
  select(year, everything()) -> est_pop_00

## unit test
expect_equal(sum(pop$pop, na.rm = TRUE), sum(est_pop_00$pop, na.rm = TRUE))

## clean-up
rm(pop)

# interpolate race ####
## interpolate
stl_tract10 %>%
  st_transform(crs = 26915) %>%
  aw_interpolate(tid = geoid, source = race, sid = geoid,
                 weight = "sum", output = "tibble", 
                 extensive = c("white", "black")) %>%
  mutate(year = 2000) %>%
  select(year, everything()) -> est_race_00

## unit test
expect_equal(sum(race$white, na.rm = TRUE), sum(est_race_00$white, na.rm = TRUE))
expect_equal(sum(race$black, na.rm = TRUE), sum(est_race_00$black, na.rm = TRUE))
expect_lte(sum(race$black, na.rm = TRUE) + sum(est_race_00$black, na.rm = TRUE),
           sum(est_pop_00$pop, na.rm = TRUE))

## clean-up
rm(race)