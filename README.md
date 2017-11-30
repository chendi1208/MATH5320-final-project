# VaR Calculation System

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
    |        |---- gbm.R
    |        |---- portfolio.R
    |        |---- xxx.R
    |
    |---- report/
    |---- sample_input.csv
    |---- README.md
```

### run Shiny app

1. The user can use the bash file `run_app.sh` to run the Shiny application automatically (Linux and Unix systems only). Change the path and ensure that `rscript` command is valid (see [here][rscript] for instruction)

2. Altenatively, the user can go into the directory and source `run_app.R`

### user input

Date invested and date withdrawal (**investment period**) are required in the app.

A separate csv file containing portfolio information (**stock ticker** and **total dollar amount** invested in) with the following format is also required. The user can upload the file through the app. Tickers that do not have data will be ignored.

| ticker   | amount |
| -------- | ------ |
| ticker_1 | xxx.xx |
| ticker_2 | xxx.xx |
| ticker_3 | xxx.xx |
| …...     | …...   |

[rscript]: https://github.com/andrewheiss/SublimeKnitr/issues/32