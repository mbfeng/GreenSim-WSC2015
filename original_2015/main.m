% main.m
% main file for the KMV example

param;
% genpaths;

%% Experiment design
% Project firm values at time t using P measure

% Generate correlated uniform(0,1) using copula 
if strcmp(Port.copula, 't')
    U_0t = copularnd(Port.copula, Port.Cor, Port.df, ExParam.nPrdnPt);
    PDF = copulapdf(Port.copula, U_0t, Port.Cor, Port.df);
elseif strcmp(copula, 'Gaussian')
    U_0t = copularnd(Port.copula,Port.Cor, ExParam.nPrdnPt);
    PDF = copulapdf(Port.copula, U_0t, Port.Cor);
else
    error('Please check copula type');
end

% correlated normals from copula
Z_0t = norminv(U_0t); 

% % --- Independent normal
% Z_0t = randn(nPrdnPt, nAsset);

% time-t firm value under P
Vt_Firm = bsxfun(@times, Port.S0,...
    exp(bsxfun(@plus, (Port.mu - (Port.vol .^ 2) ./ 2) .* Port.t,...
    bsxfun(@times, Port.vol .* sqrt(Port.t), Z_0t))));

Losses = LossAtt(Vt_Firm, Port);
mean(Losses > Port.Threshold)

% time-t firm value function
Vt_Firm_Fun = @(x,y) PortVal(x,y, Port);

