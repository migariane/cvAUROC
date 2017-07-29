*! version 1.6.0 Cross-validated AUC 28.JULY.2017
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
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

program define cvAUROC
         version 10.1
         set more off
         syntax [varlist] [if] [pw] [ , Kfold(numlist max=1) Seed(numlist max = 1) Detail Roc]
         local var `varlist'
         tokenize `var'
         local yvar = "`1'"             /*retain the y variable*/
         marksample touse
         capture drop fit
		 
*Step 1: Set Seed

if "`setseed'"=="" {
                        local textsetseed ""
}

else {
        local seedlist : word count `seed'
        if `seedlist'!=1 {
                di as error "seed must be a single number"
                drop fitted
                drop cv*
                drop AUC 
                drop group
                exit 198
        }
        cap confirm integer num `seed'
        if _rc>0 | `seed'<2{
                di as error "seed must be an integer greater than 1"
                drop fitted
                drop cv*
                drop AUC 
                drop group
                exit 198
        }
        else if `seedlist'==1 {
                local textsetseed "set seed `seed'"
        }
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
xtile group = uniform(), nq(`kfold')

*Step 3: fit the model for each of the k-fold training sets

forvalues i = 1/`kfold' {
qui: logistic `var' if group!=`i'

*Step 4: predict the outcome for each of the k-fold testing sets

qui: predict cv_fit`i' if group==`i', pr
display "`i'-fold.............................."
}

*Step 5: calculate the  AUC using the predicted probabilities for each fold

egen fit = rowtotal(cv_fit*)
replace fit = round(fit,.001)
roctab `1' fit, `detail'

*Step 6: Optinal table displaying the sensitivity, specificity and roc curve

if "`detail'"=="" {
                     local textdetail ""
}
else {
		local detail "`detail'"
		}
		
if "`roc'"=="" {
                     local textroc ""
}
else {
		local detail "`roc'"
		}


*Step 7: drop variables created by program xvalAUC

drop cv* 
drop group
//drop fit
end
