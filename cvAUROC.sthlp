{smcl}
{right:version 1.2.0}
{title:}

{phang}
{cmd:cvAUROC} {hline 2} Cross-validated Area Under the Curve for ROC Analysis after Predictive Modelling for Binary Outcomes 
 

{title:Syntax}

{p 4 4 2}
{cmd: cvAUROC} {depvar} {varlist} [if] [{cmd:,} {hi: kfold seed reps}]
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
in which the number of observations is not very large, [hi:cross-validation} and [hi:bootstrap} strategies are useful. {hi:cvAUROC} implements
k-fold cross-validation for the AUC for a binary outcome after fitting a logistic regression model, averaging the AUCs corresponding to 
each fold and bootstrapping the cross-validated AUC to obtain statistical inference.

{title:Options}

{p 4 4 2}
{bf:Kfold} This option allows the user to set the number of random folds to an integer greater than 1 (default = 10).
{p_end}

{p 4 4 2}
{bf:Seed}  This option allows the user to set the random seed to an integer greater than 1.
{p_end}

{p 4 4 2}
{bf:Reps}  This option allows the user to set the number of bootstrap replications to an integer greater than 1 (default = 1000).
{p_end} 

{title:Example}

. use http://www.stata-press.com/data/r14/cattaneo2.dta
(Excerpt from Cattaneo (2010) Journal of Econometrics 155: 138-154)

. gen lbw = cond(bweight<2500,1,0.)

. cvAUROC lbw mage medu mmarried prenatal fedu mbsmoke mrace order, kfold(10) seed(12) reps(1000)
(4,642 missing values generated)

++++++++++++++++++++++++++++++++++++++++++++++++++++++
1-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           465     0.6892       0.0510        0.58930     0.78910

++++++++++++++++++++++++++++++++++++++++++++++++++++++
2-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           464     0.6859       0.0519        0.58430     0.78760

++++++++++++++++++++++++++++++++++++++++++++++++++++++
3-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           464     0.6379       0.0572        0.52584     0.75003

++++++++++++++++++++++++++++++++++++++++++++++++++++++
4-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           464     0.6044       0.0683        0.47049     0.73836

++++++++++++++++++++++++++++++++++++++++++++++++++++++
5-fold test AUC
                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           464     0.7494       0.0661        0.61992     0.87885

++++++++++++++++++++++++++++++++++++++++++++++++++++++
6-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           465     0.7140       0.0535        0.60917     0.81888

++++++++++++++++++++++++++++++++++++++++++++++++++++++
7-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           464     0.6889       0.0404        0.60969     0.76808

++++++++++++++++++++++++++++++++++++++++++++++++++++++
8-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           464     0.6602       0.0494        0.56348     0.75701

++++++++++++++++++++++++++++++++++++++++++++++++++++++
9-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           464     0.7220       0.0612        0.60204     0.84190

++++++++++++++++++++++++++++++++++++++++++++++++++++++
10-fold test AUC

                      ROC                    -Asymptotic Normal--
           Obs       Area     Std. Err.      [95% Conf. Interval]
     ------------------------------------------------------------
           464     0.6936       0.0551        0.58557     0.80169

++++++++++++++++++++++++++++++++++++++++++++++++++++++

Cross-validated AUC:

(running mean on estimation sample)

Bootstrap replications (1000)
----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
..................................................    50
..................................................   100
..................................................   150
..................................................   200
..................................................   250
..................................................   300
..................................................   350
..................................................   400
..................................................   450
..................................................   500
..................................................   550
..................................................   600
..................................................   650
..................................................   700
..................................................   750
..................................................   800
..................................................   850
..................................................   900
..................................................   950
..................................................  1000

Mean estimation                   Number of obs   =         10
                                  Replications    =      1,000

--------------------------------------------------------------
             |   Observed   Bootstrap         Normal-based
             |       Mean   Std. Err.     [95% Conf. Interval]
-------------+------------------------------------------------
         AUC |    .684565   .0127496      .6595763    .7095537
--------------------------------------------------------------

*******************************************************
//Naive performance based on non-crossvalidated AUC
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
Online:  {helpb CROSSFOLD} 
{p_end}
