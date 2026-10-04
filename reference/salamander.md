# Eastern Red-backed Salamander Size and Mass Data from New Brunswick

This is a subset of data collected by Sara Leslie during her Honours
thesis at Mount Allison University on salamanders in New Brunswick. It
includes morphometric data for 128 Eastern Red-backed Salamanders
sampled in an old growth forest. The paper associated with this data is:
Leslie S, Edge C, Riley JL. 2025. Herbicide Application Improves
Plethodontid Salamander Habitat Conditions in Regenerating Clear-cut
Forests. Canadian Journal of Forest Research. 55: 1-12.
[doi:10.1139/cjfr-2024-0294](https://doi.org/10.1139/cjfr-2024-0294)

## Usage

``` r
salamander
```

## Format

### `salamander`

A data frame with 128 rows and 8 columns:

- salamander_ID:

  A unique identifier for each individual salamander measured.

- sex:

  Either F for female, M for male, or J if the salamander was not
  sexually mature yet (i.e., a juvenile).

- gravid:

  Either n for no or NA if not applicable. There are no occurences of y
  for yes, because all individuals that were gravid (carrying eggs) were
  removed from this dataset.

- salamander_ID:

  A unique identifier for each individual salamander measured.

- age:

  Either J for juvenile or A for adult, depending on the age of the
  salamander.

- mass_g:

  Mass, in grams, of the salamander.

- svl_mm:

  Snout-vent length (SVL) in mm of the salamander. SVL is the distance
  from the individual's snout to the anterior edge of their cloaca.

- total_length_mm:

  Total length in mm of the salamander.

## Source

[doi:10.1139/cjfr-2024-0294](https://doi.org/10.1139/cjfr-2024-0294)
