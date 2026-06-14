
## Coordinates file
cp_fl      <- "~/MANUSCRIPTS/ROUT_analysis/side_data/CP_cords.ods"
cp_wth_fl  <- "~/MANUSCRIPTS/ROUT_analysis/side_data/CP_cords_weather.Rds"

## Race start time
START       <- as.POSIXct("2026-10-16 00:00 EEST")
START_UTC   <- as.POSIXct(START, tz = "UTC")

EST_TBLS_dr <- "~/MANUSCRIPTS/ROUT_analysis/Estimation_Tables/"


## Formating dates function
minutes_to_time <- function(minutes, format = c("hh:mm", "mm:ss", "hh:mm:ss")) {
  format <- match.arg(format)

  # Initialize result with NA for all inputs
  result <- rep(NA_character_, length(minutes))

  # Process only non-NA values
  valid <- !is.na(minutes)

  if (any(valid)) {
    if (format == "hh:mm") {
      hours <- floor(minutes[valid] / 60)
      mins  <- round(minutes[valid] %% 60)
      hours[mins == 60] <- hours[mins == 60] + 1
      mins[mins == 60]  <- 0
      result[valid] <- sprintf("%02d:%02d", hours, mins)

    } else if (format == "mm:ss") {
      # Convert minutes to total seconds, then to mm:ss
      total_seconds <- minutes[valid] * 60
      mins <- floor(total_seconds / 60)
      secs <- round(total_seconds %% 60)

      # Handle seconds rounding to 60
      secs[secs == 60] <- 0
      mins[secs == 60] <- mins[secs == 60] + 1

      result[valid] <- sprintf("%02d:%02d", mins, secs)

    } else { # hh:mm:ss
      total_seconds <- minutes[valid] * 60
      hours <- floor(total_seconds / 3600)
      mins  <- floor((total_seconds %% 3600) / 60)
      secs  <- round(total_seconds %% 60)

      secs[secs == 60] <- 0
      mins[secs == 60] <- mins[secs == 60] + 1
      hours[mins == 60] <- hours[mins == 60] + 1
      mins[mins == 60]  <- 0

      result[valid] <- sprintf("%02d:%02d:%02d", hours, mins, secs)
    }
  }

  return(result)
}


minutes_to_hhmm <- function(minutes) {
  minutes_to_time(minutes = minutes, format = "hh:mm")
}

minutes_to_hhmmss <- function(minutes) {
  minutes_to_time(minutes = minutes, format = "hh:mm:ss")
}

minutes_to_mmss <- function(minutes) {
  minutes_to_time(minutes = minutes, format = "mm:ss")
}



