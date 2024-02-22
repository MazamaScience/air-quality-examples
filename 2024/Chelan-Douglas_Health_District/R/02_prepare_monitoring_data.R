# Step 2) Prepare monitoring data for north central Washington state
#
# After running 01_explore_monitoring_data.R we know:
# - data only exist starting in 2014
# - we need to ensure that countyName is populated before filtering on that field

# ----- Setup ------------------------------------------------------------------

VERSION = "1.0.0"

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "Chelan-Douglas_Health_District$") ) {
  stop("WD_ERROR:  Please set the working directory to 'Chelan-Douglas_Health_District/'")
}

if ( packageVersion("AirMonitor") < "0.4.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirMonitor 0.4.0 or later.")
}

library(MazamaCoreUtils)
library(MazamaSpatialUtils)
library(AirMonitor)

# Load dataset used to assign countyName
setSpatialDataDir("~/Data/Spatial")
loadSpatialData("USCensusCounties")

# Use MazamaCoreUtils logging functionality to save logs in the data/ directory
MazamaCoreUtils::initializeLogging("./data")
logger.setLevel(TRACE)

logger.info("Running prepare_monitoring_data.R version %s", VERSION)

# Log session info to see package versions
logger.debug(capture.output(sessionInfo()))

# ----- Internal functions -----------------------------------------------------

# The AirMonitor package does not have a monitor_addCountyName() function so we
# create one here that can be used in a pipeline recipe. If a monitor is empty,
# we return it without processing so that this function does not error out in
# the middle of a recipe.

monitor_addCountyName <- function(monitor, stateCodes = ("WA")) {
  if ( !monitor_isEmpty(monitor) ) {
    monitor$meta$countyName <- 
      MazamaSpatialUtils::getUSCounty(
        monitor$meta$longitude, 
        monitor$meta$latitude, 
        stateCodes = stateCodes, 
        useBuffering = TRUE
      )  
  }
  return(monitor)
}

# ----- Process data -----------------------------------------------------------

# All processed data will live in the data/ directory.

# Configurable parameters
years <- 2014:2023
start_MMDD <- "0701"                   # appended to year to get YYYYMMDD
end_MMDD <- "1101"                     # appended to year to get YYYYMMDD
countyNames <- c("Chelan", "Douglas", "Okanogan")
timezone <- "America/Los_Angeles"

for ( year in years ) {
  
  logger.info("\n===== %d =====", year)
  
  startdate <- sprintf("%d%s", year, start_MMDD)
  enddate <- sprintf("%d%s", year, end_MMDD)
  
  # * AirNow -------------------------------------------------------------------
  
  logger.info("Processing AirNow %d data...", year)
  
  # Create an AirNow monitor object 
  monitor <- 
    airnow_loadAnnual(year) %>% 
    monitor_filter(stateCode == "WA") %>%
    monitor_addCountyName(stateCodes = c("WA")) %>%
    monitor_filter(countyName %in% countyNames)
  
  if ( monitor_isEmpty(monitor) ) {
    logger.warn("No AirNow data found in %d. Any empty monitor object will be saved.", year)
  } else {
    monitor <-
      monitor %>%
      monitor_filterDate(startdate, enddate, timezone)
  }
  
  # Assign a unique object name so that we can load more than one at a time
  objectName <- sprintf("airnow_%d", year)
  assign(objectName, monitor)
  
  # Save to the data/ directory
  fileName <- sprintf("%s.rda", objectName)
  filePath <- file.path("./data", fileName)
  logger.info("Saving %s", filePath)
  save(list = objectName, file = filePath)
  
  # * AIRSIS -------------------------------------------------------------------
  
  logger.info("Processing AIRSIS %d data...", year)
  
  # Create an AIRSIS monitor object 
  monitor <- 
    airsis_loadAnnual(year) %>% 
    monitor_filter(stateCode == "WA") %>%
    monitor_addCountyName(stateCodes = c("WA")) %>%
    monitor_filter(countyName %in% countyNames)
  
  if ( monitor_isEmpty(monitor) ) {
    logger.warn("No AIRSIS data found in %d. Any empty monitor object will be saved.", year)
  } else {
    monitor <-
      monitor %>%
      monitor_filterDate(startdate, enddate, timezone)
  }
  
  # Assign a unique object name so that we can load more than one at a time
  objectName <- sprintf("airsis_%d", year)
  assign(objectName, monitor)
  
  # Save to the data/ directory
  fileName <- sprintf("%s.rda", objectName)
  filePath <- file.path("./data", fileName)
  logger.info("Saving %s", filePath)
  save(list = objectName, file = filePath)
  
  # * WRCC ---------------------------------------------------------------------
  
  logger.info("Processing WRCC %d data...", year)
  
  # Create a WRCC monitor object 
  monitor <- 
    wrcc_loadAnnual(year) %>% 
    monitor_filter(stateCode == "WA") %>%
    monitor_addCountyName(stateCodes = c("WA")) %>%
    monitor_filter(countyName %in% countyNames)
  
  if ( monitor_isEmpty(monitor) ) {
    logger.warn("No WRCC data found in %d. Any empty monitor object will be saved.", year)
  } else {
    monitor <-
      monitor %>%
      monitor_filterDate(startdate, enddate, timezone)
  }
  
  # Assign a unique object name so that we can load more than one at a time
  objectName <- sprintf("wrcc_%d", year)
  assign(objectName, monitor)
  
  # Save to the data/ directory
  fileName <- sprintf("%s.rda", objectName)
  filePath <- file.path("./data", fileName)
  logger.info("Saving %s", filePath)
  save(list = objectName, file = filePath)
  
}

