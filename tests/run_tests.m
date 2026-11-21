function run_tests()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_tests.m                                                                 %
% Regression tests: (1) the estimators equal a direct implementation of      %
% Equations 1, 2 and 4; (2) model checks (loss vs. the original code,        %
% t-copula, density); (3) all outputs equal the saved snapshot.              %
% Run from the Code folder: addpath('tests'); run_tests                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TestsFolder = fileparts(mfilename('fullpath'));
CodeFolder = fileparts(TestsFolder);
addpath(fullfile(CodeFolder, 'functions'), TestsFolder);

test_estimators();
test_model();

Saved = load(fullfile(TestsFolder, 'reference_outputs.mat'));
Saved = Saved.Reference;
Current = reference_outputs();
Differences = [max(abs(Current.Accurate - Saved.Accurate));
               max(abs(Current.Loss - Saved.Loss));
               max(abs(Current.Density ./ Saved.Density - 1));
               max(abs(Current.Figure2{:, 3:end} - Saved.Figure2{:, 3:end}), [], 'all')];
for Path = 1:2
    Differences(end + 1) = max(abs(Current.States{Path} - Saved.States{Path}), [], 'all'); %#ok<AGROW>
    Differences(end + 1) = max(abs(Current.Estimates{Path} - Saved.Estimates{Path}), [], 'all'); %#ok<AGROW>
end
fprintf('run_tests: largest difference from the snapshot %.2e\n', max(Differences));
if max(Differences) > 1e-10
    error('The results differ from tests/reference_outputs.mat.');
end
fprintf('run_tests: all tests passed\n');
end
