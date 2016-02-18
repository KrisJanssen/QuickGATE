classdef App < handle
    %APP The Application Controller.
    %   TODO: Add.
    
    properties
        model;
    end
    
    methods
        function obj = App(model)
            obj.model = model;
            % Observe model changes and update view accordingly.
            addlistener(model, 'NewFile', @obj.onNewFile);
        end
        
        function onNewFile(obj, ~, ~)
            ImModel = Model.Image;
            ImModel.source = obj.model.files{end:end};
            ImView = View.Image(ImModel);
            ImCtrl = Controller.Image(ImView);
        end
    end
    
end

