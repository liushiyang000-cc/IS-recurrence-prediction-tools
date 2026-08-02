# 🚀 Quick Start Guide & Usage Tutorial

This guide will walk you through how to use the `IS-recurrence-prediction-tools` pipeline using our provided synthetic dataset.

## 1. Prerequisites
Ensure you have **R (>= 4.1.0)** installed. The pipeline requires the following standard R packages:
```R
install.packages(c("dplyr", "readr", "tibble"))
IS-recurrence-prediction-tools/
├── data/
│   └── synthetic_stroke_cohort.csv   # Integrated clinical & metabolomics dataset
├── R/
│   └── preprocess_data.R             # Core data preprocessing engine
├── README.md                         # Project overview and architecture
└── Usage.md                          # This tutorial documentation
# Load required library
library(dplyr)

# Source the core preprocessing functions into the R environment
source("R/preprocess_data.R")
# Load the raw dataset
raw_data <- read.csv("data/synthetic_stroke_cohort.csv")

# Preview the data structure
head(raw_data)
# Define clinical and metabolomic variable names matching the dataset
clin_vars <- c("patient_id", "age", "gender", "nihss_score", "recurrent_stroke")
metab_vars <- c("metabolite_01", "metabolite_02", "metabolite_03", "metabolite_04")

# Execute the automated preprocessing pipeline
clean_dataset <- preprocess_stroke_data(
  data = raw_data,
  clinical_cols = clin_vars,
  metabolite_cols = metab_vars,
  impute_missing = TRUE,   # Enable missing value imputation
  log_transform = TRUE,    # Enable Log2 transformation
  auto_scale = TRUE        # Enable Pareto scaling
)
# Preview the cleaned and normalized dataset ready for ML modeling
head(clean_dataset)
