function Estimates = green_estimates_one_path(Model, States, NumOutputs, Stream)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% green_estimates_one_path.m                                                  %
% The three estimators of Section 2 (SMC, OIS, MIS) in the K repeated         %
% experiments along one sample path of states                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input(s):
% -- Model: struct from kmv_settings.m
% -- States: K x 2, observed states x_1, ..., x_K (simulate_states.m)
% -- NumOutputs: N, new outputs (scenarios) generated in each experiment
% -- Stream: RandStream
% Output(s):
% -- Estimates: K x 3, columns = SMC, OIS, MIS estimates of
%    f(x_k) = Pr(l(Y) > kappa | x_k), k = 1, ..., K
% formula (all experiments have N outputs, so p^k_i = 1/k):
%   SMC: (1/N) sum_j F(Y_k^(j))                                  (Eq. 1)
%   OIS: (1/(kN)) sum_{i<=k} sum_j h(Y_i^(j); x_k) / h(Y_i^(j); x_i) F(Y_i^(j))  (Eq. 2)
%   MIS: (1/(kN)) sum_{i<=k} sum_j h(Y_i^(j); x_k) / h*_k(Y_i^(j)) F(Y_i^(j)),
%        h*_k(y) = (1/k) sum_{i<=k} h(y; x_i)                    (Eqs. 3-4)
% Only outputs with F = 1 (high losses) contribute to the sums, so only
% those scenarios are stored; this is the same estimator with less memory.

NumWeeks = size(States, 1);
Estimates = zeros(NumWeeks, 3);

% Stored high-loss scenarios of all experiments so far, and their densities
% under every state so far: Density(m, i) = h(Y_m; x_i)
Stored = zeros(0, 2);          % scenarios with F = 1
Origin = zeros(0, 1);          % experiment in which each was generated
Density = zeros(0, NumWeeks);  % filled column by column

for Week = 1:NumWeeks
    State = States(Week, :);                                   % x_k

    %-- New experiment: N scenarios from h(.; x_k) and their outputs
    Scenarios = sample_scenarios(Model, State, NumOutputs, Stream);
    HighLoss = portfolio_loss(Model, Scenarios) > Model.Threshold; % F(Y) = 1
    Estimates(Week, 1) = mean(HighLoss);                       % SMC

    %-- Add the new high-loss scenarios to the store
    NewScenarios = Scenarios(HighLoss, :);
    NumNew = size(NewScenarios, 1);
    Stored = [Stored; NewScenarios];                            %#ok<AGROW>
    Origin = [Origin; Week * ones(NumNew, 1)];                  %#ok<AGROW>
    Density = [Density; zeros(NumNew, NumWeeks)];               %#ok<AGROW>

    %-- Densities of the new scenarios under the earlier states, and of
    % all stored scenarios under the current state
    NewRows = size(Stored, 1) - NumNew + 1 : size(Stored, 1);
    for Earlier = 1:Week - 1
        Density(NewRows, Earlier) = scenario_density(Model, NewScenarios, States(Earlier, :));
    end
    Density(:, Week) = scenario_density(Model, Stored, State);

    %-- Likelihood ratios of all stored outputs for the target state x_k
    Target = Density(:, Week);                                  % h(Y; x_k)
    RowIndex = (1:size(Stored, 1))';
    OwnDensity = Density(sub2ind(size(Density), RowIndex, Origin)); % h(Y_i; x_i)
    Mixture = mean(Density(:, 1:Week), 2);                      % h*_k(Y)
    TotalOutputs = Week * NumOutputs;                           % k N
    Estimates(Week, 2) = sum(Target ./ OwnDensity) / TotalOutputs; % OIS
    Estimates(Week, 3) = sum(Target ./ Mixture) / TotalOutputs;    % MIS
end
end
