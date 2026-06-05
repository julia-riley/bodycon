test_that("Check output values are correct", {
  
  # OLS Residuals
  ## Using the R package
  bci_resid_ols_pkg <- gartersnake |>
                        bci_resid_ols(svl_mm, mass_g)

  ## Estimation by hand 
  ols <- lm(log(mass_g) ~ log(svl_mm), data = gartersnake)
  bci_resid_ols_hand <- ols$residuals
 
  ## Is bci_resid_ols calculating what we expect (values)?  
  identical(bci_resid_ols_pkg, bci_resid_ols_hand)
  
  # SMI using OLS regression
  ## Using the R package
  bci_smi_ols_pkg <- gartersnake |>
                    bci_smi_ols(svl_mm, mass_g)
  
  ## Estimation by hand 
  x0 <- mean(gartersnake$svl_mm)
  logM_ols <- lm(log(gartersnake$mass_g) ~ log(gartersnake$svl_mm))
  b_msa_ols <- coef(smatr::sma(log(gartersnake$mass_g) ~ log(gartersnake$svl_mm)))[2]
  SMI_ols <- gartersnake$mass_g * (x0 / gartersnake$svl_mm)^b_msa_ols
  bci_smi_ols_hand <- SMI_ols
  
  ## Is bci_smi_ols calculating what we expect (values)?  
  identical(bci_smi_ols_pkg, bci_smi_ols_hand)
  
  # SMI using robust regression
  ## Using the R package
  bci_smi_rob_pkg <- gartersnake_data |>
                        bci_smi_rob(svl_mm, mass_g)
  
  ## Estimation by hand 
  x0 <- mean(gartersnake$svl_mm)
  logM_rob <- MASS::rlm(log(gartersnake$mass_g) ~ log(gartersnake$svl_mm), method = "M")
  b_msa_rob <- coef(smatr::sma(log(gartersnake$mass_g) ~ log(gartersnake$svl_mm), robust = T))[2]
  SMI_rob <- gartersnake$mass_g * (x0 / gartersnake$svl_mm)^b_msa_rob
  bci_smi_rob_hand <- SMI_rob

  ## Is bci_smi_rob calculating what we expect (values)?  
  identical(bci_smi_rob_pkg, bci_smi_rob_hand)
    
})



test_that("Check output structure is correct", {
  gartersnake_data |>
    bci_resid_ols(svl_mm, mass_g)
  
  gartersnake_data |>
    bci_smi_ols(svl_mm, mass_g)
  
  gartersnake_data |>
    bci_smi_rob(svl_mm, mass_g)
  
})