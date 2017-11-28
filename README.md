# 1 Data Transfomation

1. Request user to upload a `csv` including:
   - Stocks and options chosen
   - Invest amount for each position (sum = total position)
   - Date invested (+ date withdrawal)
2. Get shares, prices to form a portfolio

This part are in `initial_data.R`

# 2 Different Methods for VaR Calculation

1. Fuctions in seperate code module:
   - `winEstGBM.R` - Estimates GBM parameters from history using windowed his-
     tory (equal weighting).
   - `expEstGBM.R` - Estimates GBM parameters from history using exponential
     weighting.
   - `gbmVaR.R` – Compute VaR assuming portfolio follows GBM.
   - `gbmES.R` – Compute ES assuming portfolio follows GBM.
   - `bmsampset.R` – Generates sample paths for specified BM.
   - `gbmsampset.R` – Generates paths under GBM.

