# Body Condition Index - Ordinary Least Squares (OLS) , Scaled Mass Index (SMI), or Both

# This function calculates body condition indices using the ordinary least squares (OLS) or scaled mass index (SMI) methods

# It was partially inspired by Peig & Green (2009) and was adapted from code by Chen-Pan Liao (https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html)


bci <- function(body_size, weight, method, print) { #Fonti, should we put in a data argument here?
    
  require(smatr)
  require(magrittr)
  require(MASS)
  require(data.table)
  x0 = mean(body_size)
  
  # fonti, this is a note from the paper on pg. 1888:
  
  # Although any body length value could be used as L0, we recommend those values which falls in the middle range of L (e.g. arithmetic mean, geometric mean, or median), since confidence intervals tend to be narrower in the middle of
  # the fitted lnMlnL line than at its extremes.
  
  #should we include an argument where the reader can decide whether this is mean/median, etc?
  
    
  }

if(method == "OLS") {

  log_ols <- lm(log(weight) ~ log(body_size))
  b_msa_ols <- coef(sma(log(weight) ~ log(body_size)))[2]  
  bci_ols <- weight * (x0 / body_size)^b_msa_ols 
  
  # Fonti, to me this may not be the simple OLS method, because I am not sure why the X0 (mean bosy size of the population) is included in this calculation
  # This is how I think it should be calculated. What do you think?
  
  #ols_reg <- lm(log(weight) ~ log(body_size))
  #bci_ols <- resid(ols_reg)
  
  # If this is the case, then this needs to be fixed in the graph function too.
  # I am now VERY confused about the difference between the OLS method (what I understand to be described in Peig and Green, and the Robust method below - where did it come from)
  
  # Okay, I looked up the function "rlm" below and it is a linear model fitted by "robust regression using an M estimator".
  # So, in short, BOTH of these are the scaled mass index for body condition - one is fit using a standard linear model and the second is fit using a robust linear model.
  # DARN IT. I should have caught that.
  
  #What I would like to do is have (1) the proper OLS residual index (coded in the commented out section above), (2) scaled mass index that is estimated with A. OLS or B. Robust regression (helpful link for this: https://www.spsanderson.com/steveondata/posts/2023-11-28/index.html).
  # If you do check out the website above, Liao's graphs seems to suggest that the latter does better for some data. 
  
  # If you want to have a meeting about this... let me know.

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
    
    
    

