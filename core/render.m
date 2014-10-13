function [ gmin, gmax ] = render(hObject, updateaxes)
%profile('on', '-detail', 'builtin')
% Get all handles.
handles = guidata(hObject);

switch updateaxes
    case 'left'
        gmin = str2double(get(handles.lowGateLeft, 'string'));
        gmax = str2double(get(handles.highGateLeft, 'string'));
    case 'right'
        gmin = str2double(get(handles.lowGateRight, 'string'));
        gmax = str2double(get(handles.highGateRight, 'string'));
    otherwise
        gmin = 0;
        gmax = 100;
end

[~,~,ext] = fileparts(filename);

switch ext
    case '.dat'
        
    case '.t3r'
        [ ImageData, gmin, gmax, SYNCrate, messages ] = ...
            ExtractImageT3R(strcat(handles.path, handles.file), gmin, gmax);      
end

updateUI(hObject, ...
    ImageData{1,1}(:,:), ...
    gmin, ...
    gmax, ...
    messages, ...
    updateaxes);

handles.rawdata = ImageData;

handles.SYNCrate = SYNCrate;

guidata(hObject, handles);
