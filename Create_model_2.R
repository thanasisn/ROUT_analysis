# /* Copyright (C) 2023 Athanasios Natsis <natsisphysicist@gmail.com> */
#' ---
#' title:  "A data driven prediction, based on the finishing times of last few ROUT races"
#' date:   "`r strftime(Sys.time(), '%F', tz= 'Europe/Athens')`"
#' author: "Athanasios N Natsis"
#'
#' output:
#'   bookdown::html_document2:
#'     toc:              yes
#'     number_sections:  no
#'     fig_width:        6
#'     fig_height:       4
#'     keep_md:          no
#'   bookdown::pdf_document2:
#'     number_sections:  no
#'     fig_caption:      no
#'     keep_tex:         no
#'     keep_md:          yes
#'     latex_engine:     xelatex
#'     toc:              yes
#'     toc_depth:        4
#'     fig_width:        6
#'     fig_height:       4
#'   html_document:
#'     toc:             true
#'     number_sections: false
#'     fig_width:       6
#'     fig_height:      4
#'     keep_md:         no
#'
#' header-includes:
#'   - \usepackage{fontspec}
#'   - \usepackage{xunicode}
#'   - \usepackage{xltxtra}
#'   - \usepackage{placeins}
#'   - \geometry{
#'      a4paper,
#'      left     = 20mm,
#'      right    = 20mm,
#'      top      = 25mm,
#'      bottom   = 25mm,
#'      headsep  = 3\baselineskip,
#'      footskip = 4\baselineskip
#'    }
#'   - \setmainfont[Scale=1.2]{Linux Libertine O}
#' ---

#+ echo=F, include=F, warning=F, message=F
rm(list = (ls()[ls() != ""]))
Script.Name <- "~/MANUSCRIPTS/ROUT_analysis/Create_model_2.R"
Sys.setenv(TZ = "UTC")
tic <- Sys.time()

## __ Document options ---------------------------------------------------------
#+ echo=FALSE, include=TRUE
knitr::opts_chunk$set(comment    = ""       )
knitr::opts_chunk$set(dev        = c("pdf", "png")) ## expected option
# knitr::opts_chunk$set(dev        = "png"    )       ## for too much data
knitr::opts_chunk$set(out.width  = "90%"   )
knitr::opts_chunk$set(fig.align  = "center" )
knitr::opts_chunk$set(fig.cap    = " - empty caption - " )
knitr::opts_chunk$set(cache      =  FALSE   )  ## !! breaks calculations
knitr::opts_chunk$set(fig.pos    = 'h!'    )
knitr::opts_chunk$set(tidy = TRUE,
                      tidy.opts = list(
                        indent       = 4,
                        blank        = FALSE,
                        comment      = FALSE,
                        args.newline = TRUE,
                        arrow        = TRUE)
)

## __  Set environment ---------------------------------------------------------
suppressMessages({
  library(data.table, quietly = TRUE, warn.conflicts = FALSE)
  library(janitor,    quietly = TRUE, warn.conflicts = FALSE)
  library(ggplot2,    quietly = TRUE, warn.conflicts = FALSE)
  library(pander,     quietly = TRUE, warn.conflicts = FALSE)
  require(dplyr,      quietly = TRUE, warn.conflicts = FALSE)
  require(readODS,    quietly = TRUE, warn.conflicts = FALSE)
  require(plotly,     quietly = TRUE, warn.conflicts = FALSE)
  require(reticulate, quietly = TRUE, warn.conflicts = FALSE)
  require(grid,       quietly = TRUE, warn.conflicts = FALSE)
  require(gridExtra,  quietly = TRUE, warn.conflicts = FALSE)
  require(gtable,     quietly = TRUE, warn.conflicts = FALSE)
})

source("~/MANUSCRIPTS/ROUT_analysis/DEFINITIONS.R")

## load muliptle years

base_years <- 2023:2025
base_years <- 2023:2024
test_year  <- 2025


DT <- data.table()
for (ay in base_years) {

  dtk_fl <- paste0("~/Documents/Running/ROUT results/ROUT_", ay, ".ods")
  tmp    <- data.table(read_ods(dtk_fl))
  tmp[, year := ay]

  DT     <- rbind(DT, tmp, fill = TRUE)
}


PLANS  <- TRUE


## get locations
CP <- data.table(read_ods(cp_fl))

