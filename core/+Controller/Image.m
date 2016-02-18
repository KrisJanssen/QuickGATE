classdef Image < handle
    %IMAGE The Image Controller.
    %   TODO: Add.
    
    properties
        model;
        view;
    end
    
    methods
        function obj = Image(view)
            obj.view = view;
            obj.model = view.model;
            
            % Set FM callbacks and provide the respective models as 
            % arguments.
            set(view.handles.btnup, 'Callback', {@obj.onFwdBack, 1})
            set(view.handles.btndwn, 'Callback', {@obj.onFwdBack, -1})
            set(view.handles.edtfr, 'Callback', {@obj.onFrameEnter})
            set(view.handles.edtgmin, 'Callback', {@obj.onGateEnter})
            set(view.handles.edtgmax, 'Callback', {@obj.onGateEnter})
            set(view.handles.edtsmin, 'Callback', {@obj.onGateEnter})
            set(view.handles.edtsmax, 'Callback', {@obj.onGateEnter})
            set(view.handles.chkbidir, 'Callback', {@obj.onGateEnter})
        end
        
        function onFwdBack(obj, sender, evdata, data)
            newval = obj.model.frame + data;
            if (newval <= 1)
                obj.model.frame = 1;
            else
                obj.model.frame = newval;
            end
            
            % Let the model fire it's dirty event.
            obj.model.dirty();
        end
        
        function onFrameEnter(obj, sender, evdata, data)
            newval = get(sender,'String');
            if (newval <= 1)
                obj.model.frame = 1;
            else
                obj.model.frame = newval;
            end
            
            obj.model.dirty();
        end
        
        function onGateEnter(obj, sender, evdata, data)
            obj.model.gate = [ ...
                str2double(get(obj.view.handles.edtgmin,'String')), ...
                str2double(get(obj.view.handles.edtgmax,'String'))];
            obj.model.disprange = [ ...
                str2double(get(obj.view.handles.edtsmin,'String')), ...
                str2double(get(obj.view.handles.edtsmax,'String'))];
            obj.model.bidir = get(obj.view.handles.chkbidir,'Value');
            
            % Let the model fire it's dirty event.
            % We only want to be doing this after all model properties have
            % been set.
            obj.model.dirty();
        end
    end
    
end

