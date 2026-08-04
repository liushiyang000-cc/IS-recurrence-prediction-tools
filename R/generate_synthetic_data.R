# ==============================================================================
# Pipeline Component: Synthetic Data Generator
# Project: IS-recurrence-prediction-tools
# Description: Generates realistic synthetic clinical & metabolomics cohort data
#              for reproducible testing of stroke recurrence prediction models.
# ==============================================================================

#' Generate Synthetic Ischemic Stroke Cohort Data
#'
#' @description
#' Simulates an integrated dataset containing patient demographics, baseline clinical 
#' scores, outcome markers (stroke recurrence), and quantified targeted metabolomics features.
#'
#' @param n_patients Integer. Number of synthetic patient samples to simulate. Default is 100.
#' @param seed Integer. Random seed for reproducibility. Default is 2026.
#'
#' @return A \code{data.frame} containing clinical variables and synthetic metabolite intensity profiles.
#' @export
generate_synthetic_stroke_cohort <- function(n_patients = 100, seed = 2026) {
  set.seed(seed)
  
  message(sprintf("[INFO] Generating synthetic dataset for %d patients...", n_patients))
  
  # 1. Simulate Patient Demographics & Clinical Profiles
  patient_ids <- sprintf("PAT_%04d", 1:n_patients)
  ages <- round(rnorm(n_patients, mean = 65, sd = 10))
  ages <- pmax(pmin(ages, 90), 35) # Constraint age between 35 and 90
  
  genders <- sample(c("Male", "Female"), size = n_patients, replace = TRUE, prob = c(0.6, 0.4))
  nihss_scores <- rpois(n_patients, lambda = 6) # Baseline NIHSS score
  
  # Outcome variable: Recurrent ischemic stroke (0 = No, 1 = Yes)
  recurrent_stroke <- sample(c(0, 1), size = n_patients, replace = TRUE, prob = c(0.75, 0.25))
  
  # 2. Simulate Metabolomics Feature Matrix
  # Simulating 4 metabolites with positive intensity distributions
  metabolite_01 <- rlnorm(n_patients, meanlog = 4.5, sdlog = 0.8)
  metabolite_02 <- rlnorm(n_patients, meanlog = 3.2, sdlog = 0.5)
  metabolite_03 <- rlnorm(n_patients, meanlog = 5.0, sdlog = 1.0)
  metabolite_04 <- rlnorm(n_patients, meanlog = 2.8, sdlog = 0.6)
  
  # Introduce simulated missingness (zeros) into 3% of metabolomics entries to test imputation
  metabolite_01[sample(1:n_patients, size = floor(n_patients * 0.03))] <- 0
  metabolite_03[sample(1:n_patients, size = floor(n_patients * 0.02))] <- NA
  
  # Combine into final data.frame
  synthetic_df <- data.frame(
    patient_id = patient_ids,
    age = ages,
    gender = genders,
    nihss_score = nihss_scores,
    recurrent_stroke = recurrent_stroke,
    metabolite_01 = round(metabolite_01, 4),
    metabolite_02 = round(metabolite_02, 4),
    metabolite_03 = round(metabolite_03, 4),
    metabolite_04 = round(metabolite_04, 4),
    stringsAsFactors = FALSE
  )
  
  message("[SUCCESS] Synthetic dataset generated successfully.")
  return(synthetic_df)
}

# Optional: Direct script execution block to generate the CSV file under data/
if (!interactive()) {
  if (!dir.exists("data")) dir.create("data")
  df <- generate_synthetic_stroke_cohort(n_patients = 100)
  write.csv(df, file = "data/synthetic_stroke_cohort.csv", row.names = FALSE)
  message("[INFO] Saved synthetic dataset to 'data/synthetic_stroke_cohort.csv'")
}
