clear all
set more off
ssc install estout, replace

*******************************************************
* Paths
*******************************************************
global ROOT "Y:\RM_macro_project"
global OUT  "$ROOT\bld"
cap mkdir "$OUT\data"

cap mkdir "$OUT\tables"
cap mkdir "$OUT\tables\main_results"
cap mkdir "$OUT\tables\standardized_results"

cap mkdir "$OUT\graphs"
cap mkdir "$OUT\graphs\ycentered"
cap mkdir "$OUT\graphs\yz"


*********************************
*** Data cleaning and preparation
*********************************

cd "$ROOT\code"
run "1_merge_climate_with_frontier_data.do"
cd "$ROOT\code"
run "2_merge_repShare_data.do"
cd "$ROOT\code"
run "3_merge_population_density_data.do"

*********************************
*** Data analysis
*********************************
cd "$ROOT\code"
run "4_all_regressions.do"
