# Step 1) Extract data from provided xlsx file
#
# NOTE:  Separate sheets for 2012:2022

# ----- Setup ------------------------------------------------------------------

# Check that the working directory is set properly
if ( !stringr::str_detect(getwd(), "Chelan-Douglas_Health_District$") ) {
  stop("WD_ERROR:  Please set the working directory to 'Chelan-Douglas_Health_District/'")
}

library(AirMonitor)

library(readxl)      # to read in the xlsx file
library(tidyr)       # to pivot the dataframe from "tidy" to "wide"

# ----- Ingest data ------------------------------------------------------------

file <- "./data/CentralWA_24hr_PM25_2012_2022_SmokeSeasonsByYear.xlsx"

sheetNames <- readxl::excel_sheets(file)

# > print(sheetNames)
# [1] "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022"

# Create an empty list to hold all of the dataframes
tidy_dfList <- list()

# Read in all of the data
for ( sheetName in sheetNames ) {
  tidy_dfList[[sheetName]] <- readxl::read_xlsx(file, sheet = sheetName)
}

# > head(tidy_dfList[[1]])
# # A tibble: 6 × 4
# Date                Site                 Conc_ug_m3 Source
# <dttm>              <chr>                     <dbl> <chr> 
# 1 2012-07-01 00:00:00 Wenatchee-Alaska Way         NA Purple
# 2 2012-07-02 00:00:00 Wenatchee-Alaska Way         NA Purple
# 3 2012-07-03 00:00:00 Wenatchee-Alaska Way         NA Purple
# 4 2012-07-04 00:00:00 Wenatchee-Alaska Way         NA Purple
# 5 2012-07-05 00:00:00 Wenatchee-Alaska Way         NA Purple
# 6 2012-07-06 00:00:00 Wenatchee-Alaska Way         NA Purple

# ----- Create compact 'data' dataframe ----------------------------------------

# Combine into a single dataframe, drop the 'Source' column and rename variables
tidy_df <- 
  dplyr::bind_rows(tidy_dfList) %>%
  dplyr::select(-Source) %>%
  dplyr::rename(
    datetime = Date,
    site = Site,
    pm25 = Conc_ug_m3
  )

# Now 'pivot' so there is one timeseries per column
df <-
  tidy_df %>%
  tidyr::pivot_wider(
    names_from = site,
    values_from = pm25
  )

# > dplyr::glimpse(df, width = 75)
# Rows: 1,355
# Columns: 14
# $ datetime               <dttm> 2012-07-01, 2012-07-02, 2012-07-03, 2012-…
# $ `Wenatchee-Alaska Way` <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# $ `Leavenworth-Evans St` <dbl> 2.5, 3.6, 2.0, 5.2, 3.9, 6.3, 7.8, 8.8, 6.…
# $ `Twisp-Glover St`      <dbl> 3.7, 5.0, 2.3, 2.2, 3.9, 6.2, 8.8, 9.4, 7.…
# $ `Winthrop-Chewuch Rd`  <dbl> 3.3, 5.1, 2.0, 1.9, 3.2, 6.6, 8.2, 10.7, 8…
# $ `Omak-Colville Tribe`  <dbl> 3.8, 4.1, 2.6, 2.4, 3.4, 4.1, 6.6, 8.8, 6.…
# $ `Wenatchee-Fifth St`   <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# $ `Chelan-Woodin Ave`    <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# $ Chelan                 <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# $ Leavenworth            <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# $ Omak                   <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# $ Twisp                  <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# $ Wenatchee              <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# $ Winthrop               <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…

# After plotting a few of these, I see that town names identify unique sites
plot(df$datetime, df$`Omak-Colville Tribe`)
points(df$datetime, df$Omak)

# Use uniform town-onlhy names and recreate the 'wide' dataframe
df <-
  tidy_df %>%
  dplyr::mutate(
    site = stringr::str_replace(site, "-.*", "")
  ) %>%
  tidyr::pivot_wider(
    names_from = site,
    values_from = pm25,
    values_fn = mean
  )

plot(df$datetime, df$Wenatchee) 
# Excellent! Contains all years.

# ----- Create 'monitor' object ------------------------------------------------

# Assign metadata from airnow_latest by hand
wa <- airnow_loadLatest() %>% 
  monitor_filter(stateCode == "WA")

# Interactive map
wa %>% monitor_leaflet()

# Click on dots to get these deviceDeploymentIDs
Wenatchee_ddID <- "8e54314f43eb8746_840530070011"
Leavenworth_ddID <- "f4ac27b3de8b9c19_840530070010"
Twisp_ddID <- "3bbe9a9becb9ae96_840530470016"
Winthrop_ddID <- "40ffdacb421a5ee6_840530470010"
Omak_ddID <- "e5d75388f0cfcbf6_840530470013"
Chelan_ddID <- "efce6225e8b2b1b8_840530070007"

ddIDs <- c(
  Wenatchee_ddID,
  Leavenworth_ddID,
  Twisp_ddID,
  Winthrop_ddID,
  Omak_ddID,
  Chelan_ddID
)

# Subset latest data to only retain these monitors
CDHD_daily_smoke_season <- 
  wa %>%
  monitor_select(ddIDs)

# Assign deviceDeploymentIDs as column names in our original 'wide' dataframe
names(df) <- c('datetime', ddIDs)

# Replace latest data with datas from .xlsx file
CDHD_daily_smoke_season$data <- df

# Modify the new metadata to use town-only names
CDHD_daily_smoke_season$meta <-
  CDHD_daily_smoke_season$meta %>%
  dplyr::mutate(
    locationName = stringr::str_replace(locationName, "-.*", "")
  )
  

# Test
CDHD_daily_smoke_season %>% monitor_filterDate(20200701, 20201101) %>% monitor_timeseriesPlot()
CDHD_daily_smoke_season %>% monitor_filterDate(20200701, 20201101) %>% monitor_toAQCTable()

# Save
save(CDHD_daily_smoke_season, file = "./data/CDHD_daily_smoke_season.rda")


