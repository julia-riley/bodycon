#' Body Condition Index Estimation using Residuals from an OLS Regression
#'
#' @description
#' This function calculates body condition indices from the residuals of an ordinary 
#' least squares regression (OLS). This is a traditional approach in ecology as outlined 
#' by \insertCite{krebs1993;textual}{bodycon}. There is discussion whether it is the most 
#' robust approach \insertCite{schulte2005,peig2009}{bodycon}, how its appropriateness
#' may vary by taxon \insertCite{jakob1996,buancilua2010,labocha2012}{bodycon}, and whether
#' or not it fits the assumptions of certain statistical tests \insertCite{garcia2001}{bodycon}. 
#' 
#' @param data tibble/dataframe containing a standard body size variable and the corresponding weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param id a unique identifier for the animals included in your dataset. If included, a tibble with these unique identifiers and the estimates is returned and, if not, the estimate alone is returned. Default is `NULL`.
#' @param log_transform an argument to specify whether or not the weight and body size variable should be log-transformed. Default is `TRUE`. Biologically speaking, most animals exhibit a allometric relationship between their weight and body size measurements, so log-transformation is appropriate. Please note that if you choose not to log-transform these variables, you are assuming a linear relationship between them.
#'
#' @returns a vector of body condition indices for each individual estimates that are the residuals from an OLS regression
#' 
#' @references 
#'   \insertAllCited{}
#'
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices (using residuals from an OLS) for the gartersnakes
#' # in this dataset, one could:
#' 
#' gartersnake |>
#'    bci_resid_ols(svl_mm, mass_g)
#'
#' @export    
bci_resid_ols <- function(data, body_size, weight, 
                          id = NULL,
                          log_transform = TRUE){

  # Create tmp data for use in models and log transformations
  tmp_data <- data |>
    dplyr::transmute(
      x = {{ body_size }},
      y = {{ weight }}
    )
  
  # Compute OLS conditional on log-transformation selection
  if (log_transform) {
    
    tmp_data <- tmp_data |>
      dplyr::mutate(
        x = log(x),
        y = log(y)
      )
    
    model <- lm(y ~ x, data = tmp_data)
    
    bci <- tmp_data |> 
            dplyr::mutate(bci_resid_ols = resid(model))
    
  } else {
    
    warning(paste(
      "log_transform = FALSE.",
      "You have not selected log-transformation of your size and weight variables,",
      "which assumes a linear relationships between them. This differs from the",
      "more common log-log approach used to model allometric relationships."
    ),
    call. = FALSE
    )
    
    model <- lm(y ~ x, data = tmp_data)
    
    bci <- tmp_data |> 
      dplyr::mutate(bci_resid_ols = resid(model))
  }
  
  # Output options
  ## If ID is included, then a tibble is provided
  if (!rlang::quo_is_null(rlang::enquo(id))) {
    
    out <- data |>
      dplyr::transmute(
        id = dplyr::pull(data, {{ id }}),
        bci_resid_ols = bci$bci_resid_ols
      )
    
    return(out)
  }
    
  ## If ID is not included included, then named vector is provided
    if (is.null(id)) {
      
      out <- data |>
        dplyr::transmute(
          bci_resid_ols = bci$bci_resid_ols
        )
    
    return(out)
    }
}


