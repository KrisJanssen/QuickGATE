classdef FileManager < handle
    %FILEMANAGER The FM View.
    %   TODO: Add.
    
    properties
        handles
        model
    end
    
    methods
        
        function obj = FileManager(model)
            
            obj.model = model;
            
            % Build GUI, i.e. add all ui elements and pass back the necessary handles.
            obj.initGUI();
            
            % Initial update.
            obj.onModelChanged();
            
            % Observe model changes and update view accordingly.
            addlistener(model, 'files', 'PostSet', ...
                @obj.onModelChanged);
            
        end
        
        function initGUI(obj)
            % Gets the px coordinates delimiting screen area as:
            % Left Bottom Width Height
            scrsz = get(groot,'ScreenSize');
            
            hFig = figure(...
                'Menubar','none', ...
                'Position',[1 scrsz(4) - 120 scrsz(3)/4 scrsz(4)/10], ...
                'Name', 'File Manager', ...
                'NumberTitle', 'off');
            
            vBox = uix.VBox('Parent', hFig);
            
            hBtnfile = uicontrol('Parent', vBox, ...
                'Style', 'pushbutton', ...
                'String', 'Open');
            hLstfile = uicontrol('Parent', vBox, ...
                'Style', 'listbox', ...
                'String', {'No File', 'No File'});
            
            obj.handles = struct( ...
                'fig', hFig, ...
                'btnfile', hBtnfile, ...
                'lstfile', hLstfile);
            
            movegui(hFig, 'northwest');
            
        end
        
        function onModelChanged(obj, ~, ~)
            set(obj.handles.lstfile, 'String', obj.model.files);
            
        end
    end
end

