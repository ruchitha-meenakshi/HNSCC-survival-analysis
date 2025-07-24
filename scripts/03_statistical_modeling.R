# Purpose: Applying Kaplan-Meier and Cox Proportional Hazards models to TCGA-HNSC data

# Loading necessary libraries
library(survival)
library(survminer)
library(here)

# Loading cleaned data
clinical_data <- readRDS(here("data", "cleaned_clinical_data.rds"))

# Creating a Surv object
surv_object <- Surv(time = clinical_data$os_months, event = clinical_data$os_status_bin)

# --- Kaplan-Meier Survival Analysis by Stage ---
km_stage <- survfit(surv_object ~ stage, data = clinical_data)
plot_km_stage <- ggsurvplot(km_stage, data = clinical_data, pval = TRUE, conf.int = TRUE,
                            title = "Kaplan-Meier Survival Curves by Tumor Stage",
                            xlab = "Time (Months)",
                            ylab = "Survial Probability",
                            risk.table = TRUE, risk.table.col = "stage")
ggsave(
  filename = here("outputs", "plots", "survival", "km_survival_by_stage.png"),
  plot = plot_km_stage$plot,  # Only the main plot
  width = 8, height = 6, dpi = 300
)

# --- Kaplan-Meier Survival Analysis by Gender ---
km_gender <- survfit(surv_object ~ gender, data = clinical_data)
plot_km_gender <- ggsurvplot(km_gender, data = clinical_data, pval = TRUE, conf.int = TRUE,
                             title = "Kaplan-Meier Survival Curves by Gender",
                             xlab = "Time (Months)", 
                             ylab = "Survival Probability",
                             risk.table = TRUE, risk.table.col = "gender")
ggsave(
  filename = here("outputs", "plots", "survival", "km_survival_by_gender.png"),
  plot = plot_km_gender$plot,  # Only the main plot
  width = 8, height = 6, dpi = 300
)


# --- Cox Proportional Hazards Model ---
cox_model <- coxph(surv_object ~ age + gender + stage + primary_site, data = clinical_data)
summary(cox_model)

# --- Plot Cox Model Forest Plot ---
png(here("outputs", "plots", "survival", "cox_forest_plot.png"), width = 800, height = 600)
ggforest(cox_model, data = clinical_data, main = "Cox Proportional Hazards Model")
dev.off()

# --- Checking Proportional Hazards Assumption ---
cox_zph <- cox.zph(cox_model)
print(cox_zph)
plot(cox_zph)