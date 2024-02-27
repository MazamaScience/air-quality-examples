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

# ----- Render daily_AQC_tables reports ----------------------------------------

for ( month in 4:4 ) {
  
  params <- 
    list(
      stateCode = "GA",
      timezone = "America/New_York",
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
