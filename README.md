# Labour-Force-Analysis
The goal of this project was to describe the relationship between job experience and hourly wages among full time workers in Canada. Additionally, I did tests whether the relationship varies by immigration status or gender. 

## Data 
The data is the 2022 public use microdata files from the Canadian Labour Force Survey. It can be found on the StatCan website: (https://www150.statcan.gc.ca\/n1\/pub\/71m0001x\/71m0001x2021001-eng.html). All 12 months were used.

## Sample 
The sample was restricted to full-time workers. Total sample size was just under 700k observations.

- NA's were kept because they get dropped when running regressions anyways
- Variable of interest were gender, immigration status, and hourly wage. 
- Additional variables I control for were: age, education attainment, marital status, indicator of child under 6, industry type, different occupations, province, and survey month. 

## Analysis
To answer my assignment I perform the following: 

- Descriptive statistics
- OLS regression
- Frisch-Waugh-Lovell Theorem 
- OLS regression with interaction terms
- OLS regresssion using robust standard errors
- OLS regression using clustered standard errors

## Acknowledgements
This project was an assignment for ECON 835 at Simon Fraser University taught by Professor Kevin Schnepel. 
