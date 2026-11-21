function extract_published_run(OriginalFile, RunFolder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract_published_run.m                                                     %
% One-off provenance tool: reduces the saved workspace of the run behind      %
% Figure 2 (Results40Weeks.mat, April 2015, 1000 paths x 40 weeks) to the     %
% compact format written by run_simulation.m                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input(s):
% -- OriginalFile: path of Results40Weeks.mat (not part of this repository)
% -- RunFolder: output folder, e.g. results/published_run
% Output(s):
% -- RunFolder/estimates.csv.gz: Path, Week, SMC, OIS, MIS, Accurate,
%    AccurateVariance for all 1000 paths and 40 weeks (the paper shows the
%    first 26 weeks)
% The workspace variables used: SimProb_SMC, SimProb_OIS, SimProb_MIS,
% TrueProb, TrueProbVar (all 40 x 1000, week x path).

Saved = load(OriginalFile, 'SimProb_SMC', 'SimProb_OIS', 'SimProb_MIS', ...
    'TrueProb', 'TrueProbVar', 'ExParam');
[NumWeeks, NumPaths] = size(Saved.TrueProb);
[WeekGrid, PathGrid] = ndgrid(1:NumWeeks, 1:NumPaths);   % week x path
Table = table(PathGrid(:), WeekGrid(:), Saved.SimProb_SMC(:), ...
    Saved.SimProb_OIS(:), Saved.SimProb_MIS(:), Saved.TrueProb(:), ...
    Saved.TrueProbVar(:), 'VariableNames', ...
    {'Path', 'Week', 'SMC', 'OIS', 'MIS', 'Accurate', 'AccurateVariance'});
Table = sortrows(Table, {'Path', 'Week'});

if ~exist(RunFolder, 'dir'), mkdir(RunFolder); end
CsvFile = fullfile(RunFolder, 'estimates.csv');
writetable(Table, CsvFile);
gzip(CsvFile); delete(CsvFile);
fprintf('extract_published_run: %d paths x %d weeks written to %s\n', ...
    NumPaths, NumWeeks, RunFolder);
end
