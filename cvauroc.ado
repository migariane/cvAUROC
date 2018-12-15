*! version 1.6.3 Cross-validated Area Under the Curve ROC 15.December.2018
*! cvauroc: Stata module for cross-validated area under the curve (cvauroc)
*! by Miguel Angel Luque-Fernandez, Camille Maringe, Paul Nelson [cre,aut]
*! Sampling weights, robust SE, cluster(var), probit and logit models
*! Bug reports: 
*! miguel-angel.luque at lshtm.ac.uk

/*
Copyright (c) 2018  <Miguel Angel Luque-Fernandez>

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


capture program drop cvauroc
program define cvauroc
         version 10.1
         set more off
         syntax varlist(fv) [if] [pw] [, /*
		 */ Kfold(numlist max=1) Seed(numlist max=1) CLuster(varname) Detail Graph Probit]
         local var `varlist'
         tokenize `var'
         local yvar = "`1'"             /*retain the y variable*/
         marksample touse, zeroweight
		 markout `touse' `cluster', strok
		 if "`weight'"!="" {
			tempvar w
			qui gen double `w' `exp' if `touse'
			local pw "[pw=`w']"
			capture assert `w' >= 0 if `touse'
			if c(rc) error 402
			}
		 if "`cluster'"!="" {
			local clopt "cluster(`cluster')"
			}
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
                drop grp
                exit 198
        }
        cap confirm integer num `kfold'
        if _rc>0 | `kfold'<2 {
                di as error "k-fold must be an integer greater than 1"
                drop fitted
                drop AUC 
                drop grp
                exit 198
        }
}

set seed `seed'
xtile grp = uniform() if `touse', nq(`kfold')

*Step 3: fit the model for each of the k-fold training sets

if "`probit'" == "" {
	local pro "logistic" 
	}
else { 
	local pro "probit" 
	}	
	gen AUC = .
	forvalues i = 1/`kfold' {
	qui: `pro' `var' `pw' if grp!=`i' & `touse', `clopt'

*Step 4: predict the outcome for each of the k-fold testing sets

    qui: predict cv_fit`i' if grp==`i' & `touse', pr
	display "`i'-fold.............................."	
	}
					

*Step 5: calculate the  AUC using the predicted probabilities for each fold
egen _fit = rowtotal(cv_fit*)
replace _fit = round(_fit,.001)
	display ""
	display "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    display "Model: `pro'"
    display "Random seed: `seed'" 
	display ""
roctab `1' _fit`i' if `touse', `detail' `graph'

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


*Step 7: drop variables created by program cvauroc
drop AUC
drop cv* 
drop grp
//drop _fit
end

