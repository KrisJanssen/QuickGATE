classdef Image < handle
    %IMAGE The Image View.
    %   TODO: Add.
    
    properties
        handles
        model
    end
    
    methods
        
        function obj = Image(model)
            
            obj.model = model;
            
            % Build GUI
            obj.initGUI();
            
            % Initial update
            obj.onModelChanged();
            
            % Observe model changes and update view accordingly
            addlistener(model, 'Dirty', ...
                @(o,e) onModelChanged);
            addlistener(model, 'frame', 'PostSet', ...
                @obj.onModelChanged);
            addlistener(model, 'gate', 'PostSet', ...
                @obj.onModelChanged);
            addlistener(model, 'disprange', 'PostSet', ...
                @obj.onModelChanged);
            
        end
        
        function initGUI(obj)
            % Gets the px coordinates delimiting screen area as:
            % Left Bottom Width Height
            scrsz = get(groot,'ScreenSize');
            
            hFig = figure(...
                'Menubar','none', ...
                'Position',[scrsz(3)/4  scrsz(4) / 4 scrsz(3)/2 scrsz(3)/2], ...
                'Name', 'Image', ...
                'NumberTitle', 'off');
            
            % Master panel
            hPanel = uix.Panel('Parent', hFig, ...
                'Padding', 20);
            % Master panel is divided in a 1 column grid with multple lines of
            % controls.
            hGrid = uix.Grid('Parent', hPanel, ...
                'Spacing', 20);
            
            % First the axes.
            hAxes = axes('Parent', uicontainer('Parent', hGrid));
            axis square;
            
            % Next, a row of buttons and labels.
            hBox2 = uix.HBox('Parent', hGrid);
            
            hGridGate = uix.Grid('Parent', hBox2, ...
                'Spacing', 5);
            
            hLblgmin = uicontrol('Parent', hGridGate, ...
                'Style', 'text', ...
                'String', 'Min gate (ns)');
            
            hLblgmax = uicontrol('Parent', hGridGate, ...
                'Style', 'text', ...
                'String', 'Max gate (ns)');
            
            hEdtgmin = uicontrol('Parent', hGridGate, ...
                'Style', 'edit', ...
                'String', '0');
            
            hEdtgmax = uicontrol('Parent', hGridGate, ...
                'Style', 'edit', ...
                'String', '100');
            
            hEdtsmin = uicontrol('Parent', hGridGate, ...
                'Style', 'edit', ...
                'String', '0');
            
            hEdtsmax = uicontrol('Parent', hGridGate, ...
                'Style', 'edit', ...
                'String', '100');
            
            uix.Empty( 'Parent', hGridGate )
            
            set(hGridGate, 'Widths', [ -1 -1 -1 ], 'Heights', [ -1 -1 ]);
            
            hBox3 = uix.HBox('Parent', hGrid);
            
            set(hGrid, 'Widths', [ -1 ], 'Heights', [ -1 -0.05 -0.05 ]);
            
            hBtndwn = uicontrol('Parent', hBox3, ...
                'Style', 'pushbutton', ...
                'String', 'Previous');
            
            hEdtfr = uicontrol('Parent', hBox3, ...
                'Style', 'edit', ...
                'String', '1');
            
            hBtnup = uicontrol('Parent', hBox3, ...
                'Style', 'pushbutton', ...
                'String', 'Next');
            
            obj.handles = struct( ...
                'fig', hFig, ...
                'axes', hAxes, ...
                'edtgmin', hEdtgmin, ...
                'edtgmax', hEdtgmax, ...
                'edtsmin', hEdtsmin, ...
                'edtsmax', hEdtsmax, ...
                'btnup', hBtnup, ...
                'edtfr', hEdtfr, ...
                'btndwn', hBtndwn);
            
        end
        
        function onModelChanged(obj, ~, ~)
            image = obj.model.render();
            Min = max(max(image(:))) * obj.model.disprange(1,1) / 100.0;
            Max = max(max(image(:))) * obj.model.disprange(1,2) / 100.0;
            set(obj.handles.fig, 'CurrentAxes', obj.handles.axes);
            imagesc(obj.model.render(), [ Min, Max ]);
            colorbar(obj.handles.axes);
            set(obj.handles.edtfr, 'String', obj.model.frame);
        end
        
    end
    
end