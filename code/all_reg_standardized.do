*******************************************************
* Frontier Culture & Climate Attitudes
* Produce NEW outputs for:
* (A) outcome mean-centered
* (B) outcome z-standardized
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

* NEW table folders
cap mkdir "$OUT\tables\threecol_ycentered"
cap mkdir "$OUT\tables\threecol_yz"

cap mkdir "$OUT\graphs"

* NEW graph folders
cap mkdir "$OUT\graphs\ycentered"
cap mkdir "$OUT\graphs\yz"

use "$OUT\data\county_level_repshare_project_data.dta", clear

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
    ave_gyi d_mrdspre1890 d_batt

global hist ///
    shslav1860 wsexrat1890 fb_shr1890 fbscotirel_shr1890 ///
    bplfrac_1890 yearswithRRbef1890 shempmanu1890

*******************************************************
* Mean-centering X (uniform across all models)
*******************************************************
capture drop TFE_c rep_share_c
qui sum TFE, meanonly
gen double TFE_c = TFE - r(mean)

qui sum rep_share, meanonly
gen double rep_share_c = rep_share - r(mean)

label var TFE_c "TFE (centered)"
label var rep_share_c "RepShare (centered)"

*******************************************************
* Create transformed outcomes:
*   y_mc = y - mean(y)
*   y_z  = (y - mean(y))/sd(y)
*******************************************************
foreach y of global outcomes {
    cap drop `y'_mc `y'_z

    * mean-centering
    quietly summarize `y', meanonly
    gen double `y'_mc = `y' - r(mean)
    label var `y'_mc "`y' (mean-centered)"

    * z-standardization (robust)
    egen double `y'_z = std(`y')
    label var `y'_z "`y' (z-standardized)"
}

*******************************************************
* mediator regression
*******************************************************
eststo clear
reg rep_share_c TFE_c $geo $hist i.statea, cluster(km_grid_cel_code)
eststo medX

esttab medX using "$OUT\tables\threecol_ycentered\mediator_TFE_to_repShare_centered.tex", replace ///
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

esttab medX using "$OUT\tables\threecol_yz\mediator_TFE_to_repShare_centered.tex", replace ///
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
* (A) TABLES: Outcome mean-centered (y_mc)
*******************************************************
foreach y of global outcomes {

    di "=================================================="
    di "Outcome: `y'  (3-column table) -- y mean-centered"
    di "=================================================="

    eststo clear

    * (1) Baseline
    reg `y'_mc TFE_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m1

    * (2) "Mediation" style
    reg `y'_mc TFE_c rep_share_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m2

    * (3) Moderation
    reg `y'_mc c.TFE_c##c.rep_share_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m3

    esttab m1 m2 m3 using "$OUT\tables\threecol_ycentered\threecol_`y'_mc.tex", replace ///
        title("Frontier Experience and `y' (y mean-centered; x centered)") ///
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
          "Centered: x_c = x - mean(x); y_mc = y - mean(y)." ///
        )

    * LaTeX wrapper
    file open f using "$OUT\tables\threecol_ycentered\wrap_`y'_mc.tex", write replace
    file write f "\begin{table}[htbp]\centering" _n
    file write f "\caption{Frontier Experience and `y' (y mean-centered)}" _n
    file write f "\label{tab:threecol_ycentered_`y'}" _n
    file write f "\input{$OUT/tables/threecol_ycentered/threecol_`y'_mc.tex}" _n
    file write f "\end{table}" _n
    file close f
}

*******************************************************
* (B) TABLES: Outcome z-standardized (y_z)
*******************************************************
foreach y of global outcomes {

    di "=================================================="
    di "Outcome: `y'  (3-column table) -- y z-standardized"
    di "=================================================="

    eststo clear

    * (1) Baseline
    reg `y'_z TFE_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m1

    * (2) "Mediation" style
    reg `y'_z TFE_c rep_share_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m2

    * (3) Moderation
    reg `y'_z c.TFE_c##c.rep_share_c $geo $hist i.statea, cluster(km_grid_cel_code)
    eststo m3

    esttab m1 m2 m3 using "$OUT\tables\threecol_yz\threecol_`y'_z.tex", replace ///
        title("Frontier Experience and `y' (y z-standardized; x centered)") ///
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
          "Centered: x_c = x - mean(x); y_z = (y - mean(y))/sd(y)." ///
        )

    * LaTeX wrapper
    file open f using "$OUT\tables\threecol_yz\wrap_`y'_z.tex", write replace
    file write f "\begin{table}[htbp]\centering" _n
    file write f "\caption{Frontier Experience and `y' (y z-standardized)}" _n
    file write f "\label{tab:threecol_yz_`y'}" _n
    file write f "\input{$OUT/tables/threecol_yz/threecol_`y'_z.tex}" _n
    file write f "\end{table}" _n
    file close f
}

