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
  if (!is.null(group)) {
    plot_data$group <- dplyr::pull(data, {{ group }})
  } else {
    plot_data$group <- "All"
  }
  
  # Set default method colours
  if (is.null(method_colours)) {
    method_colours <- c(
      "OLS residuals" = "grey30",
      "SMI (OLS)" = "gold2",
      "SMI (robust)" = "steelblue"
    )
  }
  
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(body_size, weight)) +
    ggplot2::geom_point(
      ggplot2::aes(colour = group),
      alpha = 0.7,
      size = 2
    ) +
    ggplot2::theme_classic() +
    ggplot2::labs(
      x = "body_size",
      y = "weight",
      colour = "method"
    )
  
  if (!is.null(raw_colours)) {
    p <- p + ggplot2::scale_color_manual(values = raw_colours)
  }
  
  pred_lines <- list()
  
  if ("resid_ols" %in% method) {
    pred_lines$resid_ols <- data.frame(
      body_size = sort(x),
      weight = exp(predict(stats::lm(log(y) ~ log(x)),
                           newdata = data.frame(x = sort(x)))),
      method = "OLS residuals"
    )
  }
  
  if ("smi_ols" %in% method) {
    pred_lines$smi_ols <- data.frame(
      body_size = x,
      weight = bci(data, {{ body_size }}, {{ weight }}, method = "smi_ols"),
      method = "SMI (OLS)"
    )
  }
  
  if ("smi_rob" %in% method) {
    pred_lines$smi_rob <- data.frame(
      body_size = x,
      weight = bci(data, {{ body_size }}, {{ weight }}, method = "smi_rob"),
      method = "SMI (robust)"
    )
  }
  
  pred_df <- do.call(rbind, pred_lines)
  
  # Add method lines
  p <- p +
    ggplot2::geom_line(
      data = pred_df,
      ggplot2::aes(body_size, weight, colour = method),
      linewidth = 1.2
    ) +
    ggplot2::scale_colour_manual(values = method_colours)
  
  # Optionally hide legend
  if (!legend) {
    p <- p + ggplot2::theme(legend.position = "none")
  }
  
  p
}