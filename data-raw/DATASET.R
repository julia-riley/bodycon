## Code to prepare the datasets used in the bodycon R package

library(dplyr)

# Snake Data 
snake_data <- read_csv("data-raw/issac_acker_snake_data.csv")


gartersnake <- 
  snake_data |>
  dplyr::select("species", "snake_id_no", "age (A/J)", "sex (M/F)", "mass_g", "svl_mm", "total_length_mm") |>
  dplyr::filter(species == "Maritime Garter",
         !is.na(svl_mm),
         !is.na(mass_g)) |>
    dplyr::select("snake_id_no", "age (A/J)", "sex (M/F)", "mass_g", "svl_mm", "total_length_mm") |>
    dplyr::rename("age_class" = `age (A/J)`, 
         "sex" = `sex (M/F)`,
         "id_num" = snake_id_no)


# Salamander Data 
salamander_data <- read_csv("data-raw/sara_leslie_salamander_data.csv")


salamander <- 
  salamander_data |>
    dplyr::select("species", "group", "salamander_ID", "sex", "morph", "gravid", "age", "mass_g", "svl_mm", "total_length_mm") |>
    dplyr::filter(species == "RB",
         group == "control",
         gravid == "n" | NA,
         !is.na(svl_mm),
         !is.na(mass_g)) |>
    dplyr::select("salamander_ID", "sex", "morph", "gravid", "age", "mass_g", "svl_mm", "total_length_mm")


usethis::use_data(gartersnake, salamander, overwrite = TRUE)
