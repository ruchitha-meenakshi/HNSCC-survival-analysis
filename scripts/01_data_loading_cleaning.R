# Purpose: Loading and Cleaning TCGA-HNSC clinical data for survival analysis

# Loading required libraries
library(here)
library(readr)
library(dplyr)

# Set file path
data_path <- here("data", "data_clinical_patient.txt")

# Loading data
# Ignoring first 4 lines as they represent metadata
clinical_data <- read.delim(data_path, skip = 4, stringsAsFactors = FALSE)

# Previewing data structure and first few rows
glimpse(clinical_data)
head(clinical_data)

# Renaming key columns for readability
clinical_data <- clinical_data %>%
  rename(
    patient = PATIENT_ID,
    gender = SEX,
    age = AGE,
    primary_site = PRIMARY_SITE_PATIENT,
    stage = AJCC_PATHOLOGIC_TUMOR_STAGE,
    os_status = OS_STATUS,
    os_months = OS_MONTHS
  )

# Re-coding overall survival status to binary (1 = deceased, 0 = alive)
clinical_data <- clinical_data %>% 
  mutate(
    os_status_bin = ifelse(grepl("DECEASED", os_status, ignore.case = TRUE), 1, 0)
  )

# Filtering out rows with missing survival time or stage
clinical_data <- clinical_data %>%
  filter(!is.na(os_months), !is.na(stage))

# Converting stage to a ordered factor
clinical_data$stage <- factor(
  clinical_data$stage,
  levels = c("Stage I", "Stage II", "Stage III", "Stage IVA", "Stage IVB", "Stage IVC"),
  ordered = TRUE
)

# Converting age to a numeric variable
clinical_data$age <- as.numeric(as.character(clinical_data$age))

# Converting os_months to a numeric variable
clinical_data$os_months <- as.numeric(as.character(clinical_data$os_months))

# Converting gender to a factor variable
clinical_data$gender <- as.factor(clinical_data$gender)

# Converting primary_site to a factor variable
clinical_data$primary_site <- as.factor(clinical_data$primary_site)


# Ensuring os_status_bin is numeric or integer
clinical_data$os_status_bin <- as.numeric(clinical_data$os_status_bin)

# Saving cleaned data set for accessibility
write.csv(clinical_data, here("data", "cleaned_clinical_data.csv"), row.names = FALSE)
saveRDS(clinical_data, here("data", "cleaned_clinical_data.rds"))

# Confirming cleaned data is ready for use
dim(clinical_data)
summary(clinical_data)



  
