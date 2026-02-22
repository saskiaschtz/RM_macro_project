*******************************************************
* Frontier Culture & Climate Attitudes
* Baseline vs "Mediation" vs Moderation (3-column tables)
*******************************************************

clear all
set more off
ssc install estout, replace

*******************************************************
* Paths
*******************************************************
global ROOT "Y:\RM_macro_project"
global OUT  "$ROOT\bld"
cap mkdir "$OUT\tables"
cap mkdir "$OUT\tables\threecol"

use "$OUT\data\county_level_repShare_Density_project_data.dta", clear

*******************************************************
* Outcomes
*******************************************************
global outcomes citizens citizensOppose localofficials localofficialsOppose priority priorityOppose reducetax reducetaxOppose

*******************************************************
* Controls 
*******************************************************
global geo ///
    log_area_2010 lat lon temp_mean rain_mean elev_mean ///
    d_coa d_riv d_lak d_port tri_ave ppt_risk ///
    ave_gyi d_mrdspre1890 d_batt log_PopDensity2020

global hist ///
    shslav1860 wsexrat1890 fb_shr1890 fbscotirel_shr1890 ///
    bplfrac_1890 yearswithRRbef1890 shempmanu1890

*******************************************************
* Mean-centering (uniform across all models)
*******************************************************
capture drop TFE_c rep_share_c
qui sum TFE, meanonly
gen double TFE_c = TFE - r(mean)

qui sum rep_share, meanonly
gen double rep_share_c = rep_share - r(mean)

label var TFE_c "TFE (centered)"
label var rep_share_c "RepShare (centered)"

*******************************************************
* Log Population Density
*******************************************************
gen double log_PopDensity2020 = log(PopDensity2020 + 1)
label var log_PopDensity2020 "Log Population Density (2020)"

*******************************************************
* Optional: mediator regression once 
*******************************************************
eststo clear
reg rep_share_c TFE_c $geo $hist i.statea, cluster(km_grid_cel_code)
eststo medX

esttab medX using "$OUT\tables\threecol\mediator_TFE_to_repShare_centered.tex", replace ///
    title("Mediator regression (centered): TFE -> RepShare") ///
    booktabs label ///
    cells("b(star fmt(3)) se(par fmt(3))") ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    keep(TFE_c) ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    nomtitles nonumber noobs compress ///
    addnotes( ///
      "Controls: geographic + historical; state fixed effects.", ///
      "SEs clustered at 60km grid cell (km_grid_cel_code).", ///
      "Centered: x_c = x - mean(x)." ///
    )

*******************************************************
* Per outcome: 3-column table (Baseline / "Mediation" / Moderation)
*******************************************************
foreach y of global outcomes {

    di "=================================================="
    di "Outcome: `y'  (3-column table)"
    di "=================================================="

    eststo clear

    * (1) Baseline
    reg `y' TFE_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m1

    * (2) "Mediation" style: add mediator (diagnostic, not causal proof)
    reg `y' TFE_c rep_share_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m2

    * (3) Moderation: interaction
    reg `y' c.TFE_c##c.rep_share_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m3

    esttab m1 m2 m3 using "$OUT\tables\threecol\threecol_`y'.tex", replace ///
        title("Frontier Experience and `y' (centered)") ///
        booktabs label ///
        mtitles("Baseline" " + RepShare" "Interaction") ///
        cells("b(star fmt(3)) se(par fmt(3))") ///
        starlevels(* 0.10 ** 0.05 *** 0.01) ///
        keep(TFE_c rep_share_c c.TFE_c#c.rep_share_c) ///
        order(TFE_c rep_share_c c.TFE_c#c.rep_share_c) ///
        varlabels( ///
            TFE_c "TFE (centered)" ///
            rep_share_c "RepShare (centered)" ///
            c.TFE_c#c.rep_share_c "TFE (centered) $\times$ RepShare (centered)" ///
        ) ///
        stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
        nonumber noobs compress ///
        addnotes( ///
          "All models include geographic + historical controls and state fixed effects.", ///
          "SEs clustered at 60km grid cell.", ///
          "Centered: x_c = x - mean(x).", ///
        )
}

* --- LaTeX wrapper file that includes the generated tabular
file open f using "$OUT\tables\threecol\wrap_`y'.tex", write replace
file write f "\begin{table}[htbp]\centering" _n
file write f "\caption{Frontier Experience and `y'}" _n
file write f "\label{tab:threecol_`y'}" _n
file write f "\input{$OUT/tables/threecol/threecol_`y'.tex}" _n
file write f "\end{table}" _n
file close f



cap mkdir "$OUT\graphs"

reg citizensOppose TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Citizens should do less to adress global warming") ///
    subtitle("{&beta}{sub:1} = `beta1'***") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Estimated Percentage") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter citizensOppose TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off) 

graph export "$OUT\graphs\scatter_citizensOppose.png", replace as(png)


reg localofficialsOppose TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Local officials should do less to adress global warming") ///
    subtitle("{&beta}{sub:1} = `beta1'***") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Estimated Percentage") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter localofficialsOppose TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off) 

graph export "$OUT\graphs\scatter_localofficialsOppose.png", replace as(png)



reg priorityOppose TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Global warming should not be a high priority for the next president and Congress") ///
    subtitle("{&beta}{sub:1} = `beta1'***") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Estimated Percentage") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter priorityOppose TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off) 

graph export "$OUT\graphs\scatter_priorityOppose.png", replace as(png)


reg reducetaxOppose TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

local t1 "Opposition to requiring fossil fuel companies to pay a carbon tax"
local t2 "and use the money to reduce other taxes (such as income tax) by an equal amount"

marginsplot, recast(line) noci ///
   title("`t1'" "`t2'") ///
    subtitle("{&beta}{sub:1} = `beta1'***") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Estimated Percentage") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter reducetaxOppose TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off) 

graph export "$OUT\graphs\scatter_reducetaxOppose.png", replace as(png)


