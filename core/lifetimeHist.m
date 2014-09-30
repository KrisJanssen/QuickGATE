function [ output_args ] = lifetimeHist( data, bins )
%LIFETIMEHIST Summary of this function goes here
%   Detailed explanation goes here

% Consolidate start-stop times.
startstop_ns = vertcat(data{:,:}) * 1E9;

% Plot the histogram.
histData = hist(startstop_ns,bins);

% We only want to fit the decay part of the curve.
fitStart = find(histData == max(histData), 1);
fitEnd = round(bins * 0.9);

% Fit exp1 and exp2.
fitSingle = fit((fitStart:fitEnd)',histData(fitStart:fitEnd)','exp1')
fitDouble = fit((fitStart:fitEnd)',histData(fitStart:fitEnd)','exp2')

% Generate a figure.
figure;
hold on

% Plot the histogram.
plot(1:bins,histData);

% Plot both fits.
plot(fitSingle,'-or');
plot(fitDouble,'-xg');

end

