clear all
ssc install estout

**** Make sure to run _merge_climate_with_frontier_data.do first to create the merged datatset 

**** Insert path to the cloned git repository 
global ROOT "Y:\RM_macro_project" 
global OUT "$ROOT\bld"

* RepShare Data 
cd "$ROOT\raw_data"
import delimited using countypres_2000-2024.tab, delimiter(tab) clear

keep if year == 2020
keep if mode == "TOTAL"
keep if party == "REPUBLICAN"
generate rep_share = candidatevotes / totalvotes

rename county_fips fips 
keep fips rep_share 

save "$OUT/data/rep_vote_share_USpres_2020.dta", replace

use "$OUT\data\county_level_project_data.dta", clear

merge 1:1 fips using  "$OUT/data/rep_vote_share_USpres_2020.dta"
keep if _merge == 3 // cuts our data down to half only 1,480 left 
drop _merge 

save "$OUT\data\county_level_repShare_project_data.dta", replace