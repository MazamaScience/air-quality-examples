# We need text that looks like this for every state:

# ### Oregon
# 
# [Jan](./daily_AQC_tables_OR_01.html)
# [Feb](./daily_AQC_tables_OR_02.html)
# [Mar](./daily_AQC_tables_OR_03.html)
# [Apr](./daily_AQC_tables_OR_04.html)
# [May](./daily_AQC_tables_OR_05.html)
# [Jun](./daily_AQC_tables_OR_06.html)
# [Jul](./daily_AQC_tables_OR_07.html)
# [Aug](./daily_AQC_tables_OR_08.html)
# [Sep](./daily_AQC_tables_OR_09.html)
# [Oct](./daily_AQC_tables_OR_10.html)
# [Nov](./daily_AQC_tables_OR_11.html)
# [Dec](./daily_AQC_tables_OR_12.html)

library(dplyr)

stateCodesDF <-
  MazamaSpatialUtils::US_stateCodes %>%
  dplyr::filter(!stateCode %in% c("DC", "PR"))

# Create a blank file
cat("", file = "index.txt", apppend = FALSE)

for ( i in seq_len(nrow(stateCodesDF)) ) {
  
  stateName <- stateCodesDF$stateName[i]
  stateCode <- stateCodesDF$stateCode[i]
  
  cat(sprintf("\n### %s", stateName), file = "index.txt", append = TRUE)
  cat(sprintf("\n"), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Jan](./daily_AQC_tables_%s_01.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Feb](./daily_AQC_tables_%s_02.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Mar](./daily_AQC_tables_%s_03.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Apr](./daily_AQC_tables_%s_04.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[May](./daily_AQC_tables_%s_05.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Jun](./daily_AQC_tables_%s_06.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Jul](./daily_AQC_tables_%s_07.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Aug](./daily_AQC_tables_%s_08.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Sep](./daily_AQC_tables_%s_09.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Oct](./daily_AQC_tables_%s_10.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Nov](./daily_AQC_tables_%s_11.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n[Dec](./daily_AQC_tables_%s_12.html)", stateCode), file = "index.txt", append = TRUE)
  cat(sprintf("\n"), file = "index.txt", append = TRUE)
  
  
}
