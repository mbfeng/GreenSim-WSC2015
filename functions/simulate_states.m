function States = simulate_states(Model, NumWeeks, Stream)
% Weekly observed states x_1, ..., x_K of one sample path (Section 3.1):
% asset values following geometric Brownian motions whose weekly
% innovations are dependent through the t-copula
% Input(s):
% -- Model: struct from kmv_settings.m
% -- NumWeeks: K, number of experiments (weeks)
% -- Stream: RandStream to draw from
% Output(s):
% -- States: K x 2, row k = asset values (S_1, S_2) at time t_k; row 1 is
%    Model.InitialAssets
% formula: log S_{k+1} = log S_k + (mu - sigma^2/2) Delta + sigma sqrt(Delta) Z_k,
%          Z_k = normal quantiles of t-copula uniforms

Correlation = [1, Model.CopulaRho; Model.CopulaRho, 1];
LogDrift = (Model.Drift - Model.Volatility.^2 / 2) * Model.RepeatPeriod; % per week
LogVol = Model.Volatility * sqrt(Model.RepeatPeriod);                    % per week

States = zeros(NumWeeks, 2);
States(1, :) = Model.InitialAssets;
if NumWeeks > 1
    Uniforms = t_copula_uniforms(Correlation, Model.CopulaDF, NumWeeks - 1, Stream);
    Innovations = norminv(Uniforms);                     % dependent N(0,1)
    LogSteps = LogDrift + LogVol .* Innovations;         % (K-1) x 2
    LogStates = log(Model.InitialAssets) + cumsum(LogSteps, 1);
    States(2:end, :) = exp(LogStates);
end
end
