%% MS_IS2.m
% Implement the second type of importance sampling
clear all;
close all;
clc;
rng(0);

%% Load parameters
param;
% genpaths;
%% Generate sample paths
load('TrueProb.mat');

%% Experiment design
SimProb_SMC = zeros(ExParam.nPeriods, ExParam.nPaths);
SimProb_OIS = zeros(ExParam.nPeriods, ExParam.nPaths);
SimProb_MIS = zeros(ExParam.nPeriods, ExParam.nPaths);

SimProbVar_SMC = zeros(ExParam.nPeriods, ExParam.nPaths);
SimProbVar_OIS = zeros(ExParam.nPeriods, ExParam.nPaths);
SimProbVar_MIS = zeros(ExParam.nPeriods, ExParam.nPaths);

% Expected percentage of high losses (shrinks memory usage)
Shrink = 0.2;
tic
for path = 1:ExParam.nPaths
    tic
    % Indices for boundaries between stored prdn pts in each period
    BoundaryInd = ones(ExParam.nPeriods + 1, 1);
    
    % The copula(0,1) r.v's and the corresponding stock prices
    Ut_MIS = zeros(ExParam.nPrdnPt*ExParam.nPeriods*Shrink, ExParam.nAsset);
    Vt_MIS = zeros(ExParam.nPrdnPt*ExParam.nPeriods*Shrink, ExParam.nAsset);
    
    % copula pdf and marginal pdf for each design point
    CopulaPDF_MIS = zeros(ExParam.nPrdnPt*ExParam.nPeriods*Shrink, ExParam.nPeriods);
    MarginPDF_MIS = zeros(ExParam.nPrdnPt*ExParam.nPeriods*Shrink, ExParam.nPeriods);
    
    % mean and standard deviation of stock prices in each period
    MU_MIS = zeros(ExParam.nPeriods, ExParam.nAsset);
    SIGMA_MIS = zeros(ExParam.nPeriods, ExParam.nAsset);
    
    for period = 1:ExParam.nPeriods
        % Initilize dummy variables
        % --- mean and std of stock prices in the current period
        MU_cur = zeros(ExParam.nAsset,1);
        SIGMA_cur = zeros(ExParam.nAsset,1);
        nPrdnPt_cur = ExParam.nPrdnPt;      % # of prdn pts in current period
        
        % Current price scenario
        S0 = SamPaths(period, :, path);
        
        % Generate correlated uniform(0,1) using copula
        if strcmp(Port.copula, 't')
            U_0t = copularnd(Port.copula, Port.Cor, Port.df, nPrdnPt_cur);
        elseif strcmp(Port.copula, 'Gaussian')
            U_0t = copularnd(Port.copula,Port.Cor, nPrdnPt_cur);
        else
            error('Please check copula type');
        end
        
        % Crude Monte Carlo estimate
        Vt_Firm = zeros(nPrdnPt_cur, ExParam.nAsset);
        for asset = 1:ExParam.nAsset
            MU_cur(asset) = log(S0(asset)) + (Port.mu(asset) - (Port.vol(asset) .^ 2) ./ 2) .* Port.t(asset);
            SIGMA_cur(asset) = Port.vol(asset) .* sqrt(Port.t(asset));
            Vt_Firm(:,asset) = logninv(U_0t(:,asset), MU_cur(asset), SIGMA_cur(asset));
        end
        
        BigLossInd = LossAtt(Vt_Firm, Port) > Port.Threshold;
        nBigLoss_cur = sum(BigLossInd); % number of big losses in the current period
        pBigLoss_cur = nBigLoss_cur / nPrdnPt_cur;  % the CMC estimate
        
        % update result recorders
        SimProb_SMC(period, path) = pBigLoss_cur;
        SimProbVar_SMC(period, path) = (pBigLoss_cur*(1-pBigLoss_cur))/nPrdnPt_cur;
        
        % OIS and MIS estimators are calculated in the following codes
        U_0t_cur = U_0t(BigLossInd,:);
        Vt_cur = Vt_Firm(BigLossInd,:);
        
        BoundaryInd(period+1) = BoundaryInd(period) + nBigLoss_cur;
        Ut_MIS(BoundaryInd(period):BoundaryInd(period+1)-1,:) = U_0t_cur;
        Vt_MIS(BoundaryInd(period):BoundaryInd(period+1)-1,:) = Vt_cur;
        
        MU_MIS(period, :) = MU_cur;
        SIGMA_MIS(period, :) = SIGMA_cur;
        
        % update copula and marginal pdf for ALL desn pts and the CURRENT
        % stock price scenaior
        MarginPDF_cur = zeros(BoundaryInd(period+1)-1, ExParam.nAsset);
        Vt_all = Vt_MIS(1:BoundaryInd(period+1)-1,:);
        U_0t_all = Ut_MIS(1:BoundaryInd(period+1)-1,:);
        for asset = 1:ExParam.nAsset
            MarginPDF_cur(:, asset) = lognpdf(Vt_all(:, asset), MU_cur(asset), SIGMA_cur(asset));
            U_0t_all(:, asset) = logncdf(Vt_all(:, asset), MU_cur(asset), SIGMA_cur(asset));
        end
        if strcmp(Port.copula, 't')
            CopulaPDF_cur = copulapdf(Port.copula, U_0t_all, Port.Cor, Port.df);
        elseif strcmp(Port.copula, 'Gaussian')
            CopulaPDF_cur = copulapdf(Port.copula, U_0t_all, Port.Cor);
        else
            error('Please check copula type');
        end
        CopulaPDF_MIS(1:BoundaryInd(period+1)-1, period) = CopulaPDF_cur;
        MarginPDF_MIS(1:BoundaryInd(period+1)-1, period) = prod(MarginPDF_cur, 2);
        
        for hist = 1:(period-1)
            MU_hist = MU_MIS(hist,:);
            SIGMA_hist = SIGMA_MIS(hist,:);
            
            U_0t_hist = zeros(nBigLoss_cur, ExParam.nAsset);
            MarginPDF_hist = zeros(nBigLoss_cur, ExParam.nAsset);
            for asset = 1:ExParam.nAsset
                MarginPDF_hist(:, asset) = lognpdf(Vt_cur(:, asset), MU_hist(asset), SIGMA_hist(asset));
                U_0t_hist(:,asset) = logncdf(Vt_cur(:, asset), MU_hist(asset), SIGMA_hist(asset));
            end
            if strcmp(Port.copula, 't')
                CopulaPDF_hist = copulapdf(Port.copula, U_0t_hist, Port.Cor, Port.df);
            elseif strcmp(Port.copula, 'Gaussian')
                CopulaPDF_hist = copulapdf(Port.copula, U_0t_hist, Port.Cor);
            else
                error('Please check copula type');
            end
            CopulaPDF_MIS(BoundaryInd(period):BoundaryInd(period+1)-1, hist) = CopulaPDF_hist;
            MarginPDF_MIS(BoundaryInd(period):BoundaryInd(period+1)-1, hist) = prod(MarginPDF_hist, 2);
        end
        
        % OIS estimator
        NewLoss = 0;
        for hist = 1:period
            Jacob_num = CopulaPDF_MIS(BoundaryInd(hist):BoundaryInd(hist+1)-1, period)...
                        .*MarginPDF_MIS(BoundaryInd(hist):BoundaryInd(hist+1)-1, period);
            Jacob_den = CopulaPDF_MIS(BoundaryInd(hist):BoundaryInd(hist+1)-1, hist)...
                        .*MarginPDF_MIS(BoundaryInd(hist):BoundaryInd(hist+1)-1, hist);
            NewLoss = NewLoss + sum(Jacob_num./Jacob_den) /(period*ExParam.nPrdnPt); 
        end
        SimProb_OIS(period, path) = NewLoss;
        
        % MIS estimator
        Jacob_cur = CopulaPDF_MIS(1:BoundaryInd(period+1)-1, period).*MarginPDF_MIS(1:BoundaryInd(period+1)-1, period);
        Jacob_mix = sum(CopulaPDF_MIS(1:BoundaryInd(period+1)-1, 1:period).*MarginPDF_MIS(1:BoundaryInd(period+1)-1, 1:period),2)/period;
        
        NewLoss = Jacob_cur./Jacob_mix;
        pBigLoss_MIS = sum(NewLoss)/(period*ExParam.nPrdnPt);  % the MIS estimate
        
        SimProb_MIS(period, path) = pBigLoss_MIS;

    end
    
    
    toc
end
toc
MSE_SMC = (TrueProb(:,1:ExParam.nPaths)-SimProb_SMC(:,1:ExParam.nPaths)).^2;
MSE_OIS = (TrueProb(:,1:ExParam.nPaths)-SimProb_OIS(:,1:ExParam.nPaths)).^2;
MSE_MIS = (TrueProb(:,1:ExParam.nPaths)-SimProb_MIS(:,1:ExParam.nPaths)).^2;

Y_SMC = mean(MSE_SMC,2);
Y_OIS = mean(MSE_OIS,2);
Y_MIS = mean(MSE_MIS,2);

E_SMC = 1.96*std(MSE_SMC,0,2)/sqrt(ExParam.nPaths);
E_OIS = 1.96*std(MSE_OIS,0,2)/sqrt(ExParam.nPaths);
E_MIS = 1.96*std(MSE_MIS,0,2)/sqrt(ExParam.nPaths);

figure
ax = axes();
errorbar(Y_SMC,E_SMC);
hold on
errorbar(Y_OIS,E_OIS);
errorbar(Y_MIS,E_MIS);
