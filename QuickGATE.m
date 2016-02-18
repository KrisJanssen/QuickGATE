function QuickGate()

% Make sure the workspace is empty.
clear;
close all;

% Add necessary paths.
% TODO: Find out how to handle '+XXXX' style directories.
addpath_recurse('refs');
addpath_recurse('core');

% Create a Filemanager model.
FMmodel = Model.FileManager;
 
% Pass the model to the view.
FMview = View.FileManager(FMmodel);
 
% Pass the view to the controller.
FMcontroller = Controller.FileManager(FMview);

% Create the application model and it's controller.
Application = Model.App(FMmodel);
AppCtrl = Controller.App(Application);

% ... Off to the races!
