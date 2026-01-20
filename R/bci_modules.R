#' Body Condition Index Estimation using Residuals from an OLS Regression
#'
#' @description
#' This function calculates body condition indices from the residuals of an ordinary 
#' least squares regression (OLS). This is a traditional approach in ecology as outlined 
#' by \insertCite{krebs1993;textual}{bodycon}. There is discussion whether it is the most 
#' robust approach \insertCite{schulte2005,peig2009}{bodycon}, how its appropriateness
#' may vary by taxon \insertCite{jakob1996,buancilua2010,labocha2012}{bodycon}, and whether
#' or not it fits the assumptions of certain statistical tests \insertCite{garcia2001}{bodycon}. 
#' 
#' @param data tibble/dataframe containing a standard body size variable and the corresponding weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#'
#' @returns a vector of body condition indices for each individual estimates that are the residuals from an OLS regression
#' 
#' @references 
#'   \insertAllCited{}
#'
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices (using residuals from an OLS) for the gartersnakes
#' # in this dataset, one could:
#' 
#' \dontrun{
#' library(bodycon)
#' gartersnake |>
#'    bci_resid_ols(svl_mm, mass_g)
#' }
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
#' This function calculates body condition indices using the scaled mass index (SMI method)
#' as described in \insertCite{peig2009;textual}{bodycon}. Specifically, this method
#' uses ordinary least squares regression in its estimation of the body condition indices.
#' Yet, this method is sensitive to the presence of outliers (i.e., data points that may
#' distort the expected relationship between body length and weight), and so SMI estimation
#' using robust regression (see function `bci_smi_rob`) may be more appropriate in cases where
#' outliers are present.
#' 
#' @param data tibble/dataframe containing a standard body size variable and the 
#' corresponding weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length 
#' of reptiles, tarsus length of birds, length from the snout to the base of the 
#' tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' 
#' @return a vector of body condition indices for each individual estimates using 
#' the SMI method using an OLS regression
#'
#' @references 
#'  \insertAllCited{}
#' 
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices (using the scaled mass index with OLS)
#' # for the gartersnakes this dataset, one could:
#' 
#' \dontrun{
#' library(bodycon)
#' gartersnake  |>
#'   bci_smi_ols(svl_mm, mass_g)
#' }
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



#' Scaled Mass Body Condition Index Estimation with Robust Regression
#' @description 
#' This function calculates body condition indices using the scaled mass index (SMI method)
#'  as described in \insertCite{peig2009;textual}{bodycon}. Specifically, this method uses robust regression using an M estimator (from the MASS R package) \insertCite{venables2002}{bodycon} in its estimation of the body condition indices. This method is less sensitive to the presence of outliers (i.e., data points that may distort the expected relationship between body length and weight), as shown in [this blog by by Chen-Pan Liao](https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html).
#'
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, 
#' tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' 
#' @return a vector of body condition indices for each individual estimates using the SMI
#'  method using a robust regression
#' @importFrom Rdpack reprompt
#' 
#' @references 
#'   \insertAllCited{}
#' 
#' @examples 
#' # In this examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices (using the scaled mass index with a robust regression)
#' # for the gartersnakes from this dataset, one could:
#'
#' \dontrun{ 
#' library(bodycon)
#' gartersnake |>
#'   bci_smi_rob(svl_mm, mass_g)
#' }
bci_smi_rob <- function(data, body_size, weight){
  #browser()
  
  # Compute mean of body size
  x0 = data |> dplyr::pull({{body_size}}) |> mean(na.rm = TRUE)
  
  # Create tmp data for log transformations
  tmp_data <- data |> 
    dplyr::select({{body_size}}, {{weight}}) |> 
    dplyr::mutate(log_body_size = log({{body_size}}), #Note here about log-transformation: for the scale-mass index calculation of body condition, log-transformation needs to occur, so it cannot be an option for this module 
                  log_weight = log({{weight}}))
  
  # Compute OLS
  log_rob <- MASS::rlm(log_weight ~ log_body_size, method = "M", data = tmp_data)
  b_msa_rob <- coef(smatr::sma(log_weight ~ log_body_size, robust = T, data = tmp_data))[2]   
  bci <- tmp_data |> 
    dplyr::mutate(bci_smi_rob = {{weight}} * (x0 / {{body_size}})^b_msa_rob)
  
  return(bci$bci_smi_rob)
}


