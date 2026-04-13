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
│   │   ├── cpue_analysis.R                  #   Fixed-effects regressions
│   │   └── summary_stats.R                  #   Summary statistics table
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

## Manuscript TO DO

Here's my proposed wrap-up plan for turning the current draft into a finalized manuscript. Rememmer we are documenting patterns in the data associated with Mexico's 2020 fuel subsidy reform, not claiming the reform *caused* the observed changes. We will want to be careful about how we frame things. Throughout the text, please prefer phrases like "we observe", "is associated with", "after the reform", and "patterns consistent with" rather than "the reform caused", "the effect of", or "treatment".

Our main audience is people interested fisheries sustainability and SDG 14. That means we will have to explain what fixed effects are doing using plain language, we motivate CPUE as an accessible index of catch efficiency / revenues, and we keep the policy implications front and center. I can help with these parts.

### 0. Global polish (do these as you go)

- [ ] Replace placeholder captions ("Map of VMS fishing coordinates.", "Barchart with means before/after") with self-contained, stand-alone captions. A good fisheries-journal caption tells the reader what they are looking at, what the axes mean, and what the key takeaway is, without requiring them to read the main text.
- [ ] Tighten the writing pass-by-pass. Use short, declarative sentences. The first sentence of every paragraph should be a topic sentence that could stand alone as a bullet point summary of the paragraph.

### 1. Abstract (currently empty — write last)

- [ ] Draft a ~200-word structured abstract after the rest of the paper is stable. Suggested flow, one sentence each: (1) why subsidy reform matters for SDG 14.6 and overfishing; (2) what Mexico did in 2020 and why it is a useful natural experiment setting; (3) what data we combined (VMS + CONAPESCA landings + CausaNatura subsidies, 23 vessels, 2016–2024); (4) what method we used (pre/post comparison at the vessel-level); (5) the three headline patterns (effort −20%, catch −15%, CPUE unchanged); (6) what this means for policy and what we can and cannot conclude from a descriptive design. You can largely reuse wha tyou had from GCFI.

### 2. Introduction (expand from ~2 paragraphs to ~4–5)

The goal here is foryou to convert each bullet point into an entire paragraph. Depending on your stile, some of these maybe merged into one single paragraph. We don't have a goal length in mind. It should be as long as it needs to be, and not a word more.

- [ ] **Paragraph 1 — the global problem.** Start with the scale of overfishing (the 35% figure from Sharma 2025 is a good hook) and why it persists despite decades of management attention. End with the sentence: "One commonly identified driver is the widespread use of capacity-enhancing fisheries subsidies."
- [ ] **Paragraph 2 — what subsidies are and why fuel subsidies specifically are of concern.** Cite Sumaila 2019 for the magnitude (the global total, the fuel share), sumaila2006fuel for why fuel subsidies are considered harmful, and add 1–2 references on the mechanism (fuel subsidies lower marginal cost of fishing, which encourage overcapitalization and effort).
- [ ] **Paragraph 3 — the policy landscape.** WTO Agreement on Fisheries Subsidies (2022), SDG 14.6, the recently finalized negotiations. Explain that empirical evidence on what happens when subsidies are actually removed is scarce because the data reuqired to analyze this is hard to come by.
- [ ] **Paragraph 4 — the Mexican setting.** One paragraph situating Mexico's 2020 reform: it was unanticipated, motivated by COVID-era fiscal pressure (not fisheries policy), and eliminated a well-documented fuel subsidy regime. Cite aranceta2025learning and RevolloFernandez2024 as examples. This is where you explicitly say this is **not** a controlled experiment but a useful observational study.
- [ ] **Paragraph 5 — our contribution.** Three sentences max. Like in the GCFI presentation, this is where we tell everyone what we do: (a) We combine vessel-level tracking, landings, and subsidy records into a novel panel for the Gulf of Mexico tuna longline fleet. (b) We describe patterns in effort, catch, and CPUE before and after the 2020 reform. (c) We discuss what these descriptive patterns imply for SDG 14.6 implementation, while being explicit about the limits of an observational design.

