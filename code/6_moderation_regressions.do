*******************************************************
* Frontier Culture & Climate Attitudes
* Moderation Analysis
*******************************************************

clear all
ssc install estout, replace

*******************************************************
* Paths
*******************************************************
global ROOT "Y:\RM_macro_project"
global OUT  "$ROOT\bld"

cap mkdir "$OUT\tables"
cap mkdir "$OUT\tables\moderation"

*******************************************************
* Load data
*******************************************************
use "$OUT\data\county_level_repshare_project_data.dta", clear

*******************************************************
* Outcomes
*******************************************************
global outcomes citizensOppose localofficialsOppose priorityOppose reducetaxOppose

*******************************************************
* Controls
*******************************************************
global geo ///
    log_area_2010 lat lon temp_mean rain_mean elev_mean ///
    d_coa d_riv d_lak d_port tri_ave ppt_risk ///
    ave_gyi d_mrdspre1890 d_batt

global hist ///
    shslav1860 wsexrat1890 fb_shr1890 fbscotirel_shr1890 ///
    bplfrac_1890 yearswithRRbef1890 shempmanu1890

*******************************************************
* Mean-centering
*******************************************************
capture drop TFE_c rep_share_c
qui sum TFE, meanonly
gen double TFE_c = TFE - r(mean)

qui sum rep_share, meanonly
gen double rep_share_c = rep_share - r(mean)

*******************************************************
* Moderation Regressions
*******************************************************
foreach y of global outcomes {

    di "=================================================="
    di "Centered moderation outcome: `y'"
    di "=================================================="
	
    eststo clear
    qui reg `y' c.TFE_c##c.rep_share_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo mint_c

    test c.TFE_c#c.rep_share_c

    esttab mint_c using "$OUT\tables\moderation\moderation_`y'.tex", replace ///
    title("Moderation (centered): TFE $\times$ RepShare on `y'") ///
    cells("b(fmt(3)) se(fmt(3) par) t(fmt(2)) p(fmt(3))") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    keep(TFE_c rep_share_c c.TFE_c#c.rep_share_c) ///
    varlabels( ///
        TFE_c "TFE (centered)" ///
        rep_share_c "RepShare (centered)" ///
        c.TFE_c#c.rep_share_c "TFE (centered) $\times$ RepShare (centered)" ///
    ) ///
    nonumber noobs compress ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    addnotes( ///
      "All models include geographic + historical controls and state fixed effects.", ///
      "SEs clustered at 60km grid cell.", ///
      "Centered: TFE\_c = TFE - mean(TFE); rep\_share\_c = rep\_share - mean(rep\_share).", ///
      "RepShare is included in YCOM estimation; interpret as diagnostic, not causal." ///
    )

}

