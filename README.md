# Predicting Overall Survival in Head and Neck Squamous Cell Carcinoma
This project explores **prognostic modeling** for patients with **Head and Neck Squamous Cell Carcinoma (HNSCC)** using clinical data from The Cancer Genome Atlas (TCGA). The analysis compares traditional statistical survival methods and modern machine learning models for predicting overall survival.

## Objectives

- Identify key clinical predictors of survival in HNSCC.
- Compare traditional models (Kaplan-Meier, Cox PH) with ML approaches (Random Forest, XGBoost, CoxNet, RSF).
- Evaluate models using metrics like **C-index** and **AUC**.
- Visualize subgroup survival estimates and model performance.

## Project Structure
```
HNSCC-survival-analysis
├── data
│   ├── data_clinical_patient.txt
│   ├── cleaned_clinical_data.rds
│   └── ml_data.RData
├── outputs
│   ├── plots
│   └── tables
├── scripts
│   ├── 01_data_loading_cleaning.R
│   ├── 02_exploratory_data_analysis.R
│   ├── 03_statistical_modeling.R
│   ├── 04_machine_learning_rf_modeling.R
│   ├── 05_ml_feature_log_xgb_modeling.R
│   ├── 06_survival_forest_coxnet.R
│   └── 07_results_visualisation_interpretation.R
├── report
│   ├── Final_Report.Rmd
│   └── Final_Report.pdf
└── README.md
```

## Key Findings
- **Random Survival Forest (RSF)** achieved the best performance (C-index = 0.74).
- **CoxNet (L1-penalized)** models offered interpretability with good performance (C-index = 0.639).
- Classification models like Random Forest and XGBoost performed modestly due to class imbalance and loss of time granularity.
- Subgroup analysis revealed survival variations across **age** and **gender**.

## Requirements

- R 4.5.x
- R packages:
  - `survival`, `survminer`, `randomForestSRC`, `glmnet`, `xgboost`, `caret`, `here`, `tidyverse`, `ggplot2`
    
To install packages:

```r
install.packages(c("survival", "survminer", "randomForestSRC", "glmnet", "xgboost", "caret", "here", "tidyverse", "ggplot2"))
```

## Running the Project
1. Clone the repository:
   ```bash
   git clone https://github.com/ruchitha-meenakshi/HNSCC-survival-analysis.git
   ```
2. Open the R project file HNSurvival.Rproj in RStudio. This ensures your working directory is correctly managed with the {here} package.
3. Open report/Final_Report.Rmd in RStudio.
4. Click the Knit button to render the full analysis report as a PDF.
   ```
   ✅ All paths in the project use the {here} package, so no manual setting of the working directory is required.
   ```

## Outputs
- Visualizations of survival distributions
- Kaplan–Meier survival plots
- Model performance comparisons
- Subgroup median survival estimates
- Final report (Final_Report.pdf)

