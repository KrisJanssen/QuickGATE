classdef App < handle
    %APP The Application Model.
    %   TODO: Add.
    
    properties (SetObservable = true)
        files
        filemanager
    end
    
    properties (Access = private)
        map;
    end
    
    events
        FileOpen
        FileClose
    end
    
    methods
        
        % The App model binds all components together. Therefore we can
        % pass in all of its dependencies here such as e.g. a File Manager,
        % an ROI Manager or perhaps logging classes.
        function obj = App(filemanager)
            obj.filemanager = filemanager;
        end
        
        function out = get.files(obj)
            out = obj.filemanager.files;
        end
    end
    
end

