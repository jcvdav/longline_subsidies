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

## Manuscript TO DO

Here's my proposed wrap-up plan for turning the current draft into a finalized manuscript. Rememmer we are documenting patterns in the data associated with Mexico's 2020 fuel subsidy reform, not claiming the reform *caused* the observed changes. We will want to be careful about how we frame things. Throughout the text, please prefer phrases like "we observe", "is associated with", "after the reform", and "patterns consistent with" rather than "the reform caused", "the effect of", or "treatment".

Our main audience is people interested fisheries sustainability and SDG 14. That means we will have to explain what fixed effects are doing using plain language, we motivate CPUE as an accessible index of catch efficiency / revenues, and we keep the policy implications front and center. I can help with these parts.

### 0. Global polish (do these as you go)

- [x] Fix typos already flagged in the draft: "subsides" → "subsidies", "subsidy form" → "subsidy reform", missing space in "fishing(26%". Updated results numbers in the same paragraph.
- [ ] Resolve the duplicate `\label{fig:map}` — the barchart currently shares a label with the fishing map. Rename to `\label{fig:bars}` and update the `\autoref`.
- [ ] Replace placeholder captions ("Map of VMS fishing coordinates.", "Barchart with means before/after") with self-contained, stand-alone captions. A good fisheries-journal caption tells the reader what they are looking at, what the axes mean, and what the key takeaway is, without requiring them to read the main text.
- [x] The regression table caption previously said "clustered standard errors" but the models use Newey-West. Caption has been corrected to say "Newey-West standard errors (L=1)".
- [ ] Tighten the writing pass-by-pass. Short declarative sentences > long compound sentences. First sentence of every paragraph should be a topic sentence that could stand alone as a bullet point summary of the paragraph.

### 1. Abstract (currently empty — write last)

- [ ] Draft a ~200-word structured abstract after the rest of the paper is stable. Suggested flow, one sentence each: (1) why subsidy reform matters for SDG 14.6 and overfishing; (2) what Mexico did in 2020 and why it is a useful natural setting; (3) what data we combined (VMS + CONAPESCA landings + CausaNatura subsidies, 25 vessels, 2016–2024); (4) what method we used (vessel-level panel, vessel fixed effects, pre/post comparison); (5) the three headline patterns (effort −19%, catch −21%, CPUE unchanged); (6) what this means for policy and what we can and cannot conclude from a descriptive design.

### 2. Introduction (expand from ~2 paragraphs to ~4–5)

Target structure — aim for one paragraph per bullet:

- [ ] **Paragraph 1 — the global problem.** Open with the scale of overfishing (the 35% figure from Sharma 2025 is a good hook) and why it persists despite decades of management attention. End with the sentence: "One commonly identified driver is the widespread use of capacity-enhancing fisheries subsidies."
- [ ] **Paragraph 2 — what subsidies are and why fuel subsidies specifically are of concern.** Cite Sumaila 2019 for the magnitude (the global total, the fuel share), sumaila2006fuel for why fuel subsidies are considered harmful, and add 1–2 references on the mechanism (fuel subsidies lower marginal cost → encourage overcapitalization and effort on marginal stocks).
- [ ] **Paragraph 3 — the policy landscape.** WTO Agreement on Fisheries Subsidies (2022), SDG 14.6, the ongoing negotiations. Explain why empirical evidence on what happens when subsidies are actually removed is scarce.
- [ ] **Paragraph 4 — the Mexican setting.** One paragraph situating Mexico's 2020 reform: it was unanticipated, motivated by COVID-era fiscal pressure (not fisheries policy), and eliminated a well-documented fuel subsidy regime. Cite aranceta2025learning and RevolloFernandez2024. This is where you explicitly say this is **not** a controlled experiment but a useful observational window.
- [ ] **Paragraph 5 — our contribution.** Three sentences max. (a) We combine vessel-level tracking, landings, and subsidy records into a novel panel for the Gulf of Mexico tuna longline fleet. (b) We describe patterns in effort, catch, and CPUE before and after the 2020 reform. (c) We discuss what these descriptive patterns imply for SDG 14.6 implementation, while being explicit about the limits of an observational design.

