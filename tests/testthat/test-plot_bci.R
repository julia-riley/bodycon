# Test of Basic Plot
test_that("plot_bci basic plot renders correctly", {
  
  p <- plot_bci(
    data = gartersnake,
    body_size = svl_mm,
    weight = mass_g,
    legend = TRUE
  )
  
  vdiffr::expect_doppelganger("bci-basic", p)
})


# Tests of Plot with Grouping
## Age
test_that("plot_bci with grouping renders correctly", {
  
  p <- plot_bci(
    data = salamander,
    body_size = svl_mm,
    weight = mass_g,
    group = age,
    legend = TRUE
  )
  
  vdiffr::expect_doppelganger("bci-group-age", p)
})

## Sex
test_that("plot_bci with grouping renders correctly", {
  
  p <- plot_bci(
    data = gartersnake,
    body_size = svl_mm,
    weight = mass_g,
    group = sex,
    legend = TRUE
  )
  
  vdiffr::expect_doppelganger("bci-group-sex", p)
})


# OLS residual method
test_that("plot_bci only OLS method", {
  
  p <- plot_bci(
    data = salamander,
    body_size = svl_mm,
    weight = mass_g,
    method = "resid_ols"
  )
  
  vdiffr::expect_doppelganger("bci-ols-only", p)
})


# SMI OLS method only
test_that("plot_bci SMI OLS only", {
  
  p <- plot_bci(
    data = salamander,
    body_size = svl_mm,
    weight = mass_g,
    method = "smi_ols"
  )
  
  vdiffr::expect_doppelganger("bci-smi-ols-only", p)
})


# SMI robus method only
test_that("plot_bci SMI robust only", {
  
  p <- plot_bci(
    data = gartersnake,
    body_size = svl_mm,
    weight = mass_g,
    method = "smi_rob"
  )
  
  vdiffr::expect_doppelganger("bci-smi-rob-only", p)
})


# Plot without legend
test_that("plot_bci without legend", {
  
  p <- plot_bci(
    data = salamander,
    body_size = svl_mm,
    weight = mass_g,
    group = sex,
    legend = FALSE
  )
  
  vdiffr::expect_doppelganger("bci-no-legend", p)
})


# Plot tha also returns predictions
test_that("plot_bci returns predictions correctly", {
  
  out <- plot_bci(
    data = salamander,
    body_size = svl_mm,
    weight = mass_g,
    return_predictions = TRUE
  )
  
  expect_true(is.list(out))
  expect_true("plot" %in% names(out))
  expect_true("predictions" %in% names(out))
  expect_true("data" %in% names(out))
})

#Does the plot show both linear and alometric when requested?
test_that("plot_bci shows linear and allometric when requested", {
  
  res <- plot_bci(
    gartersnake,
    svl_mm,
    mass_g,
    method = "resid_ols",
    relation = c("allometric", "linear")
  )
  
  expect_s3_class(res, "ggplot")
})

#Does this real-world mixed-methods version work?
test_that("plot_bci mixed methods snapshot", {
  
  skip_on_cran()
  
  p <- plot_bci(
    gartersnake,
    svl_mm,
    mass_g,
    method = c("resid_ols", "smi_ols", "smi_rob"),
    relation = "allometric"
  )
  
  vdiffr::expect_doppelganger(
    "plot_bci_all_methods",
    p
  )
})

#Does plot grouping work?
test_that("plot_bci grouping snapshot", {
  
  p <- plot_bci(
    gartersnake,
    svl_mm,
    mass_g,
    method = "resid_ols",
    relation = "allometric",
    group = sex
  )
  
  vdiffr::expect_doppelganger(
    "plot_bci_grouped",
    p
  )
})