* Step 1: Load the Rural Atlas data and rename FIPS to match project data
use "Z:\raw_data\RuralAtlasData24.dta", clear
rename FIPS fips

* Step 2: Sort by the merge key
sort fips

* Step 3: Save the modified Rural Atlas data temporarily
save "RuralAtlasData24_temp.dta", replace

* Step 4: Load your project data and merge
use "Z:\bld\data\county_level_repShare_project_data.dta", clear
sort fips
merge 1:1 fips using "RuralAtlasData24_temp.dta"

* Step 5: Check results
tab _merge