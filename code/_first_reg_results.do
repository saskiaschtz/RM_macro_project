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
* First Look: Summary Statistics & Correlations
*******************************************************

summarize citizens TFE
correlate citizens TFE
correlate rep_share TFE


*******************************************************
* Distributions
*******************************************************

histogram TFE, bins(50) color("128 100 162")
graph export "$OUT\graphs\histo_TFE.png", as(png) replace

histogram rep_share, bins(50) color("128 100 162")
graph export "$OUT\graphs\histo_rep_share.png", as(png) replace


*******************************************************
* Scatter Plots
*******************************************************

twoway ///
    (scatter citizens TFE, msymbol(o) mcolor("128 100 162")) ///
    (lfit citizens TFE), ///
    title("Frontier Experience and Support for Citizen Climate Action") ///
    subtitle("Correlation = -0.2059") ///
    xtitle("Total Frontier Experience (years)") ///
    ytitle("Citizens should do more to address Climate Change (%)") ///
    legend(off)

graph export "$OUT\graphs\scatter_TFE_citizens.png", as(png) replace


twoway ///
    (scatter rep_share TFE, msymbol(o) mcolor("128 100 162")) ///
    (lfit rep_share TFE), ///
    title("Frontier Experience and Republican Vote Share") ///
    subtitle("Correlation = 0.1564") ///
    xtitle("Total Frontier Experience (years)") ///
    ytitle("Republican vote share (county)") ///
    legend(off)

graph export "$OUT\graphs\scatter_TFE_rep_share.png", as(png) replace


*******************************************************
* Control Variables
*******************************************************

* Geographic controls
global geo ///
    log_area_2010 lat lon temp_mean rain_mean elev_mean ///
    d_coa d_riv d_lak d_port tri_ave ppt_risk ///
    ave_gyi d_mrdspre1890 d_batt

* Historical controls
global hist ///
    shslav1860 wsexrat1890 fb_shr1890 fbscotirel_shr1890 ///
    bplfrac_1890 yearswithRRbef1890 shempmanu1890


*******************************************************
* Regression Models
*******************************************************

* Model 0: Simple regression (robust SEs)
reg citizens TFE, vce(robust)
eststo m0

* Model 1: Controls + State FE, clustered SEs
reg citizens TFE $geo $hist i.statea, cluster(km_grid_cel_code)
eststo m1


*******************************************************
* Export: Baseline Comparison Table
*******************************************************

esttab m0 m1 using "$OUT\tables\tfe_two_models.tex", replace ///
    keep(TFE) label ///
    cells("b(fmt(3)) se(fmt(3) par) t(fmt(2)) p(fmt(3)) ci(fmt(3))") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    collabels(none) ///
    nomtitles noobs nonumber


*******************************************************
* Model 2: Mediator Regression
*******************************************************

reg rep_share TFE $geo $hist i.statea, cluster(km_grid_cel_code)
eststo m2


*******************************************************
* Model 3: Outcome with Mediator
*******************************************************

reg citizens TFE rep_share $geo $hist i.statea, cluster(km_grid_cel_code)
eststo m3


*******************************************************
* Export: Mediation Models (1–3)
*******************************************************

esttab m1 m2 m3 using "$OUT\tables\mediation_models_1_3.tex", replace ///
    title("Frontier Experience, Republican Vote Share, and Climate Attitudes (2020)") ///
    label ///
    cells("b(fmt(3)) se(fmt(3) par) t(fmt(2)) p(fmt(3)) ci(fmt(3))") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    mtitles("(1) Outcome" "(2) Mediator" "(3) Outcome + Mediator") ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    keep(TFE rep_share) ///
    nonumber noobs compress ///
    addnotes( ///
        "Model (1) and (3) dependent variable: citizens (%). Model (2) dependent variable: Republican vote share.", ///
        "All models include geographic and historical controls and state fixed effects.", ///
        "Standard errors clustered at 60km grid cell (km_grid_cel_code)." ///
    )