## get finishers
DT <- DT[!is.na(`K-181Χαϊντού`)]

## drop data
DT[, Bib       := NULL]
DT[, `AZ ID`   := NULL]
DT[, `#`       := NULL]
DT[, Κ.Κ       := NULL]
DT[, Γ.Κ       := NULL]
DT[, Χωρ       := NULL]
DT[, `ΔΧ Ω`    := NULL]
DT[, `ΔΧ %`    := NULL]
DT[, συνμωτ    := NULL]
DT[, `K-0CP-0` := 0]


##  Compute Astropy data  ------------------------------------------------------
py_require("astropy")
py_require("ephem")
source_python("~/BBand_LAP/parameters/sun/sun_vector_astropy_p3.py")
source_python("~/BBand_LAP/parameters/sun/moon_vector_ephem.py")

moon_elevation <- function(date, lat = lat, lon = lon, height = alt) {
  res <- moon_sky_parameters(date, lat = lat, lon = lon, height = height)
  return(res$moon$elevation)
}

moon_phase <- function(date, lat = lat, lon = lon, height = alt) {
  res <- moon_sky_parameters(date, lat = lat, lon = lon, height = height)
  return(res$moon$phase)
}

# ## Call pythons Astropy for sun distance calculation
# sunR_astropy <- function(date) {
#   cbind(t(sun_vector(date, lat = lat, lon = lon, height = alt)), date)
# }

## set gender
DT <- DT |>  mutate(Gender = if_else(grepl("M",Κατ.), "Male", "Female"))

#' \FloatBarrier
#'
#' **Source code: [`github.com/thanasisn/IStillBreakStuff/blob/main/R_MISC/ROUT/Create_model.R`](https://github.com/thanasisn/IStillBreakStuff/blob/main/R_MISC/ROUT/Create_model.R)**
#'
#' # Abstract
#'
#' This document provides a statistical estimation of checkpoint passage times
#' based on a given total race time. These calculations are intended to help
#' runners plan their race strategy. Additionally, we include information about
#' sun and moon positions to assist with overall race planning and strategy.
#'
#+ echo=F, include=T, results="asis", warning=F


## symmetric splits
bbrakes <- 5

#' \FloatBarrier
#'
#' # Data
#'
#' All performance data were obtained directly from the race website
#' (www.rout.gr).  The location of each checkpoint along the race route was
#' derived from the race  GPX track and associated maps.
#'
#'
#' # Classes of models from the `r paste(unique(DT$year), collapse = ", ")` rases results
#'
#' Based on the distribution of total finishing times, we assume there are `r
#' bbrakes` distinct classes of athletes. To construct a corresponding number
#' of models, finishing times were partitioned into equal-sized bins. At this
#' stage, no additional athlete characteristics (such as age, gender, or
#' experience) are considered. For any given total time, the class
#' corresponding to its bin is used.
#'
#+ echo=F, include=T, results="asis", warning=F, fig.cap=paste("Distribution of finishing time in minutes for the", bbrakes, "classes")
breaks_vec <- seq(min(DT$`K-181Χαϊντού`, na.rm = TRUE),
                  max(DT$`K-181Χαϊντού`, na.rm = TRUE),
                  length.out = bbrakes + 1)

g_histcat <- ggplot(DT, aes(x = `K-181Χαϊντού`)) +
  geom_histogram(breaks = breaks_vec,
                 fill   = "steelblue",
                 color  = "black",
                 alpha  = 0.7) +
  labs(title = "Classes of athletes",
       x     = "Minutes",
       y     = "Athletes") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5)) +  # center title
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_continuous(expand = c(0, 0),
                     breaks = breaks_vec,
                     labels = round(breaks_vec, 0))

if (knitr::is_latex_output()) {
  print(g_histcat)
} else if (interactive() | knitr::is_html_output()) {
  ggplotly(g_histcat)
} else {
  print(g_histcat)
}

DT <- DT |> mutate(
  bin   = cut(`K-181Χαϊντού`, breaks = bbrakes),
  binid = as.numeric(cut(`K-181Χαϊντού`, breaks = bbrakes)
  ),
)

# get application bounds
DT$lower <- as.numeric( sub("\\((.+),.*", "\\1",       DT$bin) )
DT$upper <- as.numeric( sub("[^,]*,([^]]*)\\]", "\\1", DT$bin) )


# Model each class

