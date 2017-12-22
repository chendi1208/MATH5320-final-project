## Risk Calculation System

This project is intended to be the course final project for Columbia University MATH 5320 Financial Risk Management and Regulation.

All copyrights reserved by author: [Chen Di](mailto:chen.di@columbia.edu) and Zhaofeng Shi (CU UNI: cd2904)

### Directory Structure

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

This directory structure only shows directories and files that are necessary to run the code and generate certain outputs.

### Run Shiny app

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

### User input

Required input in the app: a separate csv file containing portfolio information with the following format is also required. The user can upload the file through the app.

- If you'd like your collected data of portfolio (like those in class assignment):
  - Historical data of each position in the portfolio
  - Investment amount for each position

| Date            | ticker_1                 | ticker_2                 | ...  |
| --------------- | ------------------------ | ------------------------ | ---- |
| date_1 (newest) | ticker_1 price on date_1 | ticker_2 price on date_1 | ...  |
| date_2          | ticker_1 price on date_2 | ticker_2 price on date_2 | ...  |

| ticker   | amount |
| -------- | ------ |
| ticker_1 | xxx.xx |
| ticker_2 | xxx.xx |
| ...      | ...    |

- Alternatively, you can just  enter the ticker name and initial amount,  using the database I contructed. Tickers that do not have data will be ignored.

  **But the first thing to do is to run `get_stock_prices.r` to get `stock_prices.sqlite` in local!**

| ticker   | amount |
| -------- | ------ |
| ticker_1 | xxx.xx |
| ticker_2 | xxx.xx |
| ticker_3 | xxx.xx |
| ...      | ...    |

Optional input (change the default value):

- Date invested 
- Date withdrawal (**investment period**) 
- Window length
- Horizon
- Probability for calculating VaR
- Probability for calculating ES
- Measure
- Methods
- npaths

[rscript]: https://github.com/andrewheiss/SublimeKnitr/issues/32
