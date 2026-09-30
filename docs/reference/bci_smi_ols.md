# Scaled Mass Body Condition Index Estimation with OLS Regression

This function calculates body condition indices using the scaled mass
index (SMI method) as described by Peig and Green (2009). Specifically,
this method uses ordinary least squares regression in its estimation of
the body condition indices. Yet, this method is sensitive to the
presence of outliers (i.e., data points that may distort the expected
relationship between body length and weight), and so SMI estimation
using robust regression (see function `bci_smi_rob`) may be more
appropriate in cases where outliers are present.

## Usage

``` r
bci_smi_ols(data, body_size, weight, id = NULL)
```

## Arguments

- data:

  tibble/dataframe containing a standard body size variable and the
  corresponding weight for each individual of one animal species

- body_size:

  name of standard body size variable (e.g., snout-vent-length of
  reptiles, tarsus length of birds, length from the snout to the base of
  the tail for mammals, etc.)

- weight:

  name of weight variable (e.g., mass of the animal)

- id:

  a unique identifier for the animals included in your dataset. If
  included, a tibble with these unique identifiers and the estimates is
  returned and, if not, the estimate alone is returned. Default is
  `NULL`.

## Value

a vector of body condition indices for each individual estimates using
the SMI method using an OLS regression

## References

Peig J, Green AJ (2009). "New perspectives for estimating body condition
from mass/length data: the scaled mass index as an alternative method."
*Oikos*, 118(12), 1883–1891.

## Examples

``` r
# In this examples we will make use of the `gartersnake` dataset in this R package.
# This dataset contains the mass (in grams) and snout-vent length 
# (in mm) of 46 Maritime Gartersnakes.
# To estimate body condition indices (using the scaled mass index with OLS)
# for the gartersnakes this dataset, one could:

gartersnake  |>
  bci_smi_ols(svl_mm, mass_g)
#> # A tibble: 46 × 1
#>    smi_ols
#>      <dbl>
#>  1    38.0
#>  2    46.4
#>  3    48.4
#>  4    39.8
#>  5    46.5
#>  6    46.2
#>  7    89.8
#>  8    97.2
#>  9    24.7
#> 10    24.3
#> # ℹ 36 more rows
```
