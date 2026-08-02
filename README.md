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
## 🧬 Analysis Pipeline

The following flowchart illustrates our standardized data integration and modeling pipeline for ischemic stroke recurrence prediction:

```mermaid
graph TD
    %% Define styles
    classDef data fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef process fill:#fff3e0,stroke:#e65100,stroke-width:2px;
    classDef model fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px;
    classDef outcome fill:#fce4ec,stroke:#880e4f,stroke-width:2px,color:#880e4f,font-weight:bold;

    %% Nodes
    A1[(Clinical Demographics)]:::data
    A2[(Targeted Metabolomics)]:::data
    B[Data Integration & Quality Control]:::process
    C[Preprocessing Module<br/>1/2 Min Imputation & Log2 Transformation]:::process
    D[Pareto Scaling & Normalization]:::process
    E{Feature Selection<br/>LASSO / Random Forest}:::model
    F[Multivariate Statistical Modeling<br/>Machine Learning Framework]:::model
    G(((Ischemic Stroke<br/>Recurrence Risk Assessment))):::outcome

    %% Flow
    A1 --> B
    A2 --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
