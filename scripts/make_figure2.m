function make_figure2(RunFolder, OutputFile)
% Figure 2: MSEs and error bars of the SMC, OIS and MIS estimators over the
% first 26 weekly experiments (Section 3.2)
% Input(s):
% -- RunFolder: folder of a run (results/published_run or a rerun)
% -- OutputFile: figure file (.pdf); the summary is also written as
%    <OutputFile without extension>.csv
% The error bars are +-1.96 standard errors of the MSE over sample paths, as
% in the published figure.

NumWeeks = 26;
Summary = summarise_mse(read_estimates(RunFolder), NumWeeks);
[Folder, Name] = fileparts(OutputFile);
writetable(Summary, fullfile(Folder, [Name '.csv']));

Colours = [0 0.447 0.741; 0.929 0.694 0.125; 0.851 0.325 0.098]; % SMC, OIS, MIS
Styles = {'-', ':', '-.'};                                    % as in the paper
Names = {'SMC', 'OIS', 'MIS'};
Figure = figure('Visible', 'off', 'Position', [100 100 1100 520]);
hold on
Lines = gobjects(3, 1);
for e = 1:3
    MSE = Summary.(['MSE_' Names{e}]);
    HalfWidth = 1.96 * Summary.(['SE_' Names{e}]);   % 95% error bars
    Lines(e) = plot(Summary.Week, MSE, Styles{e}, 'Color', Colours(e, :), 'LineWidth', 3);
    errorbar(Summary.Week, MSE, HalfWidth, 'LineStyle', 'none', 'Color', Colours(e, :), 'LineWidth', 2);
end
hold off
xlim([0 27]); ylim([0 1.4e-4]);
xlabel('Experiment Time Indices'); ylabel('MSE');
legend(Lines, Names, 'Location', 'northwest');
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
box on
exportgraphics(Figure, OutputFile, 'ContentType', 'vector');
close(Figure);
end
