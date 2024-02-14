# Step 5) Explore sensor data for north central Washington state
#
# Working with PurpleAir data which requires an API key

# ----- Setup ------------------------------------------------------------------

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "Chelan-Douglas_Health_District$") ) {
  stop("WD_ERROR:  Please set the working directory to 'Chelan-Douglas_Health_District/'")
}

if ( packageVersion("AirSensor2") < "0.5.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirSensor2 0.5.0 or later.")
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

fileName <- "data/pas.rda"

if ( file.exists(fileName) ) {
  
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

fields <- c("sensor_index", "locationName", "date_created", "last_seen")
time_range <-
  pas %>%
  dplyr::select(dplyr::all_of(fields))

readr::write_csv(time_range, file = "CDHD_sensors_time_range.csv")



# REDO EVERYTHING AFTER THIS


# ----- Create a 'pat' object --------------------------------------------------

fields <- c(
  "pm2.5_cf_1"
)

# Twisp Town Hall sensor_index = 10158

sensor_index <- 13669

pat_raw <-
  pat_downloadParseRawData(
    sensor_index = sensor_index,
    startdate = "2023-07-01",
    enddate = "2023-07-02",
    average = 10,                              # 1 day
    timezone = "America/Los_Angeles",
    fields = fields,
  )

# For Twisp Town Hall: 10158
# 2020,1,2,3: No data for average = 1440
# 2023: No data for average = 1440,360,10

# Does anything work?
# Example from the package:

pat_raw <-
  pat_downloadParseRawData(
    api_key = PurpleAir_API_READ_KEY,
    sensor_index = "2323",
    startdate = "2023-02-01",
    enddate = "2023-02-02",
    timezone = "UTC",
    fields = PurpleAir_HISTORY_PM25_FIELDS,
  )

# Yes!

View(pat_raw)

# Can I just get one field?

pat_raw <-
  pat_downloadParseRawData(
    api_key = PurpleAir_API_READ_KEY,
    sensor_index = "2323",
    startdate = "2023-02-01",
    enddate = "2023-02-02",
    timezone = "UTC",
    fields = c("pm2.5_cf_1"),
  )

# Yes! Can I average

pat_raw <-
  pat_downloadParseRawData(
    api_key = PurpleAir_API_READ_KEY,
    sensor_index = "2323",
    startdate = "2023-02-01",
    enddate = "2023-03-01",
    average = 1440,
    timezone = "America/Los_Angeles",
    fields = c("pm2.5_cf_1"),
  )

# 60 yes, 1440 requires the correct timezone

# Can download a month's worth of daily averages (24 * 3)

# Now for Twisp area sensors:

pat_raw <-
  pat_downloadParseRawData(
    api_key = PurpleAir_API_READ_KEY,
    sensor_index = "113370",
    startdate = "2023-02-01",
    enddate = "2023-03-01",
    average = 1440,
    timezone = "America/Los_Angeles",
    fields = c("pm2.5_cf_1"),
  )

# Balky Hill: 13669 -- NO, doesn't even show up on PA map
# Homestead Hills: 113370 -- YES

# Try older Twisp Town Hall 10158
# date_created: 2018-05-03 20:32:12
# last_seen: 2020-06-05 06:55:27

pat_raw <-
  pat_downloadParseRawData(
    api_key = PurpleAir_API_READ_KEY,
    sensor_index = "10158",
    startdate = "2019-07-01",
    enddate = "2019-08-01",
    average = 1440,
    timezone = "America/Los_Angeles",
    fields = c("pm2.5_cf_1"),
  )

# 2021 -- NO
# 2020 -- NO
# 2019 -- YES
# 2018 -- NO
# 2016 -- NO


