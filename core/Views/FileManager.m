function handles = FileManager(model)
%FILE Summary of this function goes here
%   Detailed explanation goes here

% Build GUI, i.e. add all ui elements and pass back the necessary handles.
handles = initGUI();

% Initial update.
onModelChanged(handles, model);

% Observe model changes and update view accordingly.
addlistener(model, 'fileleft', 'PostSet', ...
    @(o,e) onModelChanged(handles,e.AffectedObject));

addlistener(model, 'fileright', 'PostSet', ...
    @(o,e) onModelChanged(handles,e.AffectedObject));

end

function handles = initGUI()
% Gets the px coordinates delimiting screen area as:
% Left Bottom Width Height
scrsz = get(groot,'ScreenSize');

hFig = figure(...
    'Menubar','none', ...
    'Position',[1 scrsz(4) scrsz(3)/4 scrsz(4)/10], ...
    'Name', 'File Manager', ...
    'NumberTitle', 'off');

vBox = uix.VBox('Parent', hFig);

hBox1 = uix.HBox('Parent', vBox);
hBox2 = uix.HBox('Parent', vBox);

hBtnl = uicontrol('Parent', hBox1, ...
    'Style', 'pushbutton', ...
    'String', 'Open Left');
hLbll = uicontrol('Parent', hBox2, ...
    'Style', 'text', ...
    'String', 'No File');

hBtnr = uicontrol('Parent', hBox1, ...
    'Style', 'pushbutton', ...
    'String', 'Open Right');
hLblr = uicontrol('Parent', hBox2, ...
    'Style', 'text', ...
    'String', 'No File');

handles = struct( ...
'fig', hFig, ...
'btnleft', hBtnl, ...
'lblleft', hLbll, ...
'btnright', hBtnr, ...
'lblright', hLblr);

end

function onModelChanged(handles, model)

set(handles.lblleft, 'String', model.fileleft);
set(handles.lblright, 'String', model.fileright);

end