### 3. Methods (current version is OK but needs three additions)

- [ ] **Add a Data subsection** that clearly separates the three sources in a table or a well-structured paragraph: VMS/SISMEP (effort), CONAPESCA (landings), CausaNatura (subsidies + vessel registry). Include the spatial and temporal coverage, the filtering rules (>50 m depth, >500 m from shore, 2016–2024), and the final sample size (25 vessels, 10 economic units, 215 observations).
- [ ] **Add a summary statistics table (Table 1).** Columns: pre-reform (2016–2019) vs post-reform (2020–2024). Rows: mean & SD of effort (hours), catch (kg), CPUE (kg/hr), number of vessel-years, number of vessels, number of economic units. Write a short R script `scripts/02_analysis/summary_stats.R` that builds this table with `modelsummary::datasummary()` or `gtsummary` and exports `data/processed/summary_stats.tex`. Reference it as Table 1 and demote the current regression table to Table 2.
- [ ] **Rework the Model subsection.** The current equation is correct, but for this audience:
  - Keep the equation.
  - Add one sentence explaining, in plain language, what vessel fixed effects do: "Vessel fixed effects ($\omega_i$) absorb time-invariant differences between vessels (size, crew, home port), so $\beta$ reflects within-vessel differences between the two periods."
  - Be explicit that $\beta$ describes an association, not a causal effect. Suggested wording: "Because we lack an untreated comparison fleet, $\beta$ should be interpreted as a descriptive summary of how within-vessel outcomes differ between the two periods, not as a causal estimate of the reform's impact."
  - Keep **Newey-West (L=1) standard errors as the main specification** — serial autocorrelation within vessel is the dominant inferential concern in a short panel like this, and NW handles it cleanly. Report EU-clustered standard errors as a supplementary robustness check in the appendix (see §6) to address reviewers who will point out that subsidies are assigned at the economic-unit level. Caveat that with only 10 economic units, cluster-robust inference is asymptotically fragile; we report it for completeness, not as the preferred specification.
- [ ] **Add a Robustness subsection** pointing readers to the appendix where we exclude 2020. The code for this is already in `scripts/02_analysis/cpue_analysis.R` (exports `data/processed/cpue_regression_no2020.tex`) — just copy that .tex file into `draft/tabs/` and `\input` it from the appendix.

### 4. Results and Discussion (currently one paragraph — split into ~3 paragraphs in Results and ~3 in Discussion)

