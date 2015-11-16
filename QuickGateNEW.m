function QuickGate()

% Cleanup.
clear;
close all;

% Add necessary paths.
% TODO: Find out how to handle '+XXXX' style directories.
addpath_recurse('refs');
addpath_recurse('core');

% Create a Filemanager model and it's view.
FMmodel = Model.FileManager;

% Pass the model to the view.
FMview = FileManager(FMmodel);

global IMLmodel
global IMLview

global IMRmodel 
global IMRview

IMLmodel = Model.Image;
IMLview = Image(IMLmodel);
IMRmodel = Model.Image;
IMRview = Image(IMRmodel);

% Set FM callbacks and provide the respective models as arguments.
set(FMview.btnleft, 'Callback', {@onPushLeft, FMmodel})
set(FMview.btnright, 'Callback', {@onPushRight, FMmodel})
set(IMLview.btnapply, 'Callback', {@onApply, FMmodel})
set(IMRview.btnapply, 'Callback', {@onApply, FMmodel})


end

% Callbacks have an argument list:
% Source
% EventData
% Optional arguments
function onPushLeft(~, ~, model)
[ model.fileleft, test ] = OpenFile;
IMLmodel.source = test;
end

function onPushRight(~, ~, model)
[ model.fileright, test ] = OpenFile;
IMRmodel.source = test;
end

function onApply(~, ~, model)
model.gate = [get(model.edtgmin, 'String') get(model.edtgmin, 'String')];
end
