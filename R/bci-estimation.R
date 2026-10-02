#' Body Condition Index Estimation using Residuals from an OLS Regression
#'
#' @description
#' This function calculates body condition indices from the residuals of an ordinary 
#' least squares regression (OLS). This is a traditional approach in ecology as outlined 
#' by Krebs and Singleton (1993). There is discussion about whether it is the most
#' robust approach (Schulte-Hostedde et al., 2005; Peig and Green, 2009), how its
#' appropriateness may vary by taxon (Jakob et al., 1996; Băncilă et al., 2010;
#' Labocha and Hayes, 2012), and whether it fits the assumptions of certain
#' statistical tests (García-Berthou, 2001).
#' 
#' @param data tibble/dataframe containing a standard body size variable and the corresponding weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param id a unique identifier for the animals included in your dataset. If included, a tibble with these unique identifiers and the estimates is returned and, if not, the estimate alone is returned. Default is `NULL`.
#' @param relation an argument to specify whether or not the relationship between weight and body size variables are assumed to be allometric (`"allometric"`) or linear (`"linear"`). If allometric, both variables are log-transformed. Default is `"allometric"`. Biologically speaking, most animals exhibit an allometric relationship between their weight and body size measurements.
#'
#' @returns A tibble containing residual-based body condition indices from the specified OLS relationship.
#' 
#' @references
#' Băncilă RI, Hartel T, Plăiaşu R, Smets J, Cogălniceanu D (2010).
#' "Comparing three body condition indices in amphibians: a case study of
#' yellow-bellied toad *Bombina variegata*." *Amphibia-Reptilia*, 31(4), 558–562.
#'
#' García-Berthou E (2001). "On the misuse of residuals in ecology: testing
#' regression residuals vs. the analysis of covariance." *Journal of Animal
#' Ecology*, 70, 708–711.
#'
#' Jakob EM, Marshall SD, Uetz GW (1996). "Estimating fitness: a comparison of
#' body condition indices." *Oikos*, 77, 61–67.
#'
#' Krebs CJ, Singleton GR (1993). "Indexes of condition for small mammals."
#' *Australian Journal of Zoology*, 41, 317–323.
#'
#' Labocha MK, Hayes JP (2012). "Morphometric indices of body condition in
#' birds: a review." *Journal of Ornithology*, 153, 1–22.
#'
#' Peig J, Green AJ (2009). "New perspectives for estimating body condition
#' from mass/length data: the scaled mass index as an alternative method."
#' *Oikos*, 118(12), 1883–1891.
#'
#' Schulte-Hostedde AI, Zinner B, Millar JS, Hickling GJ (2005). "Restitution
#' of mass-size residuals: validating body condition indices." *Ecology*,
#' 86(1), 155–163.
#'
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length 
#' # (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices (using residuals from an OLS) for the gartersnakes
#' # in this dataset, one could:
#' 
#' gartersnake |>
#'    bci_resid_ols(svl_mm, mass_g)
#'
#' @export    
bci_resid_ols <- function(data, body_size, weight,
                          id = NULL,
                          relation = c("allometric")) {
  
  relation <- match.arg(relation, c("allometric", "linear"), several.ok = TRUE)
  
  out_list <- list()
  
  for (rel in relation) {
    
    tmp_data <- data |>
      dplyr::transmute(
        x = {{ body_size }},
        y = {{ weight }}
      )
    
    if (rel == "allometric") {
      tmp_data <- tmp_data |>
        dplyr::mutate(x = log(x), y = log(y))
    } else {
      warning(
        "OLS residual method used a linear (non-log) relationship. This assumes a linear relationship between body size and mass.",
        call.=FALSE
      )
    }
    
    
    fit <- lm(y ~ x, data = tmp_data, na.action = stats::na.exclude)
    
    res <- resid(fit)
    
    name <- if (rel == "allometric") {
      "resid_allometric"
    } else {
      "resid_linear"
    }
    
    out_list[[name]] <- res
  }
  
  # combine into tibble
  out <- tibble::as_tibble(out_list)
  
  # optional id
  if (!rlang::quo_is_null(rlang::enquo(id))) {
    id_vec <- dplyr::pull(data, {{ id }})
    out <- dplyr::bind_cols(tibble::tibble(id = id_vec), out)
  }
  
  out
}



