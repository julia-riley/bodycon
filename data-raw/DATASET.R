## code to prepare `DATASET` dataset goes here

# #Dependencies
library(Stat2Data)
# Example: Hawks (placeholder) 
data("Hawks")
hawks <- Hawks

# # Code to made the data for R package
# # Snake
# data <- read_csv(...
# )
# 
# output <- data  |> filter() |> rename()
# 
# # Sallie data

# https://r-pkgs.org/data.html#sec-documenting-data

usethis::use_data(hawks, overwrite = TRUE)
