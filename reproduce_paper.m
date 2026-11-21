%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reproduce_paper.m                                                           %
% Entry point: Figures 1 and 2 of Feng and Staum (2015), "Green simulation    %
% designs for repeated experiments", Proceedings of the 2015 Winter           %
% Simulation Conference, 403-413, and the check of Figure 2 against the      %
% published paper. Run from this folder.                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ===== Settings
RERUN_SIMULATIONS = false;  % false: draw Figure 2 from the saved summary of
                            % the run behind the published figure (seconds);
                            % true: rerun the 1000 x 26 experiments first
                            % (hours; see README, "Run times")
NUM_WORKERS = 0;            % parallel workers for a rerun (0 = serial)
SEED = 2015;                % seed of a rerun

% ===== Paths
CodeFolder = fileparts(mfilename('fullpath'));
addpath(fullfile(CodeFolder, 'functions'), fullfile(CodeFolder, 'scripts'), ...
    fullfile(CodeFolder, 'verify'));
cd(CodeFolder);

% ===== Figure 1 (illustration)
make_figure1('figures');
fprintf('Figure 1 written to figures/\n');

% ===== Figure 2 (MSEs over 26 weeks)
if RERUN_SIMULATIONS
    RunFolder = fullfile('results', sprintf('rerun_seed%d', SEED));
    run_simulation(1000, 26, SEED, NUM_WORKERS, RunFolder);
else
    RunFolder = fullfile('results', 'published_run');
end
make_figure2(RunFolder, fullfile('figures', 'msefig.pdf'));
fprintf('Figure 2 written to figures/ (from %s)\n', RunFolder);

% ===== Check against the published figure
verify_against_paper(RunFolder, fullfile('verify', ['verification_' strrep(RunFolder, filesep, '_') '.csv']));
