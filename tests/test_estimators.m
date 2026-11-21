function MaxDifference = test_estimators()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test_estimators.m                                                           %
% Checks green_estimates_one_path.m (which stores only high-loss outputs)     %
% against a direct implementation of Equations 1, 2 and 4 that stores every  %
% output and computes every likelihood ratio, on the same random numbers.    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output(s):
% -- MaxDifference: largest absolute difference over 5 paths x 12 weeks
%    (error if above 1e-12)

CodeFolder = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(CodeFolder, 'functions'));
Model = kmv_settings();
NumWeeks = 12; NumOutputs = 200;
MaxDifference = 0;
for Path = 1:5
    Stream = RandStream('mrg32k3a', 'Seed', 7); Stream.Substream = Path;
    States = simulate_states(Model, NumWeeks, Stream);
    StartState = Stream.State;                         % same numbers for both
    Fast = green_estimates_one_path(Model, States, NumOutputs, Stream);
    Stream.State = StartState;
    Direct = direct_estimates(Model, States, NumOutputs, Stream);
    MaxDifference = max(MaxDifference, max(abs(Fast(:) - Direct(:))));
end
fprintf('test_estimators: largest difference from the direct formulas %.2e\n', MaxDifference);
if MaxDifference > 1e-12
    error('green_estimates_one_path.m differs from Equations 1, 2 and 4.');
end
end


function Estimates = direct_estimates(Model, States, NumOutputs, Stream)
% Equations 1, 2 and 4 with all outputs stored: K x 3 (SMC, OIS, MIS)
NumWeeks = size(States, 1);
AllScenarios = cell(NumWeeks, 1);
AllOutputs = cell(NumWeeks, 1);
Estimates = zeros(NumWeeks, 3);
for k = 1:NumWeeks
    AllScenarios{k} = sample_scenarios(Model, States(k, :), NumOutputs, Stream);
    AllOutputs{k} = portfolio_loss(Model, AllScenarios{k}) > Model.Threshold;
    Estimates(k, 1) = mean(AllOutputs{k});                               % Eq. 1
    SumOIS = 0; SumMIS = 0;
    for i = 1:k
        Y = AllScenarios{i};
        Target = scenario_density(Model, Y, States(k, :));               % h(Y; x_k)
        Own = scenario_density(Model, Y, States(i, :));                  % h(Y; x_i)
        Mixture = zeros(size(Y, 1), 1);
        for l = 1:k
            Mixture = Mixture + scenario_density(Model, Y, States(l, :)) / k; % h*_k(Y)
        end
        Outputs = AllOutputs{i};
        SumOIS = SumOIS + sum(Target(Outputs) ./ Own(Outputs));
        SumMIS = SumMIS + sum(Target(Outputs) ./ Mixture(Outputs));
    end
    Estimates(k, 2) = SumOIS / (k * NumOutputs);                         % Eq. 2
    Estimates(k, 3) = SumMIS / (k * NumOutputs);                         % Eq. 4
end
end
