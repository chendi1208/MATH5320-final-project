#Software design documentation

### Description of software architecture

```
cal_system/
    |
    |---- dashboard/
    |        |---- ui.R
    |        |---- server.R
    |---- run_app.R
    |---- run_app.sh
    |
    |---- data/
    |        |---- get_stock_prices.R
    |        |---- stock_prices.sqlite
    |
    |---- model/
    |        |---- cal_measure.R
    |        |---- portfolio.R
    |
    |---- report/
    |        |---- README.md
    |        |---- main.pdf
    |---- sample_input_Investment.csv
    |---- sample_input_Position.csv
    |---- sample_input_Ticker&Investment.csv
    |---- implement.csv
    |---- vol.csv
    |---- README.md
    |---- package_requirement.R
```

###Module documentation

- Purpose: develop a risk calculation system for a user-defined portfolio. This system is used to calculate historical VaR and ES, parametric VaR and ES, as well as Monte Carlo VaR and ES.

- Assumptions:

  - Parametric (equally, exponentially): price follow GBM
  - Historical: past risk reflects future risk
  - Monte Carlo: samples follow GBM

- Interfaces: R shiny

  1. The user can use the bash file `run_app.sh` to run the Shiny application automatically (**Linux** and **Unix** systems only). Change the path and ensure that `rscript` command is valid (see [here][rscript] for instruction)

  2. Altenatively, the user can go into the directory and source `run_app.R`

  3. The third way to do this is to go to `dashboard` folder, open one of `ui.R` or `server.R`, click `run App` in R.

  4. R package requirments before running the app:

     `shiny`, `shinydashboard`: for web

     `RSQLite`: for database

     `rowr`, `DT`: for table

     `dplyr`, `zoo`: for analysis

     `ggplot2`, `dygraphs`, `reshape2`: for plot

     `MASS`, `OptionPricing`: for option

###Data structures

```
Risk System/
    |
    |---- ReadMe
    |
    |---- Plot
    |        |---- Risk Measure
    |        |---- Back Testing
    |        |---- Calibration
    |
    |---- Table
    |        |---- Source data
    |        |---- Calibration
    |        |---- Measure output
    |        |---- Exceptions
    |
    |---- Option adjustment
```

###Operation of system at the module level

1. The default page is Plot — Risk Measure. Choose one choice of data upload, upload two file.
2. Go to Parameter tab to change default parameter
3. Click **Submit**
4. All other plots and tables will change automatically as parameter change
5. If using option adjustment, three input files are required