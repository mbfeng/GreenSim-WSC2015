function Model = kmv_settings()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% kmv_settings.m                                                              %
% Parameters of the periodic credit risk evaluation in the KMV model          %
% (Section 3.2 of Feng and Staum, WSC 2015)                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output(s): struct Model with
% -- .InitialAssets: 1 x 2, asset values S at the first experiment, x_1
% -- .Debt: 1 x 2, debts D; .LossGivenDefault: 1 x 2, LGDs
% -- .Drift, .Volatility: 1 x 2, GBM parameters mu and sigma (real-world)
% -- .RiskFree: risk-free rate r (risk-neutral pricing of the loss)
% -- .CopulaRho, .CopulaDF: t-copula correlation and degrees of freedom
% -- .RepeatPeriod: Delta, time between experiments (1 week)
% -- .Projection: t, projection period (6 months)
% -- .Evaluation: tau, evaluation period of the loss
% -- .Threshold: kappa, high-loss threshold

Model.InitialAssets = [100, 90];     % x_1
Model.Debt = [85, 85];               % D
Model.LossGivenDefault = [5, 4];     % LGD
Model.Drift = [0.15, 0.10];          % mu
Model.Volatility = [0.30, 0.20];     % sigma
Model.RiskFree = 0.05;               % r
Model.CopulaRho = 0.5;               % correlation of the t-copula
Model.CopulaDF = 3;                  % degrees of freedom of the t-copula
Model.RepeatPeriod = 1/52;           % Delta: experiments are weekly
Model.Projection = 0.5;              % t: projection period
Model.Evaluation = 4.5;              % tau: evaluation period, as in the
                                     % runs behind Figure 2 (see README)
Model.Threshold = 6;                 % kappa: high-loss threshold
end
