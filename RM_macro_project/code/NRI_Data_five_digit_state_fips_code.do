

use "Y:\RM_macro_project\raw_data\National_Risk_Index_Counties.dta"

gen str5 statecountyfipscode5 = ///
    string(statefipscode, "%02.0f") + string(countyfipscode, "%03.0f")
	
order statecountyfipscode5, before(statecountyfipscode)

save "Y:\RM_macro_project\bld\data\National_Risk_Index_Counties_with5digitFIPS.dta"

