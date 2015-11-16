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
        test = data_ns{line,pixel};
        if size(test, 1) > 25
            test2 = 1;
        end
        histData = histc(data_ns{line,pixel} * 1E9,edges)';
        
        %HistImage(line,pixel) = 1/mean(data_ns{line,pixel} * 1E9);
        nonz = find(histData);
        
        
        histData = histData(nonz);
        edgest = edges(nonz);
        
        if size(test, 1) > 25    
        test = 1;
        %histNORM = histData.' ./ max(max(histData.', 1)) ;
        %edgesTransp = edgest.' ;
        end
        %We only want to fit the decay part of the curve.
        %test = size(histData, 2);
        if size(histData, 2) > 5
            fitEnd = round(length(edgest) * 0.9);
            fitStart = find(histData == max(histData(1:fitEnd)), 1);
            if fitStart<fitEnd
                % Fit exp1 and exp2.
                fitSingle = fit(edgest(fitStart:fitEnd)',histData(fitStart:fitEnd)','exp1');
                c = coeffvalues(fitSingle);
                if (-1/c(2) < 18) && (-1/c(2) > 0)
                HistImage(line,pixel) = -1/c(2);
                else
                    HistImage(line,pixel) = 0;
                end
            end
        end
    end
end

figure
imagesc(HistImage(2:end-1,2:end-1))
%colormap(hsv)

end

