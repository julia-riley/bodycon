# Animal Body Condition Index Estimation

This function calculates body condition indices using multiple
established methods: from the residuals of an ordinary least squares
regression (OLS), and using the scaled mass index (SMI) method using OLS
or robust regression for estimation.

First, calculating body condition indices from the residuals of an OLS
regression is a traditional approach in ecology as outlined by Krebs and
Singleton (1993). There is discussion about whether it is the most
robust approach (Schulte-Hostedde et al., 2005; Peig and Green, 2009),
how its appropriateness may vary by taxon (Jakob et al., 1996; Băncilă
et al., 2010; Labocha and Hayes, 2012), and whether it fits the
assumptions of certain statistical tests (García-Berthou, 2001).

The second method calculates body condition indices using the SMI method
as described by Peig and Green (2009). Specifically, this method uses
OLS or robust regression in its estimation of the body condition
indices. OLS regression is sensitive to the presence of outliers (i.e.,
data points that may distort the expected relationship between body
length and weight). So, another option is to estimate SMI using robust
regression using an M estimator from MASS (Venables and Ripley, 2002) in
its estimation of the body condition indices. The robust regression
approach is less sensitive to the presence of outliers (i.e., data
points that may distort the expected relationship between body length
and weight), as shown in [this blog by by Chen-Pan
Liao](https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html).

## Usage

``` r
bci(
  data,
  body_size,
  weight,
  id = NULL,
  method = c("resid_ols", "smi_ols", "smi_rob"),
  relation = NULL
)
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

- method:

  method used to estimate body condition, either residuals from an OLS
  regression (`"resid_ols"`) or scaled mass index using an OLS
  (`"smi_ols"` or robust regression (`"smi_ols"`). Provide one or a list
  of these.

- relation:

  an argument to specify whether or not the relationship between weight
  and body size variables are assumed to be allometric (`"allometric"`)
  or linear (`"linear"`). If allometric, both variables are
  log-transformed. Default is `"allometric`. Biologically speaking, most
  animals exhibit a allometric relationship between their weight and
  body size measurements, this is the method that is appropriate.

## Value

a vector of body condition indices for each individual estimates using
the method specified

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

Venables WN, Ripley BD (2002). *Modern Applied Statistics with S*, 4th
ed. Springer, New York.

## Examples

``` r
# In these examples we will make use of the `gartersnake` dataset in this R package.
# This dataset contains the mass (in grams) and snout-vent length 
# (in mm) of 46 Maritime Gartersnakes.
# To estimate body condition indices for the gartersnakes this dataset, one could:

# BCI that is the residuals from an OLS regression
gartersnake  |>
  bci(svl_mm, mass_g, method = "resid_ols")
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
  
# BCI using the SMI method estimated with an OLS regression
gartersnake  |>
  bci(svl_mm, mass_g, method = "smi_ols")
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
  
# BCI using the SMI method estimated with an robust regression
gartersnake  |>
  bci(svl_mm, mass_g, method = "smi_rob")
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
  
# BCI with all three methods
gartersnake |>
  bci(svl_mm, mass_g, method = c("resid_ols", "smi_ols", "smi_rob"))
#> # A tibble: 46 × 3
#>    resid_allometric smi_ols smi_rob
#>               <dbl>   <dbl>   <dbl>
#>  1          -0.372     38.0    35.6
#>  2          -0.196     46.4    43.2
#>  3           0.0686    48.4    47.9
#>  4          -0.0945    39.8    39.8
#>  5          -0.0324    46.5    45.3
#>  6          -0.0331    46.2    45.1
#>  7           0.746     89.8    90.4
#>  8           0.735     97.2    95.5
#>  9          -0.661     24.7    24.1
#> 10          -0.658     24.3    23.8
#> # ℹ 36 more rows
  
```
