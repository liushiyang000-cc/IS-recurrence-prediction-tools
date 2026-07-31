# 🧠 IS-recurrence-prediction-tools

> **An Open-Source Bioinformatics Pipeline for Ischemic Stroke Recurrence Prediction Integrating Metabolomics & Clinical Data**

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![R-Version](https://img.shields.io/badge/R-%3E%3D%204.2.0-blue.svg)

## 📌 Overview
This repository provides a standardized data processing and statistical analysis pipeline for clinical research on **Ischemic Stroke (IS) recurrence**. It integrates:
- **UPLC-Q-TOF/MS Non-targeted Metabolomics Data**
- **Clinical Evaluation Scales** (e.g., NIHSS, mRS)
- **Molecular Biomarkers** (e.g., PBMCs expression)

This pipeline serves as the analytical foundation for investigating the protective mechanisms of acupuncture ("Tongdu Tiaoshen") and establishing clinical SOPs.

## 🚀 Quick Start
All scripts are written in R. We provide synthetic mock data in the `data/` folder for pipeline testing.

## 📂 Core Modules
- `01_preprocessing.R`: Missing value imputation (KNN) and data normalization.
- `02_multivariate.R`: PCA and OPLS-DA modeling for extracting VIP scores.
- `03_association.R`: Spearman correlation mapping between metabolites and clinical scores.

## 📜 Maintainer
Shiyang Liu (Principal Investigator)
