# ==============================================================================
# Pipeline Component: Data Quality Validation
# Project: IS-recurrence-prediction-tools
# Description: Health-check functions to validate clinical data completeness 
#              and metabolomics data formatting before modeling.
# ==============================================================================

#' Validate Ischemic Stroke Integrated Data
#'
#' @description
#' Performs rigorous quality control checks on the input dataset, including 
#' duplicate patient IDs, missing clinical variables, and negative metabolic intensities.
#'
#' @param data A data.frame containing the integrated dataset.
#' @param clinical_cols A character vector of clinical column names.
#' @param metabolite_cols A character vector of metabolite column names.
#' @return Returns TRUE if all non-fatal checks pass, or throws warnings/errors.
#' @export
validate_stroke_data <- function(data, clinical_cols, metabolite_cols) {
  
  message("Starting data quality validation...")
  
  # ----------------------------------------------------------------------------
  # Check 1: Duplicate Patient Identifiers
  # ----------------------------------------------------------------------------
  if ("patient_id" %in% colnames(data)) {
    duplicates <- sum(duplicated(data$patient_id))
    if (duplicates > 0) {
      warning(sprintf("[WARNING] Found %d duplicate patient_ids. Please ensure each row represents a unique clinical event.", duplicates))
    } else {
      message("  [v] No duplicate patient IDs found.")
    }
  }

  # ----------------------------------------------------------------------------
  # Check 2: Missing Values in Clinical Columns
  # ----------------------------------------------------------------------------
  # Clinical variables (like age, gender) usually shouldn't have missing values 
  # before statistical modeling, unlike metabolomics data.
  clin_na_counts <- colSums(is.na(data[clinical_cols]))
  clin_with_na <- names(clin_na_counts[clin_na_counts > 0])
  
  if (length(clin_with_na) > 0) {
    warning(paste("[WARNING] Missing values detected in essential clinical columns:",
                  paste(clin_with_na, collapse = ", "), 
                  ". Consider clinical imputation or excluding these patients."))
  } else {
    message("  [v] Clinical variables are complete (no missing values).")
  }

  # ----------------------------------------------------------------------------
  # Check 3: Invalid Negative Values in Metabolomics
  # ----------------------------------------------------------------------------
  # Raw metabolomics intensities/areas should logically be >= 0.
  neg_check <- sapply(data[metabolite_cols], function(x) any(x < 0, na.rm = TRUE))
  neg_cols <- names(neg_check[neg_check == TRUE])
  
  if (length(neg_cols) > 0) {
    stop(paste("[ERROR] Negative intensity values found in metabolites:",
               paste(neg_cols, collapse = ", "),
               ". Raw metabolomics intensities must be non-negative. Validation aborted."))
  } else {
    message("  [v] Metabolomics numeric boundaries are valid.")
  }

  message("Data validation completed successfully.")
  return(TRUE)
}
