# Step 3) Render the daily_AQC_tables.Rmd report for months and states
#
#
# NOTE:  Data archives begin in 2014

# ----- Setup ------------------------------------------------------------------

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "State_AQC_Tables$") ) {
  stop("WD_ERROR:  Please set the working directory to 'State_AQC_Tables/'")
}

if ( packageVersion("AirMonitor") < "0.4.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirMonitor 0.4.0 or later.")
}

library(MazamaCoreUtils)

logger.setLevel(INFO)

# ----- Render daily_AQC_tables reports ----------------------------------------

skipTheseCodes <- c("GA", "MD", "NC", "OH", "OR", "UT", "VA", "WA", "DC", "PR")

stateCodes <- setdiff(AirMonitor::US_52, skipTheseCodes)

for ( stateCode in stateCodes ) {
  
  for ( month in 1:12 ) {

    logger.info("Generating AQC Tables for %s, %02d", stateCode, month)
    
    params <- 
      list(
        stateCode = "GA",
        month = month
      )
    
    # This path is relative to the Rmd/ directory
    htmlPath <- sprintf("./html/daily_AQC_tables_%s_%02d.html", stateCode, month)
    
    rmarkdown::render(
      input = 'Rmd/daily_AQC_tables.Rmd',
      params = params,
      output_file = htmlPath
    )
    
  }
  
}