**Results** (report, don't interpret):

- [ ] Paragraph 1: effort. Report the mean pre-reform level, the post-reform difference in hours and percent, and the sign/significance. Refer to Figure 2 (time series, panel B).
- [ ] Paragraph 2: catch. Same structure. Reference time series panel C.
- [ ] Paragraph 3: CPUE. Same structure, plus a sentence noting that CPUE remained essentially unchanged (coefficient near zero, not significant) despite declines in both effort and catch, suggesting that catch rates were not degraded by the reduction in activity.

**Discussion** (interpret, caveat, compare):

- [ ] Paragraph 1: what the pattern is consistent with. Less effort, less catch, stable catch rates — consistent with an overall reduction in fishing activity that did not selectively remove the most productive trips. The stability of CPUE suggests effort and catch declined roughly in proportion, and that fuel cost now acts as a stronger filter on when and where to fish. Cite wang2023fisheries for a conceptually related finding from China.
- [ ] Paragraph 2: caveats and alternative explanations. COVID-19 demand/logistics shocks, changes in tuna biomass and distribution in the Gulf over the same window, fuel price movements independent of the subsidy, possible selection if some vessels left the fishery entirely. Mention that the 2020-excluded robustness (Appendix) gives qualitatively similar patterns.
- [ ] Paragraph 3: policy implications for SDG 14.6. Keep this focused — avoid overclaiming. Concrete point: if removing fuel subsidies is associated with lower effort and catch without degrading catch efficiency, the social cost of reform may be smaller than industry often argues. Flag the distributional question (who are the marginal vessels that reduce activity?) as an open one.

### 5. Conclusion

- [ ] Expand from ~3 sentences to a short paragraph (~6 sentences). Restate (a) what we did, (b) what we found descriptively, (c) why it matters for SDG 14.6, (d) what we explicitly cannot say (causality, long-run biological impact), (e) what should come next (a proper comparison fleet, stock assessment, economic welfare analysis).

### 6. Appendix / Supplementary materials

- [ ] Add the 2020-excluded regression table to the appendix. The file is already being produced by `cpue_analysis.R` at `data/processed/cpue_regression_no2020.tex` — copy it into `draft/tabs/` and `\input` it from the appendix with a short caption explaining the COVID-year exclusion.
- [ ] Add the EU-clustered regression table to the appendix. The file is already being produced by `cpue_analysis.R` at `data/processed/cpue_regression_eucluster.tex` — copy it into `draft/tabs/` and `\input` it from the appendix. Caption should note that standard errors are clustered at the economic-unit level (10 clusters), and that this is reported as a robustness check given the treatment is assigned at the EU level, but that cluster-robust inference with so few clusters should be interpreted cautiously.
- [ ] Add a short text section describing the quality-control outlier removal (the `filter(!(year == 2018 & vessel_id == "00074500"))` line in `4_sub_GoM_merge.R`). Only one vessel-year is now dropped — vessel 00074500 in 2018, which had anomalously low effort (22.8 hours) producing a CPUE of 260.7 (IQR upper bound ≈ 20.4), flagged as a data-quality issue after VMS track inspection. The two vessel 00034389 observations previously removed (2016 and 2018) are no longer in the sample because that vessel no longer meets the continuously-subsidized filter after the upstream data fix. Include a version of the regression table **without** the outlier removal so readers can see the patterns are not driven by that choice.
- [ ] Consider adding a vessel-level trajectory figure (spaghetti plot of CPUE over time, one line per vessel) to show heterogeneity underlying the fleet means.

### 7. References — expand the bib to ~25–35 entries

The current `references.bib` has 7 entries. For a fisheries-sustainability audience, aim for ~25–35. Below is a starter list of works to look up, read, and cite where appropriate. For each one, Aubriana should read at least the abstract and intro, decide where (if anywhere) it belongs in our text, and add a proper BibTeX entry.

**Fisheries subsidies — foundational and updated estimates:**

- [ ] Sumaila et al. (2010) "A bottom-up re-estimation of global fisheries subsidies." *Journal of Bioeconomics*. The original bottom-up accounting; pair with Sumaila 2019 in the intro.
- [ ] Schuhbauer et al. (2017) "How subsidies affect the economic viability of small-scale fisheries." *Marine Policy*. Useful for the distributional point in the discussion.
- [ ] Skerritt et al. (2020) "A 20-year retrospective on the provision of fisheries subsidies in the European Union." *ICES JMS*. Shows that reform is possible and what can happen when it occurs.
- [ ] Arthur et al. (2019) "Small-scale fisheries and local food systems: transformations, threats and opportunities." *Fish and Fisheries*. Broader context for who is affected by subsidy reform.

**Evaluations of actual subsidy reforms (crucial — there are few, and we should know all of them):**

- [ ] Wang, Reimer & Wilen (2023) — already cited, but re-read and use in the discussion, not just as a passing citation.
- [ ] Abe & Anderson (2022) "Capacity reduction and fuel subsidy removal in the Japanese distant-water tuna longline fishery." If not this exact paper, any work on Japanese decommissioning schemes. Directly comparable fleet.
- [ ] Sakai (2017) on Japanese fisheries subsidies. Same reason.
- [ ] Cisneros-Montemayor et al. (2016, 2020) on Mexican fisheries subsidies specifically. Essential for the Methods framing and the Mexico-specific discussion.

**WTO and SDG 14.6 policy context:**

- [ ] WTO Agreement on Fisheries Subsidies (2022) — cite the official document.
- [ ] Schuhbauer et al. (2020) "The global fisheries subsidies divide between small- and large-scale fisheries." *Frontiers in Marine Science*. Good for framing which subsidies SDG 14.6 targets.
- [ ] Bellmann, Tipping & Sumaila (2016) "Global trade in fish and fishery products: An overview." *Marine Policy*. Background for the WTO paragraph.

**Mexican fisheries and the Gulf of Mexico tuna longline fleet:**

- [ ] Arreguín-Sánchez & Arcos-Huitrón (2011) "La pesca en México: estado de la explotación y uso de los ecosistemas." *Hidrobiológica*. General Mexican fisheries background.
- [ ] INAPESCA Carta Nacional Pesquera (most recent edition) — official stock status for Gulf of Mexico yellowfin.
- [ ] Ramírez-López & Galván-Tirado (various) on Mexican tuna fisheries. Species composition, fleet dynamics.
- [ ] Any ICCAT stock assessment for Atlantic yellowfin tuna — essential for providing stock-status context when interpreting CPUE trends.

**CPUE as an index of efficiency / abundance (methodological caveats):**

- [ ] Maunder et al. (2006) "Interpreting catch per unit effort data to assess the status of individual stocks and communities." *ICES JMS*. The standard reference for CPUE caveats — critical for our discussion.
- [ ] Harley, Myers & Dunn (2001) "Is catch-per-unit-effort proportional to abundance?" *CJFAS*. Same.

**Natural-experiment / observational designs in fisheries:**

- [ ] Costello, Gaines & Lynham (2008) "Can catch shares prevent fisheries collapse?" *Science*. Example of how a descriptive panel can nonetheless inform policy debate.
- [ ] Grafton et al. (2006) "Incentive-based approaches to sustainable fisheries." *CJFAS*. For the policy-lever framing in the discussion.

**COVID-19 and fisheries (needed for the caveats paragraph):**

- [ ] Bennett et al. (2020) "The COVID-19 pandemic, small-scale fisheries and coastal fishing communities." *Coastal Management*.
- [ ] FAO (2021) report on COVID-19 impacts on fisheries and aquaculture.
- [ ] Love et al. (2021) on US seafood during COVID. Any paper documenting 2020 demand and logistics disruptions for pelagic fisheries.

Aubriana should also do a quick Web of Science / Google Scholar search for recent (2023–2026) papers citing Sumaila 2019 or aranceta2025learning — that will surface the most current subsidy-reform literature without requiring her to know every author in the field.

### 8. Code tasks (for the student to complete alongside the writing)

- [ ] Add `scripts/02_analysis/summary_stats.R` producing `data/processed/summary_stats.tex` (see §3).
- [x] Newey-West remains the main specification. Both robustness tables (2020-excluded and EU-clustered) are **already implemented** in `scripts/02_analysis/cpue_analysis.R` and export to `data/processed/`.
- [ ] Copy the newly produced `cpue_regression.tex`, `cpue_regression_no2020.tex`, `cpue_regression_eucluster.tex`, and `summary_stats.tex` from `data/processed/` into `draft/tabs/` whenever they are regenerated. Consider adding a `make` target or a small copy step at the end of each analysis script.
- [ ] Regenerate `plots/time_series.png` with axis labels that use thousands separators (e.g. `scales::label_comma()`), and add a shaded band rather than a single dashed line for the reform year — this reads better in print.
- [ ] Check that every figure file referenced in `main.tex` actually exists in `draft/figs/` and matches the latest version in `plots/`.

### 9. Before submitting

- [ ] Read the whole manuscript aloud, end to end. Any sentence you stumble over is a sentence that needs rewriting.
- [ ] Check that every number in the prose matches the current regression table (the headline percentages will shift slightly when we switch to clustered SE).
- [ ] Confirm the draft compiles cleanly (no LaTeX warnings about undefined references, duplicate labels, or missing citations).
- [ ] Ask JC for a read-through once sections 1–5 are complete but before touching the abstract.

