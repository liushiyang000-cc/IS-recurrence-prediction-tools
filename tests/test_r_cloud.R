# Cloud/R smoke test using repository synthetic data only.
# This verifies that the R runtime and preprocessing components execute.
# It is not a scientific validation of the RIS prediction model.

source("R/generate_synthetic_data.R")
source("R/validate_data.R")
source("R/preprocess_data.R")

df <- generate_synthetic_stroke_cohort(n_patients = 120, seed = 20260923)

clinical_cols <- c("patient_id", "recurrent_stroke", "age", "gender", "nihss_score")
metabolite_cols <- c("metabolite_01", "metabolite_02", "metabolite_03", "metabolite_04")

stopifnot(
  is.data.frame(df),
  nrow(df) == 120,
  all(c(clinical_cols, metabolite_cols) %in% names(df))
)

validate_stroke_data(
  data = df,
  clinical_cols = clinical_cols,
  metabolite_cols = metabolite_cols
)

processed <- preprocess_stroke_data(
  data = df,
  clinical_cols = clinical_cols,
  metabolite_cols = metabolite_cols,
  impute_missing = TRUE,
  log_transform = TRUE,
  auto_scale = TRUE
)

stopifnot(
  nrow(processed) == nrow(df),
  ncol(processed) == ncol(df),
  all(vapply(processed[metabolite_cols], is.numeric, logical(1))),
  !anyNA(processed[metabolite_cols]),
  all(vapply(processed[metabolite_cols], function(x) all(is.finite(x)), logical(1)))
)

means <- vapply(processed[metabolite_cols], mean, numeric(1))
if (any(abs(means) > 1e-8)) {
  stop("Scaled metabolite means are unexpectedly far from zero.")
}

cat("PASS: R synthetic generation, validation, imputation, log transform, and scaling work.\n")
