# Purpose: Comparing model performance and summarize key findings

# Load libraries
library(ggplot2)
library(dplyr)
library(tibble)
library(here)

# --- Step 1: Define model performance results ---
model_results <- tribble(
  ~Model,                        ~Metric,  ~Value,
  "Cox Proportional Hazards",    "C-index", 0.646,
  "Random Forest",               "AUC",     0.546,
  "Logistic Regression (L1)",    "AUC",     0.571,
  "XGBoost",                     "AUC",     0.557,
  "Random Survival Forest (RSF)","C-index", 0.740,
  "Penalized Cox (CoxNet)",      "C-index", 0.639
)

# --- Step 2: Save summary as CSV ---
write.csv(model_results, here("outputs", "tables", "final_model_performance_summary.csv"), row.names = FALSE)

# --- Step 3: Plot comparison ---
png(here("outputs", "plots", "final_model_comparison_plot.png"), width = 800, height = 600)
ggplot(model_results, aes(x = reorder(Model, Value), y = Value, fill = Metric)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_text(aes(label = round(Value, 3)), vjust = -0.5) +
  ylim(0, 1) +
  labs(title = "Model Performance Comparison", x = "Model", y = "Performance (AUC or C-index)") +
  coord_flip() +
  theme_minimal() +
  theme(legend.position = "bottom")
dev.off()

# --- Step 4: Save textual summary ---
sink(here("outputs", "tables", "final_model_summary.txt"))
cat("MODEL COMPARISON SUMMARY\n")
cat("----------------------------\n")
cat("Cox Proportional Hazards: Concordance = 0.646\n")
cat("Random Forest (classification): AUC = 0.546\n")
cat("Logistic Regression (L1-regularized): AUC = 0.571\n")
cat("XGBoost: AUC = 0.557\n")
cat("Random Survival Forest (RSF): Concordance = 0.740\n")
cat("Penalized Cox (CoxNet): Concordance = 0.639\n\n")

cat("INTERPRETATION:\n")
cat("Traditional classifiers showed modest performance, likely limited by the clinical variables available.\n")
cat("Random Survival Forests significantly outperformed other models (C-index = 0.74), \n")
cat("demonstrating the value of native survival modeling for censored data.\n")
cat("Penalized Cox regression (CoxNet) also showed good performance (C-index = 0.639), \n")
cat("reinforcing the value of regularization and stage-based risk stratification.\n")
sink()

# --- Step 5: Export subgroup survival table ---
subgroup_table <- read_csv(here("outputs", "tables", "coxnet_subgroup_medians.csv"), show_col_types = FALSE)
write.csv(subgroup_table, here("outputs", "tables", "final_subgroup_survival_table.csv"), row.names = FALSE)