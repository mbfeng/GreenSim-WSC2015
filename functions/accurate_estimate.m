function [Estimate, Variance] = accurate_estimate(Model, State, NumSamples, Stream)
% "Accurate estimate" of f(x) = Pr(l(Y) > kappa | x) by standard Monte Carlo
% with many outputs (10^6 in Section 3.2), used as the true value
% Input(s):
% -- Model: struct from kmv_settings.m
% -- State: 1 x 2, state x
% -- NumSamples: number of outputs (simulated in batches of at most 10^5)
% -- Stream: RandStream
% Output(s):
% -- Estimate: SMC estimate of f(x)
% -- Variance: its variance estimate, p (1 - p) / NumSamples

BatchSize = 1e5;                         % limits memory
NumHigh = 0;                             % number of outputs with F = 1
Remaining = NumSamples;
while Remaining > 0
    Batch = min(BatchSize, Remaining);
    Scenarios = sample_scenarios(Model, State, Batch, Stream);
    NumHigh = NumHigh + sum(portfolio_loss(Model, Scenarios) > Model.Threshold);
    Remaining = Remaining - Batch;
end
Estimate = NumHigh / NumSamples;
Variance = Estimate * (1 - Estimate) / NumSamples;
end
