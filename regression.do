*====================================
* This file merge the occupational mobility with the minimum wage and run the regression
* Date = 7/15/2021
* Author = Andrew Liu
*====================================

use occ_mobility_08, clear

replace osTS=0 if osTS==.
keep if monthly_year>=m(2008m9) & monthly_year<=m(2013m8)

*** Merge with minimum wage
merge 1:1 statefips year month using state_minwage
keep if _merge==3
drop _merge

*** Merge with manufacturing and retail employment share
merge 1:1 state year month using emp_share_94_16.dta
keep if _merge==3
drop _merge

gen manu_share = manu_emp/t_emp
gen re_share = re_emp/t_emp

log using sipp_08.log, replace
reg osTS logrminwage i.statefips i.monthly_year manu_share re_share, cluster(statefips)
log close