#' \FloatBarrier
#'
#' For each class and for each segment between consecutive checkpoints, we
#' calculated the corresponding mean pace (minutes per kilometer) and nean speed
#' (kilometers per hour). We also computed the average pace and average speed
#' from the start of the race to each checkpoint. The actual source code is
#' displayed below.
#'
#+ echo=T, include=T, results="asis", warning=F

## create model for each class
models <- data.table()
for (id in unique(DT$binid)) {
  tmp <- DT[binid == id]
  tmp <- remove_empty(tmp, "cols")

  ## get representative data as the mean of each group
  TT <- tmp |>
    select(contains("K-")) |>
    summarise_all(mean, na.rm = T) |> t()

  TT <- data.table(TT, keep.rownames = T)
  TT <- rename(.data = TT, Ttime = V1)

  TT$km <- as.numeric(stringr::str_match(TT$rn, "K-(\\d+).*")[,2])
  setorder(TT, km)

  TT$lower <- unique(tmp$lower)
  TT$upper <- unique(tmp$upper)

  ## create model for each CP
  TT[, Dx    := diff(c(0, km))]
  TT[, Dt    := diff(c(0, Ttime))]
  TT[, Pace  := round(Dt / Dx     , 2)] ## min / km
  TT[, Speed := round(Dx / (Dt/60), 2)] ## km / h
  TT[, Class := as.character(id)]

  ## create model for total pace to each CP
  TT[, AvgPace  := round(Ttime / km,         2)]
  TT[, AvgSpeed := round(km    / (Ttime/60), 2)]

  models <- rbind(models, TT)
}
#+ echo=F

CP[, km := NULL]


#' \FloatBarrier
#'
#' The detailed model parameters are shown in Table \@ref(tab:tab-model-details). A comparison of the classes can be seen in the Figure \@ref(fig:models-speed-time) based on elapsed time, and on Figure \@ref(fig:models-speed-km) based on covered distance.
#'
#' Speeds are compared in Figure
#+ tab-model-details, echo=F, results='asis'
models |>
  select(-Dx, -Dt) |>
  mutate(
    Ttime   = minutes_to_hhmm(Ttime),
    lower   = minutes_to_hhmm(lower),
    upper   = minutes_to_hhmm(upper),
    Pace    = minutes_to_mmss(Pace),
    AvgPace = minutes_to_mmss(AvgPace),
    rn      = sub("^K-[0-9]*", "", rn),
  ) |>
  rename(
    CP = rn,
    Time = Ttime,
  ) |>
  arrange(Class, km) |>
  knitr::kable(
    caption = "Details of each class model",
    booktabs = TRUE,
    longtable = TRUE,
    format = ifelse(knitr::is_latex_output(), "latex", "html")
  )

#+ models-speed-time, echo=F, include=T, results="asis", warning=F, fig.cap="Comparison of the speeds over time, in each split for all models"

models[, TtimeH := Ttime / 60 ]

g_bytime <- ggplot(models,
       aes(x = TtimeH,
           y = Speed,
           colour = Class,
           group  = Class)) +
  labs(x = "Time (h)",
       y = "Speed (km/h)") +
  geom_point(alpha = 0.7) +
  geom_line(alpha = 0.7) +
  theme_bw()

if (knitr::is_latex_output()) {
  print(g_bytime)
} else if (interactive() | knitr::is_html_output()) {
  ggplotly(g_bytime)
} else {
  print(g_bytime)
}

#+  models-speed-km, echo=F, include=T, results="asis", warning=F, fig.cap="Comparison of the speeds over distance in each split for all models"
g_bydist <- ggplot(models,
       aes(x = km,
           y = Speed,
           colour = Class,
           group  = Class)) +
  labs(x = "Distance (km)",
       y = "Speed (km/h)") +
  geom_point(alpha = 0.7) +
  geom_line(alpha = 0.7) +
  theme_bw()

if (knitr::is_latex_output()) {
  print(g_bydist)
} else if (interactive() | knitr::is_html_output()) {
  ggplotly(g_bydist)
} else {
  print(g_bydist)
}


## Store models

##  get the actual coordinates of check points for sun calculation
models <- merge(models, CP, by.x = "rn", by.y = "rn" )


#' \FloatBarrier
#'
#' # Create prediction for each hour within it's class
#'
#' Predict passes for a range of finishing time. This was posted online.
#' Sun angles are computed at the actual location of each check point.
#'
#+ echo=F, include=PLANS, results="asis", warning=F