### 3. Methods (current version is OK but needs three additions)

A lot of this is already there. It just needs to be expanded or clarified.

- [ ] Add a Data subsection that clearly separates the three data sources in a well-structured paragraph: VMS/SISMEP (effort), CONAPESCA (landings), CausaNatura (subsidies + vessel registry). Include the spatial and temporal coverage of our data, the filtering rules (>50 m depth, >500 m from shore, 2016–2024), and the final sample size (23 vessels, 9 economic units, 185 observations).
- [ ] Rework the Model subsection. The current equation is correct, but for this audience:
  - Keep the equation.
  - Add one sentence explaining, in plain language, what vessel fixed effects do. Basically, the same piece of info you mentioned during our GCFI practice talk: "Vessel fixed effects ($\omega_i$) absorb time-invariant differences between vessels (size, crew, home port), so $\beta$ reflects within-vessel differences between the two periods."
  - Be explicit that $\beta$ describes an association, not a causal effect. Something along the lines of: "Because we lack an untreated comparison fleet, $\beta$ should be interpreted as a descriptive summary of how within-vessel outcomes differ between the two periods, not as a causal estimate of the reform's impact."
  - Mention that we are using Newey-West (L=1) standard errors for the main specification to account for serial autocorrelation within vessel, but mention that robustness tests clustering by EU are also included int he supplementes (I already added the tables required for this).
- [ ] Add a super short `Robustness` subsection, where we point readers to the appendix. I've included two robustness test. One where I exclude 2020 (due to COVID) and one where I use SE clustered by year.

### 4. Results and Discussion (currently one paragraph — expand to ~6 paragraphs)

This is a combined section. Lead with the results (what we found), then transition into interpretation, caveats, and implications. Roughly:

- [ ] Paragraph 1: effort. Report the mean pre-reform level, the post-reform difference in hours and percent, and the sign/significance. Refer to Figure 3 (panel A).
- [ ] Paragraph 2: catch. Same structure. Reference barcharts in Fig 3B.
- [ ] Paragraph 3: CPUE. Same structure, plus a sentence noting that CPUE remained essentially unchanged (coefficient near zero, not significant) despite declines in both effort and catch, suggesting that catch rates were not degraded by the reduction in activity.
- [ ] Paragraph 4: Consistencie sin pattersn: We see less effort post, less catch post, but generaly stable catch rates. This is consistent with an overall reduction in fishing activity that did not selectively remove the most productive trips. The stability of CPUE suggests effort and catch declined roughly in proportion, and that fuel cost now acts as a stronger filter on when and where to fish. Cite wang2023fisheries for a conceptually related finding from China's reform case.
- [ ] Paragraph 5: This is where we mention caveats, shortcomings, and alternative explanations. COVID-19 demand/logistics shocks, changes in tuna biomass and distribution in the Gulf over the same window (e.g. what if something environmental changed in the Gulf that just so happens to coincide with patters in longlines?), fuel price movements independent of the subsidy, possible selection if some vessels left the fishery entirely. Once could argue that COVID shocked fisheries (there are plenty of papers to cite about this), but we show that our results are the same when we exclude 2020 from our samplle (suplpementary table).
- [ ] Paragraph 6: policy implications for SDG 14.6. Keep this focused — avoid overclaiming. Concrete point: if removing fuel subsidies is associated with lower effort and catch without degrading catch efficiency, the social cost of reform may be smaller than industry often argues. Flag the distributional question (who are the marginal vessels that reduce activity?) as an open one.

### 5. Conclusion

- [ ] Expand from ~3 sentences to a short paragraph (~6 sentences). Restate (a) what we did, (b) what we found descriptively, (c) why it matters for SDG 14.6, (d) what we explicitly cannot say (causality, long-run biological impact), (e) what should come next (a proper comparison fleet, stock assessment, economic welfare analysis).

