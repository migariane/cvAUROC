*! version 1.2.0 Cross-validated AUC by MA.LUQUE & C.MARINGE & P.NELSON 07.APRIL.2017

program define cvAUROC
	 set more off
     syntax [varlist] [if] [ , KFOLD(numlist max=1) SEED(numlist max = 1) REPS(numlist max = 1)]
	 local var `varlist'
	 tokenize `var'
	 local yvar = "`1'"		/*retain the y variable*/
	 marksample touse
     quietly logistic `var'
     predict fitted, pr	
     		
*Step 1: Set Seed

if "`seed'"=="" {
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

gen AUC = . 

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
xtile group = uniform(), nq(`kfold')

*Step 3: fit the model for each of the k-fold training sets

forvalues i = 1/`kfold' {
qui: logistic `var' if group!=`i'

*Step 4: predict the outcome for each of the k-fold testing sets

qui: predict cv_fit`i' if group==`i', pr

*Step 5: calculate the  AUC for each testing set

display ""
display "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
display "`i'-fold test AUC"
display ""
roctab `1' cv_fit`i'
qui: local AUC = r(area)
qui: replace AUC = r(area) in `i'
}

*Step 6: Set number of bootstrap replications (default = 1000)

if "`reps'"=="" {
			local reps 1000
}
else {
	local repslist : word count `reps'
	if `repslist'!=1 {
		di as error "reps must be a single number"
		drop fitted
		drop cv*
		drop AUC 
		drop group
		exit 198
	}
	cap confirm integer num `reps'
	if _rc>0 | `reps'<50{
		di as error "reps must be an integer greater than 50"
		drop fitted
		drop cv*
		drop AUC 
		drop group
		exit 198
	}
}

*Step 7: calculate cross-validated AUC and compare

qui: mean AUC
display ""
display "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
display "Crossvalidated AUC:"
display ""
bootstrap, rep( `reps' ): mean AUC 

*Step 8: drop variables created by program xvalAUC

drop cv* 
drop fitted 
drop AUC 
drop group
end
