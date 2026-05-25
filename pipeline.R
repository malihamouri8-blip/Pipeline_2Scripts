# The Integrity & Wrangling Puzzle


install.packages("tidyverse")
install.packages("dplyr")

library(tidyverse)
library(dplyr)
#import the dataset


setwd("/Users/maliha/Documents/Assignment 1")

read.csv("raw_expression_matrix.csv")
read.csv("raw_clinical_metadata.csv")

# 1. Read the files
clinical_data <- read_csv("raw_clinical_metadata.csv", trim_ws = TRUE)
expression_data <- read_csv("raw_expression_matrix.csv", trim_ws = TRUE)

names(clinical_data) <- trimws(names(clinical_data))
names(expression_data) <- trimws(names(expression_data))

str(expr)
str(clinical_data)

head(expr)
head(clinical_data)

names(expr)
names(clinical_data)

# 2.Fix ID mismatch

expression_data$Sample_Ref <- gsub("_", "-", expression_data$Sample_Ref)
clinical_data$Patient_ID <- gsub("_", "-", clinical_data$Patient_ID)



#3.data type curruption

clinical_data$Age <- as.character(clinical_data$Age)

clinical_data$Age[clinical_data$Age == "fifty-two"] <- 52
clinical_data$Age[clinical_data$Age == "sixty-seven"] <- 67
clinical_data$Age <- as.numeric(clinical_data$Age)


head(clinical_data)

#4.PATHOLOGY SIFTING:

clinical_data <- clinical_data %>%
  filter(!is.na(Condition)) %>%
  filter(trimws(Condition) != "")



#5.Join them together

clean_expression <- expression_data

clean_expression$Patient_ID <- clean_expression$Sample_Ref

master_tibble <- inner_join(clean_expression, clinical_data, by = "Patient_ID")

# 5. Show the final result
print(master_tibble)


library(tidyverse)

long_data <- master_tibble %>%
  pivot_longer(
    cols = c(Gene_A, Gene_B, Gene_C),
    names_to = "Gene",
    values_to = "Expression"
  )

head(long_data)

ggplot(long_data,
       aes(x = Condition,
           y = Expression,
           fill = Condition))+
  
  geom_boxplot(alpha = 0.7,
               outlier.shape = NA) +
  
  geom_jitter(alpha = 0.6,
              width = 0.1,
              size = 2) +
  
  facet_wrap( ~ Gene,
              scales = "free_y") +
  
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





































