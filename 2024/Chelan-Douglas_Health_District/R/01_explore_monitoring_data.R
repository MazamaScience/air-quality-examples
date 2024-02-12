# Step 1) Explore monitoring data for north central Washington state
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

if ( packageVersion("AirMonitor") < "0.4.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirMonitor 0.4.0 or later.")
}

library(AirMonitor)

# ----- Check metadata ---------------------------------------------------------

# The stateCode field is guaranteed to be populated but the countyName field
# may have NAs. Here we check for missing countyNames in WRCC data.

# Create monitor object with annual data for Washington
wrcc <-
  wrcc_loadAnnual(2014) %>%
  monitor_filter(stateCode == "WA")

# Check countyName field in metadata
wrcc %>%
  monitor_pull("countyName") %>%
  unique()

# [1] NA         "Okanogan" "Chelan" 
#
# We see some NAs so we will have to add countyName

# Review all metadata
View(wrcc$meta)

# ----- Check data -------------------------------------------------------------

# Always take a quick look at raw data to see if there are obvious problems

# Plot all hourly data points
wrcc %>%
  monitor_timeseriesPlot()

# We see reasonable looking data in the July-August time frame

# ----- Bottom line ------------------------------------------------------------

# The data look reasonable but we need to add countyName
