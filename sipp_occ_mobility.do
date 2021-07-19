*====================================
* This file calculates occupational mobility in SIPP by waves
* Date=07/09/2021
* Author=Andrew Liu
*====================================

global age_upper 30
global age_lower 16

*** 2008 wave
local first=1
while `first'<=15 {
    local second=`first'+1
	use sippl08puw`second', clear
    keep ssuseq ssuid epppnum srefmon rhcalmn rhcalyr spanel wpfinwgt tpearn rmesr rmhrswk tjbocc1 tage esex eeducate tfipsst efkind ejbhrs1 estlemp1 erace
	rename rhcalmn month
	rename rhcalyr year
	gen month_year1=ym(year,month)
	format month_year1 %tm
	rename wpfinwgt weight1
	rename tage age1
	rename eeducate educ1
	rename tjbocc1 occ1
	rename tfipsst state1
	
	rename srefmon refmon
	rename esex sex
	rename erace race

	gen str1 lfs1 = "E" if rmesr >=1 & rmesr <= 5
	replace lfs1 = "U" if rmesr >=6 & rmesr <= 7
	replace lfs1 = "I" if rmesr == 8
	replace lfs1 = "M" if rmesr == -1
	
	bysort ssuid epppnum refmon: gen dup = cond(_N==1,0,_n)
	    *** Flag any duplicate records so none of them can be matched.
	sort ssuid epppnum refmon dup
	save `second', replace
	
    use sippl08puw`first', clear
	keep ssuseq ssuid epppnum srefmon rhcalmn rhcalyr spanel wpfinwgt tpearn rmesr rmhrswk tjbocc1 tage esex eeducate tfipsst efkind ejbhrs1 estlemp1 erace
	rename rhcalmn month
	rename rhcalyr year
	gen month_year0=ym(year,month)
	format month_year0 %tm
	rename wpfinwgt weight0
	rename tage age0
	rename eeducate educ0
	rename tjbocc1 occ0
	rename tfipsst state0
	
	rename srefmon refmon
	rename esex sex
	rename erace race
	
	gen str1 lfs0 = "E" if rmesr >=1 & rmesr <= 5
	replace lfs0 = "U" if rmesr >=6 & rmesr <= 7
	replace lfs0 = "I" if rmesr == 8
	replace lfs0 = "M" if rmesr == -1
	
	bysort ssuid epppnum refmon: gen dup = cond(_N==1,0,_n)
	    *** Flag any duplicate records so none of them can be matched.
	sort ssuid epppnum refmon dup
	merge 1:1 ssuid epppnum refmon dup using `second'

	keep if _merge==3
	drop _merge
	save merge08_`second', replace
	
	local first=`first'+1
	erase `second'.dta
}


*===================
* Now has the merged waves, combine them to obtain the 4-month average occupational mobility 
*===================

forvalues i=2/16{
	use merge08_`i', clear
	keep if age1>=$age_lower & age1<=$age_upper
	replace occ0=-1 if occ0==.
	replace occ1=-1 if occ1==.
	gen str2 os="TS" if occ0!=occ1 & refmon==4 & state0==state1 & occ0!=-1 & occ1!=-1 & lfs0 == "E" & lfs1 =="E"
	replace os="ST" if if occ0==occ1 & refmon==4 & state0==state1 & occ0!=-1 & occ1!=-1 & lfs0 == "E" & lfs1 =="E" & os==""
	replace os="NA" if os==""
	gen weight=(weight1+weight0)/2
	collapse (sum) weight, by(state1 month_year1 os)
	if `i' >= 3{
	    append using occ_mobility_08
	}
	save occ_mobility_08, replace
}
collapse (sum) weight, by(state1 month_year1 os)
reshape wide weight, i(state1 month_year1) j(os) string
gen osTS=weightTS/(weightST+weightTS)
rename state1 state
rename month_year1 month_year
save occ_mobility_08, replace

replace osTS=0 if osTS==.
gen count=1 if osTS>0
replace count=0 if count==.
keep if month_year>=m(2008m8) & month_year<=m(2013m9)
mean(osTS)
mean(count)
