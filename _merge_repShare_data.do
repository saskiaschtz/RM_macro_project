clear all
ssc install estout

**** Make sure to run _merge_climate_with_frontier_data.do first to create the merged datatset 

**** Insert path to the cloned git repository 
global ROOT "Y:\RM_macro_project" 
global OUT "$ROOT\bld"

* RepShare Data: Looking at missing data cases 
cd "$ROOT\raw_data"
import delimited using countypres_2000-2024.tab, delimiter(tab) clear

rename county_fips fips 
replace fips = substr("00000", 1, 5 - length(fips)) + fips ///
    if length(fips) < 5


keep if year == 2020
keep if mode == "TOTAL"
keep if party == "REPUBLICAN"
generate rep_share = candidatevotes / totalvotes

keep fips rep_share 

save "$OUT/data/rep_vote_share_USpres_2020.dta", replace

use "$OUT\data\county_level_project_data.dta", clear

merge 1:1 fips using  "$OUT/data/rep_vote_share_USpres_2020.dta"
************Note to self: check _merge == 1 and ==2, why is repSHare not available? 
************Data from rep data is not 100% compatable but not a problem. 


