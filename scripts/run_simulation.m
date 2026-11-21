function run_simulation(NumPaths, NumWeeks, Seed, NumWorkers, RunFolder, NumParts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_simulation.m                                                            %
% Numerical example of Section 3.2: for each sample path of weekly states,    %
% the SMC, OIS and MIS estimates in the K weekly experiments and the          %
% accurate estimates (SMC with 10^6 outputs) of the true values               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input(s) (all optional; defaults are the paper's settings):
% -- NumPaths: number of sample paths (macro replications), 1000
% -- NumWeeks: K, experiments per path, 26
% -- Seed: seed of the random streams, 2015
% -- NumWorkers: parallel workers (0 = serial), 0
% -- RunFolder: output folder, results/rerun_seed<Seed>
% -- NumParts: the paths are run in parts that are saved separately, so an
%    interrupted run can be resumed (finished parts are skipped), 10
% Output(s): files in RunFolder
% -- parts/part_<p>.csv: one row per (path, week): Path, Week, SMC, OIS,
%    MIS, Accurate, AccurateVariance
% -- estimates.csv.gz: all parts combined; run_info.txt: settings, time
% Reproducibility: path m uses substream m of two mrg32k3a streams (seeds
% Seed and Seed + 1): the first for the states and the estimators, the
% second for the accurate estimate. Serial and parallel runs are identical.
% Example (on a server, from the Code folder):
%   matlab -batch "addpath('functions','scripts'); run_simulation(1000, 26, 2015, 40)"

% ===== Defaults (the paper's settings, Section 3.2)
if nargin < 1 || isempty(NumPaths), NumPaths = 1000; end
if nargin < 2 || isempty(NumWeeks), NumWeeks = 26; end
if nargin < 3 || isempty(Seed), Seed = 2015; end
if nargin < 4 || isempty(NumWorkers), NumWorkers = 0; end
if nargin < 5 || isempty(RunFolder), RunFolder = fullfile('results', sprintf('rerun_seed%d', Seed)); end
if nargin < 6 || isempty(NumParts), NumParts = 10; end
NumOutputs = 1000;           % N, new outputs per experiment
NumAccurate = 1e6;           % outputs of the accurate estimate
Model = kmv_settings();

PartsFolder = fullfile(RunFolder, 'parts');
if ~exist(PartsFolder, 'dir'), mkdir(PartsFolder); end
if NumWorkers > 0 && isempty(gcp('nocreate'))
    parpool(NumWorkers);
end

% ===== Run the parts
Start = tic;
PathsPerPart = ceil(NumPaths / NumParts);
for Part = 1:NumParts
    PartFile = fullfile(PartsFolder, sprintf('part_%03d.csv', Part));
    if exist(PartFile, 'file')
        fprintf('part %d already done, skipped\n', Part);
        continue
    end
    FirstPath = (Part - 1) * PathsPerPart + 1;
    LastPath = min(Part * PathsPerPart, NumPaths);
    if FirstPath > LastPath, break; end
    Paths = FirstPath:LastPath;
    Results = cell(length(Paths), 1);          % one table block per path
    parfor (m = 1:length(Paths), max(NumWorkers, 0))
        Results{m} = one_path(Model, Paths(m), NumWeeks, NumOutputs, NumAccurate, Seed);
    end
    Block = vertcat(Results{:});
    writematrix(Block, PartFile);
    fprintf('part %d of %d (paths %d-%d) done, %.1f min so far\n', ...
        Part, NumParts, FirstPath, LastPath, toc(Start) / 60);
end

% ===== Combine the parts
Header = {'Path', 'Week', 'SMC', 'OIS', 'MIS', 'Accurate', 'AccurateVariance'};
All = [];
for Part = 1:NumParts
    PartFile = fullfile(PartsFolder, sprintf('part_%03d.csv', Part));
    if exist(PartFile, 'file')
        All = [All; readmatrix(PartFile)]; %#ok<AGROW> (few parts)
    end
end
Combined = array2table(All, 'VariableNames', Header);
CsvFile = fullfile(RunFolder, 'estimates.csv');
writetable(Combined, CsvFile);
gzip(CsvFile); delete(CsvFile);

Info = fopen(fullfile(RunFolder, 'run_info.txt'), 'w');
fprintf(Info, 'paths %d, weeks %d, outputs %d, accurate outputs %d, seed %d\n', ...
    NumPaths, NumWeeks, NumOutputs, NumAccurate, Seed);
fprintf(Info, 'workers %d, wall-clock of this call %.1f min, MATLAB %s\n', ...
    NumWorkers, toc(Start) / 60, version);
fclose(Info);
end


function Rows = one_path(Model, Path, NumWeeks, NumOutputs, NumAccurate, Seed)
% Estimates and accurate estimates for one sample path
% Output(s):
% -- Rows: K x 7, columns as in the header of run_simulation.m
MainStream = RandStream('mrg32k3a', 'Seed', Seed);
MainStream.Substream = Path;
AccurateStream = RandStream('mrg32k3a', 'Seed', Seed + 1);
AccurateStream.Substream = Path;

States = simulate_states(Model, NumWeeks, MainStream);
Estimates = green_estimates_one_path(Model, States, NumOutputs, MainStream);
Accurate = zeros(NumWeeks, 2);
for Week = 1:NumWeeks
    [Accurate(Week, 1), Accurate(Week, 2)] = accurate_estimate(Model, States(Week, :), NumAccurate, AccurateStream);
end
Rows = [Path * ones(NumWeeks, 1), (1:NumWeeks)', Estimates, Accurate];
end
