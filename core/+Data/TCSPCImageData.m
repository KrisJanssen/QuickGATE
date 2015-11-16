classdef TCSPCImageData < handle
    %TCSPCImageData Abstract superclass representing TCSPC image data.
    %   An abstract class that represents a universal way to treat TCSPC
    %   based image data.
    
    properties (SetAccess = protected)
        framedata = {};
        frameindex = -1;
        ismultiframe = 0;
        path = '';
        pixels = [0, 0];
        tshift = 0;
    end
    
    properties (Abstract, SetAccess = protected)
        
        % Type is determined by the actual subclass.
        type
        
    end
    
    methods
        
        function obj = TCSPCImageData(path)
            if nargin == 0
                error('A path must be specified!')
            else
                obj.path = path;
            end
        end
        
        function data = frame(obj, idx, tshift)
            % We want to be lazy and only read from disk when needed.
            if (obj.frameindex == idx && obj.tshift == tshift)
                data = obj.framedata;
            else
                % Call the subclass method.
                data = obj.getframe(idx,tshift);
                obj.frameindex = idx;
                obj.tshift = tshift;
            end
        end
        
    end
    
    methods (Abstract)
        
        % The implementation of this method will depend on the
        % origin of the underlying file.
        getframe(obj, idx, tshift)

    end
    
end

