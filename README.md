# Pipeline_2Scripts
This repository contains an end-to-end R data engineering and analysis pipeline designed to clean, wrangle, and visualize complex clinical and transcriptomic data. The project comprehensively addresses systemic data integrity issues—such as string formatting mismatches, data type corruptions, and missing pathological classifications—to construct a clean master dataset for evaluating downstream oncological biomarkers.

---

## Project Structure & Pipeline Overview

The analysis follows a strict data engineering pipeline to guarantee reproducible research:
1. Environment Setup & Dependencies: Activating core `tidyverse` and `dplyr` packages.
2. Data Ingestion: Reading raw structural expression matrices and clinical metadata profiles.
3. Identifier Sanitization: Reconciling string formatting disparities across patient keys (`_` vs `-`).
4. Data Type Correction: Resolving data type corruptions (converting text numbers like "fifty-two" to numeric integers).
5. Pathology Filtering: Sifting out corrupt or missing diagnostic classifications.
6. Relational Integration & Reshaping: Executing a clean inner join to build a unified `master_tibble` and pivoting to a long format optimized for `ggplot2` facet mapping.
7. Analytical Visualization: Creating a publication-ready boxplot overlaid with jittered patient data points to expose distribution structures.

---

## R Script & Data Wrangling Code

Below is the complete, self-contained R workflow executed within your script:

```r
# ==============================================================================
# THE INTEGRITY & WRANGLING PUZZLE
# ==============================================================================

# 1. Environment Setup & Dependencies
# install.packages("tidyverse")
# install.packages("dplyr")
library(tidyverse)
library(dplyr)

# Set Working Directory
setwd("/Users/maliha/Documents/Assignment 1")

# 2. Data Ingestion & Initial Inspection
clinical_data <- read_csv("raw_clinical_metadata.csv", trim_ws = TRUE)
expression_data <- read_csv("raw_expression_matrix.csv", trim_ws = TRUE)

# Strip any residual whitespace from column headers to prevent parsing issues
names(clinical_data) <- trimws(names(clinical_data))
names(expression_data) <- trimws(names(expression_data))

# 3. Fix ID Mismatch
# Standardizing string formatting to reconcile sample reference keys between datasets
expression_data$Sample_Ref <- gsub("_", "-", expression_data$Sample_Ref)
clinical_data$Patient_ID <- gsub("_", "-", clinical_data$Patient_ID)

# 4. Resolve Data Type Corruption
# Standardizing the 'Age' variable by converting qualitative text entries to numeric integers
clinical_data$Age <- as.character(clinical_data$Age)
clinical_data$Age[clinical_data$Age == "fifty-two"] <- 52
clinical_data$Age[clinical_data$Age == "sixty-seven"] <- 67
clinical_data$Age <- as.numeric(clinical_data$Age)

# 5. Pathology Sifting
# Filtering out records missing vital diagnostic definitions
clinical_data <- clinical_data %>%
  filter(!is.na(Condition)) %>%
  filter(trimws(Condition) != "")

# 6. Relational Integration (Inner Join)
clean_expression <- expression_data
clean_expression$Patient_ID <- clean_expression$Sample_Ref

master_tibble <- inner_join(clean_expression, clinical_data, by = "Patient_ID")

# Print the clean integrated master dataset
print(master_tibble)

# 7. Reshaping for Visualization (Tidy Data Principles)
long_data <- master_tibble %>%
  pivot_longer(
    cols = c(Gene_A, Gene_B, Gene_C),
    names_to = "Gene",
    values_to = "Expression"
  )

# 8. Generation of Publication-Ready Visualization
ggplot(long_data, aes(x = Condition, y = Expression, fill = Condition)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(alpha = 0.6, width = 0.1, size = 2) +
  facet_wrap(~ Gene, scales = "free_y") +
  scale_fill_manual(values = c(
    "Normal" = "#4DBBD5",
    "Tumor"  = "#E64B35"
  )) +
  labs(
    title = "Comparative Expression of Biomarkers",
    x = "Condition",
    y = "Expression Level"
  ) +
  theme_bw()
Output VisualizationThe generated pipeline plots a multi-paneled comparative analysis across three targeted gene profiles:(Note: You can update this image link path once you save your plot and commit it to GitHub)

####Analytical Interpretation###

###Section 1: Biomarker Identification: The target biomarker that exhibits a highly anomalous, split sub-distribution within the Normal control patient cohort is Gene_C.While Gene_A and Gene_B show relatively uniform, continuous distributions in their control states, Gene_C’s Normal cohort presents a stark bimodal dispersion pattern characterized by two completely isolated, non-overlapping sub-clusters of patient data points.


###Section 2: The Biological Paradox: When evaluating the individual patient data points mapped via geom_jitter() against Gene_C's overall boxplot summary, an evident  statistical paradox emerges:The Boxplot Summary Illusion: The boxplot graphic implies a single, continuous distribution with heavy skewness, a wide variance stretching between expression levels 2.0 and 9.0, and a median marker sitting around 5.5.The Jittered Reality: Individual data points demonstrate that not a single healthy patient actually expresses Gene_C anywhere near that calculated 5.5 median. Instead, the healthy cohort is entirely split:The Majority Population: The vast majority of healthy individuals maintain an incredibly tight, low-level baseline expression (grouped tightly between 2.0 and 2.5).The Outlier Population: A small, distinct subset of healthy individuals (~2 patients) exhibits massive over-expression (ranging from 8.0 to 9.0), perfectly mimicking the high expression values observed inside the pathological Tumor cohort.

###Section 3: The Biomedical Engineering Design Flaw: Mathematical FallacyThe standard arithmetic mean ($$\mu = \frac{1}{n}\sum_{i=1}^{n}x_i$$) relies on the fundamental assumption of a unimodal, normally distributed dataset where values cluster around a true central tendency. Under a bimodal variance structure like Gene_C's Normal cohort, the mean functions as a mathematical phantom.The extreme high-expression healthy outliers artificially pull the calculation upwards, establishing an arbitrary mean value around 4.0 to 4.5. This single value completely misrepresents both sub-populations, yielding a threshold that has no basis in the true biological reality of either group.Clinical & Diagnostic ConsequencesIf an inexperienced biomedical engineer utilizes this flat arithmetic mean to establish a diagnostic screening cutoff threshold, it introduces a severe real-world engineering failure:Massive False Positives: Because the threshold is pulled down by the mathematical mean, any healthy patient falling into the high-expression outlier group will cross the diagnostic limit and be incorrectly flagged as a "Tumor" case. (Note: False Negatives are minimal here since the tumor group expresses the gene robustly above this line).Clinical Impact: Healthy individuals will be pushed into high-anxiety clinical pathways, exposed to unwarranted, invasive secondary confirmations (such as tissue biopsies or radioactive diagnostic imaging), and subjected to costly medical treatments for an oncology profile they do not possess. Relying on a flat mean completely blinds a diagnostic tool to natural, non-pathological bimodal variations within healthy cohorts.
