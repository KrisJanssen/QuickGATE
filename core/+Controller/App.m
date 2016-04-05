classdef App < handle
    %APP The Application Controller.
    %   TODO: Add.
    
    properties
        model
        images
    end
    
    methods
        function obj = App(model)
            obj.model = model;
            obj.images = mcodekit.list.dl_list();
            
            % Observe File Manager changes and update accordingly.
            addlistener(model.filemanager, 'FileOpened', @obj.onFileOpened);
            addlistener(model.filemanager, 'FileClosed', @obj.onFileClosed);
        end
        
        function onFileClosed(obj, ~, ~)
            delete(obj.images.get_key(obj.model.filemanager.changedfile));
            obj.images.remove_key(obj.model.filemanager.changedfile)
        end
        
        function onFileOpened(obj, ~, ~)
            hImModel = Model.Image;
            hImModel.source = obj.model.files{end:end};
            hImView = View.Image(hImModel);
            hImCtrl = Controller.Image(hImView);
            obj.images.append_key(hImCtrl);
        end
    end
    
end

