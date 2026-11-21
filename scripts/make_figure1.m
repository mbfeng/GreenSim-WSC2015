function make_figure1(FigureFolder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_figure1.m                                                              %
% Figure 1: illustration of the first two experiments for a portfolio of one  %
% bond (Section 3.1): three asset paths over the projection period from      %
% x_1 = 100 (top) and x_2 = 95 (bottom), the scenario densities h(y; x) and  %
% the outputs F(Y) of the current (circles) and earlier (stars) experiment.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input(s):
% -- FigureFolder: output folder (1dFig1.pdf, 1dFig2.pdf: the file names of
%    the paper's source)
% The paths use the seeds of the original figure (rng(18), rng(10)) and are
% the same as in the published figure. The outputs are the illustrative
% values of the original figure (0, 0, 1 and 1, 0, 0), so that each
% estimator equals 1/3 in the first experiment. The densities are drawn to
% scale (x 10, starting at t + 0.1).

Drift = 0.15; Volatility = 0.30; Projection = 0.5;   % mu, sigma, t of the bond
NumSteps = 500; NumPaths = 3;
Step = Projection / NumSteps;
LogDrift = Drift - Volatility^2 / 2;
LogStd = Volatility * sqrt(Projection);
Grid = 60:0.5:140;                                    % asset values for the densities
Time = (0:Step:Projection)';
Colours = get(groot, 'defaultAxesColorOrder');        % MATLAB default colours
Brown = [0.6 0.4 0.4];                                % h(y; x_1) in the second panel
FontArgs = {'FontSize', 14, 'FontWeight', 'bold'};

rng(18);                                              % seed of the original figure
Paths1 = asset_paths(100, LogDrift, Volatility, Step, NumSteps, NumPaths);
rng(10);
Paths2 = asset_paths(95, LogDrift, Volatility, Step, NumSteps, NumPaths);
Density1 = lognpdf(Grid, log(100) + LogDrift * Projection, LogStd) * 10 + Projection + 0.1;
Density2 = lognpdf(Grid, log(95) + LogDrift * Projection, LogStd) * 10 + Projection + 0.1;
Ends = Projection * ones(NumPaths, 1);                 % end of the projection period
Outputs1 = [0 0 1];                                   % F(Y_1^(j)), illustrative
Outputs2 = [1 0 0];                                   % F(Y_2^(j)), illustrative

% ===== Top panel: experiment at time t_1, x_1 = 100
Figure = new_figure();
for p = 1:NumPaths
    plot3(Time, Paths1(:, p), zeros(size(Time)), 'Color', Colours(p, :), 'LineWidth', 3);
end
plot3(Density1, Grid, zeros(size(Grid)), 'r', 'LineWidth', 3);
stem3(Ends, Paths1(end, :)', Outputs1', 'ok', 'LineWidth', 3, 'MarkerSize', 10);
for j = 1:NumPaths
    text(0.51, Paths1(end, j) + 2, Outputs1(j) + 0.08, sprintf('F(Y^{(%d)}_{1})', j), FontArgs{:});
    text(0.53, Paths1(end, j) - 2, 0, sprintf('Y^{(%d)}_{1}', j), FontArgs{:});
end
text(0.75, 100, 0, 'h(y;x_1)', FontArgs{:});
text(0, 110, 0, 'x_1 = 100', FontArgs{:});
finish_axes();
exportgraphics(Figure, fullfile(FigureFolder, '1dFig1.pdf'), 'ContentType', 'vector');
close(Figure);

% ===== Bottom panel: experiment at time t_2, x_2 = 95, earlier outputs as stars
Figure = new_figure();
PathColours = Colours([7 5 4], :);                    % colours of the published panel
for p = 1:NumPaths
    plot3(Time, Paths2(:, p), zeros(size(Time)), 'Color', PathColours(p, :), 'LineWidth', 3);
end
plot3(Density1, Grid, zeros(size(Grid)), '-.', 'Color', Brown, 'LineWidth', 3);
plot3(Density2, Grid, zeros(size(Grid)), 'r', 'LineWidth', 3);
stem3(Ends + 0.01, Paths1(end, :)', Outputs1', '*k', 'LineWidth', 1.5, 'MarkerSize', 10);
stem3(Ends, Paths2(end, :)', Outputs2', 'ok', 'LineWidth', 3, 'MarkerSize', 10);
for j = 1:NumPaths
    Label = NumPaths + 1 - j;    % the published panel numbers the paths in reverse
    text(0.48, Paths2(end, j) + 2, Outputs2(j) + 0.08, sprintf('F(Y^{(%d)}_{2})', Label), FontArgs{:});
    text(0.53, Paths2(end, j) - 2, 0, sprintf('Y^{(%d)}_{2}', Label), FontArgs{:});
end
text(0.75, 104, 0, 'h(y;x_1) \rightarrow', FontArgs{:});
text(0.75, 90, 0, 'h(y;x_2) \rightarrow', FontArgs{:});
text(0, 102, 0, 'x_2 = 95', FontArgs{:});
finish_axes();
exportgraphics(Figure, fullfile(FigureFolder, '1dFig2.pdf'), 'ContentType', 'vector');
close(Figure);
end


function Paths = asset_paths(Start, LogDrift, Volatility, Step, NumSteps, NumPaths)
% Geometric Brownian motion paths, (NumSteps + 1) x NumPaths, drawn with
% normrnd from the global stream as in the original figure
LogSteps = normrnd(LogDrift * Step, Volatility * sqrt(Step), [NumSteps, NumPaths]);
LogPaths = cumsum([zeros(1, NumPaths); LogSteps]);
Paths = Start * exp(LogPaths);
end


function Figure = new_figure()
% Figure window of the size of the original figure
Figure = figure('Visible', 'off', 'Position', [100 100 1350 700]);
hold on
end


function finish_axes()
% Axes, labels and view of Figure 1
grid on
zlim([0 1]); ylim([70 130]); xlim([0 0.8]);
xticks(0:0.1:0.5);
set(gca, 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Projection Period'); ylabel('Asset Value'); zlabel('Function Value');
view(-17, 58);
hold off
end
