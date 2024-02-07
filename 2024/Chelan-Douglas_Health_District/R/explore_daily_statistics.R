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

# Define a function to convert numeric values into AQC categories (factors)
pm25_to_AQC <- function(x) {
  aqc <-
    cut(x, breaks = US_AQI$breaks_PM2.5, labels = US_AQI$names_eng)
  return(aqc)
}

# Use cut() to convert PM2.5 measurements into Air Quality Category (AQC)

dailyAQC <- 
  monitor %>%
  monitor_dailyStatistic(
    FUN = mean,
    na.rm = TRUE,
    minHours = 18,
    dayBoundary = c("LST")
  ) %>%
  monitor_dropEmpty() %>%
  monitor_mutate(
    FUN = pm25_to_AQC 
  )

dayCounts <- data.frame(row.names = c(US_AQI$names_eng, "Missing"))
# Create a table with needed information
for ( i in 2:ncol(dailyAQC$data) ) {
  # Site name
  siteName <- dailyAQC$meta$locationName[i-1]
  # AQC day counts
  aqcDayCounts <- 
    dplyr::pull(dailyAQC$data, i) %>%
    factor(levels = US_AQI$names_eng) %>%
    table(useNA = "always") %>%
    as.numeric()
  # Build up the table with one row per site
  # if ( i == 2 ) {
  #   dayCounts <- data.frame(siteName = aqcDayCounts)
  # } else {
    dayCounts[[siteName]] = aqcDayCounts
  # }
}

finalTable <- t(dayCounts)

print(finalTable)


