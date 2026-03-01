# Replication Package – README

This ZIP contains **(i)** the raw input data and **(ii)** the Stata code for data preparation and the regression analysis.  
After running the master script, the workflow automatically creates a **`BLD/`** (build/output) folder that stores all generated datasets, graphs, and tables.

## Folder structure (contents of the ZIP)

## `Raw Data/` (input datasets)

This folder includes all external datasets used to construct our results.

- **`YCOM_2024_PublicData.xlsx`**  
  Yale Climate Opinion Maps (YCOM) public data. This file provides our **outcome variables** capturing county-level climate attitudes.

- **`Social Economic Control Data/`** (folder)  
  Socio-economic control data that were collected but **not used** in the final version of our paper.

- **`Rural Atlas Data 24.dta`** and **`Rural Atlas Data 24.xlsx`**  
  Rural Atlas data at the county level. Used to construct **population density** as a **control variable**.

- **`PropTaxVote.dta`**  
  Dataset from the **replication files of Bazzi et. al. (2020)**. We use this file to obtain the **TFI variable**, and **geographic and historical control variables**.

- **`National_Risk_Index_Counties.dta`**  
  County-level National Risk Index dataset. Collected to potentially include a **risk control variable**, but **not included** in the final analysis/paper due to concerns about the way the variable is constructed. The file remains in the package for transparency about who was doing what for the project.

- **`Country_Press_2000_2024.tab`**  
  County-level voting/election data (2000–2024). Used to construct our **political voting variables**.


## `Code/` (Stata do-files)

The code is organized into numbered scripts. **The only file that needs to be run directly is `Master.do`, which calls the other scripts in the correct order.

- **`master.do`**: Please adjust the path to executes the full pipeline (scripts **1–4** but not the NRI robustness check).

- **`1_*.do`**  - **`3_*.do`**: Merging & data cleaning.

- **`4_all_regression.do`**: Main analysis file (regressions). Produces the tables and figures for the main results and the z-standardized outcome robustness outputs in the appendix.

- **`5_NRI_robustness_check.do`**: Robustness check using the **National Risk Index** control variable.  
  **Not part of the final paper results** and **not linked in `Master.do`**, but included for completeness and transparency.


## Output: `BLD/` (created by the workflow)

- **`BLD/data/`**  
  Datasets created during the workflow (e.g., after merges, reshaping, or variable construction).

- **`BLD/graphs/`**  
  Scatterplots in three variants: `normal/` (outcomes in original units), `ycentered/` (mean-centered outcomes) and `ystandardized/` (z-standardized outcomes)

- **`BLD/tables/`**
  Tables for the main paper results (`main_results/`), for the z-standardized outcomes in the appendix (`standardized_results/`) and the NRI robustness check which is **not included in the paper** (`NRI_check/`)



