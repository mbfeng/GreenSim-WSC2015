function Summary = summarise_mse(Estimates, NumWeeks)
% Mean squared errors of the three estimators per week, over sample paths
% (the figure of merit of Section 3.2)
% Input(s):
% -- Estimates: table with columns Path, Week, SMC, OIS, MIS, Accurate
%    (one row per path and week)
% -- NumWeeks: number of weeks to summarise (first weeks)
% Output(s):
% -- Summary: table, one row per week: Week, NumPaths, MSE_SMC, MSE_OIS,
%    MSE_MIS and their standard errors SE_* = std(squared errors)/sqrt(paths)
% formula: MSE_k = (1/M) sum_m (fhat_k^(m) - accurate_k^(m))^2

Names = {'SMC', 'OIS', 'MIS'};
Summary = table((1:NumWeeks)', zeros(NumWeeks, 1), 'VariableNames', {'Week', 'NumPaths'});
for e = 1:3
    Summary.(['MSE_' Names{e}]) = zeros(NumWeeks, 1);
    Summary.(['SE_' Names{e}]) = zeros(NumWeeks, 1);
end
for Week = 1:NumWeeks
    Rows = Estimates.Week == Week;
    Summary.NumPaths(Week) = sum(Rows);
    for e = 1:3
        SquaredError = (Estimates.(Names{e})(Rows) - Estimates.Accurate(Rows)).^2;
        Summary.(['MSE_' Names{e}])(Week) = mean(SquaredError);
        Summary.(['SE_' Names{e}])(Week) = std(SquaredError) / sqrt(sum(Rows));
    end
end
end
