# Purpose: Applying Kaplan-Meier and Cox Proportional Hazards models to TCGA-HNSC data

# Loading necessary libraries
library(survival)
library(survminer)
library(here)

# Loading cleaned data
clinical_data <- readRDS(here("data", "cleaned_clinical_data.rds"))

# Creating a Surv object
surv_object <- Surv(time = clinical_data$os_months, event = clinical_data$os_status_bin)

# --- 1. Kaplan-Meier Analysis by Stage ---
km_stage <- survfit(surv_object ~ stage, data = clinical_data)

# Create the full plot object
plot_km_stage <- ggsurvplot(
  km_stage, 
  data = clinical_data, 
  pval = TRUE, 
  conf.int = TRUE,
  title = "Kaplan-Meier Survival Curves by Tumor Stage",
  xlab = "Time (Months)",
  ylab = "Survival Probability",
  risk.table = TRUE,       # Show the table
  risk.table.col = "strata", # Match colors to curves
  risk.table.height = 0.25,# Give the table enough space
  ggtheme = theme_classic(), # Cleaner background
  palette = "jco",         # Professional color palette (Journal of Clinical Oncology)
  legend.title = "Stage",
  risk.table.y.text = FALSE # Clean up table axis labels
)

# We must print the object to a device to capture both parts
png(here("outputs", "plots", "survival", "km_survival_by_stage.png"), 
    width = 10, height = 8, units = "in", res = 300)
print(plot_km_stage)
dev.off()


# --- 2. Kaplan-Meier Analysis by Gender (Remastered) ---
km_gender <- survfit(surv_object ~ gender, data = clinical_data)

plot_km_gender <- ggsurvplot(
  km_gender, 
  data = clinical_data, 
  pval = TRUE, 
  conf.int = TRUE,
  title = "Kaplan-Meier Survival Curves by Gender",
  xlab = "Time (Months)", 
  ylab = "Survival Probability",
  risk.table = TRUE, 
  risk.table.col = "strata",
  risk.table.height = 0.25,
  ggtheme = theme_classic(),
  palette = "jco",
  legend.title = "Gender",
  risk.table.y.text = FALSE
)

# Save Curve + Table
png(here("outputs", "plots", "survival", "km_survival_by_gender.png"), 
    width = 10, height = 8, units = "in", res = 300)
print(plot_km_gender)
dev.off()


# --- 3. Cox Proportional Hazards Model ---
cox_model <- coxph(surv_object ~ age + gender + stage + primary_site, data = clinical_data)
summary(cox_model)

# --- Plot Cox Model Forest Plot ---
# This is already correct, but ensuring high-res output
png(here("outputs", "plots", "survival", "cox_forest_plot.png"), 
    width = 10, height = 6, units = "in", res = 300)
print(ggforest(cox_model, data = clinical_data, main = "Cox Proportional Hazards Model"))
dev.off()

# --- Checking Proportional Hazards Assumption ---
cox_zph <- cox.zph(cox_model)
print(cox_zph)

# Optional: Save the PH assumption check plot too if you want it for the report
png(here("outputs", "plots", "survival", "cox_zph_check.png"), 
    width = 8, height = 6, units = "in", res = 300)
plot(cox_zph)
dev.off()
