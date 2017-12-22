#Tests

###Component Test

We first go over several main functions in the system andsee if there are any potential issues or logistic mistakes, etc.

For the combined_VaR functions, this part of the R codemight cause waste of computation resources.

![img](file://localhost/Users/doris/Library/Group%20Containers/UBF8T346G9.Office/msoclip1/01/clip_image002.png)

Since for the function, we only need tocompute the drift and volatility term on a certain day. But this part of thefunction go over the calibration for the whole dataset while we just need onlyone row of the result. We suppose this might cause an inefficiency of the wholesystem when calculating the VaR of the portfolio of stocks together with putand call options. And we tried rotating the function for a continuous 1000days, and it turns out the system still cannot give the result in 20 minutes. Sothis is a point to be improved in the future. 

The other functions in the system are logistically andconceptually and mathematically appropriate. 

The model works fine when doing the visualization. And theusage is simple. The visualization is fancy. Users can easily choose methodsand get the output and VaR graph. Same graph comparison is also available as follows:

![img](file://localhost/Users/doris/Library/Group%20Containers/UBF8T346G9.Office/msoclip1/01/clip_image004.png)

To check the accuracy of the model, we randomly choseparameters for a GBM VaR and check the backtesting results. 

![img](file://localhost/Users/doris/Library/Group%20Containers/UBF8T346G9.Office/msoclip1/01/clip_image006.png)

We can see that the exceptions in a 1-year window excess 10many times but the expected exceptions in a 1-year window is below 2. But thismight due to the inefficiency of GBM model. Then we tried Monte Carlo VaR.

![img](file://localhost/Users/doris/Library/Group%20Containers/UBF8T346G9.Office/msoclip1/01/clip_image008.png) 

Still the result is not satisfactory. Then it comes to ourmind that the assumption of normality might have been violated. We runn ashapiro-wilk test on the logreturn of the portfolio and find that it fails the testand thus the normality assumption is violated. So our risk models of GBM VaR andMonte Carlo VaR are ineffective when the normality assumption is violated.

Historical VaR always passes the backtest. So ourbacktesting method makes sense to some extent.

![img](file://localhost/Users/doris/Library/Group%20Containers/UBF8T346G9.Office/msoclip1/01/clip_image010.png)

The third column of the list represents the number ofexceptions occurring in a 1-year window. The exceptions are mostly 3, which isclose to 252*0.01.

###Robustness Test

As we already see in the previous step, the models don notperform well when the historical log return do not resemble normaldistribution. 

![img](file://localhost/Users/doris/Library/Group%20Containers/UBF8T346G9.Office/msoclip1/01/clip_image012.png)

 

Also when the number of paths in the Monte Carlo VaRexcesses 10000, it takes a long time for the computer to do the calculation.And when it comes to the complex Portfolio consists of both stocks and options,the number of path can only be bounded with 1000 to ensure the efficiency ofcomputation. The small number of paths could give an inaccurate result and thusthere is a dilemma. 

To sum up, the pros of the system is that it can do a really good visualization and it performs well when the normality is valid. But whenthe normality is violated, it can be fatal. 