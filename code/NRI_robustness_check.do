*******************************************************
* Frontier Culture & Climate Attitudes
* Natural desaster (Robustness)
*******************************************************

clear all
ssc install estout, replace

*******************************************************
* Paths
*******************************************************

* Make sure to run _merge_climate_with_frontier_data.do first
global ROOT "Y:\RM_macro_project"
global OUT  "$ROOT\bld"


*******************************************************
* Merge with NRI data 
*******************************************************

use "$OUT\data\National_Risk_Index_Counties_with5digitFIPS.dta", clear

keep statecountyfipscode5 nationalriskindexscorecomposite nationalriskindexratingcomposite
tab nationalriskindexratingcomposite
rename statecountyfipscode5 fips 

merge 1:1 fips using "$OUT\data\county_level_repshare_project_data.dta"
drop _merge 

cap mkdir "$OUT\tables"
cap mkdir "$OUT\tables\NRI_check"



*******************************************************
* Outcomes list (EDIT THIS IF WE WANT DIFFERENT SURVEY QUESTIONS!)
*******************************************************

* Relevant survey Questions 
global outcomes  citizensOppose  localofficialsOppose  priorityOppose  reducetaxOppose


*******************************************************
* Control Variables: score 
*******************************************************

global geo ///
    log_area_2010 lat lon temp_mean rain_mean elev_mean ///
    d_coa d_riv d_lak d_port tri_ave ppt_risk ///
    ave_gyi d_mrdspre1890 d_batt ///
	nationalriskindexscorecomposite

global hist ///
    shslav1860 wsexrat1890 fb_shr1890 fbscotirel_shr1890 ///
    bplfrac_1890 yearswithRRbef1890 shempmanu1890


***************************************************
* Regression models for outcome `y' score 
***************************************************
foreach y of global outcomes {

eststo clear

* Model 1: outcome on TFE + controls + state FE (clustered SEs)
qui reg `y' TFE $geo $hist i.statea, cluster(km_grid_cel_code)
eststo m1

* Model 3: outcome on TFE + rep_share + controls + state FE (clustered SEs)
qui  reg `y' TFE rep_share $geo $hist i.statea, cluster(km_grid_cel_code)
eststo m3

* Export: two-column table (Outcome vs Outcome+Mediator)
esttab m1 m3 using "$OUT\tables\NRI_check\score_NRI_`y'.tex", replace ///
    title("Frontier Experience and `y' (2020)") ///
    label ///
    cells("b(fmt(3)) se(fmt(3) par) t(fmt(2)) p(fmt(3)) ci(fmt(3))") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    mtitles("(1) Outcome" "(2) Outcome + RepShare") ///
    keep(TFE rep_share) ///
    nonumber noobs compress ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    addnotes( ///
        "Dependent variable: `y'.", ///
        "All models include geographic and historical controls (inlcuding NRI) and state fixed effects.", ///
        "Standard errors clustered at 60km grid cell (km_grid_cel_code).", ///
        "Note: RepShare is included in the YCOM estimator; interpret Model (2) as diagnostic, not causal mediation." ///
    )
	
}
