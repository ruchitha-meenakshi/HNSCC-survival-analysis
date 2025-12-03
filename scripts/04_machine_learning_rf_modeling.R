# Purpose: Applying machine learning models to predict 2-year survival using TCGA-HNSC data

# Loading required libraries
library(tidyverse)
library(caret)
library(randomForest)
library(pROC)
library(here)

# Loading cleaned dataset
clinical_data <- readRDS(here("data", "cleaned_clinical_data.rds"))

# --- Step 1: Create Binary Survival Outcome ---
# Define 2-year (24-month) survival as the classification target
clinical_data <- clinical_data %>%
  filter(!is.na(os_months)) %>%
  mutate(survived_24M = ifelse(os_months >= 24, "Survived", "Not_Survived"))

# --- Step 2: Remove rows with missing predictors ---
ml_data <- clinical_data %>%
  select(age, gender, stage, primary_site, survived_24M) %>%
  na.omit()

# --- Step 3: Encode categorical variables ---
ml_data$gender <- as.factor(ml_data$gender)
ml_data$stage <- factor(ml_data$stage, ordered = FALSE)
ml_data$primary_site <- as.factor(ml_data$primary_site)
ml_data$survived_24M <- factor(ml_data$survived_24M, levels = c("Not_Survived", "Survived"))

# --- Step 4: Cross-Validation Setup ---
set.seed(123)
train_control <- trainControl(
  method = "cv",
  number = 10,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

# --- Step 5: Train Random Forest with CV ---
rf_model_cv <- train(
  survived_24M ~ .,
  data = ml_data,
  method = "rf",
  trControl = train_control,
  metric = "ROC",
  preProcess = c("center", "scale")
)

# Print model summary
print(rf_model_cv)

# --- Step 6: ROC Curve and AUC ---
roc_obj <- roc(rf_model_cv$pred$obs, rf_model_cv$pred$Survived)
auc_val <- auc(roc_obj)
cat("Cross-Validated AUC:", auc_val, "\n")

# # --- Step 7: Plot ROC Curve
# png(here("outputs", "plots", "ml", "rf_cv_roc_curve.png"), width = 800, height = 600)
# plot(roc_obj, col = "darkblue", main = "Cross-Validated ROC Curve - Random Forest")
# dev.off()
# 
# # --- Step 8: Variable Importance Plot ---
# png(here("outputs", "plots", "ml", "rf_cv_variable_importance.png"), width = 800, height = 600)
# varImpPlot(rf_model_cv$finalModel, main = "Variable Importance - Random Forest")
# dev.off()

# --- Step 7: Plot ROC Curve (ggplot style) ---
# Extract data for plotting
roc_dat <- data.frame(
  Specificity = roc_obj$specificities,
  Sensitivity = roc_obj$sensitivities
)

p_roc <- ggplot(roc_dat, aes(x = 1 - Specificity, y = Sensitivity)) +
  geom_line(color = "#00468BFF", size = 1.2) +
  geom_abline(linetype = "dashed", color = "grey") +
  labs(title = "ROC Curve: Random Forest",
       subtitle = paste("Cross-Validated AUC =", round(auc_val, 3)),
       x = "1 - Specificity (False Positive Rate)",
       y = "Sensitivity (True Positive Rate)") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(here("outputs", "plots", "ml", "rf_cv_roc_curve.png"), p_roc, width = 8, height = 6)

# --- Step 8: Variable Importance (Lollipop Chart) ---
# Extract importance
imp_df <- varImp(rf_model_cv)$importance %>% 
  as.data.frame() %>%
  rownames_to_column("Feature") %>%
  arrange(desc(Overall))

p_imp <- ggplot(imp_df, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_point(size = 4, color = "#00468BFF") +
  geom_segment(aes(x = Feature, xend = Feature, y = 0, yend = Overall), color = "#00468BFF") +
  coord_flip() +
  labs(title = "Feature Importance (Random Forest)", x = "", y = "Importance Score") +
  theme_minimal()

ggsave(here("outputs", "plots", "ml", "rf_cv_variable_importance.png"), p_imp, width = 8, height = 6)

# --- Step 9: Save prepared ML dataset ---
save(ml_data, file = here("data", "ml_data.RData"))
