% param.m
% generate parameters in the current workspace

%% initializing workspace
clear;      % clear variables
close all;  % close all figures
clc;        % clear screen
rng(0);     % random number seed

%% ===== 1 KMV model parameters
% ----- 1.1 shared parameters
nAsset = 2;      % number of assets
nPrdnPt = 1e3;   % number of prdn pts at time t
nPaths = 1e0;    % number of sample paths
nPeriods = 100;   % number of periods in each sample path
nLargeSam = 1e6; % number of large sample to approximate "true" default probability

T = 4.5*ones(1,nAsset);      % asset valuation period = 5 years
t = 0.5*ones(1,nAsset);    % projection period = 6 months
dt = 1/52*ones(1,nAsset);  % re-evaluation period = 1 week

% ----- 1.2 Parameters
V0_Eqty = [15, 5]; % value of equity
V0_Debt = [85, 85]; % value of debt
LossGD = [5, 4];  % loss given default
Threshold = 6;    % threshold for large loss

% Black-Scholes parameters
BSmu = [0.15, 0.10];     % drift 
BSvol = [0.3, 0.2];     % volatility
BSrf = 0.05*ones(1,nAsset);    % risk free rate

% choice of copula and parameter
copula = 't';   % choice of copula 
df = 3;         % degree of freedom in t-copula simulation
Cor = [1     0.5;
       0.5   1;];

% ------ 1.3 derived parameters
V0_Lvge = V0_Debt ./ V0_Eqty;  % financial leverage, for reference
V0_Firm = V0_Debt + V0_Eqty;   % firm values at time 0

% ----- 1.4 Summary portfolio parameters
Port.dt = dt;
Port.t = t;
Port.T = T;
Port.S0 = V0_Firm;
Port.K = V0_Debt;
Port.LGD = LossGD;
Port.mu = BSmu;
Port.rf = BSrf;
Port.vol = BSvol;
Port.Threshold = Threshold;
Port.Cor = Cor;
Port.copula = copula;

if strcmp(copula, 't')
    Port.df = df;
    clearvars copula df
elseif strcmp(copula, 'Gaussian')
    clearvars copula
else
    error('Please check copula type');
end


%% ===== 2. Experiment design parameters
% ----- summary of parameters into a MATLAB structure
ExParam.nPrdnPt = nPrdnPt; % number of prediction points
ExParam.nAsset = nAsset; % number of assets
ExParam.nPaths = nPaths; 
ExParam.nPeriods = nPeriods;
ExParam.nLargeSam = nLargeSam;

clearvars -except Port ExParam
