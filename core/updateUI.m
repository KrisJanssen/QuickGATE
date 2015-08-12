function updateUI(hObject, imdata, gmin, gmax, output, updateaxes)

% Get all handles.
handles = guidata(hObject);

switch updateaxes
    case 'left'
        axes(handles.axesLeft);
        imagesc(imdata); 
        colormap(hot);
        colorbar('northoutside');
        axis square;
        set(handles.lowGateLeft, 'string', sprintf('%5.2f', gmin));
        set(handles.highGateLeft, 'string', sprintf('%5.2f', gmax));
        gmax = str2double(get(handles.highGateLeft, 'string'));
    case 'right'
        axes(handles.axesRight);
        imagesc(imdata);
        colormap(hot);
        colorbar('northoutside');
        axis square;
        set(handles.lowGateRight, 'string', sprintf('%5.2f', gmin));
        set(handles.highGateRight, 'string', sprintf('%5.2f', gmax));
    otherwise
        axes(handles.axesLeft);
        imagesc(imdata); 
        colormap(hot);
        colorbar('northoutside');
        axis square;
        set(handles.lowGateLeft, 'string', sprintf('%5.2f', gmin));
        set(handles.highGateLeft, 'string', sprintf('%5.2f', gmax));
        
        axes(handles.axesRight);
        imagesc(imdata);
        colormap(hot);
        colorbar('northoutside');
        axis square;
        set(handles.lowGateRight, 'string', sprintf('%5.2f', gmin));
        set(handles.highGateRight, 'string', sprintf('%5.2f', gmax));
end

% Show output to the user.
set(handles.txtOutput, 'string', output);
