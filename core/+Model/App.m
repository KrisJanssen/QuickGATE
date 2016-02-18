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
        NewFile
    end
    
    methods
        function obj = App(filemanager)
            obj.filemanager = filemanager;
            
            % Observe model changes and update view accordingly.
            addlistener(filemanager, 'files', 'PostSet', ...
                @obj.onModelChanged);
        end
        
        function onModelChanged(obj, ~, ~)
            notify(obj, 'NewFile');
            test = size(obj.filemanager.files)

        end
        
        function out = get.files(obj)
            out = obj.filemanager.files;
        end
    end
    
end

