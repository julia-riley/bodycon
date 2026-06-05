test_that("Check output values are correct", {
  gartersnake |>
    bci_resid_ols(svl_mm, mass_g)
  
  gartersnake_data |>
    bci_smi_ols(svl_mm, mass_g)
  
  gartersnake_data |>
    bci_smi_rob(svl_mm, mass_g)
  
})





test_that("Check output structure is correct", {
  gartersnake_data |>
    bci_resid_ols(svl_mm, mass_g)
  
  gartersnake_data |>
    bci_smi_ols(svl_mm, mass_g)
  
  gartersnake_data |>
    bci_smi_rob(svl_mm, mass_g)
  
})