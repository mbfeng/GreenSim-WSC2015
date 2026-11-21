%% Clean up workspace and fix random seed for simulation
clear all; 
% close all; 
clc; rng(0);
Color = get(gca,'ColorOrder');
% %% Example one, estimate E[sin(Y)] where 
% %  -- Y \sim N(Xk, 1), Xk is simple random walk, 
% %%%%%% Plot 1, illustration of experiments in the first two periods
% y=-5:0.1:5;  % range of plot
% Minus = @(y) normpdf(y+1); % density of N(-1, 1)
% Plus = @(y) normpdf(y-1); % density of N(1, 1)
% Funcy = @(y) 0.75-0.25*cos(2*y); % F(y), the inner random function
% SampSize = 5;
% 
% % -- Day 1, X1 = -1
% figure
% X1 = -1;
% Samp1 = normrnd(X1, 1, [SampSize, 1]);
% plot(y, Minus(y), y, Funcy(y),'LineWidth',3);
% hold on 
% stem(Samp1, Funcy(Samp1),':k','LineWidth',1,'MarkerSize',8);
% str1 = 'h_{-1}(y)';
% text(0.5,0.15,str1,'FontSize',14,'FontWeight','bold');
% str1 = 'F(y)';
% text(-2.5,0.65,str1,'FontSize',14,'FontWeight','bold');
% xlim([-5,5]);
% xlabel('support of ramdom scenario y');
% title('Experiment at time 1 given state X_1=-1','FontSize',15,'FontWeight','bold');
% set(gca,'FontSize',14,'FontWeight','bold');
% 
% % -- Day 2, X2 = 1
% figure
% X2=1;
% Samp2 = normrnd(X2, 1, [SampSize, 1]);
% plot(y, Plus(y), y, Funcy(y),'LineWidth',3);
% hold on 
% plot(Samp1, Funcy(Samp1), '*k','MarkerSize',8);
% stem(Samp2, Funcy(Samp2),':k','LineWidth',1,'MarkerSize',8);
% str2 = 'h_{1}(y)';
% text(-2,0.15,str2, 'FontSize',14,'FontWeight','bold');
% str2 = 'F(y)';
% text(-2.5,0.65,str2,'FontSize',14,'FontWeight','bold');
% xlim([-5,5]);
% xlabel('support of ramdom scenario y');
% title('Experiment at time 1 given state X_2=1','FontSize',15,'FontWeight','bold');
% set(gca,'FontSize',14,'FontWeight','bold');
% 
% %%%%%% Plot 2, likelihood ratios of OIS and MIS
% figure
% % Samp1 = normrnd(X1, 1, [20, 1]);
% % Samp2 = normrnd(X2, 1, [20, 1]);
% LROIS1 = normpdf(Samp1, X2, 1)./normpdf(Samp1, X1, 1); 
% LROIS2 = normpdf(Samp2, X2, 1)./normpdf(Samp2, X2, 1);
%     
% 
% LRMIS1 = normpdf(Samp1, X2, 1)./(0.5*(normpdf(Samp1, X1, 1)...
%                                       + normpdf(Samp1, X2, 1))); 
% LRMIS2 = normpdf(Samp2, X2, 1)./(0.5*(normpdf(Samp2, X1, 1)...
%                                       + normpdf(Samp2, X2, 1))); 
% bp = boxplot([[LRMIS1; LRMIS2],[LROIS1; LROIS2]],'orientation', 'horizontal', 'symbol', 'x');
% xlabel('Likelihood ratios','FontSize',14,'FontWeight','bold');
% set(bp(:,:),'linewidth',4);
% set(gca,'FontSize',18,'FontWeight','bold','YTickLabel',{'MIS','OIS'});

