# Step 5) Explore sensor data for north central Washington state
#
# Working with PurpleAir data which requires an API key

# ----- Setup ------------------------------------------------------------------

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "Chelan-Douglas_Health_District$") ) {
  stop("WD_ERROR:  Please set the working directory to 'Chelan-Douglas_Health_District/'")
}

if ( packageVersion("AirSensor2") < "0.4.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirSensor2 0.4.0 or later.")
}

library(MazamaSpatialUtils)
library(AirSensor2)

# Load dataset used to assign countyName
initializeMazamaSpatialUtils("~/Data/Spatial")

# Read in and set the PurpleAir API key
source("global_vars.R")
setAPIKey("PurpleAir-read", PurpleAir_API_READ_KEY)

# ----- Create a 'pas' object --------------------------------------------------

# PAS stands for Purple Air Synoptic. We create this object first to learn
# about available sensors.

# TODO:  Need a way to ask for as little data as possible

# TODO:  Read in pas if found

fileName <- "data/pas.rda"

if ( exists(fileName) ) {

  pas <- get(load(fileName))

} else {

  pas <-
    pas_createNew(
      countryCodes = "US",
      stateCodes = "WA",
      counties = c("Chelan", "Douglas", "Okanogan"),
      lookbackDays = 13650, # 10 years
      location_type = 0
    )

  save(pas, file = "data/pas.rda")

}

# Check out available data
fields <- c("sensor_index", "name", "date_created", "last_seen")

for ( year in 2014:2020 ) {

  message(sprintf("===== %d =====", year))
  startdate <- year * 1e4 + 701
  enddate <- year * 1e4 + 1101

  pas %>%
    pas_filterDate(startdate, enddate, timezone = "America/Los_Angeles") %>%
    dplyr::select(dplyr::all_of(fields)) %>%
    print()

}

# ----- Create a 'pat' object --------------------------------------------------

fields <- c(
  "pm2.5_cf_1"
)

# Twisp Town Hall sensor_index = 10158

sensor_index <- 10158

pat_raw <-
  pat_downloadParseRawData(
    sensor_index = sensor_index,
    startdate = "2021-07-01",
    enddate = "2021-08-01",
    average = 1440,                              # 1 day
    timezone = "America/Los_Angeles",
    fields = fields,
  )

# 2020: No data
# 2021: No data