*******************************************************
* GRAPHS: replicate your 4 scatter+margins plots
* (1) citizensOppose, (2) localofficialsOppose, (3) priorityOppose, (4) reducetaxOppose
* Produce BOTH: mean-centered outcome and z-standardized outcome
*******************************************************

* ---------- (A) Graphs with y mean-centered ----------
reg citizensOppose_mc TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Citizens should do less to adress global warming") ///
    subtitle("{&beta}{sub:1} = `beta1'*** (y mean-centered)") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Deviation from mean (p.p.)") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter citizensOppose_mc TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off)

graph export "$OUT\graphs\ycentered\scatter_citizensOppose_mc.png", replace as(png)


reg localofficialsOppose_mc TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Local officials should do less to adress global warming") ///
    subtitle("{&beta}{sub:1} = `beta1'*** (y mean-centered)") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Deviation from mean (p.p.)") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter localofficialsOppose_mc TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off)

graph export "$OUT\graphs\ycentered\scatter_localofficialsOppose_mc.png", replace as(png)


reg priorityOppose_mc TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Global warming should not be a high priority for the next president and Congress") ///
    subtitle("{&beta}{sub:1} = `beta1'*** (y mean-centered)") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Deviation from mean (p.p.)") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter priorityOppose_mc TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off)

graph export "$OUT\graphs\ycentered\scatter_priorityOppose_mc.png", replace as(png)


reg reducetaxOppose_mc TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

local t1 "Opposition to requiring fossil fuel companies to pay a carbon tax"
local t2 "and use the money to reduce other taxes (such as income tax) by an equal amount"

marginsplot, recast(line) noci ///
    title("`t1'" "`t2'") ///
    subtitle("{&beta}{sub:1} = `beta1'*** (y mean-centered)") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Deviation from mean (p.p.)") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter reducetaxOppose_mc TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off)

graph export "$OUT\graphs\ycentered\scatter_reducetaxOppose_mc.png", replace as(png)


* ---------- (B) Graphs with y z-standardized ----------
reg citizensOppose_z TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Citizens should do less to adress global warming") ///
    subtitle("{&beta}{sub:1} = `beta1'*** (y z-standardized)") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Standard deviations (z)") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter citizensOppose_z TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off)

graph export "$OUT\graphs\yz\scatter_citizensOppose_z.png", replace as(png)


reg localofficialsOppose_z TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Local officials should do less to adress global warming") ///
    subtitle("{&beta}{sub:1} = `beta1'*** (y z-standardized)") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Standard deviations (z)") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter localofficialsOppose_z TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off)

graph export "$OUT\graphs\yz\scatter_localofficialsOppose_z.png", replace as(png)


reg priorityOppose_z TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("Global warming should not be a high priority for the next president and Congress") ///
    subtitle("{&beta}{sub:1} = `beta1'*** (y z-standardized)") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Standard deviations (z)") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter priorityOppose_z TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off)

graph export "$OUT\graphs\yz\scatter_priorityOppose_z.png", replace as(png)


reg reducetaxOppose_z TFE $geo $hist i.statea, cluster(km_grid_cel_code)
local beta1 : display %9.3f _b[TFE]
margins, at(TFE=(0(0.25)6)) post

marginsplot, recast(line) noci ///
    title("`t1'" "`t2'") ///
    subtitle("{&beta}{sub:1} = `beta1'*** (y z-standardized)") ///
    xtitle("Total Frontier Experience (decades)") ///
    ytitle("Standard deviations (z)") ///
    xscale(range(0 6)) ///
    xlabel(0(1)6) ///
    plot1opts(lcolor(black) lwidth(medthick)) ///
    addplot(scatter reducetaxOppose_z TFE, ///
        msymbol(O) msize(vsmall) ///
        mcolor("163 0 0") mfcolor("163 0 0")) ///
    legend(off)

graph export "$OUT\graphs\yz\scatter_reducetaxOppose_z.png", replace as(png)