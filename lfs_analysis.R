
# Prelims -----------------------------------------------------------------
library(tidyverse)
library(ggplot2)
library(modelsummary)
library(modelr)
library(estimatr)
library(texreg)
library(gt)
library(gtsummary)
library(here)


# Load Data ---------------------------------------------------------------
# Identify working directory
here()
# Load all 12 files
months_2022 <- sprintf("data/pub%02d22.csv", 1:12)

# Create a data frame that I will combine all the surveys into
dt_2022 <- data.frame()

# Create a function that will load all the data then append them
for (i in months_2022){
  dt <- read_csv(i)
  dt_2022 <- rbind(dt_2022, dt)
}

# Data Cleaning -----------------------------------------------------------
clean_2022 <- dt_2022 %>%
  # Select only the relevant variables for the analysis 
  select(SEX, HRLYEARN, TENURE, IMMIG, AGE_12, EDUC, MARSTAT, EFAMTYPE, AGYOWNK, 
         NAICS_21, NOC_43, PROV, SURVMNTH, LFSSTAT) %>%
  filter(LFSSTAT == 1) %>%  # Keep only FT workers
  mutate(
    hourlyearn = HRLYEARN / 100,  # Convert cents to dollars
    jobtenure = TENURE / 12,  # Convert months to years
    female = as.integer(SEX == 2),  # Female dummy (0 or 1)
    immigrant = as.integer(IMMIG != 3),  # Immigrant dummy (0 or 1)
    ychild = as.integer(AGYOWNK == 1),  # Young child dummy (0 or 1)
    ychild_clean = if_else(is.na(ychild), 0, ychild)  # Clean NA in young child dummy
  ) %>%
  # Select new and cleaned columns
  select(hourlyearn, jobtenure, female, immigrant, ychild_clean, AGE_12, EDUC, 
         MARSTAT, EFAMTYPE, NAICS_21, NOC_43, PROV, SURVMNTH, LFSSTAT)

# Summary Statistics ------------------------------------------------------

# Rename variables for readability
sum_stat <- clean_2022 %>%
  select(
    `Hourly Earnings` = hourlyearn,
    `Job Tenure (yrs)` = jobtenure,
    `Female` = female,
    `Immigrant` = immigrant,
    `Young Child?` = ychild_clean,
    `Age` = AGE_12
  )

# Create the table
datasummary_balance(~1, 
                    sum_stat,
                    title = "Table 1: LFS 2022 Summary"
)

# Full OLS -------------------------------------------------------------
mod_full <- lm(hourlyearn~jobtenure + female + immigrant + 
                 ychild_clean + factor(AGE_12) +
                 factor(EDUC) + factor(MARSTAT) +
                 factor(EFAMTYPE) + factor(NAICS_21) + 
                 factor(NOC_43) + factor(PROV) +
                 factor(SURVMNTH), clean_2022)

# FWL Regression ----------------------------------------------------------
mod_y <- lm(hourlyearn~female + immigrant + 
                ychild_clean + factor(AGE_12) +
                factor(EDUC) + factor(MARSTAT) +
                factor(EFAMTYPE) + factor(NAICS_21) + 
                factor(NOC_43) + factor(PROV) +
                factor(SURVMNTH), clean_2022)

mod_x <- lm(jobtenure~female + immigrant + 
              ychild_clean + factor(AGE_12) +
              factor(EDUC) + factor(MARSTAT) +
              factor(EFAMTYPE) + factor(NAICS_21) + 
              factor(NOC_43) + factor(PROV) +
              factor(SURVMNTH), clean_2022)

clean_2022 <- add_residuals(clean_2022, mod_y, var="residY") 
clean_2022 <- add_residuals(clean_2022, mod_x, var="residX")

# Plot residuals
p <- clean_2022 %>% 
  ggplot(aes(x = residX, y = residY)) +
  geom_point(alpha = 0.8) +
  geom_smooth(method = "lm", color = "blue")
p

# Heterogeneity -----------------------------------------------------------
# Regression with interactions
mod_interact <- lm(hourlyearn~jobtenure + female + immigrant +
                     jobtenure*immigrant + jobtenure*female +
                 ychild_clean + factor(AGE_12) +
                 factor(EDUC) + factor(MARSTAT) +
                 factor(EFAMTYPE) + factor(NAICS_21) + 
                 factor(NOC_43) + factor(PROV) +
                 factor(SURVMNTH), clean_2022)
summary(mod_interact)


# Robustness --------------------------------------------------------------
# Robust standard errors
mod_robust <- lm_robust(hourlyearn~jobtenure + female + immigrant + 
                   ychild_clean + factor(AGE_12) +
                   factor(EDUC) + factor(MARSTAT) +
                   factor(EFAMTYPE) + factor(NAICS_21) + 
                   factor(NOC_43) + factor(PROV) +
                   factor(SURVMNTH), clean_2022)
summary(mod_robust)

# Cluster Standard errors
# First I take a sample of the data as I dont have the computational power to cluster the full dataset
smpl_dt <- clean_2022 %>% 
  sample_frac(0.02)

mod_cluster <- lm_robust(hourlyearn~jobtenure + female + immigrant + 
                           ychild_clean + factor(AGE_12) +
                           factor(EDUC) + factor(MARSTAT) +
                           factor(EFAMTYPE) + factor(NAICS_21) + 
                           factor(NOC_43) + factor(PROV) +
                           factor(SURVMNTH), smpl_dt, clusters = PROV)

summary(mod_cluster)

                 
  
  
  
  
