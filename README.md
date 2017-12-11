## Risk Calculation System

This project is intended to be the course final project for Columbia University MATH 5320 Financial Risk Management and Regulation.

All copyrights reserved by author: [Chen Di](mailto:chen.di@columbia.edu) and Zhaofeng Shi (CU UNI: cd2904)

### Directory Structure

```
cal_system/
    |
    |---- dashboard/
    |        |---- www/
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
    |---- sample_input.csv
    |---- README.md
```

This directory structure only shows directories and files that are necessary to run the code and generate certain outputs.

### Run Shiny app

1. The user can use the bash file `run_app.sh` to run the Shiny application automatically (Linux and Unix systems only). Change the path and ensure that `rscript` command is valid (see [here][rscript] for instruction)

2. Altenatively, the user can go into the directory and source `run_app.R`

3. R package requirments before running the app:

    `shiny`, `shinydashboard`: for web

    `RSQLite`: for database

    `rowr`, `DT`: for table

    `dplyr`, `zoo`: for analysis

    `ggplot2`, `dygraphs`, `reshape2`: for plot

### User input

Required input in the app:

- Date invested 
- Date withdrawal (**investment period**) 
- Measure
- Methods

Optional input (change the default value):

- Window length
- Horizon
- Probability for calculating VaR
- Probability for calculating ES
- npaths

A separate csv file containing portfolio information (**stock ticker** and **total dollar amount** invested in) with the following format is also required. The user can upload the file through the app. Tickers that do not have data will be ignored.

| ticker   | amount |
| -------- | ------ |
| ticker_1 | xxx.xx |
| ticker_2 | xxx.xx |
| ticker_3 | xxx.xx |
| …...     | …...   |

### Error message

The following message may due to the improper use of the model, and available solutions are also provided:

1. `'names' attribute [1] must be the same length as the vector [0]`

   The effective investment period must be greater than 0 day, so change the **investment period**

2. `object 'variable' not found`

   Check that **method** and **measure** input are not blank

3. `f() values at end points not of opposite sign`

   If "**exponentially** weighted" method is chosen, make sure that window length must be greater than 2 years

4. `'file' must be a character string or connection`

   Check if **file** uploaded is the same format as the sample input


[rscript]: https://github.com/andrewheiss/SublimeKnitr/issues/32