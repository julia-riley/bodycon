## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 5,
  out.width = "100%"
)

## ----eval = FALSE-------------------------------------------------------------
# install.packages("bodycon")

## ----eval = FALSE-------------------------------------------------------------
# install.packages("remotes")
# remotes::install_github("julia-riley/bodycon")

## -----------------------------------------------------------------------------
library(bodycon)

## -----------------------------------------------------------------------------
dplyr::glimpse(gartersnake)

## -----------------------------------------------------------------------------
dplyr::glimpse(salamander)

## -----------------------------------------------------------------------------
bci_resid_ols(gartersnake, svl_mm, mass_g)

## -----------------------------------------------------------------------------

bci_smi(salamander, svl_mm, mass_g)


## -----------------------------------------------------------------------------

bci_smi_rob(salamander, svl_mm, mass_g)


## -----------------------------------------------------------------------------

bci(gartersnake, svl_mm, mass_g, 
    method = c("resid_ols", "smi", "smi_rob"),
    relation = c("linear", "allometric"))


## -----------------------------------------------------------------------------

bci(gartersnake, svl_mm, mass_g,
    id = id_num,
    method = c("resid_ols", "smi", "smi_rob"))


## -----------------------------------------------------------------------------
plot_bci(
   gartersnake,
   svl_mm,
   mass_g,
   method = c("resid_ols", "smi", "smi_rob")
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

