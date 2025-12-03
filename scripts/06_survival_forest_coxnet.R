# Purpose: Applying time-to-event ML models - Random Survival Forest and penalized Cox (coxnet)

# Load libraries
library(tidyverse)
library(randomForestSRC)
library(survival)
library(glmnet)
library(here)
library(survminer)
library(gridExtra)

# Load cleaned dataset
clinical_data <- readRDS(here("data", "cleaned_clinical_data.rds"))

# Filter and prepare data
surv_data <- clinical_data %>%
  select(age, gender, stage, primary_site, os_months, os_status_bin) %>%
  na.omit() %>%
  mutate(
    gender = as.factor(gender),
    stage = factor(stage, ordered = FALSE),
    primary_site = fct_lump(factor(primary_site), n = 5)
  )

# --- Step 1: Random Survival Forest ---
set.seed(123)
rsf_model <- rfsrc(Surv(os_months, os_status_bin) ~ age + gender + stage + primary_site,
                   data = surv_data, ntree = 1000, importance = TRUE)
# Print model summary
print(rsf_model)

# Extract survival response
surv_obj <- with(surv_data, Surv(os_months, os_status_bin))

# Get predicted mortality scores
rsf_preds <- predict(rsf_model)$predicted

# Compute C-index using the 'survConcordance' function from the 'survival' package
rsf_cindex <- survConcordance(surv_obj ~ rsf_preds)$concordance

cat("RSF Concordance Index:", round(rsf_cindex, 3), "\n")


# --- Improved RSF Variable Importance Plot (Professional Lollipop) ---
# Extract VIMP (Variable Importance)
vimp_obj <- vimp(rsf_model)
imp_df <- data.frame(
  Variable = names(vimp_obj$importance),
  Importance = vimp_obj$importance
) %>%
  arrange(desc(Importance))

# Create Lollipop Chart
p_rsf_imp <- ggplot(imp_df, aes(x = reorder(Variable, Importance), y = Importance)) +
  geom_point(size = 5, color = "#2c3e50") + # Dark Slate Blue points
  geom_segment(aes(x = Variable, xend = Variable, y = 0, yend = Importance), color = "#95a5a6", size = 1) + # Grey stems
  coord_flip() +
  labs(title = "Variable Importance: Random Survival Forest", 
       subtitle = "Key predictors of patient survival (VIMP Score)",
       x = "", y = "Importance Score") +
  theme_classic() +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0, color = "#2c3e50"),
    plot.subtitle = element_text(size = 11, color = "grey40", hjust = 0),
    axis.text = element_text(size = 11, color = "black"),
    panel.grid.major.x = element_line(color = "grey90", size = 0.5) # Vertical grid lines for easier reading
  )

# Save high-res image
ggsave(here("outputs", "plots", "rsf", "rsf_variable_importance.png"), p_rsf_imp, width = 8, height = 6, dpi = 300)
# --- Step 2: Penalized Cox Regression (CoxNet) ---
# Prepare model matrix
x <- model.matrix(~ age + gender + stage + primary_site, data = surv_data)[, -1]
y <- Surv(surv_data$os_months, surv_data$os_status_bin)

# Fit penalized Cox model
set.seed(123)
cv_cox <- cv.glmnet(x, y, family = "cox", alpha = 1)

# Plot cross-validation curve
png(here("outputs", "plots", "survival", "coxnet_cv_curve.png"), width = 800, height = 600)
plot(cv_cox)
dev.off()

# Best lambda and coefficients
cat("Best lambda:", cv_cox$lambda.min, "\n")
cat("CoxNet coefficients at best lambda:\n")
print(coef(cv_cox, s = "lambda.min"))

# Concordance index for CoxNet
coxnet_lp <- predict(cv_cox, newx = x, s = "lambda.min", type = "link")
coxnet_cindex <- survConcordance(y ~ coxnet_lp)$concordance
cat("CoxNet Concordance Index:", round(coxnet_cindex, 3), "\n")

# --- CoxNet Variable Importance Plot ---
coef_df <- as.data.frame(as.matrix(coef(cv_cox, s = "lambda.min"))) %>%
  rownames_to_column("Variable") %>%
  rename(Coefficient = `1`) %>%
  filter(Coefficient != 0)

write.csv(coef_df, here("outputs", "tables", "coxnet_variable_importance.csv"), row.names = FALSE)

png(here("outputs", "plots", "survival","coxnet_variable_importance.png"), width = 800, height = 600)
ggplot(coef_df, aes(x = reorder(Variable, Coefficient), y = Coefficient)) +
  geom_col(fill = "darkorange") +
  coord_flip() +
  labs(title = "CoxNet Variable Importance", x = "Variable", y = "Coefficient") +
  theme_minimal()
dev.off()

# --- Step 4: Subgroup Survival Curves (Cox Model) ---
cox_base <- coxph(Surv(os_months, os_status_bin) ~ age + gender + stage + primary_site, data = surv_data)

# Predict survival curves for age groups and gender
newdata_age <- data.frame(
  age = c(50, 60, 70),
  gender = factor("Male", levels = levels(surv_data$gender)),
  stage = factor("Stage IVA", levels = levels(surv_data$stage)),
  primary_site = factor("Larynx", levels = levels(surv_data$primary_site))
)

newdata_gender <- data.frame(
  age = 60,
  gender = factor(c("Male", "Female"), levels = levels(surv_data$gender)),
  stage = factor("Stage IVA", levels = levels(surv_data$stage)),
  primary_site = factor("Larynx", levels = levels(surv_data$primary_site))
)

fit_age <- survfit(cox_base, newdata = newdata_age)
fit_gender <- survfit(cox_base, newdata = newdata_gender)

# Plot
png(here("outputs", "plots", "survival","coxnet_predicted_survival_age.png"), width = 800, height = 600)
ggsurvplot(fit_age, data = newdata_age, legend.title = "Age", legend.labs = c("50", "60", "70"),
           palette = "Dark2", xlab = "Months", ylab = "Survival Probability",
           title = "Predicted Survival Curves by Age")
dev.off()

png(here("outputs", "plots", "survival", "coxnet_predicted_survival_gender.png"), width = 800, height = 600)
ggsurvplot(fit_gender, data = newdata_gender, legend.title = "Gender",
           palette = "Dark2", xlab = "Months", ylab = "Survival Probability",
           title = "Predicted Survival Curves by Gender")
dev.off()

# Save subgroup predictions as summary table
summary_df <- data.frame(
  Group = c("Age 50", "Age 60", "Age 70", "Male", "Female"),
  Median_Survival_Months = c(median(fit_age$time[fit_age$surv[,1] <= 0.5], na.rm = TRUE),
                             median(fit_age$time[fit_age$surv[,2] <= 0.5], na.rm = TRUE),
                             median(fit_age$time[fit_age$surv[,3] <= 0.5], na.rm = TRUE),
                             median(fit_gender$time[fit_gender$surv[,1] <= 0.5], na.rm = TRUE),
                             median(fit_gender$time[fit_gender$surv[,2] <= 0.5], na.rm = TRUE))
)

write.csv(summary_df, here("outputs", "tables", "coxnet_subgroup_medians.csv"), row.names = FALSE)
