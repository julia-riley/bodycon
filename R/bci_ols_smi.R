# Body Condition Index - Ordinary Least Squares (OLS) , Scaled Mass Index (SMI), or Both

# This function calculates body condition indices using the ordinary least squares (OLS) or scaled mass index (SMI) methods

# It was partially inspired by Peig & Green (2009) and was adapted from code by Chen-Pan Liao (https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html)


# bci <- function(body_size, weight, bc_index, est_method, print) { #Fonti, should we put in a data argument here so a user could refer to a dataset?
#     
#   require(smatr)
#   require(magrittr)
#   require(MASS)
#   require(data.table)
#   x0 = mean(body_size)
#   
#   # fonti, this is a note from the paper on pg. 1888:
#   
#   # Although any body length value could be used as x0, we recommend those values which falls in the middle range of L (e.g. arithmetic mean, geometric mean, or median), since confidence intervals tend to be narrower in the middle of
#   # the fitted lnMlnL line than at its extremes.
#   
#   # Should we include an argument where the reader can decide whether this is mean/median, etc?
#   
#     
# }
# 
# 
# if(bc_index == "OLS_residuals") { #for this index, there is not a est_method argument. Is there a way to say that the user should not define that if they select this method?
#   
#   # Fonti, I added this in from lines 29-48 after I realised that I was not calculating the body condition inex based on OLS regression only before... Whoops
#   # I also edited below to adjust object and argument names accordingly with this change :) 
#   
#   ols_regress <- lm(log(weight) ~ log(body_size)) 
#   bci_ols_resid <- resid(ols_regress)
#   
# }
# 
# if(print == "index") {
#   
#   bci_ols_resid_only <- data.frame(bci_ols_resid)
#   return(bci_ols_resid_only)
#   
# }
# 
# if(print == "index and raw") {
#   bci_ols_resid_and_raw <- data.frame(bci_ols_resid, body_size, weight)
#   return(bci_ols_resid_and_raw)
#   
# }
#   
# }
# 
# if(bc_index == "scaled_mass_index" & est_method == "OLS") { #this is the method described in Peig and Green
# 
#   log_smi_ols <- lm(log(weight) ~ log(body_size))
#   b_msa_ols <- coef(sma(log(weight) ~ log(body_size)))[2]  
#   bci_smi_ols <- weight * (x0 / body_size)^b_msa_ols 
# 
#   }
# 
#   if(print == "index") {
# 
#   bci_smi_ols_only <- data.frame(bci_smi_ols)
#   return(bci_smi_ols_only )
#   
#   }
# 
#   if(print == "index and raw") {
#   bci_smi_ols_and_raw <- data.frame(bci_smi_ols, body_size, weight)
#   return(bci_smi_ols_and_raw)
#   
#   }
#   
# if(bc_index == "scaled_mass_index" & est_method == "robust_regression") { #this is a method that was on the blog linked above, and this regression is more robust to outliers
#   
#   logM_rob <- rlm(log(weight) ~ log(body_size), method = "M")
#   b_msa_rob <- coef(sma(log(weight) ~ log(body_size), robust = T))[2]
#   bci_smi_rob <- weight * (x0 / body_size)^b_msa_rob
#   
# }
# 
# if(print == "index") {
#   
#   bci_smi_rob_only <- data.frame(bci_smi_rob)
#   return(bci_smi_rob_only)
#   
# }
# 
# if(print == "index and raw") {
#   
#   bci_smi_rob_and_raw <- data.frame(bci_smi_rob, body_size, weight)
#   return(bci_smi_rob_and_raw)
#   
# }
#   
# if(bc_index == "all" & est_method = "both") {  #fonti, do we have to include the option to calculate bc with ols-residuals, and then smi with ONE of the methods, instead of all? This is a whole bunch of repetition. I am wondering if it is worth it.
#   
#     ols_regress <- lm(log(weight) ~ log(body_size)) 
#     bci_ols_resid <- resid(ols_regress)  
#     logM_ols <- lm(log(weight) ~ log(body_size))
#     logM_rob <- rlm(log(weight) ~ log(body_size), method = "M")
#     b_msa_ols <- coef(sma(log(weight) ~ log(body_size)))[2]
#     b_msa_rob <- coef(sma(log(weight) ~ log(body_size), robust = T))[2]
#     bci_smi_ols <- weight * (x0 / body_size)^b_msa_ols
#     bci_smi_rob <- weight * (x0 / body_size)^b_msa_rob
#     
# }
# 
# if(print == "index") {
#   
#   res_bci_only <- data.frame(bci_ols_resid, bci_smi_ols, bci_smi_rob)
#   return(res_bci_only)
#   
# }
# 
# if(print == "index and raw") {
#   
#   res_bci_and_raw <- data.frame(bci_ols_resid, bci_smi_ols, bci_smi_rob, body_size, weight)
#   return(res_bci_and_raw)
#   
# }  
#     
#     
#     
# 