%% Example 2, credit risk evaluation
% % --- Type 1
% rng(18);
% S1 = 100; 
% mu1 = 0.15; sigma1 = 0.3; 
% t = 0.5; 
% nsteps = 500; npaths = 3;
% dt = t/nsteps; 
% 
% muN = (mu1 - sigma1^2/2);
% sigmaN = sigma1;
% 
% exponent = normrnd(muN*dt,sigmaN*sqrt(dt), [nsteps, npaths]);
% exponent = [zeros(1,npaths); exponent];
% exponent = cumsum(exponent);
% 
% St1 = S1*exp(exponent);
% figure(1)
% x = 0:dt:t; y = St1; z = zeros(length(St1),1);
% plot3(x, y, z,'LineWidth',3);
% grid on
% zlim([0,1])
% ylim([70,130])
% hold on
% 
% S = 60:0.5:140;
% x = lognpdf(S, log(S1) + muN*t, sigmaN*sqrt(t))*10 + t+0.1; y = S; z = 0*ones(length(S));
% plot3(x, y, z,'m','LineWidth',3);
% hold on
% 
% x = t*ones(npaths,1);  y = St1(end,:);	z = [0 0 1];
% stem3(x, y, z,'ok','LineWidth',3, 'MarkerSize', 10);
% 
% set(gca,'FontSize',14,'FontWeight','bold');
% xlabel('Projection Period','FontSize',14,'FontWeight','bold');
% ylabel('Asset Value','FontSize',14,'FontWeight','bold');
% zlabel('Function Value','FontSize',14,'FontWeight','bold');
% text(0.7, 100, 0, 'h_{x_1}(y)','FontSize',14,'FontWeight','bold');
% text(0, 110, 0, 'x_1 = 100','FontSize',14,'FontWeight','bold');
% 
% text(0.5, 107, 0, 'Y^{(1)}_{1}','FontSize',14,'FontWeight','bold');
% text(0.5, 87.5, 0, 'Y^{(2)}_{1}','FontSize',14,'FontWeight','bold');
% text(0.5, 77, 0, 'Y^{(3)}_{1}','FontSize',14,'FontWeight','bold');
% 
% text(0.51, 114, 0, 'F(Y^{(1)}_{1})','FontSize',14,'FontWeight','bold');
% text(0.51, 95, 0, 'F(Y^{(2)}_{1})','FontSize',14,'FontWeight','bold');
% text(0.51, 82.5, 1, 'F(Y^{(3)}_{1})','FontSize',14,'FontWeight','bold');
% view(-17,58)
% hold off
% 
% % ---------------------------------------------
% rng(10);
% S2 = 95; 
% mu1 = 0.15; sigma1 = 0.3; 
% t = 0.5; 
% nsteps = 500; npaths = 3;
% dt = t/nsteps; 
% 
% muN = (mu1 - sigma1^2/2);
% sigmaN = sigma1;
% 
% exponent = normrnd(muN*dt,sigmaN*sqrt(dt), [nsteps, npaths]);
% exponent = [zeros(1,npaths); exponent];
% exponent = cumsum(exponent);
% 
% St2 = S2*exp(exponent);
% figure(2)
% x = 0:dt:t; y = St2; z = zeros(length(St2),1);
% plot3(x, y, z,'LineWidth',3);
% grid on
% zlim([0,1])
% ylim([70,130])
% hold on
% x = lognpdf(S, log(S1) + muN*t, sigmaN*sqrt(t))*10 + t+0.1; y = S; z = 0*ones(length(S));
% plot3(x, y, z,'-.r','LineWidth',3);
% 
% S = 60:0.5:140;
% % x = 0.5*ones(length(S)); y = S; z = lognpdf(S, log(S1) + muN*t, sigmaN*sqrt(t));
% x = lognpdf(S, log(S2) + muN*t, sigmaN*sqrt(t))*10 + t+0.1; y = S; z = 0*ones(length(S));
% plot3(x, y, z,'m','LineWidth',3);
% hold on
% 
% x = t*ones(npaths,1);  y = St1(end,:);	z = [0 0 1];
% stem3(x, y, z,'*k','LineWidth',1.5, 'MarkerSize', 10);
% 
% x = t*ones(npaths,1);  y = St2(end,:);	z = [1 0 0];
% stem3(x, y, z,'ok','LineWidth',3, 'MarkerSize', 10);
% 
% set(gca,'FontSize',14,'FontWeight','bold');
% xlabel('Projection Period','FontSize',14,'FontWeight','bold');
% ylabel('Asset Value','FontSize',14,'FontWeight','bold');
% zlabel('Function Value','FontSize',14,'FontWeight','bold');
% text(0.7, 100, 0, 'h_{x_1}(y)','FontSize',14,'FontWeight','bold');
% text(0.7, 95, 0, 'h_{x_2}(y)','FontSize',14,'FontWeight','bold');
% text(0, 102, 0, 'x_2 = 95','FontSize',14,'FontWeight','bold');
% 
% text(0.5, 115, 0, 'Y^{(1)}_{2}','FontSize',14,'FontWeight','bold');
% text(0.52, 95, 0, 'Y^{(2)}_{2}','FontSize',14,'FontWeight','bold');
% text(0.52, 83, 0, 'Y^{(3)}_{2}','FontSize',14,'FontWeight','bold');
% 
% text(0.51, 122, 0, 'F(Y^{(1)}_{2})','FontSize',14,'FontWeight','bold');
% text(0.5, 100, 0, 'F(Y^{(2)}_{2})','FontSize',14,'FontWeight','bold');
% text(0.51, 82.5, 1, 'F(Y^{(3)}_{2})','FontSize',14,'FontWeight','bold');
% view(-17,58)
% hold off
% ----- Type 2
% param;
% rng(17);
% nasset = 2;
% S1 = [100; 100]; 
% mu = [0.15; 0.10];     % drift 
% vol = [0.3; 0.2];     % volatility
% t = 0.5; 
% nsteps = 1; 
% dt = t/nsteps; 
% 
% muN = mu - vol.^2./2;
% sigmaN = vol;
% 
% npaths = 5;
% Paths = cell(npaths,1);
% St = zeros(npaths, nasset);
% 
% for i = 1:npaths
%     exponent =normrnd(0,1, [nsteps, nasset]);
%     exponent = ones(nsteps, nasset) * diag(muN) * dt...
%                 + exponent * diag(sigmaN) * sqrt(dt);
%     exponent = [zeros(1,nasset); exponent];
%     exponent = cumsum(exponent);
%     Paths{i} = exp(exponent) * diag(S1);
%     
%     St(i,:) = Paths{i}(end,:);
% end
% BigLossInd = LossAtt(St, Port) > Port.Threshold;
% 
% x = Paths{1}(:,1);  y = Paths{1}(:,2);  z = zeros(length(x));
% plot3(x, y , z, 'k')
% grid on;
% hold on;
% zlim([0,1])
% 
% for i = 2:npaths
%     x = Paths{i}(:,1);  y = Paths{i}(:,2);  z = zeros(length(x));
%     plot3(x, y , z, 'k')
% 
% end
% plot3(St(:,1), St(:,2), zeros(npaths,1), 'ok', 'MarkerSize', 15)
% 
% stem3(St(:,1), St(:,2), BigLossInd, '*b', 'MarkerSize', 10, 'LineWidth', 2)
% plot3(S1(1), S1(2), 0, 'pr', 'MarkerSize', 15, 'MarkerFaceColor', 'r')
% exponent = [zeros(1,npaths); exponent];
% exponent = cumsum(exponent);
% 
% St = S1*exp(exponent);

