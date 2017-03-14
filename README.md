#cvAUROC: Cross-validated Area Under the Curve (AUC)

Receiver operating characteristic (ROC) analysis is used for comparing predictive models, both in model selection and model evaluation.
This method is often applied in clinical medicine and social science to assess the tradeoff between model sensitivity and specificity. 
After fitting a binary logistic regression model with a set of independent variables, the predictive performance of this set of variables 
- as assessed by the area under the curve (AUC) from a ROC curve - must be estimated for a sample (the 'test' sample) that is independent 
of the sample used to predict the dependent variable (the 'training' sample). An important aspect of predictive modeling (regardless of 
model type) is the ability of a model to generalize to new cases. Evaluating the predictive performance (AUC) of a set of independent 
variables using all cases from the original analysis sample tends to result in an overly optimistic estimate of predictive performance. 
K-fold cross-validation can be used to generate a more realistic estimate of predictive performance. To assess this ability in situations 
in which the number of observations is not very large, **cross-validation** and **bootstrap** strategies are useful. **cvAUROC** implements
k-fold cross-validation for the AUC for a binary outcome after fitting a logistic regression model, averaging the AUCs corresponding to 
each fold and bootstrapping the cross-validated AUC to obtain statistical inference.  

#Installation note    

To install cvAUROC directly from github you need to use a Stata module for installing Stata packages from GitHub, including previous releases of a package. You can install the latest version of the github command by executing the following code in your Stata session:    

    .net install github, from("https://haghish.github.io/github/")

    then, you can install cvAUROC simply using the following code in Stata: 
    
    .github install migariane/cvAUROC
    .which cvAUROC
    .help cvAUROC
     
    To uninstall the package type:    
	
    .ado uninstall cvAUROC  

**note**: the github package only works with the latest versions of Stata >13.1, otherwise you can install manually the package directly downloading the files from the Github repository and placing it in your Stata ADO PERSONAL folder.  

#Updates

In case you have updates or changes that you would like to make, please send me a pull request.  
Alternatively, if you have any questions, please e-mail me.  
E-mail: miguel-angel.luque at lshtm.ac.uk    
Twitter @WATZILEI      

#Citation

You can cite this repository as:

Luque-Fernandez MA, Maringe C., Nelson P. (2017). Cross-validated Area Under the Curve. GitHub repository, https://github.com/migariane/cvAUROC  

#Copyright

This software is distributed under the GPL-2 license.



