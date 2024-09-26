library(tidyverse)
library(data.table)
all_years_data <- list()
file_root<-"https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h"
tail<- ".txt.gz&dir=data/historical/stdmet/"
for (year in 1985:2023) {
  path <- paste0(file_root,year,tail)
  header <- scan(path,what= 'character',nlines=1)
  skip_lines <- ifelse(header[1] == "YY",1,2)
  buoy <- fread(path,header=FALSE,skip=skip_lines,fill = Inf)
  colnames(buoy)<-header
  if ("#YY" %in% colnames(buoy)) {
    colnames(buoy)[colnames(buoy) == "#YY"] <- "YY"
  }
  if ("WD" %in% colnames(buoy)) {
    colnames(buoy)[colnames(buoy) == "WD"] <- "WDIR"
  }
  if ("BAR" %in% colnames(buoy)) {
    colnames(buoy)[colnames(buoy) == "BAR"] <- "PRES"
  }
  if ("mm" %in% colnames(buoy)) {
    buoy <- buoy %>%  mutate(Date=ymd_hm(paste(buoy$YY, buoy$MM, buoy$DD, buoy$hh, buoy$mm)), .before = 1)
  } else {
    buoy <- buoy %>%  mutate(Date=ymd_h(paste(buoy$YY, buoy$MM, buoy$DD, buoy$hh)), .before = 1)
  }
  buoy <- buoy[, !c("YY", "MM", "DD", "hh", "mm", "YYYY"),with = FALSE]
  all_years_data[[as.character(year)]] <- buoy
}
combined_data <- rbindlist(all_years_data, fill = TRUE)
fwrite(combined_data, "buoy_data_1985_2023.csv")