#' Scaled Mass Body Condition Index Estimation with OLS Regression
#' @description 
#' This function calculates body condition indices using the scaled mass index (SMI method)
#' as described in \insertCite{peig2009;textual}{bodycon}. Specifically, this method
#' uses ordinary least squares regression in its estimation of the body condition indices.
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
#' @return a vector of body condition indices for each individual estimates using 
#' the SMI method using an OLS regression
#'
#' @references 
#'  \insertAllCited{}
#' 
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices (using the scaled mass index with OLS)
#' # for the gartersnakes this dataset, one could:
#' 
#' gartersnake  |>
#'   bci_smi_ols(svl_mm, mass_g)
#'
#' @export   
bci_smi_ols <- function(data, body_size, weight, id = NULL){
  
  # Compute mean of body size
  x0 = data |> dplyr::pull({{body_size}}) |> mean(na.rm = TRUE)
  
  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}),
                  log_weight = log({{weight}}))
  
  # Compute OLS
  log_ols <- lm(log_weight ~ log_body_size, data = tmp_data)
  b_msa_ols <- coef(smatr::sma(log_weight ~ log_body_size, data = tmp_data))[2]   
  bci <- tmp_data |> 
    dplyr::mutate(bci_smi_ols = {{weight}} * (x0 / {{body_size}})^b_msa_ols)
  
  # Output options
  ## If ID is included, then a tibble is provided
  if (!rlang::quo_is_null(rlang::enquo(id))) {
    
    out <- data |>
      dplyr::transmute(
        id = dplyr::pull(data, {{ id }}),
        bci_smi_ols = bci$bci_smi_ols
      )
    
    return(out)
  }
  
  ## If ID is not included included, then named vector is provided
  if (is.null(id)) {
    
    out <- data |>
      dplyr::transmute(
        bci_smi_ols = bci$bci_smi_ols
      )
    
    return(out)
  }
}



#' Scaled Mass Body Condition Index Estimation with Robust Regression
#' @description 
#' This function calculates body condition indices using the scaled mass index (SMI method)
#'  as described in \insertCite{peig2009;textual}{bodycon}. Specifically, this method uses robust regression using an M estimator (from the MASS R package) \insertCite{venables2002}{bodycon} in its estimation of the body condition indices. This method is less sensitive to the presence of outliers (i.e., data points that may distort the expected relationship between body length and weight), as shown in [this blog by by Chen-Pan Liao](https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html).
#'
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, 
#' tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param id a unique identifier for the animals included in your dataset. If included, a tibble with these unique identifiers and the estimates is returned and, if not, the estimate alone is returned. Default is `NULL`.
#' 
#' @return a vector of body condition indices for each individual estimates using the SMI
#'  method using a robust regression
#' @importFrom Rdpack reprompt
#' 
#' @references 
#'   \insertAllCited{}
#' 
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
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
  
  # Compute OLS
  log_rob <- MASS::rlm(log_weight ~ log_body_size, method = "M", data = tmp_data)
  b_msa_rob <- coef(smatr::sma(log_weight ~ log_body_size, robust = T, data = tmp_data))[2]   
  bci <- tmp_data |> 
    dplyr::mutate(bci_smi_rob = {{weight}} * (x0 / {{body_size}})^b_msa_rob)
  
  # Output options
  ## If ID is included, then a tibble is provided
  if (!rlang::quo_is_null(rlang::enquo(id))) {
    
    out <- data |>
      dplyr::transmute(
        id = dplyr::pull(data, {{ id }}),
        bci_smi_rob = bci$bci_smi_rob
      )
    
    return(out)
  }
  
  ## If ID is not included, then named vector is provided
  if (is.null(id)) {
    
    out <- data |>
      dplyr::transmute(
        bci_smi_rob = bci$bci_smi_rob
      )
    
    return(out)
}}


