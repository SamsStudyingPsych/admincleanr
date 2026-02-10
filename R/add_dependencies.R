# --- Replacements for "tidyverse" ---
usethis::use_package("dplyr", type = "Depends")
usethis::use_package("tidyr", type = "Depends")
usethis::use_package("purrr", type = "Depends")
usethis::use_package("tibble", type = "Depends")
usethis::use_package("ggplot2", type = "Depends")

# --- Core Data & Analysis ---
usethis::use_package("data.table", type = "Depends")
usethis::use_package("psych", type = "Depends")
usethis::use_package("janitor", type = "Depends")
usethis::use_package("zoo", type = "Depends")
usethis::use_package("Hmisc", type = "Depends")
usethis::use_package("skimr", type = "Depends")
usethis::use_package("fastDummies", type = "Depends")

# --- IO & Database ---
usethis::use_package("readxl", type = "Depends")
usethis::use_package("openxlsx", type = "Depends")
usethis::use_package("arrow", type = "Depends")
usethis::use_package("excel.link", type = "Depends")
usethis::use_package("odbc", type = "Depends")
usethis::use_package("DBI", type = "Depends")

# --- Geospatial & Maps ---
usethis::use_package("sf", type = "Depends")
usethis::use_package("tigris", type = "Depends")
usethis::use_package("tidygeocoder", type = "Depends")
usethis::use_package("zipcodeR", type = "Depends")
usethis::use_package("osrm", type = "Depends")
usethis::use_package("gmapsdistance", type = "Depends")
usethis::use_package("googleway", type = "Depends")

# --- Visualization & Tables ---
usethis::use_package("gt", type = "Depends")
usethis::use_package("tinytable", type = "Depends")
usethis::use_package("ggnewscale", type = "Depends")
usethis::use_package("ggbreak", type = "Depends")
usethis::use_package("scales", type = "Depends")

# --- Text & String Manipulation ---
usethis::use_package("glue", type = "Depends")
usethis::use_package("stringr", type = "Depends")
usethis::use_package("tidytext", type = "Depends")
usethis::use_package("labelled", type = "Depends")

# --- Utilities ---
usethis::use_package("tictoc", type = "Depends")
usethis::use_package("lubridate", type = "Depends")
usethis::use_package("progress", type = "Depends")
usethis::use_package("rlang", type = "Depends")
usethis::use_package("reticulate", type = "Depends")

# --- Base R Packages ---
usethis::use_package("grDevices", type = "Depends")
usethis::use_package("tools", type = "Depends")

# --- Development Tools ---
# Kept as Suggests because these are for BUILDING, not USING the package
usethis::use_package("usethis", type = "Suggests")
usethis::use_package("devtools", type = "Suggests")

# --- New Dependencies (20260210) ---
usethis::use_package("openxlsx", type = "Depends")
usethis::use_package("readxl", type = "Depends")
usethis::use_package("purrr", type = "Depends")
usethis::use_package("dplyr", type = "Depends")
usethis::use_package("tidygeocoder", type = "Depends") # For split_and_geocode
usethis::use_package("tigris", type = "Depends")       # For county lookups
usethis::use_package("stringdist", type = "Depends")   # For the FASTER matching logic
