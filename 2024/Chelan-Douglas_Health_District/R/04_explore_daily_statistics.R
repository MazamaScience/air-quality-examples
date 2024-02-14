# Explore monitoring data daily statistics for north central Washington state
#
# Three sources of data:
# - airnow -- offical EPA data with permanent and temporary monitors
# - airsis -- temporary monitors set up during wildfires
# -   wrcc -- temporary monitors set up during wildfires
#
# NOTE:  Data archives begin in 2014

# ----- Setup ------------------------------------------------------------------

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "Chelan-Douglas_Health_District$") ) {
  stop("WD_ERROR:  Please set the working directory to 'Chelan-Douglas_Health_District/'")
}

if ( packageVersion("AirMonitor") < "0.5.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirMonitor 0.5.0 or later.")
}

library(AirMonitor)

# ----- Combine data -----------------------------------------------------------

airnow <- get(load("./data/airnow_2014.rda"))
airsis <- get(load("./data/airsis_2014.rda"))
wrcc <- get(load("./data/wrcc_2014.rda"))

# Combine them
# NOTE:  We put airnow last so it's meta and data will be used  if an ID appears more than once
monitor <-
  monitor_combine(
    wrcc, airsis, airnow,
    replaceMeta = TRUE,
    overlapStrategy = "replace all"
  ) %>%
  monitor_dropEmpty() %>%
  monitor_trimDate()

# ----- Daily hours above threshold --------------------------------------------

unhealthy <-
  monitor %>%
  monitor_dailyThreshold(
    threshold = "unhealthy",
    na.rm = TRUE,
    minHours = 18,
    dayBoundary = "LST"
  )

dplyr::glimpse(unhealthy$data)

# ----- Daily average ----------------------------------------------------------

dailyAQCTable <-
  monitor %>%
  monitor_dailyStatistic(
    FUN = mean,
    na.rm = TRUE,
    minHours = 18,
    dayBoundary = c("LST")
  ) %>%
  monitor_dropEmpty() %>%
  monitor_toAQCTable(NAAQS = "PM2.5")

print(dailyAQCTable)


