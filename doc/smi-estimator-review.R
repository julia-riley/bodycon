## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 5,
  out.width = "100%",
  digits = 4
)

## ----packages, message=FALSE--------------------------------------------------
library(bodycon)

## ----helpers------------------------------------------------------------------
fit_candidates <- function(data, size, mass) {
  log_size <- log(data[[size]])
  log_mass <- log(data[[mass]])

  ols <- stats::lm(log_mass ~ log_size)
  robust_ols <- MASS::rlm(log_mass ~ log_size, method = "M")
  sma <- smatr::sma(
    log_mass ~ log_size,
    method = "SMA",
    robust = FALSE,
    quiet = TRUE
  )
  robust_sma <- smatr::sma(
    log_mass ~ log_size,
    method = "SMA",
    robust = TRUE,
    quiet = TRUE
  )

  data.frame(
    estimator = c("OLS", "Robust OLS (MASS::rlm)",
                  "SMA", "Robust SMA (smatr)"),
    intercept = c(
      unname(stats::coef(ols)[1]),
      unname(stats::coef(robust_ols)[1]),
      unname(stats::coef(sma)[1]),
      unname(stats::coef(robust_sma)[1])
    ),
    slope = c(
      unname(stats::coef(ols)[2]),
      unname(stats::coef(robust_ols)[2]),
      unname(stats::coef(sma)[2]),
      unname(stats::coef(robust_sma)[2])
    )
  )
}

calculate_smi <- function(data, size, mass, slope) {
  size_values <- data[[size]]
  mass_values <- data[[mass]]
  reference_size <- mean(size_values, na.rm = TRUE)

  mass_values * (reference_size / size_values)^slope
}

candidate_indices <- function(data, size, mass) {
  fits <- fit_candidates(data, size, mass)
  values <- lapply(
    fits$slope,
    function(slope) calculate_smi(data, size, mass, slope)
  )
  names(values) <- fits$estimator
  values
}

## ----slope-table--------------------------------------------------------------
snake_fits <- fit_candidates(gartersnake, "svl_mm", "mass_g")
snake_fits$dataset <- "Gartersnake"

salamander_fits <- fit_candidates(salamander, "svl_mm", "mass_g")
salamander_fits$dataset <- "Salamander"

slope_table <- rbind(snake_fits, salamander_fits)
slope_table <- slope_table[c("dataset", "estimator", "slope", "intercept")]

knitr::kable(
  slope_table,
  digits = 4,
  caption = "Candidate fits for the two bodycon datasets. Fits use natural-log mass and body size."
)

## ----current-behavior---------------------------------------------------------
snake_indices <- candidate_indices(gartersnake, "svl_mm", "mass_g")
salamander_indices <- candidate_indices(salamander, "svl_mm", "mass_g")

current_check <- data.frame(
  dataset = c("Gartersnake", "Gartersnake", "Salamander", "Salamander"),
  package_output = c("bci_smi_ols", "bci_smi_rob",
                     "bci_smi_ols", "bci_smi_rob"),
  candidate = c("SMA", "Robust SMA (smatr)",
                "SMA", "Robust SMA (smatr)"),
  maximum_absolute_difference = c(
    max(abs(
      bci_smi_ols(gartersnake, svl_mm, mass_g)$smi_ols -
        snake_indices[["SMA"]]
    )),
    max(abs(
      bci_smi_rob(gartersnake, svl_mm, mass_g)$smi_rob -
        snake_indices[["Robust SMA (smatr)"]]
    )),
    max(abs(
      bci_smi_ols(salamander, svl_mm, mass_g)$smi_ols -
        salamander_indices[["SMA"]]
    )),
    max(abs(
      bci_smi_rob(salamander, svl_mm, mass_g)$smi_rob -
        salamander_indices[["Robust SMA (smatr)"]]
    ))
  )
)

knitr::kable(
  current_check,
  digits = 12,
  caption = "The current public functions reproduce the SMA candidates, not the fitted lm or MASS::rlm candidates."
)

## ----index-summary------------------------------------------------------------
summarise_candidates <- function(indices, dataset) {
  reference <- indices[["SMA"]]

  do.call(
    rbind,
    lapply(names(indices), function(estimator) {
      values <- indices[[estimator]]
      data.frame(
        dataset = dataset,
        estimator = estimator,
        mean_smi = mean(values, na.rm = TRUE),
        sd_smi = stats::sd(values, na.rm = TRUE),
        maximum_absolute_difference_from_sma =
          max(abs(values - reference), na.rm = TRUE),
        correlation_with_sma = stats::cor(values, reference,
                                          use = "complete.obs")
      )
    })
  )
}

index_summary <- rbind(
  summarise_candidates(snake_indices, "Gartersnake"),
  summarise_candidates(salamander_indices, "Salamander")
)

knitr::kable(
  index_summary,
  digits = 4,
  caption = "How alternative exponents change SMI values relative to classical SMA."
)

## ----fit-plot-----------------------------------------------------------------
plot_data <- rbind(
  data.frame(
    dataset = "Gartersnake",
    log_size = log(gartersnake$svl_mm),
    log_mass = log(gartersnake$mass_g)
  ),
  data.frame(
    dataset = "Salamander",
    log_size = log(salamander$svl_mm),
    log_mass = log(salamander$mass_g)
  )
)

line_data <- slope_table

ggplot2::ggplot(plot_data, ggplot2::aes(log_size, log_mass)) +
  ggplot2::geom_point(alpha = 0.55) +
  ggplot2::geom_abline(
    data = line_data,
    ggplot2::aes(slope = slope, intercept = intercept, colour = estimator),
    linewidth = 0.9
  ) +
  ggplot2::facet_wrap(~ dataset, scales = "free") +
  ggplot2::labs(
    x = "log body size",
    y = "log mass",
    colour = "Estimator"
  ) +
  ggplot2::theme_classic()

## ----directionality-----------------------------------------------------------
direction_check <- function(data, size, mass, dataset) {
  x <- log(data[[size]])
  y <- log(data[[mass]])

  data.frame(
    dataset = dataset,
    estimator = c("Robust OLS", "Robust SMA"),
    forward_slope = c(
      unname(stats::coef(MASS::rlm(y ~ x, method = "M"))[2]),
      unname(stats::coef(smatr::sma(
        y ~ x, method = "SMA", robust = TRUE, quiet = TRUE
      ))[2])
    ),
    reciprocal_reversed_slope = c(
      1 / unname(stats::coef(MASS::rlm(x ~ y, method = "M"))[2]),
      1 / unname(stats::coef(smatr::sma(
        x ~ y, method = "SMA", robust = TRUE, quiet = TRUE
      ))[2])
    )
  )
}

direction_table <- rbind(
  direction_check(gartersnake, "svl_mm", "mass_g", "Gartersnake"),
  direction_check(salamander, "svl_mm", "mass_g", "Salamander")
)

knitr::kable(direction_table, digits = 4)

