#' Visualise and Compare Body Condition Index Methods
#'
#' @description
#' Visualize and compare body condition index (BCI) estimation methods by
#' plotting raw, observed body size–weight data alongside BCI estimated fits. 
#' The function uses the \code{bci()} wrapper to ensure consistency between
#' analytical and visual outputs.
#'
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param method method used to estimate body condition, either residuals from an OLS regression (`"resid_ols"`) or scaled mass index using an OLS (`"smi_ols"`) or robust regression (`"smi_ols"`). Provide one or a list of these. 
#' @param legend Logical indicating whether a legend mapping methods to
#'   visual elements should be displayed. Default is `TRUE`.
#' @param group Optional column in \code{data} specifying grouping of raw points
#'   (e.g., sex, population). Default is \code{NULL} (all points treated as one group).
#' @param raw_colours Optional named vector specifying colours for each group of raw points.
#'   Names must match the values in the \code{group} column.
#'   If \code{NULL}, default ggplot2 colours are used.
#' @param method_colours Optional named vector specifying colours for the BCI methods.
#'   Names must match \code{"OLS residuals"}, \code{"SMI (OLS)"}, \code{"SMI (robust)"}.
#'   Defaults are grey, yellow, and blue.
#' @param legend Logical indicating whether to display the legend. Default is \code{TRUE}.
#'
#'
#' @return A `ggplot` object.
#'
#' @details
#' This function is intended for exploratory and comparative visualization
#' of body condition estimation methods. When multiple BCI methods are shown,
#' fitted lines are coloured by method, and points can optionally be split
#' and coloured by a grouping variable.
#'
#' @examples
#' gartersnake <- data("gartersnake")
#'
#' # Basic plot with all methods
#' plot_bci(
#'   gartersnake,
#'   svl_mm,
#'   mass_g,
#'   method = c("resid_ols", "smi_ols", "smi_rob")
#'  )
#'
#' # Plot only BCI using the SMI method estimated with an robust regression
#' # and group your raw data by sex
#' plot_bci(
#'   gartersnake,
#'   svl_mm,
#'   mass_g,
#'   method = c("smi_rob"),
#'   group = sex
#' )
#'
#' # Plot BCI using two SMI methods &
#' # have custom colours for groups and methods
#' plot_bci(
#'   gartersnake,
#'   svl_mm,
#'   mass_g,
#'   method = c("smi_ols", "smi_rob"),
#'   group = sex,
#'   raw_colours = c("M" = "darkorange2", "F" = "mediumpurple"),
#'   method_colours = c("OLS residuals" = "black", "SMI (robust)" = "navy")
#' )
#' 
#' # Plot BCI using the SMI method estimated with an robust regression
#' # and hide the legend
#' plot_bci(
#'   gartersnake,
#'   svl_mm,
#'   mass_g,
#'   method = c("smi_ols"),
#'   legend = FALSE
#' )
#' 
#' @importFrom ggplot2 ggplot aes geom_point geom_line theme_classic labs
#'   scale_colour_manual theme
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_line
#'   theme_classic labs scale_colour_manual theme
#' @export
plot_bci <- function(data, body_size, weight,
                     method = c("resid_ols", "smi_ols", "smi_rob"),
                     group = NULL,
                     raw_colours = NULL,
                     method_colours = NULL,
                     legend = TRUE) {
    
  x <- dplyr::pull(data, {{ body_size }})
  y <- dplyr::pull(data, {{ weight }})
  
  plot_data <- data.frame(
    body_size = x,
    weight = y
  )
  
  # Add grouping if specified
  group_var <- rlang::enquo(group)
  
  if (rlang::quo_is_null(group_var)) {
    plot_data$.group <- "all"
  } else {
    plot_data$.group <- dplyr::pull(plot_data, !!group_var)
  }
  
  plot_data$.group <- as.factor(plot_data$.group)
  
  # Define colours for points
  if (is.null(raw_colours)) {
    raw_colours <- scales::hue_pal()(length(unique(plot_data$.group)))
    names(raw_colours) <- unique(plot_data$.group)
  }
  
  # Set default method colours for lines
  if (is.null(method_colours)) {
    method_colours <- c(
      "OLS regression" = "grey30",
      "SMI (OLS)" = "gold2",
      "SMI (robust)" = "steelblue"
    )
  }
  
  # Calculating possible prediction lines
  pred_lines <- list()
  
  body_seq <- seq(
    min(plot_data$body_size, na.rm = TRUE),
    max(plot_data$body_size, na.rm = TRUE),
    length.out = 100
  )
  
  pred_grid <- data.frame(body_size = body_seq)
  
  ## OLS regression line
  if ("resid_ols" %in% method) {
    
    log_ols <- lm(log(weight) ~ log(body_size), data = plot_data)
    
    pred_lines$resid_ols <- pred_grid |>
      dplyr::mutate(
        pred_wgt = exp(predict(log_ols, newdata = pred_grid)),
        method = "OLS regression"
      )
  }
  
  ## SMI (OLS)
  if ("smi_ols" %in% method) {
    
    x0 <- mean(plot_data$body_size, na.rm = TRUE)
    
    b_msa_ols <- coef(
      smatr::sma(log(weight) ~ log(body_size), data = plot_data)
    )[2]
    
    smi_values <- plot_data$weight *
      (x0 / plot_data$body_size)^b_msa_ols
    
    mean_smi <- mean(smi_values, na.rm = TRUE)
    
    pred_lines$smi_ols <- pred_grid |>
      dplyr::mutate(
        pred_wgt = mean_smi * (body_size / x0)^b_msa_ols,
        method = "SMI (OLS)"
      )
  }
  
  ## SMI (robust)
  if ("smi_rob" %in% method) {
    
    x0 <- mean(plot_data$body_size, na.rm = TRUE)
    
    b_msa_rob <- coef(
      smatr::sma(log(weight) ~ log(body_size),
                 data = plot_data,
                 robust = TRUE)
    )[2]
    
    smi_values <- plot_data$weight *
      (x0 / plot_data$body_size)^b_msa_rob
    
    mean_smi <- mean(smi_values, na.rm = TRUE)
    
    pred_lines$smi_rob <- pred_grid |>
      dplyr::mutate(
        pred_wgt = mean_smi * (body_size / x0)^b_msa_rob,
        method = "SMI (robust)"
      )
  }
  
  ## Combine all
  pred_df <- dplyr::bind_rows(pred_lines)
  
  
  # Plot of point data 
  if (length(unique(plot_data$.group)) == 1) {
    
    # Default neutral colour
    p <- ggplot2::ggplot(plot_data, ggplot2::aes(body_size, weight)) +
      ggplot2::geom_point(
        colour = "grey80",
        alpha = 0.7,
        size = 2
      )
    
  } else {
    
    # real grouping → mapped colours
    p <- ggplot2::ggplot(plot_data, ggplot2::aes(body_size, weight)) +
      ggplot2::geom_point(
        ggplot2::aes(colour = .group),
        alpha = 0.7,
        size = 2
      ) +
      
      ggplot2::scale_colour_manual(values = raw_colours)
  }
  
  # Add lines to plot
    
    ##Reset colours for lines
    p <- ggnewscale::new_scale_colour() +
    
    ggplot2::geom_line(
      data = pred_df,
      ggplot2::aes(body_size, pred_wgt, colour = method),
      linewidth = 1.2
    ) +
      
    ggplot2::scale_colour_manual(values = method_colours)
    
  # Add themes to plot
    p <- ggplot2::theme_classic() +
    
    ggplot2::labs(
      x = "body_size",
      y = "weight",
      colour = "legend"
    )
  
  # Optionally hide legend
  if (!legend) {
    p <- p + ggplot2::theme(legend.position = "none")
  }
 
  # Plot it as the function output 
  p
}