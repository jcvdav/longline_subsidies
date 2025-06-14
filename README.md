# Longline subsidies

Analysis by Aubriana Longnecker and Juan Carlos Villaseñor-Derbez

## Repository structure as of June 14, 2025

```
-- data
   |__estimation # these are the estimation / analysis data
      |__annual_effort_and_catch_by_vessel.csv
      |__annual_effort_and_catch_by_vessel.rds
   |__processed # These are the input data, but after some processing. They are not raw.
      |__annual_effort_by_vessel.rds
      |__annual_landings_by_vessel.rds
-- longline_subsidies.Rproj
-- README.md
-- scripts # These are the scripts that get the data and merge them
   |__1_sub_GoM_vms.R
   |__2_sub_GoM_landings.R
   |__3_sub_GoM_merge.R
```

---------
