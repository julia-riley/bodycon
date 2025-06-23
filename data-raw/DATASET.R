## Code to prepare the datasets used in the bodycon R package

library(tidyverse)

# Snake Data 
snake_data <- read_csv("data-raw/issac acker_snake_data.csv")

glimpse(snake_data)
table(snake_data$species)

gartersnake_data <- 
  snake_data |>
  select("species", "snake_id_no", "age (A/J)", "sex (M/F)", "mass_g", "svl_mm", "total_length_mm") |>
  filter(species == "Maritime Garter",
         !is.na(svl_mm),
         !is.na(mass_g)) |>
  select("snake_id_no", "age (A/J)", "sex (M/F)", "mass_g", "svl_mm", "total_length_mm") |>
  rename("age_class" = `age (A/J)`, 
         "sex" = `sex (M/F)`,
         "id_num" = snake_id_no)


# Salamander Data 
salamander_data <- read_csv("data-raw/sara leslie_salamander_data.csv")

glimpse(salamander_data)
table(snake_data$species)

erbs_data <- 
  salamander_data |>
  select("species", "group", "salamander_ID", "sex", "morph", "gravid", "age", "mass_g", "svl_mm", "total_length_mm") |>
  filter(species == "RB",
         group == "control",
         gravid == "n" | NA,
         !is.na(svl_mm),
         !is.na(mass_g)) |>
  select("salamander_ID", "sex", "morph", "gravid", "age", "mass_g", "svl_mm", "total_length_mm")

dim(erbs_data)

usethis::use_data(gartersnake_data, erbs_data, overwrite = TRUE)
