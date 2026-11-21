# Green Simulation Designs for Repeated Experiments — code

Code that reproduces the figures of

> Feng, M., & Staum, J. (2015). Green simulation designs for repeated experiments. In
> *Proceedings of the 2015 Winter Simulation Conference* (pp. 403–413). IEEE.
> https://doi.org/10.1109/WSC.2015.7408182

If you use this code, please cite the paper. The journal version of this work is Feng and Staum
(2017), Green simulation: reusing the output of repeated experiments, *ACM TOMACS* 27(4),
https://doi.org/10.1145/3129130 (code: github.com/mbfeng/GreenSim-TOMACS).

## Quick start

```matlab
% MATLAB R2023b or later with the Statistics and Machine Learning Toolbox
% (Parallel Computing Toolbox optional, for reruns). From this folder:
reproduce_paper
```

By default (`RERUN_SIMULATIONS = false`) this draws Figure 1 and Figure 2 (`figures/1dFig1.pdf`,
`1dFig2.pdf`, `msefig.pdf`, the file names of the paper's LaTeX source) from the saved summary of
the run behind the published figure (`results/published_run/`) and checks every plotted value of
Figure 2 against the paper, in a few seconds. Set `RERUN_SIMULATIONS = true` to rerun the
experiments first (see [Run times](#run-times)).

## The experiment

A portfolio of two corporate bonds is evaluated weekly (KMV model, Section 3). At week k the
observed asset values x_k (the *state*) determine the distribution h(y; x_k) of the asset values Y
six months later: lognormal marginals joined by a t-copula (3 degrees of freedom, correlation 0.5).
Each weekly experiment estimates the probability f(x_k) that the discounted portfolio loss l(Y)
exceeds κ = 6, with N = 1,000 new outputs F(Y) = 1{l(Y) > κ}. Three estimators are compared:

| Estimator | Uses | Equation |
|---|---|---|
| SMC, standard Monte Carlo | the N new outputs only | (1) |
| OIS, ordinary importance sampling | all kN outputs so far, likelihood ratios h(y; x_k)/h(y; x_i) | (2) |
| MIS, multiple importance sampling | all kN outputs so far, likelihood ratios h(y; x_k)/h*_k(y), h*_k the mixture of all sampling densities | (4) |

The figure of merit is the mean squared error over 1,000 sample paths of the states, each with 26
weekly experiments, relative to an *accurate estimate* (SMC with 10^6 outputs) of f(x_k).

| Setting | Value |
|---|---|
| Initial asset values x_1, debts D, losses given default | (100, 90), (85, 85), (5, 4) |
| Drift μ, volatility σ, risk-free rate r | (15%, 10%), (30%, 20%), 5% |
| Repeating period Δ, projection period t, threshold κ | 1/52, 0.5, 6 |
| Evaluation period τ of the loss | 4.5 years (as in the runs behind Figure 2) |
| Copula | t, 3 degrees of freedom, correlation 0.5 (asset paths and scenarios) |
| Sample paths × weeks × new outputs per week | 1,000 × 26 × 1,000 |
| Accurate estimate | SMC with 10^6 outputs, for every path and week |

## Paper result → code

| Result | Produced by | Output |
|---|---|---|
| Figure 1 (illustration of two experiments) | `scripts/make_figure1.m` | `figures/1dFig1.pdf`, `figures/1dFig2.pdf` |
| Figure 2 (MSEs of SMC, OIS, MIS over 26 weeks) | `scripts/run_simulation.m` → `scripts/make_figure2.m` | `figures/msefig.pdf`, `figures/msefig.csv` (values and standard errors) |

## Folder structure

```
reproduce_paper.m             entry point: Figures 1-2 and the check against the paper
functions/
  kmv_settings.m              parameters of the example (Section 3.2)
  simulate_states.m           weekly sample paths of the states x_k
  t_copula_uniforms.m         t-copula samples from a given random stream
  sample_scenarios.m          scenarios Y ~ h(y; x) given a state
  scenario_marginals.m        lognormal parameters of the scenarios
  scenario_density.m          h(y; x): copula density x marginal densities
  portfolio_loss.m            discounted portfolio loss l(y)
  green_estimates_one_path.m  SMC, OIS, MIS estimates along one sample path (Eqs. 1, 2, 4)
  accurate_estimate.m         SMC with 10^6 outputs ("accurate estimate")
  summarise_mse.m             MSE per week and its standard error
  read_estimates.m            reads a run's estimates.csv.gz
scripts/
  run_simulation.m            the experiments (parallel, resumable, seeded)
  make_figure1.m, make_figure2.m
results/
  published_run/              summary of the run behind the published Figure 2 (40 weeks)
  rerun_seed2015/, rerun_seed2016/   full reruns with this code (see Verification)
figures/                      reproduced figures (vector PDF)
verify/
  verify_against_paper.m      checks Figure 2 against the published values
  paper_figure2_values.csv    values plotted in the paper (read from its vector figure)
  verification_*.csv          reports
tests/                        run_tests.m: estimators vs. direct formulas, model checks, snapshot
tools/
  extract_published_run.m     provenance: published run -> results/published_run
  digitize_published_figure.py  provenance: paper figure -> verify/paper_figure2_values.csv
original_2015/                the original 2015 code (reference; not maintained)
```

## Notation: code → paper

| Code | Paper | Meaning |
|---|---|---|
| `States(k, :)` | x_k | observed asset values at the k-th experiment |
| `Scenarios` | Y | asset values at the end of the projection period |
| `scenario_density(Model, y, x)` | h(y; x) | density of Y given state x |
| `HighLoss` | F(Y) | output: 1{l(Y) > κ} |
| `Mixture` | h*_k | mixture density (1/k) Σ_i h(·; x_i) |
| `Model.Evaluation`, `.Projection`, `.RepeatPeriod` | τ, t, Δ | evaluation, projection and repeating periods |
| `NumOutputs` | N | new outputs per experiment |

## Verification

`verify/verify_against_paper.m`, the last step of `reproduce_paper.m`, compares the 78 plotted values
of Figure 2 (3 estimators × 26 weeks) with the values in the paper's vector figure
(`verify/paper_figure2_values.csv`, read by `tools/digitize_published_figure.py`):

- **Exact mode**: the summary of the published run (`results/published_run`) reproduces all 78 plotted
  values to the precision of the figure's coordinates (half a unit in their last digit,
  about 1e-10).
- **Monte Carlo mode**: full reruns with this code and new random numbers (seeds 2015 and 2016) agree
  with the published run within Monte Carlo error: z = (x − v)/√(se_x² + se_v²) for each week
  and estimator; |z| > 2.5 is flagged (about 1 chance flag expected per run), and weeks whose MSE
  is dominated by a few paths are compared by a Kolmogorov–Smirnov test of the per-path squared
  errors. Result: 78 of 78 ok for both seeds (largest |z|: 2.35 and 1.80). Reports:
  `verify/verification_results_rerun_seed2015.csv`, `..._seed2016.csv`.

`tests/run_tests.m` checks that the estimators equal a direct implementation of Equations 1, 2 and 4
(storing all outputs), the loss function equals the original `LossAtt.m`, the t-copula sampler and
the scenario density, and compares all outputs with a saved snapshot.

## Reproducibility

Sample path m uses substream m of two `mrg32k3a` streams (seed s: states and estimators; seed s + 1:
accurate estimates), so serial and parallel runs give identical results and the accurate
estimates do not change the estimators' random numbers. Figure 1 uses the seeds of the original
figure (`rng(18)`, `rng(10)`) and reproduces its paths.

## Provenance

The published Figure 2 shows the first 26 weeks of a 1,000-path, 40-week run (April 2015) whose
saved workspace was reduced to `results/published_run/estimates.csv.gz` by
`tools/extract_published_run.m`; the summary reproduces the plotted values. The script version that
produced that run and the plotting code were not kept; `original_2015/MC_MIS.m` is a later edit of
the estimator code. This code was rebuilt from the paper and the original code, and verified by the
reruns.

## Run times

`reproduce_paper` (default): a few seconds. A full rerun (1,000 paths × 26 weeks, including
26,000 accurate estimates with 10^6 outputs each): about 11 CPU-hours, mostly the accurate
estimates; 17.6 minutes wall-clock with 40 workers (4 × Intel Xeon Gold 6126, MATLAB R2025a),
for each of the seeds 2015 and 2016. About 41 seconds per path on one core of an Intel Core
i7-1280P (MATLAB R2023b).

## Change log

- **2026-11 (v1.0.0)**: archived version. Rebuilt and restructured the 2015 code: one entry point
  for all figures, functions in the paper's notation, seeded parallel runs, summaries of the
  published run, verification against the published figure, tests.
- **2015**: original code (`original_2015/`).

## License

MIT (see `LICENSE`).
