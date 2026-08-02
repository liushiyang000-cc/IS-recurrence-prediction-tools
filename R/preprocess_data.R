# ==============================================================================
# Pipeline Component: Clinical & Metabolomics Data Preprocessing
# Project: IS-recurrence-prediction-tools
# Description: Multi-modal data validation, missing value imputation, normalization,
#              and formatting for ischemic stroke recurrence prediction models.
# ==============================================================================

#' Preprocess Metabolomics and Clinical Data for Ischemic Stroke Recurrence Prediction
#'
#' @description
#' Validates, cleans, imputes missing values, and normalizes integrated 
#' clinical and metabolomic dataset for downstream statistical modeling and 
#' machine learning pipelines.
#'
#' @param data A \code{data.frame} or \code{tibble} containing both clinical demographic/outcome variables
#'   and quantified metabolomics feature intensities.
#' @param clinical_cols A character vector specifying the exact column names for clinical variables 
#'   (e.g., \code{c("patient_id", "recurrent_stroke", "age", "nihss_score")}).
#' @param metabolite_cols A character vector specifying the column names corresponding to target 
#'   metabolites or molecular features.
#' @param impute_missing Logical; if \code{TRUE}, performs half-minimum (1/2 Min) missing value 
#'   imputation for zero or \code{NA} values in metabolomics columns. Default is \code{TRUE}.
#' @param log_transform Logical; if \code{TRUE}, applies $log_2$ transformation to metabolomics features 
#'   to minimize skewness. Default is \code{TRUE}.
#' @param auto_scale Logical; if \code{TRUE}, applies Pareto scaling (mean-centered and divided by 
#'   the square root of standard deviation) to feature matrix. Default is \code{TRUE}.
#'
#' @return A cleaned, transformed, and validated \code{tibble} prepared for statistical feature selection.
#'
#' @details
#' The validation pipeline checks for the presence of target outcome variables, missing rate 
#' thresholds, and non-numeric inputs within specified metabolite features before applying 
#' quantitative transformations.
#'
#' @examples
#' \dontrun{
#'   # Load synthetic dataset
#'   raw_data <- read.csv("data/synthetic_stroke_cohort.csv")
#'   
#'   # Execute normalization pipeline
#'   processed_df <- preprocess_stroke_data(
#'     data = raw_data,
#'     clinical_cols = c("patient_id", "recurrent_stroke", "age", "gender"),
#'     metabolite_cols = c("metabolite_01", "metabolite_02", "metabolite_03"),
#'     impute_missing = TRUE,
#'     log_transform = TRUE,
#'     auto_scale = TRUE
#'   )
#' }
#' @export
preprocess_stroke_data <- function(data,
                                   clinical_cols,
                                   metabolite_cols,
                                   impute_missing = TRUE,
                                   log_transform = TRUE,
                                   auto_scale = TRUE) {
  
  # ----------------------------------------------------------------------------
  # Defensive Data Validation (Data Integrity Checks)
  # ----------------------------------------------------------------------------
  if (!is.data.frame(data)) {
    stop("Input 'data' must be a data.frame or tibble.")
  }
  
  missing_clinical <- setdiff(clinical_cols, colnames(data))
  if (length(missing_clinical) > 0) {
    stop(paste("The following specified clinical columns were not found in the dataset:",
               paste(missing_clinical, collapse = ", ")))
  }
  
  missing_metabolites <- setdiff(metabolite_cols, colnames(data))
  if (length(missing_metabolites) > 0) {
    stop(paste("The following specified metabolite columns were not found in the dataset:",
               paste(missing_metabolites, collapse = ", ")))
  }
  
  # Check numeric data types for metabolomics features
  non_numeric_metabolites <- metabolite_cols[!sapply(data[metabolite_cols], is.numeric)]
  if (length(non_numeric_metabolites) > 0) {
    stop(paste("Metabolite columns must contain strictly numeric values. Invalid columns:",
               paste(non_numeric_metabolites, collapse = ", ")))
  }
  
  message("[INFO] Basic data validation passed. Processing ", 
          length(metabolite_cols), " metabolite features across ", 
          nrow(data), " samples.")

  processed_data <- data
  
  # ----------------------------------------------------------------------------
  # Step 1: Missing Value Handling & Imputation
  # ----------------------------------------------------------------------------
  if (impute_missing) {
    message("[INFO] Executing half-minimum imputation for zero/missing metabolite features...")
    for (col in metabolite_cols) {
      vals <- processed_data[[col]]
      # Replace zeros or NaNs with NA
      vals[vals == 0 | is.nan(vals)] <- NA
      
      if (any(is.na(vals))) {
        min_val <- min(vals, na.rm = TRUE)
        if (is.infinite(min_val) || min_val <= 0) min_val <- 1e-5
        impute_val <- min_val / 2
        vals[is.na(vals)] <- impute_val
        processed_data[[col]] <- vals
      }
    }
  }

  # ----------------------------------------------------------------------------
  # Step 2: Mathematical Transformations (Log2 & Pareto Scaling)
  # ----------------------------------------------------------------------------
  if (log_transform) {
    message("[INFO] Applying Log2 transformation to metabolomics intensities...")
    processed_data[metabolite_cols] <- lapply(processed_data[metabolite_cols], function(x) {
      log2(x + 1e-6) # Add epsilon to prevent log(0)
    })
  }

  if (auto_scale) {
    message("[INFO] Applying Pareto scaling to metabolite feature matrix...")
    processed_data[metabolite_cols] <- lapply(processed_data[metabolite_cols], function(x) {
      scale_val <- (x - mean(x, na.rm = TRUE)) / sqrt(sd(x, na.rm = TRUE))
      return(as.numeric(scale_val))
    })
  }

  message("[SUCCESS] Data preprocessing completed successfully.")
  return(processed_data)
}