%% MSE plot 
load GreenSim_Oct20.mat
MSE_SMC = max(0,(TrueProb-SimProb_SMC).^2);
MSE_OIS = max(0,(TrueProb-SimProb_OIS).^2);
MSE_MIS = max(0,(TrueProb-SimProb_MIS).^2);

Y_SMC = mean(MSE_SMC,2);
Y_OIS = mean(MSE_OIS,2);
Y_MIS = mean(MSE_MIS,2);

E_SMC = 1.96*std(MSE_SMC,0,2)/sqrt(ExParam.nPaths);
E_OIS = 1.96*std(MSE_OIS,0,2)/sqrt(ExParam.nPaths);
E_MIS = 1.96*std(MSE_MIS,0,2)/sqrt(ExParam.nPaths);
close all
figure(3);
hold on
loglog(1:52,Y_SMC, '-','LineWidth',5, 'color', Color(6,:))
loglog(1:52,Y_OIS, ':', 'LineWidth',5, 'color', Color(2,:))
loglog(1:52,Y_MIS, '--', 'LineWidth',5, 'color', Color(4,:))

title('estimated current-state variance','Interpreter','Latex','Position',[8 5e-4],'FontSize',20,'FontWeight','bold')
% x = logspace(0,log(100)/log(10),20);
% y=(x.^(-1)*(Y_SMC(1)));
% loglog(x,y, '-', 'LineWidth',3, 'color', 'k')

xlim([0,53])
ylim([1e-6 1e-3])
% legend({'SMC','ILR','MLR'},'Interpreter','Latex', 'FontSize',18, 'Location','southwest','FontWeight','bold')
% errorbar(Y_SMC,E_SMC, '-','LineWidth',2, 'color', Color(6,:))
% errorbar(Y_OIS,E_OIS, ':', 'LineWidth',2, 'color', Color(2,:))
% errorbar(Y_MIS,E_MIS, '--', 'LineWidth',2, 'color', Color(4,:))

set(gca,'FontSize',15,'FontWeight','bold','xscale','log','yscale','log');
xlabel('Number of periods, $$n$$','Interpreter','Latex', 'FontSize',20,'FontWeight','bold')
% title('$$\hat{\sigma}^2_n$$','Interpreter','Latex', 'FontSize',20,'FontWeight','bold','rot',0)

hold off

% %% box plot
% figure(4)
% rng(8)
% mu = 0.15; sigma = 0.3; 
% t = 0.5; 
% npaths = 100;
% 
% S1 = 100;
% muN1 = log(S1) + (mu - sigma^2/2)*t;
% sigmaN1 = sigma*sqrt(t);
% exponent = normrnd(muN1,sigmaN1, [npaths, 1]);
% St1 = exp(exponent);
% 
% S2 = 95; 
% muN2 = log(S2) + (mu - sigma^2/2)*t;
% sigmaN2 = sigma*sqrt(t);
% exponent = normrnd(muN2, sigmaN2, [npaths, 1]);
% St2 = exp(exponent);
% 
% LROIS1 = lognpdf(St1, muN2, sigmaN2)./lognpdf(St1, muN1, sigmaN1);
% LROIS2 = lognpdf(St2, muN2, sigmaN2)./lognpdf(St2, muN2, sigmaN2);
% 
% LRMIS1 = lognpdf(St1, muN2, sigmaN2)./(0.5*(lognpdf(St1, muN1, sigmaN1) + lognpdf(St1, muN2, sigmaN2)));
% LRMIS2 = lognpdf(St2, muN2, sigmaN2)./(0.5*(lognpdf(St2, muN1, sigmaN1) + lognpdf(St2, muN2, sigmaN2)));
% 
% 
% bp = boxplot([[LRMIS1; LRMIS2],[LROIS1; LROIS2]],'orientation', 'horizontal', 'symbol', 'x');
% xlabel('Likelihood ratios','FontSize',14,'FontWeight','bold');
% set(bp(:,:),'linewidth',4);
% set(gca,'FontSize',18,'FontWeight','bold','YTickLabel',{'MIS','OIS'});
% 






