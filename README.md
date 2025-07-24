# Predicting Overall Survival in Head and Neck Squamous Cell Carcinoma
This project explores **prognostic modeling** for patients with **Head and Neck Squamous Cell Carcinoma (HNSCC)** using clinical data from The Cancer Genome Atlas (TCGA). The analysis compares traditional statistical survival methods and modern machine learning models for predicting overall survival.

## Objectives

- Identify key clinical predictors of survival in HNSCC.
- Compare traditional models (Kaplan-Meier, Cox PH) with ML approaches (Random Forest, XGBoost, CoxNet, RSF).
- Evaluate models using metrics like **C-index** and **AUC**.
- Visualize subgroup survival estimates and model performance.

## Project Structure
<pre> ``` head_neck_survival_project/ ├── data/ # Raw and processed clinical data │ ├── data_clinical_patient.txt │ ├── cleaned_clinical_data.rds │ └── ml_data.RData │ ├── outputs/ # All output files │ ├── plots/ # Visualizations │ │ ├── survival/ # Survival curves, forest plots, etc. │ │ ├── ml/ # Machine learning model plots (ROC, AUC) │ │ └── eda/ # Exploratory data analysis visuals │ ├── models/ # Saved model objects (if any) │ └── tables/ # CSV summaries, variable importance, metrics │ ├── scripts/ # Analysis scripts │ ├── 01_data_loading_cleaning.R │ ├── 02_exploratory_data_analysis.R │ ├── 03_statistical_modeling.R │ ├── 04_machine_learning_rf_modeling.R │ ├── 05_ml_feature_log_xgb_modeling.R │ ├── 06_survival_forest_coxnet.R │ └── 07_results_visualisation_interpretation.R │ ├── report/ # R Markdown report source │ └── Final_Report.Rmd │ ├── Final_Report.pdf # Rendered PDF report └── README.md # Project documentation ``` </pre>

## Key Findings
- **Random Survival Forest (RSF)** achieved the best performance (C-index = 0.74).
- **CoxNet (L1-penalized)** models offered interpretability with good performance (C-index = 0.639).
- Classification models like Random Forest and XGBoost performed modestly due to class imbalance and loss of time granularity.
- Subgroup analysis revealed survival variations across **age** and **gender**.

## Requirements

- R 4.x
- R packages:
  - `survival`, `survminer`, `randomForestSRC`, `glmnet`, `xgboost`, `caret`, `here`, `tidyverse`, `ggplot2`
  - 
To install packages:

```r
install.packages(c("survival", "survminer", "randomForestSRC", "glmnet", "xgboost", "caret", "here", "tidyverse", "ggplot2"))
```

## Running the Project
1. Clone the repo.
2. Open Final_Report.Rmd in RStudio.
3. Click Knit to PDF to render the complete analysis.
4. Ensure your working directory is correctly set via the here() package.

## Outputs
- Visualizations of survival distributions
- Kaplan–Meier survival plots
- Model performance comparisons
- Subgroup median survival estimates
- Final report (Final_Report.pdf)

