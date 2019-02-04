D*! version 1.6.5 Cross-validated Area Under the Curve ROC 24.January.2019
*! cvauroc: Stata module for cross-validated area under the curve (cvauroc)
*! by Miguel Angel Luque-Fernandez, Daniel Redondo, Camille Maringe [cre,aut]
*! Sampling weights, robust SE, cluster(var), probit and logit models
*! Bug reports: 
*! miguel-angel.luque at lshtm.ac.uk

/*
Copyright (c) 2019  <Miguel Angel Luque-Fernandez>

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
         syntax varlist(fv) [if] [in] [pw] [, Detail /*
		 */ Kfold(numlist max=1) Seed(numlist max=1) CLuster(varname) Detail Graph Probit Fit Sen Spe]
         local var `varlist'
         tokenize `var'
         local yvar = "`1'"  /*retain the y variable*/
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
		 capture drop _sen
		 capture drop _spe
		 set more off
		 
*Step 1: Set Seed for reproducibility (default: 7777)

if "`seed'"=="" {
                local rnd = 7777
				local seed = `rnd'
}

*Step 2: type of model to fit for each of the k-fold training sets

if "`probit'" == "" {
	local pro "logistic" 
	}
else { 
	local pro "probit" 
	}

*Step 3: Divide data into `kfold' mutually exclusive subsets (default: 10)

if "`kfold'"=="" {
        local kfold 10
}
else {
        local kfoldlist : word count `kfold'
        if `kfoldlist'!=1 {
                di as error "k-fold must be a single number"
                exit 198
        }
        cap confirm integer num `kfold'
        if _rc>0 | `kfold'<2 {
                di as error "k-fold must be an integer greater than 1"
                exit 198
        }
}
		
*Step 4: mean and SD for the cross-validated AUC and bootstrap corrected 95% CI

	sort `varlist'
	set seed `seed'
	tempvar fold
	xtile `fold' = uniform() if `touse', nq(`kfold')
	
	forvalues i = 1/`kfold' {
	qui: count if `fold'==`i' & `touse'
	local nb = r(N)
	qui: `pro' `var' `pw' if `fold'!=`i' & `touse', `clopt'
	*predict the outcome for each of the k-fold testing sets,
        qui: predict fitt`i' if `fold'==`i' & `touse', pr
	qui: roctab `1' fitt`i' if `touse'
	gen auc`i' = `r(area)'
	display "`i'-fold (N=" `nb' ").........AUC =" %7.3f `r(area)'
	}

	egen _fit = rowtotal(fitt*)
	drop fitt*
	
	egen mauc = rowmean(auc*)
	qui: summ(mauc)
	local mauc =  `r(mean)'
	
	egen sauc = rowsd(auc*)
	qui: summ(sauc)
	local sauc =  `r(mean)'
	
	drop mauc sauc auc* 
	
	qui: rocreg `1' _fit if `touse'
    matrix a = e(ci_bc)
	drop _roc__fit _fpr__fit
	
	display ""
    display "Model: `pro'"
    display "Seed: `seed'" 
	display ""
	
    display "Cross-validated (cv) mean AUC, SD and Bootstrap Corrected 95%CI:" 
	display "___________________________________________________________________"
	display ""
	display "cvMean AUC:" %7.4f `mauc' ";  95%CI:" "("%5.4f a[1,1] "," %7.4f a[2,1] ")"";  cvSD AUC:" %7.4f `sauc' 
		
*Step 5: plot the overall cross-validated ROC and the ROC curve for each fold 
		
if "`graph'"=="" {
        local textgraph ""
	}
else {
		local graph "`graph'"	
		
	quietly {
	
			forvalues i = 1/`kfold' {
	        qui: `pro' `var' /*`pw'*/ if `fold'!=`i' & `touse', `clopt' 
		    qui: lsens if `fold'==`i' & `touse', gensens(sens`i') genspec(spec`i') nograph
			replace spec`i' = 1 - spec`i'
			local g = "`g'" + " lowess  sens`i' spec`i', sort lpattern(dash)|| "
			}
			
			tempvar _sen
			tempvar _spe
			
	        qui: `pro' `1' _fit /*`pw'*/ if `touse', `clopt' 
			qui: lsens, gensens(`_sen') genspec(`_spe') nograph
			replace `_spe' = 1 - `_spe'
			
	        local mauc = string(round(`mauc',0.001)) 
			local sauc = string(round(`sauc',0.001))
			
			twoway `g' lowess `_sen' `_spe', sort lcolor(red) lwidth(thick) || ///
			line sens1 sens1, sort lcolor(black) lwidth(medthick) || ///
			, title("Overall cvAUC (red) and Folds ROC curves (dash)") saving(cvROC, replace) graphregion(fcolor(white)) legend(off) ///
			xlabel(0(0.2)1, angle(horizontal) format(%9.0g) labsize(small)) xtick(0(0.1)1) ytitle("Sensitivity") xtitle("1 - Specificity") ///
			ylabel(0(0.2)1, labsize(small) format(%9.0g)) ytick(0(0.1)1) ///
			text(.2 .5 "cvAUC: 0`mauc'; SD: 0`sauc'") 
			drop sens* spec*
		}	
}
			
* Optional cross-validated fitted values in var _fit _sen and _spe

if "`sen'"!="" | "`spe'"!=""{
      local sen "`sen'"
      local spe "`spe'"
     
      quietly{
      `pro' `1' _fit /*`pw'*/ if `touse', `clopt'
      lsens, gensens(_sen) genspec(_spe) nograph
      replace _spe = (1 - _spe)
 
      mean _sen
      mat b = r(table)
     
      mean _spe
      mat c = r(table)
      }
     
      display ""
      display "Cross-validated Sensitivity, Specificity, and 95%CI"
      display "___________________________________________________"
      display ""
      }
 
if "`sen'"==""{
			local textsen ""
      }
      else{
            display "cv(sen):" %7.4f b[1,1] ";"  "  95%CI:" "(" %5.4f b[5,1] "," %7.4f b[6,1] ")"
      }
if "`spe'"=="" {
            local textspe ""
      }
      else{
            display "cv(spe):" %7.4f c[1,1] ";"  "  95%CI:" "(" %5.4f c[5,1] "," %7.4f c[6,1] ")"
      }
 
if "`fit'"=="" { 
	local textfit ""
	drop _fit
}
else  {
    local fit "`fit'"
	}
	
end




