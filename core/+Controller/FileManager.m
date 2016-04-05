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
            set(view.handles.btnfile, 'Callback', {@obj.onPushFile})
            set(view.handles.btnclose, 'Callback', {@obj.onPushClose})
            set(view.handles.btnshow, 'Callback', {@obj.onPushVisible})
            set(view.handles.lstfile, 'Callback', {@obj.onList})
        end
        
        function onList(obj, sender, ~)
            obj.model.selected = get(sender,'Value');
        end
        
        function onPushFile(obj, ~, ~)
            obj.model.OpenFile();
        end
        
        function onPushClose(obj, ~, ~)
            obj.model.CloseFile(obj.model.selected);
        end
        
        function onPushVisible(obj, ~, ~)
            % TODO: implement
        end
    end
    
end

