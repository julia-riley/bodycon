# Body Condition Index - Ordinary Least Squares (OLS) , Scaled Mass Index (SMI), or Both

# This function calculates body condition indices using the ordinary least squares (OLS) or scaled mass index (SMI) methods

# It was partially inspired by Peig & Green (2009) and was adapted from code by Chen-Pan Liao (https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html)

bci_ols <- function(data, body_size, weight){
  #browser()
  
  x0 = data |> dplyr::pull({{body_size}}) |> mean()
  
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}),
                  log_weight = log({{body_size}}))
  
  log_ols <- lm(log_weight ~ log_body_size, data = tmp_data)
  b_msa_ols <- coef(smatr::ma(log_weight ~ log_body_size, data = tmp_data))[2]   # Warning message: In slope.test(Y, X, test.value = NA, method = method, alpha = alpha,  :Group found with zero error variance.
  bci_ols <- tmp_data |> 
    dplyr::mutate(bci_ols = {{weight}} * (x0 / {{body_size}})^b_msa_ols)
  
  return(bci_ols)
}

