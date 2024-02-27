# Step 2) Save annual AirNow files locally
#
# Download annual files in advance

# ----- Setup ------------------------------------------------------------------

VERSION = "1.0.0"

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "State_AQC_Tables$") ) {
  stop("WD_ERROR:  Please set the working directory to 'State_AQC_Tables/'")
}

if ( packageVersion("AirMonitor") < "0.4.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirMonitor 0.4.0 or later.")
}

library(MazamaCoreUtils)
library(AirMonitor)

# Use MazamaCoreUtils logging functionality to save logs in the data/ directory
MazamaCoreUtils::initializeLogging("./data")
logger.setLevel(TRACE)

logger.info("Running prepare_monitoring_data.R version %s", VERSION)

# Log session info to see package versions
logger.debug(capture.output(sessionInfo()))

# ----- Process data -----------------------------------------------------------

# All processed data will live in the data/ directory.

# Configurable parameters
years <- 2014:2023

for ( year in years ) {
  
  logger.info("\n===== %d =====", year)
  
  # * AirNow -------------------------------------------------------------------
  
  logger.info("Processing AirNow %d data...", year)
  
  # Create an AirNow monitor object 
  monitor <-
    airnow_loadAnnual(year)
  
  # Assign a unique object name so that we can load more than one at a time
  objectName <- sprintf("airnow_%d", year)
  assign(objectName, monitor)
  
  # Save to the data/ directory
  fileName <- sprintf("%s.rda", objectName)
  filePath <- file.path("./data", fileName)
  logger.info("Saving %s", filePath)
  save(list = objectName, file = filePath)
  
}

