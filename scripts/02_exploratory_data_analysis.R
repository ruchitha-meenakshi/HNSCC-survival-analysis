# Purpose: Performing exploratory data analysis on cleaned TCGA-HNSC clinical data

library(tidyverse)
library(ggplot2)
library(here)
library(ggsci) # Professional palettes (Nature, Lancet, etc.)

# Load Data
clinical_data <- readRDS(here("data", "cleaned_clinical_data.rds"))

# Define a Professional Theme
pro_theme <- theme_classic() +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0, color = "#2c3e50"),
    plot.subtitle = element_text(size = 11, color = "grey40", hjust = 0, margin = ggplot2::margin(b = 10)), # FIXED HERE
    axis.text = element_text(size = 10, color = "black"),
    axis.title = element_text(face = "bold", size = 11),
    panel.grid.major.y = element_line(color = "grey90", linewidth = 0.5), # Updated 'size' to 'linewidth' for best practice
    legend.position = "none" 
  )

# ---- 1. Age Distribution (Clean Histogram) ----
p1 <- ggplot(clinical_data, aes(x = age)) +
  geom_histogram(aes(y = ..density..), binwidth = 5, fill = "#3C5488FF", color = "white", alpha = 0.9) +
  geom_density(color = "#E64B35FF", size = 1) + # Dark Blue bars with Red density line
  labs(title = "Patient Age Distribution", 
       subtitle = paste("Median Age:", median(clinical_data$age, na.rm=TRUE), "years"),
       x = "Age", y = "Density") +
  pro_theme

ggsave(here("outputs", "plots", "eda", "eda_age_distribution.png"), p1, width = 8, height = 6, dpi = 300)

# ---- 2. Gender Distribution (Clean Bar Chart) ----
p4 <- clinical_data %>%
  count(gender) %>%
  ggplot(aes(x = gender, y = n)) +
  geom_col(fill = "#3C5488FF", width = 0.6) +
  labs(title = "Gender Distribution", 
       subtitle = paste("Male prevalence consistent with HNSCC epidemiology"),
       x = "Gender", y = "Count") +
  pro_theme

ggsave(here("outputs", "plots", "eda", "eda_gender_distribution.png"), p4, width = 6, height = 6, dpi = 300)

# ---- 3. Tumor Stage (Professional Bar Chart) ----
p2 <- ggplot(clinical_data, aes(x = stage)) +
  geom_bar(fill = "#3C5488FF", width = 0.7) +
  labs(title = "Tumor Stage Distribution", 
       subtitle = "Prevalence of advanced stage disease (Stage IVA)",
       x = "Stage", y = "Count") +
  pro_theme

ggsave(here("outputs", "plots", "eda", "eda_stage_distribution.png"), p2, width = 8, height = 6, dpi = 300)

# ---- 4. Survival Status (Clean & Simple) ----
p3 <- clinical_data %>%
  count(os_status_bin) %>%
  mutate(Status = ifelse(os_status_bin == 1, "Deceased", "Alive")) %>%
  ggplot(aes(x = Status, y = n, fill = Status)) +
  geom_col(width = 0.6) +
  scale_fill_manual(values = c("#4DBBD5FF", "#E64B35FF")) + # Muted Blue vs Muted Red
  labs(title = "Overall Survival Status", 
       subtitle = paste("Total Cohort: N =", nrow(clinical_data)),
       y = "Count") +
  pro_theme

ggsave(here("outputs", "plots", "eda", "eda_survival_status.png"), p3, width = 6, height = 6, dpi = 300)