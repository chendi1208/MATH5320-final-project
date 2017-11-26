# 1 Project description

Develop a risk calculation system.

You will need to assemble homework assignments pieces into a coherent whole. You will need to choose models and methodologies, document and justify the choices and write and test the code.

# 2 Requirements

The risk calculation system should be able to:

-  Take a portfolio of stock and option positions as input.
-  Both calibrate to historical data and take parameters as input.
-  Compute Monte Carlo, historical, and parametric VaR.
-  Backtest the computed VaRs against history.

The requirements are intentionally vague. In practice you will be faced with extremely vague requirements specifications and you will need to exercise judgment as to the best way to reasonably fulfill the given requirements. The expectation is that the course is giving you the background necessary to make such judgment calls.
It should be relatively easy with your system to take an arbitrary set of stocks and options as input and do the above calculations. One way of doing this is by creating a standardized input file format and writing software to read the input file and perform the requested calculations. This would be the only way to proceed if working in C++. If working in an interpreted langage (like matlab or R) one could alternatively provide the appropriate code so that these calculations can be done by writing small scripts.

# 3 Deliverables

The project should follow sound model risk management practices. As such, it has the following 5 deliverables:

1. Model documentation.
2. Software design documentation.
3. Test plan.
4. Software.
5. Test results.

The details of what constitutes appropriate model documentation, software design documentation and test plans were covered in lecture 5.
