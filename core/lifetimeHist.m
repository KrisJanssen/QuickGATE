function [ output_args ] = lifetimeHist( data_ns, bins, syncperiod)
%LIFETIMEHIST Summary of this function goes here
%   Detailed explanation goes here

% Consolidate start-stop times.
startstop_ns = vertcat(data_ns{:,:}) * 1E9;

% Lifetime bin edges
edges = linspace(syncperiod / bins,syncperiod,bins);

% Plot the histogram.
histData = histc(startstop_ns,edges)';

histNORM = histData.' /norm(histData.') ;
edgesTransp = edges.' ;

nonz = find(histData);

histData = histData(nonz);
edges = edges(nonz);
histNORM = histData.' ./ max(max(histData.', 1)) ;
edgesTransp = edges.' ;

% We only want to fit the decay part of the curve.

fitEnd = round(length(edges) * 0.9);
fitStart = find(histData == max(histData(1:fitEnd)), 1);

% Fit exp1 and exp2.
fitSingle = fit(edges(fitStart:fitEnd)',histData(fitStart:fitEnd)','exp1')
fitDouble = fit(edges(fitStart:fitEnd)',histData(fitStart:fitEnd)','exp2')

%figure
%[ nel, cent ] = hist(startstop_ns,edges,100)

% Generate a figure.
figure;
% Plot the histogram.
% plot(edges,histData,'--b');
% x = edges';
% y = histData';
hold on
% Plot both fits.
plot(edges(fitStart:fitEnd),feval(fitSingle,edges(fitStart:fitEnd)),'-xr','LineWidth',2);
plot(edges(fitStart:fitEnd),feval(fitDouble,edges(fitStart:fitEnd)),'-^g','LineWidth',2);
%semilogy(fitDouble,'-xg');
% semilogy(fitSingle,'-or');
% semilogy(fitDouble,'-xg');

end

