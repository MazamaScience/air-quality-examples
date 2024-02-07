# Chelan-Douglas Health District

_Last updated on February 7, 2024_

**_NOTE:_** All R scripts documents assume a common working directory.
To run scripts interactively, RStudio users should set the working directory to
`Chelan-Douglas_Health_District/`.

---

## Background

The Chelan-Douglas Health District (CDHP) in north central Washington state is
doing a review of the impacts of smoke during fire seasons over the past decade.
The area of interest covers Chelan, Douglas and Okanogan counties.

The code in this directory assembles available data and generates reports and
data files that may be useful to the CDHP

## Monitoring data

### Downloading data

Monitoring data is obtained from the USFS AirFire group's data archives with
the `R/assemble_monitoring_data.R` script and saved in the `data/` directory.
For reproducibility, this script can be run to recreate the monitoring data
used in further analyses and reports.
