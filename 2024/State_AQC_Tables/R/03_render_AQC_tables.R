# Step 3) Render the daily_AQC_tables.Rmd report for months and states
#
#
# NOTE:  Data archives begin in 2014

# ----- Setup ------------------------------------------------------------------

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "state_AQC_tables$") ) {
  stop("WD_ERROR:  Please set the working directory to 'state_AQC_tables/'")
}

if ( packageVersion("AirMonitor") < "0.4.0" ) {
  stop("VERSION_ERROR:  Please upgrade to AirMonitor 0.4.0 or later.")
}

# ----- Render daily_AQC_tables reports ----------------------------------------

for ( year in 2014:2023 ) {
  
  params <- list(year = year)
  
  # This path is relative to the Rmd/ directory
  htmlPath <- sprintf("./html/monitoring_data_%d.html", year)
  
  rmarkdown::render(input = 'Rmd/monitoring_data.Rmd',
                    params = params,
                    output_file = htmlPath)
  
}