#' Animal Body Condition Index Estimation
#'
#' @description
#' This function calculates body condition indices using multiple established methods: from the residuals of an ordinary 
#' least squares regression (OLS), and using the scaled mass index (SMI) method using OLS or robust regression for estimation.
#' 
#' First, calculating body condition indices from the residuals of an OLS regression  is a traditional 
#' approach in ecology as outlined by \insertCite{krebs1993;textual}{bodycon}. There is discussion whether it is the most 
#' robust approach \insertCite{schulte2005,peig2009}{bodycon}, how its appropriateness
#' may vary by taxon \insertCite{jakob1996,buancilua2010,labocha2012}{bodycon}, and whether
#' or not it fits the assumptions of certain statistical tests \insertCite{garcia2001}{bodycon}. 
#' 
#' The second method, calculates body condition indices using the SMI method as described in \insertCite{peig2009;textual}{bodycon}. 
#' Specifically, this method uses OLS or robust regression in its estimation of the body condition indices.
#' OLS regression is sensitive to the presence of outliers (i.e., data points that may distort the expected relationship between body length and weight).
#' So, another option is to estimate SMI using robust regression using an M estimator (from the MASS R package) \insertCite{venables2002}{bodycon} in its 
#' estimation of the body condition indices. The robus regression approach is less sensitive to the presence of outliers 
#' (i.e., data points that may distort the expected relationship between body length and weight), as shown in [this blog by by Chen-Pan Liao](https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html).
#'
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param id a unique identifier for the animals included in your dataset. If included, a tibble with these unique identifiers and the estimates is returned and, if not, the estimate alone is returned. Default is `NULL`.
#' @param log_transform an argument to specify whether or not the weight and body size variable should be log-transformed. This will only applied to the OLS regression residual method (`reside_ols`). Default is `TRUE`. Biologically speaking, most animals exhibit a allometric relationship between their weight and body size measurements, so log-transformation is appropriate. Please note that if you choose not to log-transform these variables, you are assuming a linear relationship between them.
#' @param method method used to estimate body condition, either residuals from an OLS regression (`"resid_ols"`) or scaled mass index using an OLS (`"smi_ols"` or robust regression (`"smi_ols"`). Provide one or a list of these. 
#'
#' @return a vector of body condition indices for each individual estimates using the method specified
#' 
#' @importFrom Rdpack reprompt
#' 
#' @references 
#'   \insertAllCited{}
#'   
#' @examples 
#' # In these examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices for the gartersnakes this dataset, one could:
#' 
#' # BCI that is the residuals from an OLS regression
#' gartersnake  |>
#'   bci(svl_mm, mass_g, method = "resid_ols")
#'   
#' # BCI using the SMI method estimated with an OLS regression
#' gartersnake  |>
#'   bci(svl_mm, mass_g, method = "smi_ols")
#'   
#' # BCI using the SMI method estimated with an robust regression
#' gartersnake  |>
#'   bci(svl_mm, mass_g, method = "smi_rob")
#'   
#' # BCI with all three methods
#' gartersnake |>
#'   bci(svl_mm, mass_g, method = c("resid_ols", "smi_ols", "smi_rob"))
#'   
#' @export
bci <- function(data, body_size, weight, id = NULL,
                log_transform = TRUE,
                method = c("resid_ols", "smi_ols", "smi_rob")) {
  
  #browser()
    
  method <- match.arg(method, several.ok = TRUE)
    
  results <- list()
    
  # Calculate methods selected
  if ("resid_ols" %in% method) {
    results$bci_resid_ols = bci_resid_ols(data, {{ body_size }}, {{ weight }}, log_transform = log_transform)[[1]]
  }
    
  if ("smi_ols" %in% method) {
    results$bci_smi_ols <- bci_smi_ols(data, {{ body_size }}, {{ weight }})[[1]]
  }
    
  if ("smi_rob" %in% method) {
    results$bci_smi_rob <- bci_smi_rob(data, {{ body_size }}, {{ weight }})[[1]]
  }
  
  out <- tibble::as_tibble(results)
  
  #---- Add ID if provided ----
  if (!rlang::quo_is_null(rlang::enquo(id))) {
    
    id_vec <- dplyr::pull(data, {{ id }})
  
  stopifnot(length(id_vec) == nrow(out))
  
  out <- dplyr::bind_cols(
    tibble::tibble(id = id_vec),
    out
  )
  }
  
  if (!log_transform &&
      any(method %in% c("smi_ols", "smi_rob"))) {
    
    warning(
      paste(
        "log_transform = FALSE only affects the OLS residual method for body condition estimation.",
        "The SMI methods always assume log-transformed allometric relationships."
      ),
      call. = FALSE
    )
  }
  
  return(out)
    
  }
