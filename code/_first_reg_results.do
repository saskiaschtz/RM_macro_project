clear all
ssc install estout

**** Make sure to run _merge_climate_with_frontier_data.do first to create the merged datatset 


**** Insert path to the cloned git repository 
global ROOT "Y:\Project\Data\"  
global OUT "$ROOT\bld"

use "$OUT\data\county_level_project_data.dta", clear 

* First look
summarize citizens TFE // mean: 57.9247 
correlate citizens TFE // corr: -0.2059
histogram TFE, bins(50) color("128 100 162")
graph export "$OUT\graphs\histo_TFE.png", as(png) replace

twoway ///
    (scatter citizens TFE, msymbol(o) mcolor("128 100 162")) ///
    (lfit citizens TFE), ///
    title("Frontier Experience and Support for Citizen Climate Action") ///
	subtitle("correlation = - 0.2059") ///
    xtitle("Total Frontier Experience (years)") ///
    ytitle("Citizens should do more to address Climate Change (%)") ///
    legend(off)
graph export "$OUT\graphs\scatter_TFE_support_gw.png", as(png) replace


* Geographic Controls:
global geo log_area_2010 lat lon temp_mean rain_mean elev_mean ///
          d_coa d_riv d_lak d_port tri_ave ppt_risk ave_gyi d_mrdspre1890 d_batt

* Historic Controls:
global hist shslav1860 wsexrat1890 fb_shr1890 fbscotirel_shr1890 ///
           bplfrac_1890 yearswithRRbef1890 shempmanu1890
		   
* Model 0: simple regression with robust SE
reg citizens TFE, vce(robust)
eststo m0

* Model 1: with controls + state FE, clustered at 60km grid cell
reg citizens TFE $geo $hist i.statea, cluster(km_grid_cel_code)
eststo m1

esttab m0 m1 using "$OUT\tables\tfe_two_models.tex", replace ///
    keep(TFE) label ///
    cells("b(fmt(3)) se(fmt(3) par) t(fmt(2)) p(fmt(3)) ci(fmt(3))") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    collabels(none) ///
    nomtitles noobs nonumber


		   
		   
		   




		   
		   
 
 
 
