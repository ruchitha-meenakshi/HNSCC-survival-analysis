# Purpose: Performing exploratory data analysis on cleaned TCGA-HNSC clinical data

# Loading necessary libraries
library(tidyverse)
library(ggplot2)
library(here)

# Loading cleaned data
clinical_data <- readRDS(here("data", "cleaned_clinical_data.rds"))

# Inspecting data structure   
glimpse(clinical_data)

# Summary statistics
summary(clinical_data)

# ---- Age Distribution ----
ggplot(clinical_data, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "steelblue", colour = "white") +
  labs(title = "Age Distribution", x = "Age", y = "Count") +
  theme_minimal()
ggsave(here("outputs", "plots", "eda", "eda_age_distribution.png"))


# ---- Gender Distribution ----
ggplot(clinical_data, aes(x = gender)) +
  geom_bar(fill = "darkgreen") +
  labs(title = "Gender Distribution", x = "Gender", y = "Count") +
  theme_minimal()
ggsave(here("outputs", "plots", "eda", "eda_gender_distribution.png"))

# --- Stage Distribution ---
ggplot(clinical_data, aes(x = stage)) +
  geom_bar(fill = "darkred") +
  labs(title = "Tumor Stage Distribution", x = "Stage", y = "Count") +
  theme_minimal()
ggsave(here("outputs", "plots", "eda", "eda_stage_distribution.png"))

# --- Survival Time Distribution ---
ggplot(clinical_data, aes(x = os_months)) +
  geom_histogram(binwidth = 6, fill = "orange", color = "black") +
  labs(title = "Overall Survival Time (Months)", x = "Months", y = "Count") +
  theme_minimal()
ggsave(here("outputs", "plots", "eda", "eda_os_distribution.png"))


# --- Survival Status ---
ggplot(clinical_data, aes(x = factor(os_status_bin))) +
  geom_bar(fill = "purple") +
  scale_x_discrete(labels = c("0" = "Alive", "1" = "Deceased")) +
  labs(title = "Survival Status", x = "Status", y = "Count") +
  theme_minimal()
ggsave(here("outputs", "plots", "eda", "eda_survival_status.png"))


# --- Age vs. Survival Status ---
ggplot(clinical_data, aes(x = factor(os_status_bin), y = age, fill = factor(os_status_bin))) +
  geom_boxplot() +
  scale_x_discrete(labels = c("0" = "Alive", "1" = "Deceased")) +
  labs(title = "Age by Survival Status", x = "Survival Status", y = "Age") +
  theme_minimal()
ggsave(here("outputs", "plots", "eda", "eda_age_survival_boxplot.png"))