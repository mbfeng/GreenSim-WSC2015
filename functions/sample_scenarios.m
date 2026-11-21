function Scenarios = sample_scenarios(Model, State, NumSamples, Stream)
% Future scenarios Y ~ h(y; x): asset values at the end of the projection
% period, given the current state x (Section 3.1)
% Input(s):
% -- Model: struct from kmv_settings.m
% -- State: 1 x 2, current asset values x_k
% -- NumSamples: number of scenarios
% -- Stream: RandStream
% Output(s):
% -- Scenarios: NumSamples x 2 asset values at time t_k + t
% formula: Y_i = lognormal(log x_i + (mu_i - sigma_i^2/2) t, sigma_i sqrt(t))
%          marginals, joined by the t-copula

Correlation = [1, Model.CopulaRho; Model.CopulaRho, 1];
Uniforms = t_copula_uniforms(Correlation, Model.CopulaDF, NumSamples, Stream);
[LogMean, LogStd] = scenario_marginals(Model, State);
Scenarios = zeros(NumSamples, 2);
for Asset = 1:2
    Scenarios(:, Asset) = logninv(Uniforms(:, Asset), LogMean(Asset), LogStd(Asset));
end
end