if (PLANS) {

  hours <- (min(models$lower) %/% 60):(max(models$upper) %/% 60)

  for (HH in hours) {
    MM  <- HH * 60
    tmp <- models[ MM < upper & MM > lower]
    if (nrow(tmp) == 0) next

    cat("\\newpage", "\n\n")
    cat("### Hours", HH, "(class", tmp[, unique(Class)], ")\n\n")

    setorder(tmp, Ttime)

    last(tmp$Ttime)

    ## compute change from previous
    change <- 1 - last(tmp$Ttime) / MM

    ## compute scaled times
    tmp$Tnew <- tmp$Ttime * (1 + change)

    tmp$Tnew_hhmm <- minutes_to_hhmm(tmp$Tnew)
    tmp$Tpartial  <- minutes_to_hhmm(c(0, diff(tmp$Tnew) ))
    tmp           <- tmp[-1,]

    tmp$Date     <- START     + tmp$Tnew * 60
    tmp$Date_UTC <- START_UTC + tmp$Tnew * 60

    ## use new time to compute

    tmp[, Dx    := diff(c(0, km))]
    tmp[, Dt    := diff(c(0, Tnew))]
    tmp[, Pace  := round(Dt / Dx     , 2)] ## min / km
    tmp[, Speed := round(Dx / (Dt/60), 2)] ## km / h
    tmp[, AvgPace  := round(Tnew / km,         2)]
    tmp[, AvgSpeed := round(km   / (Tnew/60), 2)]
    tmp[, Tpartial := minutes_to_hhmm(Dt)]

    ## Calculate sun vector
    tmp[, Sun_Elevation := mapply(function(dt, lt, ln, ht) {
      round(sun_vector(dt, lat = lt, lon = ln, height = ht)[[2]], 2)
    }, Date_UTC, lat, lon, alt)]

    tmp[, Moon_Elevation := mapply(function(dt, lt, ln, ht) {
      round(moon_elevation(dt, lat = lt, lon = ln, height = ht), 2)
    }, Date_UTC, lat, lon, alt)]

    tmp[, Moon_Phase_percent := mapply(function(dt, lt, ln, al) {
      100 * round(moon_phase(dt, lat = lt, lon = ln, height = al), 3)
    }, Date_UTC, lat, lon, alt)]

    ## for export
    pp <- tmp[, .(  rn,   km,     Tnew_hhmm,       Tpartial,   Pace,   Speed,   AvgPace,   AvgSpeed,  Date,         Sun_Elevation,         Moon_Elevation, Moon_Phase_percent)]
    names(pp) <- c("CP", "km", "Total time", "Partial time", "Pace", "Speed", "AvgPace", "AvgSpeed", "Date", "Sun elevation angle", "Moon elevation angle", "Moon Phase %")

    pp$Date <- lubridate::round_date(pp$Date, unit = "min")
    pp$Date <- strftime(pp$Date, "%F %R")

    rownames(pp) <- NULL

    ##  Export for pdf  --------
    cat(pander(pp, split.table = Inf))



    # ## create a table as an image
    ttl <- paste0("ROUT finishing target -- ", HH, " -- hours (class ", tmp[, unique(Class)],")")


    # png(paste0("B_", paste(base_years, collapse = "-"), "_C_", tmp[, unique(Class)], "_H_", HH, ".png"), height = 25 * nrow(pp), width = 90 * ncol(pp))
    #
    # t1      <- tableGrob(pp, rows = NULL)
    # title   <- textGrob(ttl, gp = gpar(fontsize = 20))
    # padding <- unit(5,"mm")
    #
    # table <- gtable_add_rows(
    #   t1,
    #   heights = grobHeight(title) + padding,
    #   pos = 0)
    #
    # table <- gtable_add_grob(
    #   table,
    #   title,
    #   1, 1, 1, ncol(table))
    #
    # grid.newpage()
    # grid.draw(table)
    #
    # dev.off()



    png(paste0(EST_TBLS_dr, "/B_", paste(base_years, collapse = "-"), "_C_", tmp[, unique(Class)], "_H_", HH, ".png"),
        height = 25 * nrow(pp),
        width = 90 * ncol(pp))

    # Create a copy of pp for display with visual indicators
    pp_display <- pp

    # Add visual indicators to the Sun elevation angle
    pp_display$`Sun elevation angle` <- ifelse(pp$`Sun elevation angle` > 0,
                                               paste0("🟡 ", pp$`Sun elevation angle`),
                                               paste0("⚫ ", pp$`Sun elevation angle`))

    # Add visual indicators to the Moon elevation angle
    pp_display$`Moon elevation angle` <- ifelse(pp$`Moon elevation angle` > 0,
                                                paste0("🌒 ", pp$`Moon elevation angle`),
                                                paste0("🌑 ", pp$`Moon elevation angle`))


    # Add moon phase symbols to Moon elevation angle based on Moon Phase %
    pp_display$`Moon elevation angle` <- ifelse(pp$`Moon elevation angle` > 0,
                                                # When moon is above horizon, show moon phase
                                                ifelse(pp$`Moon Phase %` < 3, paste0("🌑 ", pp$`Moon elevation angle`),      # New moon
                                                       ifelse(pp$`Moon Phase %` < 25, paste0("🌒 ", pp$`Moon elevation angle`),     # Waxing crescent
                                                              ifelse(pp$`Moon Phase %` < 35, paste0("🌓 ", pp$`Moon elevation angle`),     # First quarter
                                                                     ifelse(pp$`Moon Phase %` < 65, paste0("🌔 ", pp$`Moon elevation angle`),     # Waxing gibbous
                                                                            ifelse(pp$`Moon Phase %` < 75, paste0("🌕 ", pp$`Moon elevation angle`),     # Full moon
                                                                                   ifelse(pp$`Moon Phase %` < 97, paste0("🌖 ", pp$`Moon elevation angle`),     # Waning gibbous
                                                                                          ifelse(pp$`Moon Phase %` < 103, paste0("🌗 ", pp$`Moon elevation angle`),    # Last quarter
                                                                                                 paste0("🌘 ", pp$`Moon elevation angle`)))))))), # Waning crescent
                                                # When moon is below horizon, show dashed moon
                                                # paste0("💨 ", pp$`Moon elevation angle`)
                                                paste0("", pp$`Moon elevation angle`)
    )  # Below horizon

    # Create base table
    t1 <- tableGrob(pp_display, rows = NULL)

    # Add title
    title <- textGrob(ttl, gp = gpar(fontsize = 20))
    padding <- unit(5, "mm")

    table <- gtable_add_rows(
      t1,
      heights = grobHeight(title) + padding,
      pos = 0)

    table <- gtable_add_grob(
      table,
      title,
      1, 1, 1, ncol(table))

    grid.newpage()
    grid.draw(table)

    dev.off()


  }
}


