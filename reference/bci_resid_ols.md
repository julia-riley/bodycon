# Body Condition Index Estimation using Residuals from an OLS Regression

This function calculates body condition indices from the residuals of an
ordinary least squares regression (OLS). This is a traditional approach
in ecology as outlined by Krebs and Singleton (1993). There is
discussion about whether it is the most robust approach
(Schulte-Hostedde et al., 2005; Peig and Green, 2009), how its
appropriateness may vary by taxon (Jakob et al., 1996; Băncilă et al.,
2010; Labocha and Hayes, 2012), and whether it fits the assumptions of
certain statistical tests (García-Berthou, 2001).

## Usage

``` r
bci_resid_ols(data, body_size, weight, id = NULL, relation = c("allometric"))
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

- relation:

  an argument to specify whether or not the relationship between weight
  and body size variables are assumed to be allometric (`"allometric"`)
  or linear (`"linear"`). If allometric, both variables are
  log-transformed. Default is `"allometric"`. Biologically speaking,
  most animals exhibit an allometric relationship between their weight
  and body size measurements.

## Value

A tibble containing residual-based body condition indices from the
specified OLS relationship.

## References

Băncilă RI, Hartel T, Plăiaşu R, Smets J, Cogălniceanu D (2010).
"Comparing three body condition indices in amphibians: a case study of
yellow-bellied toad *Bombina variegata*." *Amphibia-Reptilia*, 31(4),
558–562.

García-Berthou E (2001). "On the misuse of residuals in ecology: testing
regression residuals vs. the analysis of covariance." *Journal of Animal
Ecology*, 70, 708–711.

Jakob EM, Marshall SD, Uetz GW (1996). "Estimating fitness: a comparison
of body condition indices." *Oikos*, 77, 61–67.

Krebs CJ, Singleton GR (1993). "Indexes of condition for small mammals."
*Australian Journal of Zoology*, 41, 317–323.

Labocha MK, Hayes JP (2012). "Morphometric indices of body condition in
birds: a review." *Journal of Ornithology*, 153, 1–22.

Peig J, Green AJ (2009). "New perspectives for estimating body condition
from mass/length data: the scaled mass index as an alternative method."
*Oikos*, 118(12), 1883–1891.

Schulte-Hostedde AI, Zinner B, Millar JS, Hickling GJ (2005).
"Restitution of mass-size residuals: validating body condition indices."
*Ecology*, 86(1), 155–163.

## Examples

``` r
# In this examples we will make use of the `gartersnake` dataset in this R package.
# This dataset contains the mass (in grams) and snout-vent length 
# (in mm) of 46 Maritime Gartersnakes.
# To estimate body condition indices (using residuals from an OLS) for the gartersnakes
# in this dataset, one could:

gartersnake |>
   bci_resid_ols(svl_mm, mass_g)
#> # A tibble: 46 × 1
#>    resid_allometric
#>               <dbl>
#>  1          -0.372 
#>  2          -0.196 
#>  3           0.0686
#>  4          -0.0945
#>  5          -0.0324
#>  6          -0.0331
#>  7           0.746 
#>  8           0.735 
#>  9          -0.661 
#> 10          -0.658 
#> # ℹ 36 more rows
```
