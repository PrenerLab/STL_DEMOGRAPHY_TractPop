# build 1990 estimates ####

# download data ####
### total population
get_decennial(geography = "tract", variable = "P0010001", year = 1990, state = 29, county = c(189, 510), geometry = TRUE) %>%
  st_transform(crs = 26915) %>%
  select(GEOID, value) %>%
  rename(
    geoid = GEOID,
    pop = value
  ) -> pop

### race
#### white population
get_decennial(geography = "tract", variables = "P0060001", year = 1990, state = 29, county = c(510, 189), geometry = TRUE) %>%
  st_transform(crs = 26915) %>%
  select(GEOID, value) %>%
  rename(
    geoid = GEOID,
    white = value
  ) -> white

#### black population
get_decennial(geography = "tract", variables = "P0060002", year = 1990, state = 29, county = c(510, 189), geometry = FALSE) %>%
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
  mutate(year = 1990) %>%
  select(year, everything()) -> est_pop_90

## unit test
### note - gte is used because there is a 12 person difference in the white population, unassigned to a geometric tract
expect_gte(sum(pop$pop, na.rm = TRUE), sum(est_pop_90$pop, na.rm = TRUE))

## clean-up
rm(pop)

# interpolate race ####
## interpolate
stl_tract10 %>%
  st_transform(crs = 26915) %>%
  aw_interpolate(tid = geoid, source = race, sid = geoid,
                 weight = "sum", output = "tibble", 
                 extensive = c("white", "black")) %>%
  mutate(year = 1990) %>%
  select(year, everything()) -> est_race_90

## unit test
expect_gte(sum(race$white, na.rm = TRUE), sum(est_race_90$white, na.rm = TRUE))
expect_gte(sum(race$black, na.rm = TRUE), sum(est_race_90$black, na.rm = TRUE))
expect_lte(sum(race$black, na.rm = TRUE) + sum(est_race_90$black, na.rm = TRUE),
           sum(est_pop_90$pop, na.rm = TRUE))

## clean-up
rm(race)
