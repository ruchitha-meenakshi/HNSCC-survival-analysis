# Purpose: Extending ML modeling with feature engineering, logistic regression, and XGBoost

# Loading required libraries
library(tidyverse)
library(caret)
library(glmnet)
library(pROC)
library(here)

# Loading cleaned dataset
clinical_data <- readRDS(here("data", "cleaned_clinical_data.rds"))

# --- Step 1: Creating Binary Survival Outcome ---
clinical_data <- clinical_data %>%
  filter(!is.na(os_months)) %>%
  mutate(survived_24M = ifelse(os_months >= 24, "Survived", "Not_Survived"))

# --- Step 2: Feature Engineering ---
clinical_data <- clinical_data %>%
  mutate(
    age_group = cut(age, breaks = c(0, 60, 70, 100), labels = c("<60", "60-70", ">70")),
    primary_site_grouped = fct_lump(factor(primary_site), n = 5)
  )

# --- Step 3: Prepare Data for Modeling ---
ml_data <- clinical_data %>%
  select(age, age_group, gender, stage, primary_site_grouped, survived_24M) %>%
  na.omit()

# Encoding factors
ml_data <- ml_data %>%
  mutate(
    gender = factor(gender),
    stage = factor(stage),
    primary_site_grouped = factor(primary_site_grouped),
    age_group = factor(age_group),
    survived_24M = factor(survived_24M, levels = c("Not_Survived", "Survived"))
  )

# Train control for all models
set.seed(123)
train_control <- trainControl(
  method = "cv",
  number = 10,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

# --- Step 4: Logistic Regression with Regularization ---
logistic_model <- train(
  survived_24M ~ .,
  data = ml_data,
  method = "glmnet",
  trControl = train_control,
  metric = "ROC",
  preProcess = c("center", "scale")
)
print(logistic_model)

# ROC for Logistic
logistic_roc <- roc(logistic_model$pred$obs, logistic_model$pred$Survived)
logistic_auc <- auc(logistic_roc)
cat("Logistic Regression AUC:", logistic_auc, "\n")

png(here("outputs", "plots", "ml", "logistic_roc_curve.png"), width = 800, height = 600)
plot(logistic_roc, col = "darkred", main = "ROC Curve - Logistic Regression")
dev.off()

# --- Step 5: XGBoost Model ---
xgb_model <- train(
  survived_24M ~ .,
  data = ml_data,
  method = "xgbTree",
  trControl = train_control,
  metric = "ROC",
  preProcess = c("center", "scale")
)
print(xgb_model)

# ROC for XGBoost
xgb_roc <- roc(xgb_model$pred$obs, xgb_model$pred$Survived)
xgb_auc <- auc(xgb_roc)
cat("XGBoost AUC:", xgb_auc, "\n")

png(here("outputs", "plots", "ml", "xgb_roc_curve.png"), width = 800, height = 600)
plot(xgb_roc, col = "darkgreen", main = "ROC Curve - XGBoost")
dev.off()

# --- Save AUCs for comparison ---
auc_results <- data.frame(
  Model = c("Logistic Regression", "XGBoost"),
  AUC = c(logistic_auc, xgb_auc)
)

write.csv(auc_results, here("outputs", "tables", "model_auc_comparison.csv"), row.names = FALSE)
