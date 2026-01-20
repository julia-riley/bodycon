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
#'
#' @returns a vector of body condition indices for each individual estimates that are the residuals from an OLS regression
#' 
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
#' \dontrun{
#' library(bodycon)
#' data("gartersnake")|>
#'    bci_resid_ols(svl_mm, mass_g)
#' 
#' # Note to Fonti: The above is a potential example? We could write it a different way.
#' # If we add additional arguments (like whether or not data is log-transformed), 
#' # then we would also have to add examples with those.
#' }
bci_resid_ols <- function(data, body_size, weight){

  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}), #TODO: Possible option as an argument log-transform = TRUE as a default
                  log_weight = log({{weight}}))
  
  # Compute OLS
  log_ols <- lm(log_weight ~ log_body_size, data = tmp_data)
  bci <- tmp_data |> 
    dplyr::mutate(bci_resid_ols = resid(log_ols))
 
   return(bci$bci_resid_ols)
}


#' Scaled Mass Body Condition Index Estimation with OLS Regression
#' @description 
#' This function calculates body condition indices using the scaled mass index (SMI method)
#' as described in \insertCite{peig2009;textual}{bodycon}. Specifically, this methods
#' uses ordinary least squares regression in its estimation of the body condition indices.
#' Yet, this method is sensitive to the presence of outliers (i.e., data points that may
#' distort the expected relationship between body length and weight), and so SMI estimation
#' using robust regression (see function `bci_smi_rob`) may be more appropriate in cases where
#' outliers are present.
#' #NOTE: FONTI, can we refer to another function in this text?
#' #Also, I am not sure if I used the correct notation for a citation;
#' trying something to figure out the references here.

#' @param data tibble/dataframe containing a standard body size variable and the 
#' corresponding weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length 
#' of reptiles, tarsus length of birds, length from the snout to the base of the 
#' tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' 
#' @return a vector of body condition indices for each individual estimates using 
#' the SMI method using an OLS regression
#' @export
#' @references 
#'  \insertAllCited{}
#' 
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices (using the scaled mass index with OLS)
#' # for the gartersnakes this dataset, one could:
#' 
#' \dontrun{
#' library(bodycon)
#' data("gartersnake")  |>
#'   bci_smi_ols(svl_mm, mass_g)
#' 
#' # Note to Fonti: The above is a potential example? We could write it a different way.
#' # If we add additional arguments, then we would also have to add examples with those.
#' }
bci_smi_ols <- function(data, body_size, weight){
  #browser()
  
  # Compute mean of body size
  x0 = data |> dplyr::pull({{body_size}}) |> mean(na.rm = TRUE)
  
  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}), #Note here about log-transformation: for the scale-mass index calculation of body condition, log-transformation needs to occur, so it cannot be an option for this module 
                  log_weight = log({{weight}}))
  
  # Compute OLS
  log_ols <- lm(log_weight ~ log_body_size, data = tmp_data)
  b_msa_ols <- coef(smatr::sma(log_weight ~ log_body_size, data = tmp_data))[2]   
  bci <- tmp_data |> 
    dplyr::mutate(bci_smi_ols = {{weight}} * (x0 / {{body_size}})^b_msa_ols)
  
  return(bci$bci_smi_ols)
}



#' Scaled Mass Body Condition Index Estimation with Robust Regression
#' @description 
#' This function calculates body condition indices using the scaled mass index (SMI method)
#'  as described in \insertCite{peig2009;textual}{bodycon}. Specifically, this method uses robust regression using an M estimator (from the MASS R package) \insertCite{venables2002}{bodycon} in its estimation of the body condition indices. This method is less sensitive to the presence of outliers (i.e., data points that may distort the expected relationship between body length and weight), as shown in [this blog by by Chen-Pan Liao](https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html).
#' #Note to Fonti: Can we refer to a link in this text? Also, I am not sure if I used the 
#' correct notation for a citation; trying something to figure out the references here.
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, 
#' tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
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
#' \dontrun{ 
#' library(bodycon)
#'   data("gartersnake") |>
#'   bci_smi_rob(svl_mm, mass_g)
#' 
#' # Note to Fonti: The above is a potential example? We could write it a different way.
#' # If we add additional arguments, then we would also have to add examples with those. This example also does not really include outliers? Does that matter?
#' 
bci_smi_rob <- function(data, body_size, weight){
  #browser()
  
  # Compute mean of body size
  x0 = data |> dplyr::pull({{body_size}}) |> mean(na.rm = TRUE)
  
  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}), #Note here about log-transformation: for the scale-mass index calculation of body condition, log-transformation needs to occur, so it cannot be an option for this module 
                  log_weight = log({{weight}}))
  
  # Compute OLS
  log_rob <- MASS::rlm(log_weight ~ log_body_size, method = "M", data = tmp_data)
  b_msa_rob <- coef(smatr::sma(log_weight ~ log_body_size, robust = T, data = tmp_data))[2]   
  bci <- tmp_data |> 
    dplyr::mutate(bci_smi_rob = {{weight}} * (x0 / {{body_size}})^b_msa_rob)
  
  return(bci$bci_smi_rob)
}


#' Visualisation of Body Condition Index Method for Selection
#' @description 
#' This function creates a plot of your raw data with body condition estimation based on different methods. 
#' This allows a visual comparison between methods to visually assess the fit fo each..
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, 
#' tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' 
#' @return a plot of your raw data and predictors from more than one body condition index (as selected by you)
#' 
#' 
#' @examples 
#' # NEED TO PROVIDE
#' 

bci_smi_rob <- function(data, body_size, weight){
  #browser()
  
  # Compute mean of body size
  x0 = data |> dplyr::pull({{body_size}}) |> mean(na.rm = TRUE)
  
  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}), #Note here about log-transformation: for the scale-mass index calculation of body condition, log-transformation needs to occur, so it cannot be an option for this module 
                  log_weight = log({{weight}}))
  
  # Compute OLS
  log_rob <- MASS::rlm(log_weight ~ log_body_size, method = "M", data = tmp_data)
  b_msa_rob <- coef(smatr::sma(log_weight ~ log_body_size, robust = T, data = tmp_data))[2]   
  bci <- tmp_data |> 
    dplyr::mutate(bci_smi_rob = {{weight}} * (x0 / {{body_size}})^b_msa_rob)
  
  return(bci$bci_smi_rob)
}

