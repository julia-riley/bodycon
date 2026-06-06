test_that("Plotting works", {
  # TODO: Need vdiffr expect_dopplerganger
  
  plot_bci(
    gartersnake_data,
    svl_mm,
    mass_g,
    method = c("smi_ols"),
    legend = FALSE
  )
  
  
  plot_bci(
    gartersnake_data,
    svl_mm,
    mass_g,
    method = c("smi_ols", "smi_rob"),
    group = "sex",
    raw_colours = c("M" = "darkorange2", "F" = "mediumpurple"),
    method_colours = c("OLS residuals" = "black", "SMI (robust)" = "navy")
  )
  
  plot_bci(
    gartersnake_data,
    svl_mm,
    mass_g,
    method = c("smi_rob"),
    group = "sex"
  )
  
  plot_bci(
    gartersnake_data,
    svl_mm,
    mass_g,
    method = c("resid_ols", "smi_ols", "smi_rob")
  )
  
})
