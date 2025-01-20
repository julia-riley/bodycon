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

bci_smi <- function(body_size, weight){
  logM_rob <- MASS::rlm(log(weight) ~ log(body_size), method = "M")
  b_msa_rob <- coef(smatr::sma(log(weight) ~ log(body_size), robust = T))[2]
  bci_smi <- weight * (x0 / body_size)^b_msa_rob
}


bci <- function(data, body_size, weight, method = "OLS", print = "index") {
  browser()
  
  x0 = data |> dplyr::pull({{body_size}}) |> mean()

  data |> 
  bci_ols({{body_size}}, {{weight}})
}

if(method == "OLS") {
  
  log_ols <- lm(log(weight) ~ log(body_size))
  b_msa_ols <- coef(sma(log(weight) ~ log(body_size)))[2]  
  bci_ols <- weight * (x0 / body_size)^b_msa_ols
  
}

if(print == "index") {
  
  res_bci_ols_only <- data.frame(bci_ols)
  return(res_bci_ols_only)
  
}

if(print == "index and raw") {
  res_bci_ols_and_raw <- data.frame(bci_ols, body_size, weight)
  return(res_bci_ols)
  
}

if(method == "SMI") {
  
  logM_rob <- rlm(log(weight) ~ log(body_size), method = "M")
  b_msa_rob <- coef(sma(log(weight) ~ log(body_size), robust = T))[2]
  bci_smi <- weight * (x0 / body_size)^b_msa_rob
  
}

if(print == "index") {
  
  res_bci_smi_only <- data.frame(bci_smi)
  return(res_bci_smi_only)
  
}

if(print == "index and raw") {
  
  res_bci_smi_and_raw <- data.frame(bci_smi, body_size, weight)
  return(res_bci_smi_and_raw)
  
}

if(method == "both") {  
  
  logM_ols <- lm(log(weight) ~ log(body_size))
  logM_rob <- rlm(log(weight) ~ log(body_size), method = "M")
  b_msa_ols <- coef(sma(log(weight) ~ log(body_size)))[2]
  b_msa_rob <- coef(sma(log(weight) ~ log(body_size), robust = T))[2]
  bci_ols <- weight * (x0 / body_size)^b_msa_ols
  bci_smi <- weight * (x0 / body_size)^b_msa_rob
  
}

if(print == "index") {
  
  res_bci_only <- data.frame(bci_ols, bci_smi)
  return(res_bci_only)
  
}

if(print == "index and raw") {
  
  res_bci_and_raw <- data.frame(bci_ols, bci_smi, body_size, weight)
  return(res_bci_and_raw)
  
}  




