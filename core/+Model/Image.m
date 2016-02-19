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
        image = [];
        lifetimes = {};
        maxcount;
        mincount;
        
    end
    
    events
        Dirty
    end
    
    methods
        function obj = Image()
        end
        
        function out = get.maxcount(obj)
            if ~isempty(obj.image)
                out = max(max(obj.image(:)));
            else
                out = 0;
            end
        end
        
        function out = get.mincount(obj)
            if ~isempty(obj.image)
                out = min(min(obj.image(:)));
            else
                out = 0;
            end
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
            obj.dirty()
%             if isa(sourceIn, 'Data.TCSPCImageData')
%                 obj.source = sourceIn;
%             else
%                 obj.source = 0;
%             end
        end
        
        function dirty(obj)
            obj.render()
            notify(obj, 'Dirty')
        end
        
        function render(obj)
            
              [ imagefull, obj.noframes, ~, ~ ] = ...
                  ExtractImagePTU( ...
                  obj.source, ...
                  obj.frame, ...
                  obj.gate(1,1), ...
                  obj.gate(1,2), ...
                  0, ...
                  obj.bidir);
              
              obj.image = imagefull{1,1};
              obj.lifetimes = imagefull{1,2};
        end
    end
    
end