res_fl <- paste0("~/Documents/Running/ROUT results/ROUT_", test_year, ".ods")
if (file.exists(res_fl)) {
  VALIDATE <- TRUE
  RS <- data.table(read_ods(res_fl))
  RS <- RS[!is.na(`K-181Χαϊντού`)]
} else {
  VALIDATE <- FALSE
}


#' \FloatBarrier
#'
#' # Evaluate models against `r test_year` results.
#'
#' For all finishers estimate pass times from each CP, using the appropriate
#' class model. Prediction are based on individual finishing time.
#'
#+ echo=F, include=VALIDATE, fig.width=6, fig.height=6, results="asis", warning=F

if (VALIDATE) {

  gather <- data.table()
  for (al in 1:nrow(RS)) {
    ll  <- RS[al]
    MM  <- ll$`K-181Χαϊντού`
    HH  <- MM / 60
    tmp <- models[ MM < upper & MM > lower]
    if (nrow(tmp) == 0) next

    # cat("\\newpage", "\n\n")
    # cat("### Hours", HH, "model class", tmp[, unique(Class)], "\n\n")

    setorder(tmp, Ttime)

    ## compute change from previous
    change <- 1 - last(tmp$Ttime) / MM

    ## compute scaled times
    tmp$Tnew <- tmp$Ttime * (1 + change)

    tmp$Tnew_hhmm <- minutes_to_hhmm(tmp$Tnew)
    tmp$Tpartial  <- minutes_to_hhmm(c(0, diff(tmp$Tnew) ))
    tmp           <- tmp[-1,]

    # tmp$Date     <- START     + tmp$Tnew * 60
    # tmp$Date_UTC <- START_UTC + tmp$Tnew * 60

    pp <- ll |>
      select(contains("K-")) |>
      t()

    tt <- data.table(
      rn      = rownames(pp),
      ActTime = pp[,1])

    tmps <- merge(tmp, tt)
    setorder(tmps, km)

    gather <- rbind(
      gather,
      tmps[, .(rn, km, Tnew, ActTime, Name = ll$Αθλητής, Class)]
    )
  }
}

