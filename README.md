# bodycon <img src="inst/hex_sticker/hex_sticker.png" align="right" height="150" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/julia-riley/bodycon/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/julia-riley/bodycon/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`bodycon` is an R package for calculating commonly used body condition indices in wildlife ecology research. In this research field, an individual's fitness traits, like reproduction and survival, are important measures of individual performance and health. However, direct measures of fitness can be impractical to collect in the field due to financial or logistical research constraints. So, in these cases, animal ecologists often rely on proxies of individual fitness, such as body condition. 

One widely used method of estimating body condition is to relate body mass to a linear measure of body size, but this can be calculated in a variety of ways. `bodycon` contains functions for a variety of methods of estimating body condition indices, including residuals from an ordinary least squares (OLS) regression and scaled mass index (SMI) using OLS and robust regression.

## Installation

The development version of `bodycon` can be installed from GitHub with: 

```r
remotes::install_github("julia-riley/bodycon")
```

A stable release of `bodycon` (version 0.1.0) is also available through the [GitHub releases](https://github.com/julia-riley/bodycon/releases).

## Getting Started

See the [package vignette](https://julia-riley.github.io/bodycon/articles/bodycon.html) for an introduction to `bodycon`, including examples of the included body condition index methods and approaches for evaluating their suitability for your data.


## Citing `bodycon`

If you make use of `bodycon` in your research, please cite:

Riley J, Kar F (2026). *bodycon: Estimation of Animal Body Condition Indices*. R package version 0.1.0. https://doi.org/10.5281/zenodo.23066174

You can also obtain the citation directly in R:

```r
citation("bodycon")
```

## Find a Bug?

Thank you for catching it! Please open an [issue on GitHub](https://github.com/julia-riley/bodycon/issues) and let us know about it. We will try to get to it as soon as we can.
