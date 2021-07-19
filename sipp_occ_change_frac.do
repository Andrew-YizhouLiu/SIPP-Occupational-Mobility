*======================
* This file calculates the fraction individual records that do not have the same occupational code in all four months
* Date=07/10/2021
* Author=Andrew Liu
*======================

cd "C:\Data\SIPP\Raw data\2008"
forvalues i=1/16 {
cd "C:\Data\SIPP\Raw data\2008"
use sippl08puw`i', clear

sort ssuseq ssuid epppnum

by ssuseq ssuid epppnum: gen count=_n
by ssuseq ssuid epppnum: egen tcount=max(count)
drop if tcount!=4

replace tjbocc1=-1 if tjbocc1==.
by ssuseq ssuid epppnum: egen max_occ=max(tjbocc1)
by ssuseq ssuid epppnum: egen min_occ=min(tjbocc1)
by ssuseq ssuid epppnum: gen change=1 if max_occ!=min_occ
replace change=0 if change==.

collapse change, by(ssuseq ssuid epppnum)
collapse change
gen wave=`i'
cd "C:\Users\andre\Dropbox\Minimum wage and occupational mobility\IER decision\Revision 2"
if `i'>=2 {
    append using occ_change_frac
}
save occ_change_frac, replace
}