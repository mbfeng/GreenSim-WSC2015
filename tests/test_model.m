function test_model()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test_model.m                                                                %
% Checks of the model functions against MATLAB's reference implementations   %
% and against the original 2015 code (original_2015/LossAtt.m)               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CodeFolder = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(CodeFolder, 'functions'), fullfile(CodeFolder, 'original_2015'));
Model = kmv_settings();
Stream = RandStream('mrg32k3a', 'Seed', 1);

% ===== Loss: same as the original LossAtt.m (with its Portfolio struct)
Scenarios = sample_scenarios(Model, [100 90], 1e4, Stream);
Portfolio = struct('K', Model.Debt, 'rf', Model.RiskFree * [1 1], ...
    'vol', Model.Volatility, 'T', Model.Evaluation * [1 1], 'LGD', Model.LossGivenDefault);
LossDifference = max(abs(portfolio_loss(Model, Scenarios) - LossAtt(Scenarios, Portfolio)));
fprintf('test_model: loss vs original LossAtt.m: %.2e\n', LossDifference);
assert(LossDifference < 1e-12, 'portfolio_loss differs from the original LossAtt.m');

% ===== t-copula samples: same distribution as copularnd (KS test per
% margin and on Kendall's tau)
Correlation = [1 Model.CopulaRho; Model.CopulaRho 1];
Ours = t_copula_uniforms(Correlation, Model.CopulaDF, 2e5, Stream);
Reference = copularnd('t', Correlation, Model.CopulaDF, 2e5);
for Margin = 1:2
    [~, PValue] = kstest2(Ours(1:2e4, Margin), Reference(1:2e4, Margin));
    assert(PValue > 1e-3, 't-copula margin %d differs from copularnd', Margin);
end
Tau = corr(Ours(1:2e4, 1), Ours(1:2e4, 2), 'type', 'Kendall');
fprintf('test_model: Kendall tau %.4f (theory %.4f)\n', Tau, 2 / pi * asin(Model.CopulaRho));
assert(abs(Tau - 2 / pi * asin(Model.CopulaRho)) < 0.02, 'Kendall tau of the t-copula');

% ===== Density: integrates to 1 over a wide grid (2-D trapezoid rule)
[LogMean, LogStd] = scenario_marginals(Model, [100 90]);
Grid1 = exp(linspace(LogMean(1) - 7 * LogStd(1), LogMean(1) + 7 * LogStd(1), 600));
Grid2 = exp(linspace(LogMean(2) - 7 * LogStd(2), LogMean(2) + 7 * LogStd(2), 600));
[Y1, Y2] = ndgrid(Grid1, Grid2);
Density = reshape(scenario_density(Model, [Y1(:), Y2(:)], [100 90]), size(Y1));
Mass = trapz(Grid2, trapz(Grid1, Density, 1), 2);
fprintf('test_model: density integrates to %.4f\n', Mass);
assert(abs(Mass - 1) < 5e-3, 'scenario_density does not integrate to 1');
end
