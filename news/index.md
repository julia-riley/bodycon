# Changelog

## bodycon 0.2.0

- Renamed `bci_smi_ols()` to
  [`bci_smi()`](https://julia-riley.github.io/bodycon/reference/bci_smi.md)
  to reflect that the scaled mass index (SMI) uses standardized major
  axis (SMA) regression to estimate the scaling exponent
- Updated
  [`bci_smi_rob()`](https://julia-riley.github.io/bodycon/reference/bci_smi_rob.md)
  to use robust standardized major axis (SMA) regression to estimate the
  SMI scaling exponent
- Updated
  [`bci()`](https://julia-riley.github.io/bodycon/reference/bci.md) and
  [`plot_bci()`](https://julia-riley.github.io/bodycon/reference/plot_bci.md)
  to use the revised SMI method names and terminology
- Improved handling of missing values in OLS residual calculations

## bodycon 0.1.0

- Initial public release
