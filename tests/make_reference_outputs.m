function make_reference_outputs()
% Saves the outputs of reference_outputs.m to tests/reference_outputs.mat.
% run_tests.m compares later versions of the code with this snapshot.
% Rerun only when a change of the results is intended.
TestsFolder = fileparts(mfilename('fullpath'));
CodeFolder = fileparts(TestsFolder);
addpath(fullfile(CodeFolder, 'functions'), TestsFolder);
Reference = reference_outputs(); %#ok<NASGU> (saved below)
save(fullfile(TestsFolder, 'reference_outputs.mat'), 'Reference');
fprintf('make_reference_outputs: saved tests/reference_outputs.mat\n');
end
