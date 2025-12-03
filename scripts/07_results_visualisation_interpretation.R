# Purpose: Comparing model performance and summarizing key findings with professional visuals

# Load libraries
library(ggplot2)
library(dplyr)
library(tibble)
library(here)
library(readr)

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

# --- Step 3: Plot comparison (Remastered) ---
# Create a factor to order bars by value
model_results$Model <- reorder(model_results$Model, model_results$Value)

p_compare <- ggplot(model_results, aes(x = Model, y = Value, fill = Metric)) +
  geom_col(width = 0.7, alpha = 0.9) +
  geom_text(aes(label = sprintf("%.3f", Value)), hjust = -0.2, size = 3.5) +
  scale_fill_manual(values = c("AUC" = "#95a5a6", "C-index" = "#2c3e50")) + # Grey for Binary, Dark Blue for Survival
  ylim(0, 0.85) + # Add headroom for labels
  coord_flip() +
  labs(title = "Model Performance Benchmark", 
       subtitle = "Survival Models (C-Index) vs. Binary Classifiers (AUC)",
       x = "", y = "Performance Score") +
  theme_classic() +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0, color = "#2c3e50"),
    plot.subtitle = element_text(size = 11, color = "grey40", hjust = 0, margin = ggplot2::margin(b = 10)),
    axis.text = element_text(size = 11, color = "black"),
    legend.position = "bottom",
    legend.title = element_blank(),
    panel.grid.major.x = element_line(color = "grey90", linewidth = 0.5)
  )

# Save high-res plot
ggsave(here("outputs", "plots", "final_model_comparison_plot.png"), p_compare, width = 8, height = 6, dpi = 300)

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
cat("1. Binary classifiers (AUC ~0.55) performed poorly, likely due to class imbalance and loss of time-to-event information.\n")
cat("2. Random Survival Forests (C-index = 0.74) significantly outperformed all other models.\n")
cat("3. This confirms that modeling censorship is critical for accurate HNSCC prognosis.\n")
sink()

# --- Step 5: Export subgroup survival table ---
# Ensure the file exists before reading
if(file.exists(here("outputs", "tables", "coxnet_subgroup_medians.csv"))) {
  subgroup_table <- read_csv(here("outputs", "tables", "coxnet_subgroup_medians.csv"), show_col_types = FALSE)
  write.csv(subgroup_table, here("outputs", "tables", "final_subgroup_survival_table.csv"), row.names = FALSE)
}