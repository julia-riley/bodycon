# Scaled Mass Index using Robust Standardized Major Axis Regression

This function calculates body condition indices using the scaled mass
index (SMI method) as described by Peig and Green (2009), with the with
the scaling exponent estimated using robust standardized major axis
(SMA) regression. This method is less sensitive to the presence of
outliers (i.e., data points that may distort the expected relationship
between body length and weight).

## Usage

``` r
bci_smi_rob(data, body_size, weight, id = NULL)
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

a tibble containing SMI estimates calculated using the robust SMA
scaling exponent.

## References

Peig J, Green AJ (2009). "New perspectives for estimating body condition
from mass/length data: the scaled mass index as an alternative method."
*Oikos*, 118(12), 1883–1891.

## Examples

``` r
# In this examples we will make use of the `gartersnake` dataset in this R package.
# This dataset contains the mass (in grams) and snout-vent length 
# (in mm) of 46 Maritime Gartersnakes.
# To estimate body condition indices (using the scaled mass index with a robust regression)
# for the gartersnakes from this dataset, one could:

gartersnake |>
  bci_smi_rob(svl_mm, mass_g)
#> # A tibble: 46 × 1
#>    smi_rob
#>      <dbl>
#>  1    35.6
#>  2    43.2
#>  3    47.9
#>  4    39.8
#>  5    45.3
#>  6    45.1
#>  7    90.4
#>  8    95.5
#>  9    24.1
#> 10    23.8
#> # ℹ 36 more rows
```
