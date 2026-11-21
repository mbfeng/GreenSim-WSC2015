function Estimates = read_estimates(RunFolder)
% Reads the estimates of a run (estimates.csv.gz written by run_simulation.m
% or tools/extract_published_run.m)
% Input(s):
% -- RunFolder: folder of the run, e.g. results/published_run
% Output(s):
% -- Estimates: table with columns Path, Week, SMC, OIS, MIS, Accurate,
%    AccurateVariance

GzFile = fullfile(RunFolder, 'estimates.csv.gz');
if ~exist(GzFile, 'file')
    error('read_estimates: %s not found (run scripts/run_simulation.m first).', GzFile);
end
TempFolder = tempname;                   % unzip into a private temp folder
Unzipped = gunzip(GzFile, TempFolder);
Estimates = readtable(Unzipped{1});
rmdir(TempFolder, 's');
end
