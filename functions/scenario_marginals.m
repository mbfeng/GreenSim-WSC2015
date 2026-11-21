function [LogMean, LogStd] = scenario_marginals(Model, State)
% Parameters of the lognormal marginals of the scenario Y given state x
% Input(s):
% -- Model: struct from kmv_settings.m
% -- State: 1 x 2, current asset values x
% Output(s):
% -- LogMean, LogStd: 1 x 2, mean and standard deviation of log Y_i
% formula: log Y_i ~ N(log x_i + (mu_i - sigma_i^2/2) t, sigma_i^2 t)

LogMean = log(State) + (Model.Drift - Model.Volatility.^2 / 2) * Model.Projection;
LogStd = Model.Volatility * sqrt(Model.Projection);
end
