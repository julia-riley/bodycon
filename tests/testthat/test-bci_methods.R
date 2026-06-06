# Are values that are calculated what we expect?
test_that("Check output values are correct", {
  
  # OLS Residuals
  ## Using the R package
  results <- gartersnake |>
               bci_resid_ols(svl_mm, mass_g)
  bci_resid_ols_pkg <- results$bci_resid_ols
  
  ##Estimation by hand 
  ols <- lm(log(mass_g) ~ log(svl_mm), data = gartersnake)
  bci_resid_ols_hand <- (ols$residuals)
  
  ## Is bci_resid_ols calculating what we expect (values)?  
  expect_true(identical(bci_resid_ols_pkg, bci_resid_ols_hand))
  
  # SMI using OLS regression
  ## Using the R package
  results <- gartersnake |>
              bci_smi_ols(svl_mm, mass_g)
  bci_smi_ols_pkg <- results$bci_smi_ols
  
  ## Estimation by hand 
  x0 <- mean(gartersnake$svl_mm)
  logM_ols <- lm(log(gartersnake$mass_g) ~ log(gartersnake$svl_mm))
  b_msa_ols <- coef(smatr::sma(log(gartersnake$mass_g) ~ log(gartersnake$svl_mm)))[2]
  SMI_ols <- gartersnake$mass_g * (x0 / gartersnake$svl_mm)^b_msa_ols
  bci_smi_ols_hand <- SMI_ols
  
  ## Is bci_smi_ols calculating what we expect (values)?  
  expect_true(identical(bci_smi_ols_pkg, bci_smi_ols_hand))
  
  # SMI using robust regression
  ## Using the R package
  results <- gartersnake |>
                bci_smi_rob(svl_mm, mass_g)
  bci_smi_rob_pkg <- results$bci_smi_rob
  
  ## Estimation by hand 
  x0 <- mean(gartersnake$svl_mm)
  logM_rob <- MASS::rlm(log(gartersnake$mass_g) ~ log(gartersnake$svl_mm), method = "M")
  b_msa_rob <- coef(smatr::sma(log(gartersnake$mass_g) ~ log(gartersnake$svl_mm), robust = T))[2]
  SMI_rob <- gartersnake$mass_g * (x0 / gartersnake$svl_mm)^b_msa_rob
  bci_smi_rob_hand <- SMI_rob
  
  ## Is bci_smi_rob calculating what we expect (values)?  
  expect_true(identical(bci_smi_rob_pkg, bci_smi_rob_hand))
  
  })


# Is the structure of 'bci' function output correct?
test_that("bci returns tibble with correct structure", {
  
  data <- data.frame(
    id = 1:10,
    svl = seq(10, 19),
    mass = seq(5, 14)
  )
  
  out <- bci(
    data,
    body_size = svl,
    weight = mass,
    method = c("resid_ols", "smi_ols")
  )
  
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), nrow(data))
  
  expect_true(all(c("bci_resid_ols", "bci_smi_ols") %in% names(out)))
})


# Does method selection work?
test_that("bci respects method selection", {
  
  data <- data.frame(
    svl = 1:10,
    mass = 1:10
  )
  
  out <- bci(data, svl, mass, method = "resid_ols")
  
  expect_true("bci_resid_ols" %in% names(out))
  expect_false("bci_smi_ols" %in% names(out))
  expect_false("bci_smi_rob" %in% names(out))
})

# Does the 'bci' function include ID when requested?
test_that("bci includes ID when requested", {
  
  out <- bci(salamander, svl_mm, mass_g, id = salamander_ID)
  
  expect_true("id" %in% names(out))
  expect_true(identical(out$id, salamander$salamander_ID))
})


# Does the 'bci' function include ID if NOT requested?
test_that("bci excludes ID when not provided", {

  out <- bci(salamander, svl_mm, mass_g)
  
  expect_false("id" %in% names(out))
})


# Are the bci outputs numeric and finite?
test_that("bci outputs are numeric and finite", {
  
  out <- bci(salamander, svl_mm, mass_g, method = c("resid_ols", "smi_ols"))
  
  num_cols <- sapply(out, is.numeric)
  
  expect_true(all(is.finite(unlist(out[, num_cols]))))
})
