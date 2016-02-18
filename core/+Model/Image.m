classdef Image < handle
    %IMAGE The Image Model.
    %   TODO: Add.
    
    properties (SetObservable = true)
        source
        tshift = 0.0;
        gate = [0 100]; 
        frame = 1;
        disprange = [0 100];
        bidir = 0;
        noframes = 1;
    end
    
    events
        Dirty
    end
    
    methods
        function obj = Image()
        end
        
        function set.gate(obj, gateIn)
            if size(gateIn) ~= [1,2]
                error('Invalid input!')
            elseif gateIn(1) > gateIn(2)
                gateIn = [ gateIn(2) gateIn(1)];
            end
            
            obj.gate = gateIn;
        end
        
        function set.source(obj,sourceIn)
            obj.source = sourceIn;
%             if isa(sourceIn, 'Data.TCSPCImageData')
%                 obj.source = sourceIn;
%             else
%                 obj.source = 0;
%             end
        end
        
        function dirty(obj)
            notify(obj, 'Dirty')
        end
        
        function image = render(obj)
%             % Get the desired frame.
%             data = obj.source.getframe(obj.frame, obj.tshift);
%             % Allocate space for the image.
%             image = zeros(size(data));
%             % Apply gate and build image.
%             for i=1:1:size(data, 1)
%                 image(i,:) = cell2mat(cellfun( ...
%                     @(x){sum(x >= obj.gate(1) & x <= obj.gate(2))}, ...
%                     data(i,:)));
%             end

              [ imagefull, obj.noframes, ~, ~ ] = ...
                  ExtractImagePTU( ...
                  obj.source, ...
                  obj.frame, ...
                  obj.gate(1,1), ...
                  obj.gate(1,2), ...
                  0, ...
                  obj.bidir);
              
              image = imagefull{1,1};
        end
    end
    
end

