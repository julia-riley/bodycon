# PLOT of Body Condition Index Predictions - Ordinary Least Squares (OLS) , Scaled Mass Index (SMI), or Both

# This function is to plot the BCI predictions, so that there can be comparisons between each method or to see how the method you choose visually fits

# It was partially inspired by Peig & Green (2009) and was adapted from code by Chen-Pan Liao (https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html)



plot_bci <- function(body_size, weight) { #font, should I put in a data argument here so that people could refer to dataset rather than vectors?
  
    require(smatr)
    require(magrittr)
    require(MASS)
    require(data.table)
    x0 = mean(body_size) #fonti, same question as per the bci_ols_smi.R file. Should we have a way that people could specify mean or median?
  

  # fonti, I don't know how to make this function, basically BCI will allow us to make the predictions
  # this one I want to plot them so we can compare the methods, or just plot one/the other method
  # I tried it below, but can you see if it works? Makes sense? Can be revised?
  
    y <- weight
    x <- body_size
    
    ols_regress <- lm(log(y) ~ log(x)) 
    bci_ols_resid <- resid(ols_regress)
    
    log_ols <- lm(log(y) ~ log(x))
    b_msa_ols <- coef(sma(log(y) ~ log(x)))[2]    
    bci_smi_ols <- y * (x0 / x)^b.msa.ols
    
    logM_rob <- rlm(log(y) ~ log(x), method = "M")
    b_msa_rob <- coef(sma(log(y) ~ log(x), robust = T))[2]
    bci_smi_rob <- y * (x0 / x)^b.msa.rob
    
    bci_data <- data.frame(bci_ols_resid, bci_smi_ols, bci_smi_rob, body_size, weight)
    
    pred <-
      data.table(body_size = seq(min(body_size), max(body_size), length = 100)) %>%
      .[, y_ols_resid := predict(ols_regress, newdata = .) %>% exp()] %>%           #fonti, I am not sure this line is correct, but let's see!
      .[, y_smi_ols := predict(logM_ols, newdata = .) %>% exp()] %>%
      .[, y_smi_rob := predict(logM_rob, newdata = .) %>% exp()]
    
    attr(bci_data, "b_msa") <- c(ols = b_msa_ols, smi = b_msa_rob)
    
    SMI_plot <- ggplot(pred, aes(body_size, weight, #colour = sex #fonti, is there a way to add a argument above, so this can be delinated by a group?
                                 )) +
      geom_point(size = 2, alpha = 0.8) +
      #scale_color_manual(
        #name = NULL,
        #values = c("#C23B3B", "skyblue2")) + #fonti, is there a way to let them select the colour for their group, or just have a default?
      theme_classic() +
      theme(
        text = element_text(size = 14, family = "serif"),
        axis.text = element_text(size = 14),
        legend.position = NULL,
        legend.title.align = 0.5,
        panel.border = element_rect(colour = "black", fill = NA, size = 1)
      ) +
      labs(
        x = "Body Size", #Fonti, we have default ones, but also can this be customized by in the argument too? How do we do that?
        y = "Weight"
      ) +
      geom_line(data = pred, aes(body_size, y_ols_resid), colour = "gray20", size = 1.8) + # This would be labelled "Residuals from a OLS Regression"
      geom_line(data = pred, aes(body_size, y_smi_ols), colour = "darkorange2", linetype = 3, size = 2) + # Is there a way to add a legend with this line labelled "Scaled Mass Index est. with. OLS Regression"
      geom_line(data = pred, aes(body_size, y_smi_rob), colour = "gold2", linetype = 2, size = 2.2) # This would be labelled "Scaled Mass Index est. with. Robust Regression"
    
    return(SMI_plot)
    
  }