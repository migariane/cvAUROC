{smcl}
{right:version 1.6.2 22.October.2018}
{title:}

{phang}
{cmd:cvauroc} {hline 2} Cross-validated Area Under the Curve for ROC Analysis after Predictive Modelling for Binary Outcomes 
 

{title:Syntax}

{p 4 4 2}
{cmd: cvauroc} {depvar} {varlist} [if] [pw] [Kfold] [Seed] [{cmd:,} {hi:Cluster(varname) Detail Graph}]
{p_end}


{title:Description}

{p 4 4 2}
Receiver operating characteristic (ROC) analysis is used for comparing predictive models, both in model selection and model evaluation.
This method is often applied in clinical medicine and social science to assess the tradeoff between model sensitivity and specificity. 
After fitting a binary logistic regression model with a set of independent variables, the predictive performance of this set of variables 
- as assessed by the area under the curve (AUC) from a ROC curve - must be estimated for a sample (the 'test' sample) that is independent 
of the sample used to predict the dependent variable (the 'training' sample). An important aspect of predictive modeling (regardless of 
model type) is the ability of a model to generalize to new cases. Evaluating the predictive performance (AUC) of a set of independent 
variables using all cases from the original analysis sample tends to result in an overly optimistic estimate of predictive performance. 
K-fold cross-validation can be used to generate a more realistic estimate of predictive performance. To assess this ability in situations 
in which the number of observations is not very large, {hi:cross-validation} and {hi:bootstrap} strategies are useful. {hi:cvauroc} implements
k-fold cross-validation for the AUC for a binary outcome after fitting a logistic regression model and provides the cross-validated fitted 
probabilities for the dependent variable or outcome, contained in a new variable named {hi:_fit}.

{title:Options}

{p 4 4 2}
{bf:pw} This option allows the user to include sampling weights (e.g. inverse-probability of censoring or treatment weights -IPCW or IPTW-).
{hi:Robust} standard errors are calculated automatically when sampling weights are specified.
{p_end}

{p 4 4 2}
{bf:Kfold} This option allows the user to set the number of random folds to an integer greater or equal than 0. 
In case the random seed is not set for the user a random seed is automatically used and displayed in the output for replicability.
{p_end}

{p 4 4 2}
{bf:Seed}  This option allows the user to set the random seed to an integer greater than 1 (default = 123).
{p_end} 

{p 4 4 2}
{bf:Cluster(varname)} This option allows the user to correct the standard error estimation for clustered data.
{p_end}

{p 4 4 4}
{bf:Detail} This option allows the user to output a table displaying the sensitivity, specificity, the percentage of subjects
correctly classified, and two likelihood ratios for each possible cutpoint of the fitted values.
{p_end} 

{p 4 4 2}
{bf:Graph} This option allows the user to graph the ROC curve
{p_end} 

{title:Example}

. use http://www.stata-press.com/data/r14/cattaneo2.dta
(Excerpt from Cattaneo (2010) Journal of Econometrics 155: 138-154)

. gen lbw = cond(bweight<2500,1,0.)

. cvauroc lbw mage medu mmarried prenatal fedu mbsmoke mrace order, kfold(10) seed(12) 

1-fold..............................
2-fold..............................
3-fold..............................
4-fold..............................
5-fold..............................
6-fold..............................
7-fold..............................
8-fold..............................
9-fold..............................
10-fold..............................

Random seed: 12
                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
         4,642     0.6826       0.0174        0.64842     0.71668


*******************************************************
*  Naive performance based on non-crossvalidated AUC  *
*******************************************************

. logistic lbw mage medu mmarried prenatal fedu mbsmoke mrace order

Logistic regression                             Number of obs     =      4,642
                                                LR chi2(8)        =     137.10
                                                Prob > chi2       =     0.0000
Log likelihood = -986.35435                     Pseudo R2         =     0.0650

------------------------------------------------------------------------------
         lbw | Odds Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        mage |   .9959165   .0140441    -0.29   0.772     .9687674    1.023826
        medu |   .9451338   .0283732    -1.88   0.060     .8911276    1.002413
    mmarried |   .6109995   .1014788    -2.97   0.003     .4412328    .8460849
    prenatal |   .5886787    .073186    -4.26   0.000     .4613759    .7511069
        fedu |   1.040936   .0214226     1.95   0.051     .9997838    1.083782
     mbsmoke |   2.145619   .3055361     5.36   0.000     1.623086    2.836376
       mrace |   .3789501    .057913    -6.35   0.000     .2808648    .5112895
       order |    1.05529   .0605811     0.94   0.349     .9429895    1.180964
       _cons |   .3468141   .1498299    -2.45   0.014     .1487176    .8087812
------------------------------------------------------------------------------

. predict fitted, pr

. roctab lbw fitted

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
         4,642     0.6939       0.0171        0.66041     0.72749

{title:Authors}

{p 4 4 2}
Miguel Angel Luque-Fernandez   {break}
LSHTM, NCDE, Cancer Survival Group, London, UK   {break}
Email: miguel-angel.luque@lshtm.ac.uk   {break}

{p 4 4 2}
Camille Maringe   {break}
LSHTM, NCDE, Cancer Survival Group, London, UK   {break}
Email: camille.maringe at lshtm.ac.uk  {break}

{p 4 4 2}
Paul Nelson  {break}
Bureau of Crime Statistics and Research | NSW Department of Justice   {break}
Email: paul.nelson at justice.nsw.gov.au  {break}

{title:Acknowledgements}

{p 4 4 2}
We would like to thank Professor Bernard Rachet (LSHTM) for his comments and support, Dr Timothy Graham (ANU) for his helpful advice and ideas and Haghish E. F. (CMBMI, Freiburg, Germany) for his 
wonderful Github and MarkDoc Stata packages.

{title:References}

{p 4 4 2}
Miguel Angel Luque-Fernandez (2016), Crossvalidation in Epidemiology {browse "http://scholar.harvard.edu/malf/presentations/cross-validation-epidemiology": Presentation}
{p_end}

{p 4 4 2}
StataCorp. 2015. Stata Statistical Software: Release 14. College Station, TX: StataCorp LP.
{p_end}

{p 4 4 2}
Hastie T., Tibshirani R., Friedman J., (2013). The elements of Statistical Learning, Data Mining, Inference and Prediction. Springer Series in Statistics.
{p_end}

{title:Also see}

{psee}
Online:  {helpb crossfold} {helpb roctab}
{p_end}
