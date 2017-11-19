*! version 1.6.1 Cross-validated Area Under the Curve ROC 19.November.2017
*! cvAUROC: Stata module for cross-validated area under the curve (cvAUROC)
*! by Miguel Angel Luque-Fernandez, Camille Maringe, Paul Nelson [cre,aut]
*! Bug reports: 
*! miguel-angel.luque at lshtm.ac.uk

/*
Copyright (c) 2017  <Miguel Angel Luque-Fernandez>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

program define cvAUROC
         version 10.1
         set more off
         syntax varlist(fv) [if] [pw] [, Kfold(numlist max=1) Seed(numlist max=1) Detail Graph]
         local var `varlist'
         tokenize `var'
         local yvar = "`1'"             /*retain the y variable*/
         marksample touse
         capture drop _fit
		 
*Step 1: Set Seed by default for reproducibility

if "`seed'"=="" {
                        local rnd = round(runiform()*10000)
						local seed `rnd'
}


*Step 2: Divide data into `kfold' mutually exclusive subsets (default: 10)

if "`kfold'"=="" {
                        local kfold 10
}
else {
        local kfoldlist : word count `kfold'
        if `kfoldlist'!=1 {
                di as error "k-fold must be a single number"
                drop fitted
                drop AUC 
                drop group
                exit 198
        }
        cap confirm integer num `kfold'
        if _rc>0 | `kfold'<2{
                di as error "k-fold must be an integer greater than 1"
                drop fitted
                drop AUC 
                drop group
                exit 198
        }
}

set seed `seed'
xtile group = uniform() if `touse', nq(`kfold')

*Step 3: fit the model for each of the k-fold training sets

forvalues i = 1/`kfold' {
qui: logistic `var' if group!=`i' & `touse'

*Step 4: predict the outcome for each of the k-fold testing sets

qui: predict cv_fit`i' if group==`i' & `touse', pr
display "`i'-fold.............................."
}

display "Random seed: `seed'" 

*Step 5: calculate the  AUC using the predicted probabilities for each fold

egen _fit = rowtotal(cv_fit*)
replace _fit = round(_fit,.001)
roctab `1' _fit if `touse', `detail' `graph'

*Step 6: Optinal table displaying the sensitivity, specificity and roc curve

if "`detail'"=="" {
                     local textdetail ""
}
else {
		local detail "`detail'"
		}
		
if "`graph'"=="" {
                     local textgraph ""
}
else {
		local graph "`graph'"
		}


*Step 7: drop variables created by program cvAUROC

drop cv* 
drop group
//drop _fit
end
