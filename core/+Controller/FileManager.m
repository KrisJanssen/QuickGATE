classdef FileManager < handle
    %FILEMANAGER The FM Controller.
    %   TODO: Add.
    
    properties
        model
        view
    end
    
    methods
        function obj = FileManager(view)
            obj.view = view;
            obj.model = view.model;
            
            % Set FM callbacks and provide the respective models as arguments.
            set(view.handles.btnfile, 'Callback', {@obj.onPush})
        end
        
        function onPush(obj, ~, ~)
            obj.model.OpenFile();
        end
    end
    
end

