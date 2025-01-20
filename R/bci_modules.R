#' SMI Body Condition Estimation with OLS Regression
#' @description 
#' This function calculates body condition indices using the ordinary least squares (OLS) or scaled mass index (SMI) methods
#' @param data tibble/dataframe containing body size and weight variables
#' @param body_size name of body size variable e.g. svl_mm
#' @param weight name of weight variable e.g. mass_g
#' 
#' @return a vector of XXXX #TODO: [Julia](www.rileyecology.com)
#' @export
#' @author 
#' @references reference # https://roxygen2.r-lib.org/articles/index-crossref.html
#' @examples
#' bci_ols()

bci_ols <- function(data, body_size, weight){
  # browser()
  
  # Compute mean of body size
  x0 = data |> dplyr::pull({{body_size}}) |> mean(na.rm = TRUE)
  
  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}), #TODO: Possible option as an argument log-transform = TRUE as a default 
                  log_weight = log({{weight}}))
  
  # Compute OLS
  log_ols <- lm(log_weight ~ log_body_size, data = tmp_data)
  b_msa_ols <- coef(smatr::sma(log_weight ~ log_body_size, data = tmp_data))[2]   
  bci_sma_ols <- tmp_data |> 
    dplyr::mutate(bci_ols = {{weight}} * (x0 / {{body_size}})^b_msa_ols)
  
  return(bci_sma_ols$bci_ols)
}

# Body Condition Index - Ordinary Least Squares (OLS) , Scaled Mass Index (SMI), or Both

# This function calculates body condition indices using the ordinary least squares (OLS) or scaled mass index (SMI) methods

# It was partially inspired by Peig & Green (2009) and was adapted from code by Chen-Pan Liao (https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html)