#' Scaled Mass Index
#' @description 
#' This function calculates body condition indices using the scaled mass index (SMI method)
#' as described by Peig and Green (2009). Specifically, this method
#' uses standardized major axis regression in its estimation of the body condition indices.
#' Yet, this method is sensitive to the presence of outliers (i.e., data points that may
#' distort the expected relationship between body length and weight), and so SMI estimation
#' using robust regression (see function `bci_smi_rob`) may be more appropriate in cases where
#' outliers are present.
#' 
#' @param data tibble/dataframe containing a standard body size variable and the 
#' corresponding weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length 
#' of reptiles, tarsus length of birds, length from the snout to the base of the 
#' tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param id a unique identifier for the animals included in your dataset. If included, a tibble with these unique identifiers and the estimates is returned and, if not, the estimate alone is returned. Default is `NULL`.
#' 
#' @returns a tibble containing SMI estimates calculated using the classical SMA scaling exponent.
#'
#' @references
#' Peig J, Green AJ (2009). "New perspectives for estimating body condition
#' from mass/length data: the scaled mass index as an alternative method."
#' *Oikos*, 118(12), 1883–1891.
#' 
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length 
#' # (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices using the scaled mass index
#' # for the gartersnakes this dataset, one could:
#' 
#' gartersnake  |>
#'   bci_smi(svl_mm, mass_g)
#'
#' @export   
bci_smi <- function(data, body_size, weight, id = NULL){
  
  # Compute mean of body size
  x0 = data |> dplyr::pull({{body_size}}) |> mean(na.rm = TRUE)
  
  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}),
                  log_weight = log({{weight}}))
  
  # Compute SMA
  b_sma <- coef(smatr::sma(log_weight ~ log_body_size, 
                           method = "SMA",
                           robust = FALSE,
                           data = tmp_data))[2]   
  bci <- tmp_data |> 
    dplyr::mutate(smi = {{weight}} * (x0 / {{body_size}})^b_sma)
  
  # Output options
  ## If ID is included, then a tibble is provided
  if (!rlang::quo_is_null(rlang::enquo(id))) {
    
    out <- data |>
      dplyr::transmute(
        id = dplyr::pull(data, {{ id }}),
        smi = bci$smi
      )
    
    return(out)
  }
  
  ## If ID is not included included, then named vector is provided
  if (is.null(id)) {
    
    out <- data |>
      dplyr::transmute(
        smi = bci$smi
      )
    
    return(out)
  }
}



#' Scaled Mass Index using Robust Standardized Major Axis Regression
#' @description 
#' This function calculates body condition indices using the scaled mass index (SMI method)
#' as described by Peig and Green (2009), with the with the scaling exponent
#' estimated using robust standardized major axis (SMA) regression. This method is less sensitive to
#' the presence of outliers (i.e., data points that may distort the expected
#' relationship between body length and weight).
#'
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, 
#' tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param id a unique identifier for the animals included in your dataset. If included, a tibble with these unique identifiers and the estimates is returned and, if not, the estimate alone is returned. Default is `NULL`.
#' 
#' @return a tibble containing SMI estimates calculated using the robust SMA scaling exponent.
#'
#' @references
#' Peig J, Green AJ (2009). "New perspectives for estimating body condition
#' from mass/length data: the scaled mass index as an alternative method."
#' *Oikos*, 118(12), 1883–1891.
#' 
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length 
#' # (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices (using the scaled mass index with a robust regression)
#' # for the gartersnakes from this dataset, one could:
#'
#' gartersnake |>
#'   bci_smi_rob(svl_mm, mass_g)
#'
#' @export
bci_smi_rob <- function(data, body_size, weight, id = NULL){
  
  # Compute mean of body size
  x0 = data |> dplyr::pull({{body_size}}) |> mean(na.rm = TRUE)
  
  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}),
                  log_weight = log({{weight}}))
  
  # Compute SMA
  b_sma_rob <- coef(smatr::sma(log_weight ~ log_body_size, 
                               method = "SMA",
                               robust = TRUE, 
                               data = tmp_data))[2]   
  bci <- tmp_data |> 
    dplyr::mutate(smi_rob = {{weight}} * (x0 / {{body_size}})^b_sma_rob)
  
  # Output options
  ## If ID is included, then a tibble is provided
  if (!rlang::quo_is_null(rlang::enquo(id))) {
    
    out <- data |>
      dplyr::transmute(
        id = dplyr::pull(data, {{ id }}),
        smi_rob = bci$smi_rob
      )
    
    return(out)
  }
  
  ## If ID is not included, then named vector is provided
  if (is.null(id)) {
    
    out <- data |>
      dplyr::transmute(
        smi_rob = bci$smi_rob
      )
    
    return(out)
}}


