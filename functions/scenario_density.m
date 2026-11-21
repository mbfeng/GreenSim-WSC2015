function Density = scenario_density(Model, Scenarios, State)
% Density h(y; x) of the scenarios given a state: t-copula density times the
% lognormal marginal densities (used in the likelihood ratios, Section 2)
% Input(s):
% -- Model: struct from kmv_settings.m
% -- Scenarios: N x 2 asset values y
% -- State: 1 x 2, state x
% Output(s):
% -- Density: N x 1, h(y; x)
% formula: h(y; x) = c(F_1(y_1), F_2(y_2)) f_1(y_1) f_2(y_2)

Correlation = [1, Model.CopulaRho; Model.CopulaRho, 1];
[LogMean, LogStd] = scenario_marginals(Model, State);
Uniforms = zeros(size(Scenarios));      % marginal CDF values F_i(y_i)
Marginals = ones(size(Scenarios, 1), 1); % product of marginal densities
for Asset = 1:2
    Uniforms(:, Asset) = logncdf(Scenarios(:, Asset), LogMean(Asset), LogStd(Asset));
    Marginals = Marginals .* lognpdf(Scenarios(:, Asset), LogMean(Asset), LogStd(Asset));
end
CopulaDensity = copulapdf('t', Uniforms, Correlation, Model.CopulaDF);
Density = CopulaDensity .* Marginals;
end
