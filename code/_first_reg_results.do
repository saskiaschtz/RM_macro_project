*******************************************************
* Frontier Culture & Climate Attitudes
* Empirical Analysis
*******************************************************

clear all
ssc install estout, replace

*******************************************************
* Paths
*******************************************************

* Make sure to run _merge_climate_with_frontier_data.do first
global ROOT "Y:\RM_macro_project"
global OUT  "$ROOT\bld"

use "$OUT\data\county_level_repshare_project_data.dta", clear


*******************************************************
* Outcomes list (EDIT THIS!)
*******************************************************

* Relevant survey Questions 
global outcomes citizens citizensOppose localofficials localofficialsOppose priority priorityOppose reducetax reducetaxOppose


*******************************************************
* Control Variables
*******************************************************

global geo ///
    log_area_2010 lat lon temp_mean rain_mean elev_mean ///
    d_coa d_riv d_lak d_port tri_ave ppt_risk ///
    ave_gyi d_mrdspre1890 d_batt

global hist ///
    shslav1860 wsexrat1890 fb_shr1890 fbscotirel_shr1890 ///
    bplfrac_1890 yearswithRRbef1890 shempmanu1890


*******************************************************
* Loop over outcomes
*******************************************************

foreach y of global outcomes {

    di "=================================================="
    di "Running outcome: `y'"
    di "=================================================="

    * Summary + correlations
    *quietly summarize `y' TFE
    quietly correlate `y' TFE
    local corr_y_TFE = r(rho)

    quietly correlate rep_share TFE
    local corr_rep_TFE = r(rho)

    * Histogram of outcome (optional)
    histogram `y', bins(50) color("128 100 162") ///
        title("Distribution of `y'")
    graph export "$OUT\graphs\histo_`y'.png", as(png) replace

    * Scatter: Outcome vs TFE
    twoway ///
        (scatter `y' TFE, msymbol(o) mcolor("128 100 162")) ///
        (lfit `y' TFE), ///
        title("Frontier Experience and `y'") ///
        subtitle("Correlation = `=string(`corr_y_TFE',"%6.3f")'") ///
        xtitle("Total Frontier Experience (years)") ///
        ytitle("`y'") ///
        legend(off)

    graph export "$OUT\graphs\scatter_TFE_`y'.png", as(png) replace
	
	
***************************************************
* Mediator regression 
***************************************************

eststo clear
reg rep_share TFE $geo $hist i.statea, cluster(km_grid_cel_code)
eststo med

esttab med using "$OUT\tables\mediator_TFE_to_rep_share.tex", replace ///
    title("Mediator regression: Frontier Experience and Republican Vote Share (2020)") ///
    keep(TFE) label ///
    cells("b(fmt(3)) se(fmt(3) par) t(fmt(2)) p(fmt(3)) ci(fmt(3))") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    collabels(none) ///
    nomtitles noobs nonumber ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    addnotes( ///
        "Dependent variable: Republican vote share (county, 2020).", ///
        "Includes geographic and historical controls and state fixed effects.", ///
        "Standard errors clustered at 60km grid cell (km_grid_cel_code)." ///
    )



***************************************************
* Regression models for outcome `y'
***************************************************

eststo clear

* Model 1: outcome on TFE + controls + state FE (clustered SEs)
reg `y' TFE $geo $hist i.statea, cluster(km_grid_cel_code)
eststo m1

* Model 3: outcome on TFE + rep_share + controls + state FE (clustered SEs)
reg `y' TFE rep_share $geo $hist i.statea, cluster(km_grid_cel_code)
eststo m3

* Export: two-column table (Outcome vs Outcome+Mediator)
esttab m1 m3 using "$OUT\tables\outcome_`y'.tex", replace ///
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
        "All models include geographic and historical controls and state fixed effects.", ///
        "Standard errors clustered at 60km grid cell (km_grid_cel_code).", ///
        "Note: RepShare is included in the YCOM estimator; interpret Model (2) as diagnostic, not causal mediation." ///
    )
	
}
	
