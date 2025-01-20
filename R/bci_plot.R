# PLOT of Body Condition Index Pedictions - Ordinary Least Squares (OLS) , Scaled Mass Index (SMI), or Both

# This function is to plot the BCI predictions, so that there can be comparisons between each method or to see how the method you choose visually fits


plot_bci <- function(body_size, weight) { #should I put in a data argument here?
  
    require(smatr)
    require(magrittr)
    require(MASS)
    require(data.table)
    x0 = mean(body_size)
  

  # fonti, I don't know how to make this function, basically BCI will allow us to make the predictions
  # this one I want to plot them so we can compare the methods, or just plot one/the other method
  # I tried it below, but can you see if it works? Makes sense? Can be revised?
  
    y <- weight
    x <- body_size
    
    log_ols <- lm(log(y) ~ log(x))
    b_msa_ols <- coef(sma(log(y) ~ log(x)))[2]    
    bci_ols <- y * (x0 / x)^b.msa.ols
    
    logM_rob <- rlm(log(y) ~ log(x), method = "M")
    b_msa_rob <- coef(sma(log(y) ~ log(x), robust = T))[2]
    bci_smi <- y * (x0 / x)^b.msa.rob
    
    bci_data <- data.frame(bci_ols, bci_smi, body_size, weight)
    
    pred <-
      data.table(body_size = seq(min(body_size), max(body_size), length = 100)) %>%
      .[, y_ols := predict(logM_ols, newdata = .) %>% exp()] %>%
      .[, y_rob := predict(logM_rob, newdata = .) %>% exp()]
    
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
      geom_line(data = SMI_predictions, aes(body_size, bci_smi), colour = "gray20", size = 1.8) + # Is there a way to add a legend with this line labelled OLS Method
      geom_line(data = SMI_predictions, aes(body_size, bci_ols), colour = "gold2", linetype = 2, size = 1.8) # This would be labelled SMI Method
    
    return(SMI_plot)
    
  }