% genpaths.m
% Generate sample paths for later simulations

param;

rng(0);     % random number seed
options = optimoptions('fsolve','TolFun',1e-16);
fun = @(x) exp(-Port.rf(2)*Port.T(2))*normcdf(-((log(x/Port.K(2))+(Port.rf(2)-Port.t(2)*Port.vol(2)^2)*Port.T(2))/(0.2*sqrt(Port.T(2)))))*Port.LGD(2);
Stock2Bound = fsolve(@(x)fun(x)-1,90,options);

TrueProb = zeros(ExParam.nPeriods, ExParam.nPaths);
SamPathsMu = zeros(ExParam.nPeriods*ExParam.nPaths, ExParam.nAsset);
Mu_t = (Port.mu - (Port.vol.^ 2) ./ 2) .* Port.t;
Sig_t = Port.vol .* sqrt(Port.t);
Mu_delt = (Port.mu - (Port.vol.^ 2) ./ 2) .* Port.dt;
Sig_delt = Port.vol .* sqrt(Port.dt);

for path = 1:ExParam.nPaths
    tic
    % simulate copula uniforms for delta-t's in the current sample path
    if strcmp(Port.copula, 't')
        U_delt = copularnd(Port.copula, Port.Cor, Port.df, ExParam.nPeriods - 1);
    elseif strcmp(Port.copula, 'Gaussian')
        U_delt = copularnd(Port.copula, Port.Cor, ExParam.nPeriods - 1);
    else
        error('Please check copula type');
    end
    
    % correlated N(0,1) r.v's
    Z_delt = norminv(U_delt);
    
    % simulate sample paths and the corresponding prdn pts (the UNIF(0,1))
    for period = 1:ExParam.nPeriods
        CurInd = (path-1)*ExParam.nPeriods + period;
        if period == 1
            SamPathsMu(CurInd,:) = log(Port.S0);
        else
            SamPathsMu(CurInd,:) = SamPathsMu(CurInd-1,:) + Mu_delt + Sig_delt.*Z_delt(period - 1, :);
        end
        
        U1 = logncdf(Port.K(1), SamPathsMu(CurInd,1) + Mu_t(1), Sig_t(1));
        U2 = logncdf(Stock2Bound, SamPathsMu(CurInd,2) + Mu_t(2), Sig_t(2));
        
        if strcmp(Port.copula, 't')
            TrueProb(period, path) = copulacdf(Port.copula, [U1,U2], Port.Cor,Port.df);
        elseif strcmp(Port.copula, 'Gaussian')
            TrueProb(period, path) = copulacdf(Port.copula, [U1,U2], Port.Cor);
        else
            error('Please check copula type');
        end
    end
    
    % calculate the "true" default probability by simulating large samples
%     for period = 1:ExParam.nPeriods
%         tic
%         
%                 % Generate correlated uniform(0,1) using copula
%                 if strcmp(Port.copula, 't')
%                     U_0t = copularnd(Port.copula, Port.Cor, Port.df, ExParam.nLargeSam);
%                 elseif strcmp(Port.copula, 'Gaussian')
%                     U_0t = copularnd(Port.copula,Port.Cor, ExParam.nLargeSam);
%                 else
%                     error('Please check copula type');
%                 end
%         
%                 Z_0t = norminv(U_0t);
%                 S0 = SamPaths(period, :, path);
%         
%                 Vt_Firm = bsxfun(@times, S0,...
%                     exp(bsxfun(@plus, (Port.mu - (Port.vol .^ 2) ./ 2) .* Port.t,...
%                     bsxfun(@times, Port.vol .* sqrt(Port.t), Z_0t))));
%         
%                 BigLossInd = LossAtt(Vt_Firm, Port) > Port.Threshold;
%                 TrueProbMC(period, path) = mean(BigLossInd);
%                 TrueProbVar(period, path) = var(BigLossInd)/(length(BigLossInd));
%         toc
%     end
    toc
end

clearvars -except Port ExParam SamPathsMu TrueProb Mu_t Sig_t
save('TrueProb_Oct19.mat')