#' Animal Body Condition Index Estimation
#'
#' @description
#' This function calculates body condition indices using three established
#' approaches: residuals from an ordinary least squares regression (OLS),
#' the scaled mass index (SMI) using classical standardized major axis (SMA)
#' regression, and the SMI using robust SMA regression.
#' 
#' First, calculating body condition indices from the residuals of an OLS regression  is a traditional 
#' approach in ecology as outlined by Krebs and Singleton (1993). There is discussion
#' about whether it is the most robust approach (Schulte-Hostedde et al., 2005;
#' Peig and Green, 2009), how its appropriateness may vary by taxon (Jakob et al.,
#' 1996; Băncilă et al., 2010; Labocha and Hayes, 2012), and whether it fits the
#' assumptions of certain statistical tests (García-Berthou, 2001).
#' 
#' The SMI method described by Peig and Green (2009) uses an allometric,
#' log-transformed relationship and the scaling exponent estimated from a
#' standardized major axis regression to scale individual mass to a common
#' reference body size. The robust SMI method uses the same SMI framework but 
#' estimates the scaling exponent using robust standardized major axis regression, 
#' reducing the influence of potential outliers on the fitted allometric relationship.
#'
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param id a unique identifier for the animals included in your dataset. If included, a tibble with these unique identifiers and the estimates is returned and, if not, the estimate alone is returned. Default is `NULL`.
#' @param method method used to estimate body condition. Options are residuals from an OLS regression (`"resid_ols"`), the scaled mass index using classical SMA regression (`"smi"`), or the scaled mass index using robust SMA regression (`"smi_rob"`). One or more methods can be supplied.
#' @param relation an argument to specify whether or not the relationship between weight and body size variables are assumed to be allometric (`"allometric"`) or linear (`"linear"`). If allometric, both variables are log-transformed. Default is `"allometric`. Biologically speaking, most animals exhibit a allometric relationship between their weight and body size measurements, this is the method that is appropriate.
#'
#' @return a tibble of body condition indices for each individual estimates using the method specified
#' 
#'
#' @references
#' Băncilă RI, Hartel T, Plăiaşu R, Smets J, Cogălniceanu D (2010).
#' "Comparing three body condition indices in amphibians: a case study of
#' yellow-bellied toad *Bombina variegata*." *Amphibia-Reptilia*, 31(4), 558–562.
#'
#' García-Berthou E (2001). "On the misuse of residuals in ecology: testing
#' regression residuals vs. the analysis of covariance." *Journal of Animal
#' Ecology*, 70, 708–711.
#'
#' Jakob EM, Marshall SD, Uetz GW (1996). "Estimating fitness: a comparison of
#' body condition indices." *Oikos*, 77, 61–67.
#'
#' Krebs CJ, Singleton GR (1993). "Indexes of condition for small mammals."
#' *Australian Journal of Zoology*, 41, 317–323.
#'
#' Labocha MK, Hayes JP (2012). "Morphometric indices of body condition in
#' birds: a review." *Journal of Ornithology*, 153, 1–22.
#'
#' Peig J, Green AJ (2009). "New perspectives for estimating body condition
#' from mass/length data: the scaled mass index as an alternative method."
#' *Oikos*, 118(12), 1883–1891.
#'
#' Schulte-Hostedde AI, Zinner B, Millar JS, Hickling GJ (2005). "Restitution
#' of mass-size residuals: validating body condition indices." *Ecology*,
#' 86(1), 155–163.
#'
#'   
#' @examples 
#' # In these examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length 
#' # (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices for the gartersnakes this dataset, one could:
#' 
#' # BCI that is the residuals from an OLS regression
#' gartersnake  |>
#'   bci(svl_mm, mass_g, method = "resid_ols")
#'   
#' # BCI using the scaled mass index
#' gartersnake  |>
#'   bci(svl_mm, mass_g, method = "smi")
#'   
#' # BCI using the scaled mass index with robust SMA
#' gartersnake  |>
#'   bci(svl_mm, mass_g, method = "smi_rob")
#'   
#' # BCI with all three methods
#' gartersnake |>
#'   bci(svl_mm, mass_g, method = c("resid_ols", "smi", "smi_rob"))
#'   
#' @export
bci <- function(data, body_size, weight, id = NULL,
                method = c("resid_ols", "smi", "smi_rob"),
                relation = NULL) {
  
  method <- match.arg(method, several.ok = TRUE)
  
  # ---- handle relation defaults ----
  if (!is.null(relation)) {
    relation_used <- match.arg(relation, c("allometric", "linear"), several.ok = TRUE)
  } else {
    relation_used <- "allometric"
  }
  
  # ---- warning messages ----
  
  # SMI relation warning (only once, not repeated)
  if (any(method %in% c("smi", "smi_rob")) &&
      !is.null(relation) &&
      "linear" %in% relation_used) {
    
    warning(
      "The 'linear' relation applies only to the OLS residual method; SMI methods always use allometric (log-log) scaling.",
      call. = FALSE
    )
  }
  
  
  results <- list()
  
  # ---- Residual OLS ----
  if ("resid_ols" %in% method) {
    
    results$resid_ols <-
      bci_resid_ols(
        data,
        {{ body_size }},
        {{ weight }},
        relation = relation_used,
        id = NULL
      )
    }
  
  # ---- SMI ----
  if ("smi" %in% method) {
    results$smi <-
      bci_smi(data, {{ body_size }}, {{ weight }})
  }
  
  # ---- SMI robust ----
  if ("smi_rob" %in% method) {
    results$smi_rob <-
      bci_smi_rob(data, {{ body_size }}, {{ weight }})
  }
  
  # ---- Combine safely ----
  out <- dplyr::bind_cols(results)
  
  # ---- ID handling ----
  if (!rlang::quo_is_null(rlang::enquo(id))) {
    id_vec <- dplyr::pull(data, {{ id }})
    stopifnot(length(id_vec) == nrow(out))
    
    out <- dplyr::bind_cols(
      tibble::tibble(id = id_vec),
      out
    )
  }
  
  out
  }