#'
#' We excluded finishing time from the statistical evaluation, as the modelled
#' finishing time is equal.
#'
#+ echo=F, include=VALIDATE, results="asis", warning=F

gather <- gather[rn != "K-181Χαϊντού"]

#'
#' ## Summary of % difference for all CP
#'
#+ echo=F, include=VALIDATE, results="asis", warning=F
pander(summary(gather[, 100 * (Tnew - ActTime) / ActTime]))


#'
#' ## Distribution of % difference for all CP and classes
#'
#+ echo=F, include=VALIDATE, results="asis", warning=F
pp <- data.frame(diff = gather[, 100 * (Tnew - ActTime) / ActTime])

g_histall <- ggplot(pp, aes(x = diff)) +
  geom_histogram(aes(y = after_stat(count / sum(count)) * 100),  # Convert to %
                 bins = 20,
                 fill = "lightblue",
                 color = "black") +
  labs(title = "Distribution of % difference for all CP",
       x = "% Difference",
       y = "Percentage (%)") +
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(x, "%"))

if (knitr::is_latex_output()) {
  print(g_histall)
} else if (interactive() | knitr::is_html_output()) {
  ggplotly(g_histall)
} else {
  print(g_histall)
}


#'
#' ## Departures by CP
#'
#' Per cent difference from the modelled time for all classes, by each check point.
#'
#+ echo=F, include=VALIDATE, results="asis", warning=F
for (cp in unique(gather$rn)) {
  tmp <- gather[rn == cp]
  if (nrow(tmp[!is.na(ActTime) & !is.na(Tnew)]) <= 4) next()

  cat("\\newpage", "\n\n")
  cat("#### ", cp, "\n\n")

  pander(summary(tmp[, 100 * (Tnew - ActTime) / ActTime]))

  hist(tmp[, 100 * (Tnew - ActTime) / ActTime],
       breaks = 20,
       freq = FALSE,
       main = paste("Distribution of % difference for", cp))
}


#'
#' ## Departures by class
#'
#' Per cent difference from the modelled time for all check point, fro each class.
#'
#+ echo=F, include=VALIDATE, results="asis", warning=F
for (cl in unique(gather$Class)) {
  tmp <- gather[Class == cl]
  if (nrow(tmp[!is.na(ActTime) & !is.na(Tnew)]) <= 4) next()

  cat("\\newpage", "\n\n")
  cat("#### ", cl, "\n\n")

  pander(summary(tmp[, 100 * (Tnew - ActTime) / ActTime]))

  hist(tmp[, 100 * (Tnew - ActTime) / ActTime],
       breaks = 20,
       freq = FALSE,
       main = paste("Distribution of % difference for class", cl))
}

#'
#' ## Departures by athlete
#'
#' Actual pass time minus predicted passes.
#'
#' Positive values mean that actual time is longer than expected, and the athlete slower than expected.
#'
#+ echo=F, include=VALIDATE, results="asis", warning=F
for (al in unique(gather$Name)) {
  tmp <- gather[Name == al]
  if (nrow(tmp) <= 4) next()

  cat("\\newpage", "\n\n")

  cat(" \n \n")
  cat("#### ", al, "\n \n")

  pander(summary(tmp[, 100 * (Tnew - ActTime) / ActTime]))

  cat(" \n \n")

  # hist(tmp[, 100 * (Tnew - ActTime) / ActTime], breaks = 20,
  #    main = paste("Distribution of % difference for", al))

  cat(" \n \n")
  plot(tmp[, ActTime - Tnew, km ],
       xlab = "",
       ylab = "Diff minutes",
       xaxt = "n",
       main = al)
  abline(h = 0, lty = 2, col = "red")
  axis(1, at = tmp$km, labels = tmp$rn, las = 2)
  cat(" \n \n")
}


#+ include=F, echo=F, results="asis"
tac <- Sys.time()
cat(sprintf("\n**END** %s %s@%s %s %f mins\n\n", Sys.time(), Sys.info()["login"],
            Sys.info()["nodename"], basename(Script.Name), difftime(tac,tic,units = "mins")))