#' Animal Body Condition Index Estimation
#'
#' @description
#' This function calculates body condition indices using multiple established methods: from the residuals of an ordinary 
#' least squares regression (OLS), and using the scaled mass index (SMI) method using OLS or robust regression for estimation.
#' 
#' First, calculating body condition indices from the residuals of an OLS regression  is a traditional 
#' approach in ecology as outlined by \insertCite{krebs1993;textual}{bodycon}. There is discussion whether it is the most 
#' robust approach \insertCite{schulte2005,peig2009}{bodycon}, how its appropriateness
#' may vary by taxon \insertCite{jakob1996,buancilua2010,labocha2012}{bodycon}, and whether
#' or not it fits the assumptions of certain statistical tests \insertCite{garcia2001}{bodycon}. 
#' 
#' The second method, calculates body condition indices using the SMI method as described in \insertCite{peig2009;textual}{bodycon}. 
#' Specifically, this method uses OLS or robust regression in its estimation of the body condition indices.
#' OLS regression is sensitive to the presence of outliers (i.e., data points that may distort the expected relationship between body length and weight).
#' So, another option is to estimate SMI using robust regression using an M estimator (from the MASS R package) \insertCite{venables2002}{bodycon} in its 
#' estimation of the body condition indices. The robus regression approach is less sensitive to the presence of outliers 
#' (i.e., data points that may distort the expected relationship between body length and weight), as shown in [this blog by by Chen-Pan Liao](https://apansharing.blogspot.com/2018/05/an-r-function-olsrobust-caled-mass-index.html).
#'
#' @param data tibble/dataframe containing a standard body size variable and the corresponding 
#' weight for each individual of one animal species
#' @param body_size name of standard body size variable (e.g., snout-vent-length of reptiles, tarsus length of birds, length from the snout to the base of the tail for mammals, etc.)
#' @param weight name of weight variable (e.g., mass of the animal)
#' @param method method used to estimate body condition, either residuals from an OLS regression (`"resid_ols"`) or scaled mass index using an OLS (`"smi_ols"` or robust regression (`"smi_ols"`). Provide one or a list of these. 
#'
#' @return a vector of body condition indices for each individual estimates using the method specified
#' 
#' @importFrom Rdpack reprompt
#' 
#' @references 
#'   \insertAllCited{}
#'   
#' @examples 
#' # In these examples we will make use of the `gartersnake` dataset in this R package.
#' # This dataset contains the mass (in grams) and snout-vent length (in mm) of 46 Maritime Gartersnakes.
#' # To estimate body condition indices for the gartersnakes this dataset, one could:
#' 
#' \dontrun{
#' library(bodycon)
#' 
#' # BCI that is the residuals from an OLS regression
#' gartersnake  |>
#'   bci_smi_ols(svl_mm, mass_g, method = "resid_ols")
#'   
#' # BCI using the SMI method estimated with an OLS regression
#' gartersnake  |>
#'   bci_smi_ols(svl_mm, mass_g, method = "smi_ols")
#'   
#' # BCI using the SMI method estimated with an robust regression
#' gartersnake  |>
#'   bci_smi_ols(svl_mm, mass_g, method = "smi_rob")
#'   
#' # BCI with all three methods
#' gartersnake |>
#'   bci_smi_ols(svl_mm, mass_g, method = c("resid_ols", "smi_ols", "smi_rob"))
#' }
#' @export
bci <- function(data, body_size, weight,
                method = c("resid_ols", "smi_ols", "smi_rob")) {
  
  method <- match.arg(method)
  
  if (method == "resid_ols") {
    bci_resid_ols(data, {{ body_size }}, {{ weight }})
  } else if (method == "smi_ols") {
    bci_smi_ols(data, {{ body_size }}, {{ weight }})
  } else if (method == "smi_rob") {
    bci_smi_rob(data, {{ body_size }}, {{ weight }})
  }
}


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
#' \dontrun{
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
#' }
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
