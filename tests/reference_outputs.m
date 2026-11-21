function Reference = reference_outputs()
% Outputs of the library functions on fixed inputs and seeds, used by
% make_reference_outputs.m (saves them) and run_tests.m (compares with them)
% Output(s): struct Reference with
% -- .States, .Estimates: 2 sample paths x 15 weeks, 300 outputs per week
% -- .Accurate: accurate estimates (10^4 outputs) at 3 states
% -- .Loss, .Density: portfolio loss and density at 100 fixed scenarios
% -- .Figure2: summary of the published run (MSE and SE, 26 weeks)

Model = kmv_settings();
Reference.States = cell(2, 1);
Reference.Estimates = cell(2, 1);
for Path = 1:2
    Stream = RandStream('mrg32k3a', 'Seed', 11); Stream.Substream = Path;
    Reference.States{Path} = simulate_states(Model, 15, Stream);
    Reference.Estimates{Path} = green_estimates_one_path(Model, Reference.States{Path}, 300, Stream);
end
Stream = RandStream('mrg32k3a', 'Seed', 12);
States = [100 90; 90 85; 110 95];
Reference.Accurate = zeros(3, 1);
for s = 1:3
    Reference.Accurate(s) = accurate_estimate(Model, States(s, :), 1e4, Stream);
end
Scenarios = sample_scenarios(Model, [100 90], 100, RandStream('mrg32k3a', 'Seed', 13));
Reference.Loss = portfolio_loss(Model, Scenarios);
Reference.Density = scenario_density(Model, Scenarios, [95 88]);
CodeFolder = fileparts(fileparts(mfilename('fullpath')));
Reference.Figure2 = summarise_mse(read_estimates(fullfile(CodeFolder, 'results', 'published_run')), 26);
end
