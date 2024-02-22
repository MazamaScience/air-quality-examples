# Create a daily average time series plotfor 2023
#
# This script creates a plot showing daily averages for *all* US monitors
# between April 15 and Nov 11, 2023.

# ----- Setup ------------------------------------------------------------------

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "IWFAQRP_Annual_Review$") ) {
  stop("WD_ERROR:  Please set the working directory to 'IWFAQRP_Annual_Review/'")
}

if ( packageVersion("AirMonitor") < "0.4.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirMonitor 0.4.0 or later.")
}

library(dplyr)
library(AirMonitor)

year <- 2023
startdate <- "2023-04-15"
enddate <- "2023-11-11"

titleText <- "2023 Timing of Smoke Impacts over entire US (all AQI levels), Apr 15-Nov 1"

# Save the output to a png file (comment this out to see it in RStudio)
filename <- sprintf("NationalMonitoring_%d_dailyTimeseries.png", year)
png(filename = filename, width = 1200, height = 400)

# ----- Load 2023 monitor data -------------------------------------------------

message(sprintf("Loading data for %d...", year))

all_monitors <-

  # 1) load all monitors
  #    - negative values are lifted up to zero
  #    - use AirNow data rather than EPA AQS
  monitor_loadAnnual(
    year = 2023,
    QC_negativeValues = "zero",
    epaPreference = "airnow"
  ) %>%

  # 2) US only
  monitor_filter(countryCode == "US") %>%

  # 3) drop any monitors with no data
  monitor_dropEmpty()

# ----- Calculate daily means --------------------------------------------------

# NOTE:  Calculating daily means will depend upon the timezone so, from here on,
# NOTE:  we do things on a per-timezone basis.

dailyMeanList <- list()

timezoneCount <- length(unique(all_monitors$meta$timezone))

message(sprintf(
  "Calculating daily averages in %d timezones...",
  timezoneCount
))

for ( tz in unique(all_monitors$meta$timezone) ) {

  dailyMeanList[[tz]] <-

    all_monitors %>%
    monitor_filter(timezone == tz) %>%
    monitor_filterDate(startdate, enddate) %>%
    monitor_dropEmpty() %>%
    monitor_dailyStatistic(
      FUN = mean,
      na.rm = TRUE,
      minHours = 18,
      dayBoundary = "LST"
    )

}

# ----- Timeseries plot --------------------------------------------------------

# Initialize the plot axes by plotting with 'transparent' color
monitor_timeseriesPlot(
  dailyMeanList[[1]],
  col = 'transparent',
  ylab = "24-hr Average PM2.5 (\u00b5g/m\u00b3)",
  xlab = year,
  ylim = c(0, 800),
  main = '',
  addAQI = FALSE
)

# Then add each timezone in succession

for ( tz in unique(all_monitors$meta$timezone) ) {

  dailyMeans <- dailyMeanList[[tz]]

  monitorCount <- nrow(dailyMeans$meta)

  message(sprintf(
    "Plotting %d monitors in the %s timezone",
    monitorCount, tz
  ))

  # NOTE:  We need to break out each individual monitor so that we can color the
  # NOTE:  points by AQI. There isn't yet a way to do that auto-magically for
  # NOTE:  multi-monitor objects.

  for ( i in seq_len(monitorCount) ) {

    id <- dailyMeanList[[tz]]$meta$deviceDeploymentID[i]

    # Keep going even if we run into an error
    result <- try({

      # Guarantee pm2.5 is of class 'numeric' rather than 'tibble'
      pm2.5 <-
        dailyMeans$data %>%
        dplyr::pull(id)

      # NOTE:  You could also make cex and opacity functions of pm2.5
      monitor_timeseriesPlot(
        dailyMeans,
        id = id,
        opacity = 0.5,
        main = '',
        add = TRUE,
        col = aqiColors(pm2.5),
        cex = aqiCategories(pm2.5)/3,
        pch = 16
      )

    }, silent = TRUE)

    if ( "try-error" %in% class(result) ) {
      sprintf("No plot for %s: %s", id, geterrmessage())
    }

  } # END of monitorCount loop

}

addAQILegend("topleft", title = "Air Quality Index")

title(titleText)

dev.off() # (comment this out if not saving as .png)
