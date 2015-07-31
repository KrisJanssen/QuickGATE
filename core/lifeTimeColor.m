function [ output_args ] = lifeTimeColor( data_ns, bins, syncperiod)
%LIFETIMEHIST Summary of this function goes here
%   Detailed explanation goes here

% The edges that can be used for all per-pixel histograms.
edges = linspace(syncperiod / bins,syncperiod,bins);

% The dimensions of our data set.
indexes = size(data_ns);

HistImage = zeros(indexes(1),indexes(2));

% Cycle through the data.
for line = 1:indexes(1)
    for pixel = 1:indexes(2)
        % Plot the histogram.
        %histData = histc(data_ns{line,pixel} * 1E9,edges)';
        
        HistImage(line,pixel) = 1/mean(data_ns{line,pixel} * 1E9);
        %nonz = find(histData);
            
        %histData = histData(nonz);
        %edges = edges(nonz);
        
        %histNORM = histData.' ./ max(max(histData.', 1)) ;
        %edgesTransp = edges.' ;
        % We only want to fit the decay part of the curve.
%         if size(histData, 2) > 0
%             fitEnd = round(length(edges) * 0.9);
%             fitStart = find(histData == max(histData(1:fitEnd)), 1);
%             if fitStart<fitEnd
%                 % Fit exp1 and exp2.
%                 fitSingle = fit(edges(fitStart:fitEnd)',histData(fitStart:fitEnd)','exp1');
%                 c = coeffvalues(fitSingle);
%                 HistImage(line,pixel) = c(2);
%             end
%         end
    end
end

figure
imagesc(HistImage(2:end-1,2:end-1))
colormap(hsv)

end

