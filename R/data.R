#' Maritime Gartersnake Size and Mass Data from the Maritimes
#'
#' This is a subset of data collected by Issac Acker during his Honour's thesis at Mount Allison University on
#' snakes in Nova Scotia and New Brunswick. It includes morphometric data for 46 Maritime Gartersnakes. The paper
#' associated with this data is:  Acker I, Baxter-Gilbert J, Riley JL. In press. Assessing the presence of 
#' Ophidiomyces ophiodiicola on snakes in New Brunswick and Nova Scotia. Herpetological Conservation & Biology, 20(3): 624-638. URL: https://www.herpconbio.org/Volume_20/Issue_3/Acker_etal_2025.pdf
#' 
#' @format ## `gartersnake`
#' A data frame with 46 rows and 6 columns:
#' \describe{
#'   \item{id_num}{A unique identifier for each individual snake measured.}
#'   \item{age_class}{Either J for juvenile or A for adult, depending on the age of the snake.}
#'   \item{sex}{Either F for female, M for male, or NA if the snake was not sexually mature yet (i.e., a juvenile).}
#'   \item{mass_g}{Mass, in grams, of the snake.}
#'   \item{svl_mm}{Snout-vent length (SVL) in mm of the snake. SVL is the distance from the snake's snout to the anterior edge of their cloaca.}
#'   \item{total_length_mm}{Total length in mm of the snake.}
#' }
#' @source <https://www.herpconbio.org/Volume_20/Issue_3/Acker_etal_2025.pdf>
"gartersnake"


#' Eastern Red-backed Salamander Size and Mass Data from New Brunswick
#'
#' This is a subset of data collected by Sara Leslie during her Honour's thesis at Mount Allison University on
#' salamanders in New Brunswick. It includes morphometric data for 128 Eastern Red-backed Salamanders sampled in an
#' old growth forest. The paper associated with this data is:  Leslie S, Edge C, Riley JL. 2025. Herbicide 
#' Application Improves Plethodontid Salamander Habitat Conditions in Regenerating Clear-cut Forests. Canadian 
#' Journal of Forest Research. 55: 1-12. DOI: https://doi.org/10.1139/cjfr-2024-0294
#'
#' @format ## `salamander`
#' A data frame with 183 rows and 8 columns:
#' \describe{
#'   \item{salamander_ID}{A unique identifier for each individual salamander measured.}
#'   \item{sex}{Either F for female, M for male, or J if the snake was not sexually mature yet (i.e., a juvenile).}
#'   \item{gravid}{Either n for no or NA if not applicable. All individuals that were gravid (carrying eggs) were removed from this dataset.}
#'   \item{salamander_ID}{A unique identifier for each individual salamander measured.}
#'   \item{age}{Either J for juvenile or A for adult, depending on the age of the salamander.}   
#'   \item{mass_g}{Mass, in grams, of the salamander.}
#'   \item{svl_mm}{Snout-vent length (SVL) in mm of the salamander. SVL is the distance from the individual's snout to the anterior edge of their cloaca.}
#'   \item{total_length_mm}{Total length in mm of the salamander.}
#' }
#' @source <https://doi.org/10.1139/cjfr-2024-0294>
"salamander"