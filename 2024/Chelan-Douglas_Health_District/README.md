# Chelan-Douglas Health District

_Last updated on February 12, 2024_

_Disclaimer: Data presented here come from a variety of sources and do not 
represent official EPA measurements. Please visit
[AirNow](https://www.airnow.gov) for official measurements._

---

## Background

The Chelan-Douglas Health District (CDHP) in north central Washington state is
doing a review of the impacts of smoke during fire seasons over the past decade.
The area of interest covers Chelan, Douglas and Okanogan counties.

The R scripts in this directory assemble available data and generates reports
and data files that may be useful to the CDHP. 
The [AirMonitor](https://github.com/MazamaScience/AirMonitor) 
package is used to access data from the USFS AirFire database of monitoring data.

## Monitoring data

Four R scripts and two RMarkdown documents are used to explore and process 
available monitoring data into simple reports.

**`R/01_explore_monitoring_data.R`**

This script walks through basic exploratory analaysis to understand what data
are available and what additional processing may be need in order to address
the needs of this project.

**`R/02_prepare_monitoring_data.R`**

This script downloads monitoirng data for the years 2014:2023, amends monitor
metadata with county names and then subsets to obtain monitoring data for
Chelan, Douglas and Okanogan counties in north central Washington during the
July - October wildfire season.

**`R/03_render_monitoring_data_reports.R`**

This script provides a way to loop through available years and process a data
report using the `Rmd/monitoring_data.Rmd` RMarkdown document.

**`R/04_explore_daily_statistics.R`**

This script explores tools in the **AirMonitor** package that will be used
to produce the annual air quality category tables.

**`Rmd/daily_AQC_counts.Rmd`**

This RMarkdown document produces a summary report with Air Quality Category
(AQC) tables for every monitoring site. Links are provided, pointing to the
annual data reports.


