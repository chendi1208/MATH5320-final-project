#Test Plans

The total system is built on R using Rshiny to create a userinterface.



The purpose of this test is to check:

- The logic of the inner functions of the system
- Accuracy of the model
- Efficiency of the model
- Limitations of the model
- The performance of model under special inputs
- The performance of system while dealing heavy computing etc



We separate the testing into 2 parts: 

- Component testing
- Robustness testing



For Component testing:

We are going to go over the several VaR calculation functionto check if they are appropriate for the intended purpose, conceptually soundand mathematically and statistically correct. And we are going to check the accuracyof model by directly checking the backtesting result.



For Robustness testing:

We are going to access the limitation of themodel(assumptions, parameter ranges, etc), behavior of the system when thereare a large range of inputs, identifying the situation when the model isperforming poorly or even unusable.

 