# SIPP-Occupational-Mobility
 
The do-files and dta files calculates the 4-month average occupational mobility in SIPP 2008 panel and study the effect of the minimum wage on occupational mobility.

Step 1:
Download the SIPP 2008 data at
https://www.census.gov/programs-surveys/sipp/data/datasets.2008.html

Step 2: 
Run "sipp_occ_mobility.do". This file generates the merged waves for the SIPP 2008 panel. The output is the average 4-month occupational mobility and the fraction of non-zero observations.

(Optional) Step 3: 
Run "sipp_occ_change_frac.do". The output is the fraction of workers whose occupational code changed in a wave.

Step 4:
Run "regression.do". The file runs the two-way fixed effect regression of the minimum wage on occupational mobility. The output is a log file.