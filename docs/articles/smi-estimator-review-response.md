# Response to the SMI estimator review

## Overall response

Thank you for working through the slope-estimation issue in detail. I
think the review identified a **real implementation/documentation
mismatch**, but I also think we can simplify the statistical
interpretation considerably.

My current interpretation is that the package is intended to provide
**three body-condition estimators**:

1.  OLS residuals (`resid_ols`)
2.  the scaled mass index (SMI) following Peig and Green (2009)
3.  a robust version of the SMI

These are different body-condition methods, so I do **not** expect their
fitted slopes to be identical. In particular, the OLS residual method
and the SMI are based on different regression approaches and therefore
estimate different scaling relationships.

The important issue is instead that the current function names imply
that the two SMI functions use OLS and robust OLS, whereas the returned
indices actually use classical SMA and robust SMA slopes. That naming
issue should be corrected.

## What I agree should be changed

### 1. The current SMI function names are misleading

This is the strongest point in the review, and I agree that we should
fix it.

At present, `bci_smi_ols()` calculates an
[`lm()`](https://rdrr.io/r/stats/lm.html) object, but the slope used to
calculate the returned SMI is obtained from
[`smatr::sma()`](https://traitecoevo.github.io/smatr/reference/sma.html).
Likewise,
[`bci_smi_rob()`](https://julia-riley.github.io/bodycon/reference/bci_smi_rob.md)
calculates a [`MASS::rlm()`](https://rdrr.io/pkg/MASS/man/rlm.html)
object, but the returned SMI uses `smatr::sma(..., robust = TRUE)`.

Thus, the current implementation is effectively:

- `bci_smi_ols()` = SMI using a classical SMA slope
- [`bci_smi_rob()`](https://julia-riley.github.io/bodycon/reference/bci_smi_rob.md)
  = SMI using a robust SMA slope

The [`lm()`](https://rdrr.io/r/stats/lm.html) and `rlm()` fits are not
affecting the returned values.

I would therefore change the public terminology rather than change the
underlying SMI calculation.

Because the package has not yet been released on CRAN, I think this is
the right time to make that change rather than retaining misleading
names for backward compatibility.

### 2. The documentation should explicitly say that SMI uses SMA

The documentation should state that the Peig and Green SMI is calculated
as

``` math
\widehat{M}_i = M_i\left(\frac{L_0}{L_i}\right)^{b_{SMA}},
```

where $`b_{SMA}`$ is estimated from the log-transformed mass–size
relationship using a standardized major axis regression.

The robust version can then be described as a **robust SMA
implementation of SMI**, rather than as robust OLS.

This is important because SMA is not just an alternative way of fitting
the same regression. It is a different estimator with different
assumptions about variation in the two variables.

### 3. The unused `lm()` and `rlm()` calculations should be removed

Once the terminology is corrected, the unused model objects can simply
be removed from the two functions. There is no reason to fit a second
model that does not contribute to the returned index.

That would make the implementation much easier to read and would
eliminate the source of the current confusion.

## What I would revise or rebut

### 1. I would not frame the choice of the SMI slope as an unresolved question

I think this is where the review goes beyond what we actually need to
decide.

If the package intends to implement the **scaled mass index as described
by Peig and Green**, then the scaling exponent is not an arbitrary
choice among OLS, robust OLS, SMA, and robust SMA. The original SMI
formulation uses the standardized major axis slope ($`b_{SMA}`$).

Therefore, I would frame the decision as:

> Do we want `bodycon` to implement Peig and Green’s SMI, plus a robust
> SMA extension of that method?

For the current package, my answer is yes.

The alternative estimators are still interesting, but they should not be
presented as four equally valid definitions of the original SMI.

### 2. I would not add robust OLS to the package just because it is another

possible estimator

The review’s comparison of OLS, robust OLS, SMA, and robust SMA is
useful as a statistical diagnostic, but it expands the question beyond
the package’s current purpose.

The package already has an OLS-based body-condition method: the residual
approach. Adding another OLS-derived condition index would only be
useful if we have a specific methodological reason for offering it.

### 3. Different slopes among the three body-condition methods are expected

I would push back on any interpretation that the package should produce
the same slope across all three methods.

The three methods are not simply three implementations of one
regression:

| Method | Scaling relationship | Role of regression |
|----|----|----|
| `resid_ols` | log-log allometry by default | OLS residuals are the condition index |
| `smi` | log-log allometry | SMA slope is used to scale mass to a common body size |
| `smi_rob` | log-log allometry | robust SMA slope is used to scale mass to a common body size |

The fitted slope therefore describes a different quantity in the
residual OLS method than it does in the SMI method. Comparing the
numerical slopes and expecting them to match would not be a useful
validation criterion.

The more relevant question is whether each function is implementing the
statistical definition it claims to implement.

## What I would leave out or defer for now

### Direction-reversal diagnostics

The comparison of forward and reversed regressions is statistically
interesting, particularly for distinguishing directional robust
regression from SMA. However, I do not think it needs to be part of the
package decision unless we decide to implement robust OLS as a package
method.

For the present package, it adds complexity without changing the core
decision.

### A new four-way SMI API

I would also defer an API such as

[`bci_smi`](https://julia-riley.github.io/bodycon/reference/bci_smi.md)`(`` `` ``data``,`` `` ``body_size``,`` `` ``weight``,`` `` slope_method ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"sma"``, ``"robust_sma"``, ``"ols"``, ``"robust_ols"``)`` ``)`

This is a reasonable future design, but I think it solves a larger
problem than we currently have.

The package will be easier to explain if the initial public API contains
the three clearly defined methods we actually intend to support.

### Passing all backend-specific fitting arguments through `...`

I would also defer this.

There is a legitimate argument for allowing advanced users to control
the underlying regression, but adding unrestricted `...` now creates a
second API problem while we are still finalizing the first one.

In particular,
[`smatr::sma()`](https://traitecoevo.github.io/smatr/reference/sma.html)
and [`MASS::rlm()`](https://rdrr.io/pkg/MASS/man/rlm.html) expose
different fitting arguments. I would rather first establish stable
method definitions and then, if needed, add explicitly validated control
arguments later.

## Proposed package terminology

Because this package is not yet on CRAN, I would make the public names
match the methods now rather than preserve the current names as legacy
aliases.

I suggest:

```
bci_resid_ols()   -> OLS residual body-condition index
bci_smi()         -> Peig-Green SMI using classical SMA
bci_smi_rob()     -> robust SMI using robust SMA
```

And in the wrapper:

[`bci`](https://julia-riley.github.io/bodycon/reference/bci.md)`(`` `` ``data``,`` `` ``body_size``,`` `` ``weight``,`` `` method ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"resid_ols"``, ``"smi"``, ``"smi_rob"``)`` ``)`

I think this is clearer than retaining `smi_ols`, because the method is
not actually OLS-based. It also makes the distinction between the three
body- condition estimators much more obvious to users.

The robust method should be described as an extension of SMI using
robust SMA, not as a different form of OLS.

## What I think the final documentation should emphasize

The package should explain the methods in this order:

#### 1. OLS residuals

A traditional body-condition approach in which condition is represented
by the residual from the fitted mass–size relationship.

#### 2. Scaled mass index

The Peig and Green method, which uses an allometric relationship and the
SMA scaling exponent to standardize individual mass to a common body
size.

#### 3. Robust scaled mass index

The same SMI framework, but with a robust SMA estimator used to estimate
the scaling relationship so that the fitted relationship is less
sensitive to outliers.

The package can then explicitly state that these methods are expected to
give somewhat different condition estimates because they use different
statistical estimators.

## Bottom line

I think the review has identified something we **should change**, but I
do not think it means that the SMI calculation itself is conceptually
wrong.

The change I would make is to align the names and documentation with
what the code actually does:

- keep the classical SMA-based SMI;
- keep the robust SMA-based SMI;
- remove the unused OLS/`rlm()` fits;
- rename `smi_ols` so that it does not imply an OLS-based SMI;
- describe the three BCI approaches as distinct methods rather than
  expecting their fitted slopes to agree;
- keep the comparison of classical and robust SMI, including the very
  high correlation in the example data, but interpret it as a
  data-specific result;
- defer additional OLS-based SMI methods and a more elaborate `...` API
  until there is a substantive reason to add them.

That seems to address the genuine implementation issue while keeping the
scientific definition of the SMI aligned with Peig and Green (2009).

## References

Peig J, Green AJ. 2009. New perspectives for estimating body condition
from mass/length data: the scaled mass index as an alternative method.
*Oikos* 118:1883–1891.
<https://doi.org/10.1111/j.1600-0706.2009.17643.x>

Warton DI, Duursma RA, Falster DS, Taskinen S. 2012. smatr 3–an R
package for estimation and inference about allometric lines. *Methods in
Ecology and Evolution* 3:257–259.
<https://doi.org/10.1111/j.2041-210X.2011.00153.x>

Venables WN, Ripley BD. 2002. *Modern Applied Statistics with S*. 4th
ed. Springer.
