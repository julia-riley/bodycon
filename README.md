<!-- badges: start -->
  [![R-CMD-check](https://github.com/julia-riley/R_package_body_condition/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/julia-riley/R_package_body_condition/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Body Condition Indices - R Package

This R package is aimed at creating functions to calculate body condition of animals from ordinary least sqaures (OLS) regression or using the scaled mass index (SMI) created by Peig and Green.

The files currently (14 Nov 2025) are as follows:

- ex_georgia christie_site_raw_data.csv: raw data from Georgia Christie's thesis on salamanders that can be used for testing the R package
- ex_sara leslie_individual_data.csv: raw data from Sara Leslie's thesis on salamanders that can be used for testing the R package
- R_package_body_condition.Rproj: the R project for this work
- Scaled Mass Index Magic.Rmd: The R code I have previously used with functions I created for my students to calaculate body condition of animals

FOLDER: functions
- bci_ols_smi.R: the R function to calculate body condition using either the OLS or SMI methods
- bci_predictions.R: the R function to visualise the body condition preductions (in progress)

FOLDER: literature
- a variety or resources to use to make an R package as well as cite in the explaination for this R package 
