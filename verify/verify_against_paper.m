function Report = verify_against_paper(RunFolder, ReportFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% verify_against_paper.m                                                      %
% Checks the MSE curves of Figure 2 (weeks 1-26; SMC, OIS, MIS) against the   %
% values plotted in the published paper (verify/paper_figure2_values.csv,    %
% read from the paper's vector figure by tools/digitize_published_figure.py) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input(s):
% -- RunFolder: results/published_run (exact mode) or a rerun (Monte Carlo
%    mode)
% -- ReportFile: CSV report (none written if empty)
% Output(s):
% -- Report: table, one row per week and estimator
% Exact mode (the published run): |x - v| <= 1.1 h, h = half a unit in the
%   last digit of the plotted coordinates (0.0005 px of the figure, 1.1e-10
%   MSE).
% Monte Carlo mode (a rerun with new random numbers): the rerun's MSE x and
%   the published run's MSE v (with standard errors se_x, se_v) must agree:
%   z = (x - v) / sqrt(se_x^2 + se_v^2 + h^2/3); |z| > 2.5 is flagged.
%   Heavy tails: when the worst 1% of paths contribute more than half of
%   the MSE (top1_share > 0.5), the standard errors are unreliable and the
%   per-path squared errors are compared by a two-sample Kolmogorov-Smirnov
%   test instead (status 'ok (KS)' if p > 0.01).

NumWeeks = 26;
CodeFolder = fileparts(fileparts(mfilename('fullpath')));
Paper = readtable(fullfile(CodeFolder, 'verify', 'paper_figure2_values.csv'));
PixelMSE = 1.4e-4 / 662;                 % MSE per pixel of the figure
HalfUnit = 0.0005 * PixelMSE;            % half a unit in the last printed digit

IsPublished = strcmp(strip(RunFolder, 'right', filesep), fullfile('results', 'published_run')) ...
    || endsWith(RunFolder, 'published_run');
Run = read_estimates(RunFolder);
RunSummary = summarise_mse(Run, NumWeeks);
if ~IsPublished
    Published = read_estimates(fullfile(CodeFolder, 'results', 'published_run'));
    PublishedSummary = summarise_mse(Published, NumWeeks);
end

Names = {'SMC', 'OIS', 'MIS'};
Rows = cell(NumWeeks * 3, 8);
r = 0;
for Week = 1:NumWeeks
    for e = 1:3
        r = r + 1;
        Name = Names{e};
        Printed = Paper.(Name)(Week);                % value plotted in the paper
        Reproduced = RunSummary.(['MSE_' Name])(Week);
        if IsPublished
            Z = (Reproduced - Printed) / HalfUnit;   % in units of h
            % 10% margin: the plotted coordinates pass through the figure's
            % scaling transform before being rounded to 3 decimals
            if abs(Reproduced - Printed) <= HalfUnit * 1.1
                Status = 'ok';
            else
                Status = 'UNEXPECTED';
            end
            Top1 = NaN; PValue = NaN;
        else
            SE_x = RunSummary.(['SE_' Name])(Week);
            Reference = PublishedSummary.(['MSE_' Name])(Week);
            SE_v = PublishedSummary.(['SE_' Name])(Week);
            Z = (Reproduced - Reference) / sqrt(SE_x^2 + SE_v^2 + HalfUnit^2 / 3);
            [Top1, PValue] = tail_diagnostics(Run, Published, Name, Week);
            if abs(Z) <= 2.5
                Status = 'ok';
            elseif Top1 > 0.5 && PValue > 0.01
                Status = 'ok (KS)';
            elseif Top1 > 0.5
                Status = 'heavy-tailed';
            else
                Status = 'UNEXPECTED';
            end
        end
        Rows(r, :) = {Week, Name, Printed, Reproduced, Z, Top1, PValue, Status};
    end
end
Report = cell2table(Rows, 'VariableNames', {'Week', 'Estimator', 'Plotted', ...
    'Reproduced', 'Z', 'Top1Share', 'KS_pValue', 'Status'});
if ~isempty(ReportFile)
    writetable(Report, ReportFile);
end

NumOk = sum(startsWith(Report.Status, 'ok'));
NumChecks = height(Report);
if IsPublished
    fprintf('verify_against_paper (exact, published run): %d of %d plotted values of Figure 2 reproduced.\n', ...
        NumOk, NumChecks);
else
    fprintf('verify_against_paper (Monte Carlo, %s vs published run): %d of %d ok', RunFolder, NumOk, NumChecks);
    fprintf(' (expected chance flags at |z| > 2.5: %.1f).\n', 0.0124 * NumChecks);
end
Flagged = Report(~startsWith(Report.Status, 'ok'), :);
if height(Flagged) > 0
    disp(Flagged);
end
if IsPublished && NumOk < NumChecks
    error('Some plotted values were not reproduced.');
end
end


function [Top1Share, PValue] = tail_diagnostics(Run, Published, Name, Week)
% Share of the rerun's MSE from its worst 1% of paths, and the KS p-value
% comparing the per-path squared errors of the rerun and the published run
RunErrors = squared_errors(Run, Name, Week);
PublishedErrors = squared_errors(Published, Name, Week);
Sorted = sort(RunErrors, 'descend');
NumTop = max(1, round(0.01 * length(Sorted)));
Top1Share = sum(Sorted(1:NumTop)) / sum(Sorted);
[~, PValue] = kstest2(RunErrors, PublishedErrors);
end


function Errors = squared_errors(Estimates, Name, Week)
% Squared errors of one estimator in one week, one per path
Rows = Estimates.Week == Week;
Errors = (Estimates.(Name)(Rows) - Estimates.Accurate(Rows)).^2;
end
