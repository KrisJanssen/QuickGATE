classdef Image < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable = true)
        isdirty = 0;
        source
        tshift = 0.0;
        gate = [0 100.0E-09]; 
        frame = 1;
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
            obj.flipdirty;
        end
        
        function set.source(obj,sourceIn)
            if isa(sourceIn, 'Data.TCSPCImageData')
                obj.source = sourceIn;
                obj.flipdirty;
            else
                obj.source = 0;
            end
        end
        
        function image = render(obj)
            % Get the desired frame.
            data = obj.source.getframe(obj.frame, obj.tshift);
            % Allocate space for the image.
            image = zeros(size(data));
            % Apply gate and build image.
            for i=1:1:size(data, 1)
                image(i,:) = cell2mat(cellfun( ...
                    @(x){sum(x >= obj.gate(1) & x <= obj.gate(2))}, ...
                    data(i,:)));
            end
        end
    end
    
    methods (Access = private)
        function flipdirty(obj)
            if obj.isdirty == 0
                obj.isdirty = 1;
            else
                obj.isdirty = 0;
            end
        end
        
    end
    
end

