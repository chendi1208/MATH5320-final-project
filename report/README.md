# 1 Executive Summary

1-2 page summary

- Purpose of review
- Model description
- Current/intended model usage
- Validation methodology and scope
- Critical analysis

# 2 Introduction

- Pricer and/or functions reviewed (including version ID), including associated production system (e.g., Calypso)
- Business unit
- Current and intended model usage (e.g., marking and risk management of USD Bermudan swaptions)
- Report purpose
- Relevant history (models & validations) (e.g., update of model, last review was...)
# 3 Product Description
- Description of product
- Payoff function
- Example term sheets or live deals
# 4 Model Description
Reference earlier validation docs as appropriate
- Modeling theory/assumptions
  - Include critical discussion on model choice pros/cons as appropriate  ！
  - Reference literature as appropriate  ！
  - Describe any approximations made and assess their significance  ！
- Mathematical description
  - Model inputs ！
  - Model outputs/reports (including later transformations if known/relevant, e.g., omega to vega transformation) and usage  ！
- Model implementation, numerical methods (refer to quant docs as appropriate)
  - Critically discuss (e.g., impact of number of MC sims, integration errors, etc.)  ！
- Calibration methodology (separate calibration tools require validation) ！
- Model usage (refer to desk docs if available)  ！
- Model exposure (perspective on current and potential future model usage) ？
# 5 Validation Methodology and Scope
- What is the scope of the validation
- Describe how validation was performed
  - Description of benchmark MRM model
  - Tests performed (seek to be comprehensive as possible in terms of model inputs and instruments tested, keeping in mind the intended model usage)
  - Outputs reviewed (e.g., NPV, delta, vega)
  - Other data reviewed such as Totem, P&L explains
# 6 Validation Results
- Presentation and critical discussion of test results and other data reviewed
  - graphs are excellent devices here for displaying anomalous behavior
# 7 Conclusions and Recommendations
- Summary of validation results
- Recommendations
# 8 Bibliography