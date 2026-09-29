## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----hex-sticker, echo=FALSE, out.width='200px'-------------------------------
knitr::include_graphics("figures/hex_sticker.png")

## -----------------------------------------------------------------------------
install.packages("bodycon")

## -----------------------------------------------------------------------------
install.packages("remotes")
remotes::install_github("julia-riley/bodycon")

## -----------------------------------------------------------------------------
library(bodycon)

## -----------------------------------------------------------------------------
# View the first (Maritime Gartersnake) dataset
dplyr::glimpse(gartersnake)

## -----------------------------------------------------------------------------
# View the second (Eastern Red-backed Salamander) dataset
dplyr::glimpse(salamander)

## -----------------------------------------------------------------------------

bci_resid_ols(gartersnake, svl_mm, mass_g)

# Piped version
gartersnake |>
  bci_resid_ols(svl_mm, mass_g)


## -----------------------------------------------------------------------------

bci_smi_ols(salamander, svl_mm, mass_g)

# Piped version
salamander |>
  bci_smi_ols(svl_mm, mass_g)


## -----------------------------------------------------------------------------

bci_smi_rob(salamander, svl_mm, mass_g)

# Piped version
salamander |>
  bci_smi_rob(svl_mm, mass_g)


## -----------------------------------------------------------------------------

bci(gartersnake, svl_mm, mass_g, 
    method = c("resid_ols", "smi_ols", "smi_rob"),
    relation = c("linear", "allometric"))

# Piped version
gartersnake |>
  bci(svl_mm, mass_g, 
      method = c("resid_ols", "smi_ols", "smi_rob"),
      relation = c("linear", "allometric"))


## -----------------------------------------------------------------------------

bci(gartersnake, svl_mm, mass_g,
    id = id_num,
    method = c("resid_ols", "smi_ols", "smi_rob"))

# Piped version
gartersnake |>
  bci(svl_mm, mass_g, 
       id = id_num,
       method = c("resid_ols", "smi_ols", "smi_rob"))


## -----------------------------------------------------------------------------
plot_bci(
   gartersnake,
   svl_mm,
   mass_g,
   method = c("resid_ols", "smi_ols", "smi_rob")
   )

## -----------------------------------------------------------------------------
plot_bci(
   gartersnake,
   svl_mm,
   mass_g,
   method = c("resid_ols"),
   relation = c("linear", "allometric")
   )

## -----------------------------------------------------------------------------
plot_bci(
   gartersnake,
   svl_mm,
   mass_g,
   method = c("smi_rob"),
   group = sex
   )

## -----------------------------------------------------------------------------
plot_bci(
   gartersnake,
   svl_mm,
   mass_g,
   method = c("smi_rob"),
   group = sex,
   group_colours = c("M" = "darkorange3", "F" = "darkorchid"),
   method_colours = c("SMI (robust)" = "black")
)

