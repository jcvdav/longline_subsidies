# Longline subsidies

Analysis of the impact of Mexico's 2020 fuel subsidy reform on the tuna longline fleet in the Gulf of Mexico.

By Aubriana Rhodes and Juan Carlos Villaseñor-Derbez.

## Repository structure

```
longline_subsidies/
├── data/
│   ├── estimation/                          # Estimation dataset (after merge + outlier removal)
│   │   └── annual_effort_and_catch_by_vessel.rds
│   └── processed/                           # Intermediate processed data (not raw)
│       ├── annual_effort_by_vessel.rds
│       ├── annual_landings_by_vessel.rds
│       ├── annual_subsidies_by_economic_unit.rds
│       └── cpue_regression.tex              # LaTeX regression table
├── plots/                                   # Manuscript figures
│   ├── combined_barchart.png
│   ├── fishing_map.png
│   └── time_series.png
├── scripts/
│   ├── 01_processing/                       # Data processing pipeline (run sequentially)
│   │   ├── 1_sub_GoM_vms.R                 #   VMS effort from BigQuery
│   │   ├── 2_sub_GoM_landings.R            #   Tuna landings from mex_fisheries repo
│   │   ├── 3_sub_GoM_subsidies.R           #   Subsidy data from mexican_subsidies repo
│   │   └── 4_sub_GoM_merge.R               #   Merge, filter, outlier removal, CPUE
│   ├── 02_analysis/
│   │   └── cpue_analysis.R                  #   Fixed-effects regressions
│   ├── 03_figures/
│   │   ├── bar_chart.R                      #   Combined bar chart (effort, catch, CPUE)
│   │   ├── fishing_map.R                    #   Map of VMS fishing positions
│   │   └── time_series.R                    #   Time series (subsidies, effort, catch, CPUE)
│   └── 99_others/
│       └── cpue_outliers.R                  #   Archived outlier investigation
└── longline_cpue.qmd                        # Archived GCFI conference presentation (Oct 2025)
```

## Reproduction

### External dependencies

- **BigQuery**: Scripts `1_sub_GoM_vms.R` and `fishing_map.R` require access to the `mex-fisheries` Google BigQuery project.
- **mexican_subsidies repo**: Script `3_sub_GoM_subsidies.R` loads data from the sibling directory `../mexican_subsidies/`.
- **mex_fisheries repo**: Script `2_sub_GoM_landings.R` downloads landings data from the `jcvdav/mex_fisheries` GitHub repository.

### Running the pipeline

1. Run processing scripts in order: `1_sub_GoM_vms.R` through `4_sub_GoM_merge.R`
2. Run `02_analysis/cpue_analysis.R` for regression results
3. Run figure scripts in `03_figures/` in any order
