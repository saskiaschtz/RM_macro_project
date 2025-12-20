clear all
ssc install estout

**** Make sure to run _merge_climate_with_frontier_data.do first to create the merged datatset 

**** Insert path to the cloned git repository 
global ROOT "Y:\RM_macro_project" 
global OUT "$ROOT\bld"

cd "$ROOT\raw_data"
import delimited using countypres_2000-2024.tab, delimiter(tab) clear

rename county_fips fips
replace fips = substr(fips, -5, 5) if length(fips) == 10
replace fips = substr("00000", 1, 5 - length(fips)) + fips if length(fips) < 5
drop if length(fips) != 5

keep if year == 2020

drop if inlist(mode, "FAILSAFE", "FAILSAFE PROVISIONAL", "PROV", "PROVISIONAL")

** dealing with mode == "TOTAL" missing for some states
bys fips: egen has_total = max(mode=="TOTAL")

gen total_tmp = totalvotes if mode=="TOTAL"
bys fips: egen total_votes_totalmode = max(total_tmp)

bys fips: egen total_votes_nomode = total(candidatevotes)

gen total_votes_cty = total_votes_totalmode
replace total_votes_cty = total_votes_nomode if has_total == 0

gen rep_tmp_total = candidatevotes if party=="REPUBLICAN" & mode=="TOTAL"
replace rep_tmp_total = 0 if missing(rep_tmp_total)
bys fips: egen rep_votes_totalmode = total(rep_tmp_total)

gen rep_tmp_all = candidatevotes if party=="REPUBLICAN"
replace rep_tmp_all = 0 if missing(rep_tmp_all)
bys fips: egen rep_votes_allmodes = total(rep_tmp_all)

gen rep_votes_cty = rep_votes_totalmode
replace rep_votes_cty = rep_votes_allmodes if has_total == 0


gen rep_share = rep_votes_cty / total_votes_cty
label var rep_share "Republican vote share, county total (2020)"

* Keep one observation per county
keep fips state county_name rep_share total_votes_cty rep_votes_cty has_total
bys fips: keep if _n == 1


**** check for total votes
preserve
import delimited using countypres_2000-2024.tab, delimiter(tab) clear
rename county_fips fips
replace fips = substr(fips, -5, 5) if length(fips) == 10
replace fips = substr("00000", 1, 5 - length(fips)) + fips if length(fips) < 5
drop if length(fips) != 5
keep if year==2020 & mode=="TOTAL"
bys fips: egen sumcand = total(candidatevotes)
bys fips: keep if _n==1
gen diff = sumcand - totalvotes
summ diff
restore



save "$OUT/data/rep_vote_share_USpres_2020.dta", replace

use "$OUT\data\county_level_project_data.dta", clear

merge 1:1 fips using  "$OUT/data/rep_vote_share_USpres_2020.dta"
keep if _merge == 3
drop _merge 
drop state county_name has_total 

save "$OUT/data/county_level_repshare_project_data.dta", replace
 



