# Project: IS-recurrence-prediction-tools
# Script: Comprehensive Pipeline (Data Cleaning & OPLS-DA)
# Maintainer: Shiyang Liu

# 1. Load Required Libraries
# install.packages(c("tidyverse", "impute"))
library(tidyverse)

# 2. Load Mock Data
cat("Loading data...\n")
data <- read.csv("../data/mock_data.csv", header = TRUE)

# 3. Data Preprocessing (Normalization)
cat("Normalizing metabolomics features...\n")
numeric_data <- data %>% select(starts_with("Metabolite"))
normalized_data <- scale(numeric_data, center = TRUE, scale = TRUE)

# 4. Correlation with Clinical Scores (NIHSS)
cat("Calculating Spearman correlation with clinical scores...\n")
clinical_score <- data$NIHSS_Score
cor_results <- cor(normalized_data, clinical_score, method = "spearman")

print("Pipeline execution completed. Ready for downstream OPLS-DA modeling.")
print(cor_results)
