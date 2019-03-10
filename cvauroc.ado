*! version 1.6.6 Cross-validated Area Under the Curve ROC 14.March.2019
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
program define cvauroc, rclass
         version 10.1
         set more off
         syntax varlist(fv) [if] [pw] [, /*
		 */ Kfold(numlist max=1) Seed(numlist max=1) CLuster(varname) Detail Probit Fit Graph Graphlowess]
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
		 capture drop _fitt*
		 capture drop _sen
		 capture drop _spe
		 capture drop _sens* 
		 capture drop _spec*
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
	return scalar Nfolds = `kfold'
	xtile `fold' = uniform() if `touse', nq(`kfold')
	
	forvalues i = 1/`kfold' {
	qui: count if `fold'==`i' & `touse'
	local nb = r(N)
	qui: `pro' `var' `pw' if `fold'!=`i' & `touse', `clopt'
	//if error  {
	//	exit 198
	 //}
	else{
		qui: `pro' `var' `pw' if `fold'!=`i' & `touse', `clopt'
	}
	return local model = e(cmd)

	*predict the outcome for each of the k-fold testing sets,
    qui: predict _fitt`i' if `fold'==`i' & `touse', pr
	qui: roctab `1' _fitt`i' 
	matrix f  =  (nullmat(f) \ r(area))
	disp as text "`i'-fold (N=" `nb' ").........AUC =" %7.3f as result `r(area)' 
	
	*Step 5: plot the overall cross-validated ROC and the ROC curve for each fold 
	
	qui: `pro' `var' /*`pw'*/ if `fold'!=`i' & `touse', `clopt' 
	qui: lsens if `fold'==`i' & `touse', gensens(_sens`i') genspec(_spec`i') nograph
	qui: replace _spec`i' = 1 - _spec`i'
	local g = "`g'" + " line _sens`i' _spec`i', sort lpattern(dash)||" 
	local gl = "`gl'" + " lowess _sens`i' _spec`i', sort lpattern(dash)||" 
	}
	
	qui: egen _fit = rowtotal(_fitt*)
    drop _fitt*
	
	tempvar auc
    svmat f, name(`auc')
	qui: sum `auc'
	return scalar mean_auc =  `r(mean)'
	return scalar sd_auc =  `r(sd)'
	mat drop f
	
	if "`graph'"=="" {
	
        local textgraph ""
	}
	
	else {
		
		local graph "`graph'"	
	
			tempvar _sen
			tempvar _spe
			
	        qui: `pro' `1' _fit /*`pw'*/ if `touse', `clopt' 
			qui: lsens, gensens(`_sen') genspec(`_spe') nograph
			qui: replace `_spe' = 1 - `_spe'

	        local mauc = string(round(return(mean_auc),0.001)) 
			local sauc = string(round(return(sd_auc),0.001))
			
			qui: twoway line _sens1 _sens1, sort lcolor(black) lwidth(medthick) || ///
			`g' line `_sen' `_spe', sort lcolor(red) lwidth(thick) ||, ///
			saving(cvROC, replace) graphregion(fcolor(white)) ///
			title("cvAUC and Folds ROC curves", color(black)) ///
			caption("Overall cvAUC (solid red curve) and folds ROC curve (dashed curves --)", size(small)) ///
			xlabel(0(0.2)1, angle(horizontal) format(%9.0g) labsize(small)) xtick(0(0.1)1) ytitle("Sensitivity") xtitle("1 - Specificity") ///
			ylabel(0(0.2)1, labsize(small) format(%9.0g)) ytick(0(0.1)1) ///
			text(.05 .5 "cvAUC: 0`mauc'; SD: 0`sauc'") legend(off)
	}	
	
	if "`graphlowess'"=="" {
			local textgraphlowess ""
			}
	else {
			local lowess "`graphlowess'"	
			
			tempvar _sen
			tempvar _spe
			
	        qui: `pro' `1' _fit /*`pw'*/ if `touse', `clopt' 
			qui: lsens, gensens(`_sen') genspec(`_spe') nograph
			qui: replace `_spe' = 1 - `_spe'
			
	        local mauc = string(round(return(mean_auc),0.001)) 
			local sauc = string(round(return(sd_auc),0.001))
			
			qui: twoway `gl' lowess `_sen' `_spe', sort lcolor(red) lwidth(thick) || ///
			line _sens1 _sens1, sort lcolor(black) lwidth(medthick) || ///
			, saving(cvROC, replace) graphregion(fcolor(white)) legend(off) ///
			title("cvAUC and Folds ROC curves", color(black)) ///
			caption("Overall cvAUC (solid red curve) and folds ROC curve (dashed curves --)", size(small)) ///
			xlabel(0(0.2)1, angle(horizontal) format(%9.0g) labsize(small)) xtick(0(0.1)1) ytitle("Sensitivity") xtitle("1 - Specificity") ///
			ylabel(0(0.2)1, labsize(small) format(%9.0g)) ytick(0(0.1)1) ///
			text(.05 .5 "cvAUC: 0`mauc'; SD: 0`sauc'") 
		}
	
	drop _sens* _spec* 
	
	qui: rocreg `1' _fit if `touse'
    matrix a = e(ci_bc)
	return scalar auc_95lb = a[1,1]
	return scalar auc_95ub = a[2,1]
	drop _roc__fit _fpr__fit
	
	disp ""
    disp as text "Model:" as result return(model)
	disp ""
    disp as text "Seed:" as result `seed'
	disp ""
	disp as text "{hline 64}"
    disp "Cross-validated (cv) mean AUC, SD and Bootstrap Corrected 95%CI" 
    disp as text "{hline 64}"
	disp as text "cvMean AUC:                 " "{c |}" %7.4f as result return(mean_auc) 
	disp as text "Booststrap corrected 95%CI: " "{c |} " %5.4f as result return(auc_95lb) "," %7.4f as result return(auc_95ub)
	disp as text "cvSD AUC:                   " "{c |}" %7.4f as result return(sd_auc) 	
	disp as text "{hline 64}"
	
* Optional fit 
 
	if "`fit'"=="" { 
	local textfit ""
	drop _fit
		}
	else  {
    local fit "`fit'"
	}
	
* Optional detail 

	if "`detail'"=="" { 
	local textfit ""
		}
	else  {
	local detail "`detail'"
		
	qui: `pro' `1' _fit `pw' if `touse', `clopt' 
	qui: lsens, genprob(_Pred_Prob) gensens(_sen) genspec(_spe) nograph
	disp ""
	disp as text "{hline 66}" 
	disp as text "Mean cross-validated Sen, Spe and false(+) at " as result "`1'" as text " predicted values"
	disp as text "{hline 66}" 
	local detail "`detail'"
	qui {
	sum `1'
	replace _Pred_Prob = (round(_Pred_Prob,.01))
	replace _sen = _sen*100
	replace _spe = _spe*100
	gen _fp = (100 - _spe)
	}
	disp""
	disp as text "Prevalence of  " as result "`1'" ": " %3.2f `r(mean)'*100 "%"
	disp as text "{hline 24}"
	tabstat _sen _spe _fp, statistics(mean) by(_Pred_Prob) notot format(%3.2f)
	drop _Pred_Prob _fp
	}
	
end




