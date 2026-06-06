# Are values that are calculated what we expect?
test_that("Check output values are correct", {
  
  # OLS Residuals (Allometric)
  ## Using the R package
  results <- gartersnake |>
               bci_resid_ols(svl_mm, mass_g)
  bci_resid_ols_pkg1 <- results$resid_allometric
  
  ##Estimation by hand 
  ols <- lm(log(mass_g) ~ log(svl_mm), data = gartersnake)
  bci_resid_ols_hand1 <- (ols$residuals)
  
  ## Is bci_resid_ols calculating what we expect (values)?  
  expect_true(identical(bci_resid_ols_pkg1, bci_resid_ols_hand1))
  
  # OLS Residuals (Linear)
  ## Using the R package
  results <- gartersnake |>
    bci_resid_ols(svl_mm, mass_g)
  bci_resid_ols_pkg2 <- results$resid_linear
  
  ##Estimation by hand 
  ols <- lm(mass_g ~ svl_mm, data = gartersnake)
  bci_resid_ols_hand2 <- (ols$residuals)
  
  ## Is bci_resid_ols calculating what we expect (values)?  
  expect_true(identical(bci_resid_ols_pkg2, bci_resid_ols_hand2))
  
  # SMI using OLS regression
  ## Using the R package
  results <- gartersnake |>
              bci_smi_ols(svl_mm, mass_g)
  bci_smi_ols_pkg <- results$smi_ols
  
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
  bci_smi_rob_pkg <- results$smi_rob
  
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
  
  skip_on_cran()
  
  out <- suppressWarnings(
  bci(
    gartersnake,
    body_size = svl_mm,
    weight = mass_g,
    method = c("resid_ols", "smi_ols")
  ))
  
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), nrow(gartersnake))
  
  expect_true(all(c("resid_allometric", "smi_ols") %in% names(out)))
})


# Does method selection work?
test_that("bci respects method selection", {
  
  skip_on_cran()
  
  data <- data.frame(
    svl = 1:10,
    mass = 1:10
  )
  
  out <- suppressWarnings(
    bci(data, svl, mass, method = "resid_ols")
  )
  
  expect_true("resid_allometric" %in% names(out))
  expect_false("smi_ols" %in% names(out))
  expect_false("smi_rob" %in% names(out))
})

# Does the 'bci' function include ID when requested?
test_that("bci includes ID when requested", {
  
  skip_on_cran()
  
  out <- suppressWarnings(
    bci(salamander, svl_mm, mass_g, id = salamander_ID)
  )
  
  expect_true("id" %in% names(out))
  expect_true(identical(out$id, salamander$salamander_ID))
})


# Does the 'bci' function include ID if NOT requested?
test_that("bci excludes ID when not provided", {

  skip_on_cran()
  
  out <- suppressWarnings(
    bci(salamander, svl_mm, mass_g)
  )
  
  expect_false("id" %in% names(out))
})


# Are the bci outputs numeric and finite?
test_that("bci outputs are numeric and finite", {
  
  skip_on_cran()
  
  out <- suppressWarnings(
    bci(salamander, svl_mm, mass_g, method = c("resid_ols", "smi_ols"))
  )
  
  num_cols <- sapply(out, is.numeric)
  
  expect_true(all(is.finite(unlist(out[, num_cols]))))
})

#Does bci_resid_ols return the allometric column correctly?
test_that("bci_resid_ols returns allometric column correctly", {
  res <- bci_resid_ols(
    gartersnake,
    svl_mm,
    mass_g,
    relation = "allometric"
  )
  
  expect_s3_class(res, "tbl_df")
  expect_true("resid_allometric" %in% names(res))
  expect_false("resid_linear" %in% names(res))
})

#Does bci_resid_ols return both allometric and linear column when requested?
test_that("bci_resid_ols returns both allometric and linear", {
  
  res <- bci_resid_ols(
    gartersnake,
    svl_mm,
    mass_g,
    relation = c("allometric", "linear")
  )
  
  expect_true(all(c(
    "resid_allometric",
    "resid_linear"
  ) %in% names(res)))
})

# Is the linear warning produced?
test_that("bci_resid_ols warns when linear is selected", {
  
  expect_warning(
    bci_resid_ols(
      gartersnake,
      svl_mm,
      mass_g,
      relation = "linear"
    )
  )
})

# Does the output length match the input length?
test_that("bci_resid_ols output length matches input", {
  
  res <- bci_resid_ols(gartersnake, svl_mm, mass_g)
  
  expect_equal(nrow(res), nrow(gartersnake))
})

#Does bci() return columns for all methods?
test_that("bci returns correct columns for all methods", {
  
  skip_on_cran()
  
  res <- suppressWarnings(
    bci(
    gartersnake,
    svl_mm,
    mass_g,
    method = c("resid_ols", "smi_ols", "smi_rob")
  ))
  
  expect_true(any(grepl("resid_", names(res))))
  expect_true("smi_ols" %in% names(res))
  expect_true("smi_rob" %in% names(res))
})

#Does the argument 'relation' affect only resid_ols?
test_that("relation only affects resid_ols in bci()", {
  
  skip_on_cran()
  
  res <- suppressWarnings(
    bci(
    gartersnake,
    svl_mm,
    mass_g,
    method = c("smi_ols"),
    relation = "linear"
  ))
  
  expect_true("smi_ols" %in% names(res))
})

# Is a warning triggers in bci() when relation = linear is used?
test_that("SMI methods trigger warning with linear relation", {
  
  expect_warning(
    bci(
      gartersnake,
      svl_mm,
      mass_g,
      method = "smi_ols",
      relation = "linear"
    ),
    "SMI methods"
  )
  })
  
  # Does error occurs when relation = linear is improperly used?
  test_that("invalid relation-method combo throws error", {
    
    skip_on_cran()
    
    expect_error(
      suppressWarnings(bci(
        gartersnake,
        svl_mm,
        mass_g,
        method = c("smi_ols", "smi_rob"),
        relation = "linear"
      )))
  })
  
  
  #Does bci() handle NA values okay?
  test_that("functions handle NA values", {
    
    skip_on_cran()
    
    df <- gartersnake
    df$svl_mm[1] <- NA
    
    res <- suppressWarnings(
      bci(df, svl_mm, mass_g, id = id_num, method = "smi_ols")
    )
    
    expect_true(nrow(res) == nrow(df))
  })

  # Does referring to a single method still return a tibble?
  test_that("single method still returns tibble", {
    
    skip_on_cran()
    
    res <- suppressWarnings(
      bci(
      gartersnake,
      svl_mm,
      mass_g,
      method = "smi_rob"
    ))
    
    expect_s3_class(res, "tbl_df")
  })
  
  #Does SMI ignore the relation = linear?
  test_that("SMI ignores linear relation safely in plot", {
    
    expect_warning(
      plot_bci(
        gartersnake,
        svl_mm,
        mass_g,
        method = "smi_ols",
        relation = "linear"
      ),
      "SMI"
    )
  })
  
