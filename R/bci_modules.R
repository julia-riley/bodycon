
#' Body Condition Index Estimation using Residuals from an OLS Regression
#'
#' @description 
#'
#' @param data tibble/dataframe containing a standard body size variable and the corresponding weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#'
#' @returns
#' @importFrom Rdpack reprompt
#' 
#' @references 
#'   \references{
#'      \insertAllCited{}
#'      }
#'
#' @examples FONT! What do we do here?
#' 
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
#' This function calculates body condition indices using the scaled mass index (SMI method) as described in \insertCite{peig2009;textual}{bodycon}. Specifically, this methods uses ordinary least squares regression in its estimation of the body condition indices. Yet, this method is sensitive to the presence of outliers (i.e., data points that may distort the expected relationship between body length and weight), and so SMI estimation using robust regression (see function `name`) may be more appropriate in cases where outliers are present.

#' #NOTE: FONTI, can we refer to another function in this text? Also, I am not sure if I used the correct notation for a citation; trying something to figure out the references here.

#' @param data tibble/dataframe containing a standard body size variable and the corresponding weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' 
#' @return a vector of body condition indices for each individual estimates using the SMI method using an OLS regression
#' @importFrom Rdpack reprompt
#' 
#' @references 
#'   \references{
#'      \insertAllCited{}
#'      }
#' 
#' @examples 
#' FONTI? WHAT DO WE DO HERE?
#' 
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

