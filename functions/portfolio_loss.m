function Loss = portfolio_loss(Model, Scenarios)
% Discounted portfolio loss l(y) at the end of the projection period
% (Section 3.1, Equation 6)
% Input(s):
% -- Model: struct from kmv_settings.m
% -- Scenarios: N x 2 asset values y at time t_k + t
% Output(s):
% -- Loss: N x 1, l(y) = sum_i max{1{y_i < D_i}, e^{-r tau} Phi(-d2_i)} LGD_i
% formula: d2_i = (ln(y_i / D_i) + (r - sigma_i^2/2) tau) / (sigma_i sqrt(tau));
%          e^{-r tau} Phi(-d2_i) is the price of a digital put paying 1 if
%          the asset is below the debt at the end of the evaluation period

Tau = Model.Evaluation;                                       % tau
Default = Scenarios < Model.Debt;                             % 1{y_i < D_i}
DistanceToDefault = (log(Scenarios ./ Model.Debt) ...
    + (Model.RiskFree - Model.Volatility.^2 / 2) * Tau) ...
    ./ (Model.Volatility * sqrt(Tau));                        % d2_i
DigitalPut = exp(-Model.RiskFree * Tau) * normcdf(-DistanceToDefault);
LossPerBond = max(Default, DigitalPut) .* Model.LossGivenDefault; % N x 2
Loss = sum(LossPerBond, 2);
end
