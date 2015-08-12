function varargout = QuickGATE(varargin)
% QUICKGATE MATLAB code for QuickGATE.fig
%      QUICKGATE, by itself, creates a new QUICKGATE or raises the existing
%      singleton*.
%
%      H = QUICKGATE returns the handle to a new QUICKGATE or the handle to
%      the existing singleton*.
%
%      QUICKGATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUICKGATE.M with the given input arguments.
%
%      QUICKGATE('Property','Value',...) creates a new QUICKGATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QuickGATE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QuickGATE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QuickGATE

% Last Modified by GUIDE v2.5 05-Aug-2015 21:02:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QuickGATE_OpeningFcn, ...
                   'gui_OutputFcn',  @QuickGATE_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before QuickGATE is made visible.
function QuickGATE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QuickGATE (see VARARGIN)

% Choose default command line output for QuickGATE
handles.output = hObject;
handles.fileName = [];
handles.path = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes QuickGATE wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Add path to external helper references.

addpath_recurse('refs');
addpath_recurse('core');

% --- Outputs from this function are returned to the command line.
function varargout = QuickGATE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnExport.
function btnExport_Callback(hObject, eventdata, handles)
% hObject    handle to btnExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iml = getimage(handles.axesLeft);
imr = getimage(handles.axesRight);
normiml = (iml-min(iml(:))) ./ (max(iml(:)-min(iml(:))));
normimr = (imr-min(imr(:))) ./ (max(imr(:)-min(imr(:))));

%cm = colormap(hot(256));
imwrite(normiml,['L_' get(handles.lowGateLeft, 'string') '_' get(handles.highGateLeft, 'string') '_' handles.fileName '.png'],'png')
imwrite(normimr,['R_' get(handles.lowGateLeft, 'string') '_' get(handles.highGateLeft, 'string') '_' handles.fileName '.png'],'png')


% --- Executes on button press in btnGateOne.
function btnGateOne_Callback(hObject, eventdata, handles)
% hObject    handle to btnGateOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

render(hObject, 'left');

% --- Executes on button press in btnGateTwo.
function btnGateTwo_Callback(hObject, eventdata, handles)
% hObject    handle to btnGateTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

render(hObject, 'right');


function lowGateLeft_Callback(hObject, eventdata, handles)
% hObject    handle to lowGateLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowGateLeft as text
%        str2double(get(hObject,'String')) returns contents of lowGateLeft as a double


% --- Executes during object creation, after setting all properties.
function lowGateLeft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowGateLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function highGateLeft_Callback(hObject, eventdata, handles)
% hObject    handle to highGateLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highGateLeft as text
%        str2double(get(hObject,'String')) returns contents of highGateLeft as a double


% --- Executes during object creation, after setting all properties.
function highGateLeft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highGateLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowGateRight_Callback(hObject, eventdata, handles)
% hObject    handle to lowGateRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowGateRight as text
%        str2double(get(hObject,'String')) returns contents of lowGateRight as a double


% --- Executes during object creation, after setting all properties.
function lowGateRight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowGateRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function highGateRight_Callback(hObject, eventdata, handles)
% hObject    handle to highGateRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highGateRight as text
%        str2double(get(hObject,'String')) returns contents of highGateRight as a double


% --- Executes during object creation, after setting all properties.
function highGateRight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highGateRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uipushopen_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushopen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile('*.ptu;*.t3r','Select a file');

if path == 0
    return
else
    
    handles.path = path;
    handles.file = file;
    
    % Save variables for access by other callbacks.
    guidata(hObject, handles);
    
    % Render both axes.
    render(hObject, '');
    
end


% --- Executes on button press in btnColor.
function btnColor_Callback(hObject, eventdata, handles)
% hObject    handle to btnColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%colormapeditor
Y = improfile;
n = size(Y,1);
X = linspace(0,n*20,n).';
f = fit(X,Y,'gauss2');
figure
plot(X,Y)
figure 
plot(f,Y)

% --- Executes on button press in btnLTROI.
function btnLTROI_Callback(hObject, eventdata, handles)
% hObject    handle to btnLTROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get all handles.
handles = guidata(hObject);

% We will always define the ROI on the left axes.
axes(handles.axesLeft);

% Get an ROI.
h = imrect;

% If we previously defined an ROI, delete it.
if isfield(handles, 'rect')
    delete(handles.rect)
end

% Get the extents of the ROI returned as coordinates top left X, top left
% Y, width, height.
pos = int32(round(getPosition(h)));

x1 = pos(1,1);
x2 = pos(1,3) + x1 - 1;

y1 = pos(1,2);
y2 = pos(1,4) + y1 - 1;

% Store the handle to the just-defined ROI.
handles.rect = h;
guidata(hObject, handles);


lifetimeHist(handles.rawdata{1,2}(y1:y2,x1:x2), 4096, 1E9 / handles.SYNCrate);

function txtOutput_Callback(hObject, eventdata, handles)
% hObject    handle to txtOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtOutput as text
%        str2double(get(hObject,'String')) returns contents of txtOutput as a double

% --- Executes during object creation, after setting all properties.
function txtOutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnCrossSection.
function btnCrossSection_Callback(hObject, eventdata, handles)
% hObject    handle to btnCrossSection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

noOfSections= str2double(get(handles.txtSections, 'string'));
sectionWidth = str2double(get(handles.txtSectionWidth, 'string'));

% Operate on the left axes.
axes(handles.axesLeft);

% Let the user define a line on the image.
h = imline;

% Wait until the line is positioned correctly.
position = LinePoints2Row(wait(h));

% Generate two parallel lines.
LineRight = parallelLine(position, sectionWidth);
LineLeft = parallelLine(position, -sectionWidth);

% Generate the right line.
hr = imline(handles.axesLeft, Row2LinePoints(LineRight));

% Get the length and position of this line.
% TODO: clean up.
api = iptgetapi(hr);
linePosition = api.getPosition();
length = [ 0; edgeLength([ linePosition(1,:) linePosition(2,:) ])];
dist_steps = linspace(0, length(end), noOfSections);
pointsRight = interp1(length,linePosition,dist_steps);

hl = imline(handles.axesLeft, Row2LinePoints(LineLeft));

% Get the length and position of this line.
% TODO: clean up.
api = iptgetapi(hl);
linePosition = api.getPosition();
length = [ 0; edgeLength([ linePosition(1,:) linePosition(2,:) ])];
dist_steps = linspace(0, length(end), noOfSections);
pointsLeft = interp1(length,linePosition,dist_steps);

% We now have start and end points for the improfile function.
sectionStartPoints = [ pointsLeft(:,1) pointsRight(:,1) ];
sectionEndPoints = [ pointsLeft(:,2) pointsRight(:,2) ];

% We get the image from which we need to get sections.
iml = getimage(handles.axesLeft);
normiml = (iml-min(iml(:))) ./ (max(iml(:)-min(iml(:))));
imr = getimage(handles.axesRight);
normimr = (imr-min(imr(:))) ./ (max(imr(:)-min(imr(:))));

% Some tricks to apply improfile more than once.
I=1:size(sectionStartPoints,1);
Fl=@(i,j) improfile(normiml,sectionStartPoints(i,:) ,sectionEndPoints(i,:));
Fr=@(i,j) improfile(normimr,sectionStartPoints(i,:) ,sectionEndPoints(i,:));

sectionsl = arrayfun(Fl,I,I,'UniformOutput', false); 
sectionsr = arrayfun(Fr,I,I,'UniformOutput', false); 

% The sections. We also dump them to console...
sectionsArrayl = cell2mat(sectionsl);
sectionsArrayr = cell2mat(sectionsr);


avl = mean(sectionsArrayl, 2);
normavl = (avl-min(avl(:))) ./ (max(avl(:)-min(avl(:))));
avr = mean(sectionsArrayr, 2);
normavr = (avr-min(avr(:))) ./ (max(avr(:)-min(avr(:))));

x = 1:size(avl,1);
f = fit(x',normavl,'gauss2')


figure
hold on
plot(normavl,'-or');
plot(normavr,'-xb');
plot(f,'-.g');
hold off

sectionsArrayl = sectionsArrayl'
sectionsArrayr = sectionsArrayr'


function txtSections_Callback(hObject, eventdata, handles)
% hObject    handle to txtSections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSections as text
%        str2double(get(hObject,'String')) returns contents of txtSections as a double


% --- Executes during object creation, after setting all properties.
function txtSections_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSectionWidth_Callback(hObject, eventdata, handles)
% hObject    handle to txtSectionWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSectionWidth as text
%        str2double(get(hObject,'String')) returns contents of txtSectionWidth as a double


% --- Executes during object creation, after setting all properties.
function txtSectionWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSectionWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSCross.
function btnSCross_Callback(hObject, eventdata, handles)
% hObject    handle to btnSCross (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We get the image from which we need to get sections.
iml = getimage(handles.axesLeft);
normiml = (iml-min(iml(:))) ./ (max(iml(:)-min(iml(:))));

imr = getimage(handles.axesRight);
normimr = (imr-min(imr(:))) ./ (max(imr(:)-min(imr(:))));

% Operate on the left axes.
axes(handles.axesLeft);
[ ~, ~, sectionl, x, y ] = improfile;

sectionr = improfile(normimr,x,y);
normsectionl = (sectionl-min(sectionl(:))) ./ (max(sectionl(:)-min(sectionl(:))));
normsectionr = (sectionr-min(sectionr(:))) ./ (max(sectionr(:)-min(sectionr(:))));

x = 1:size(normsectionl,1);
f = fit(x',normsectionl,'gauss2');


figure
hold on
plot(normsectionl,'-xb');
plot(normsectionr,'--r');
plot(f,'-.g');
hold off


% --- Executes on button press in btnLifeTime.
function btnLifeTime_Callback(hObject, eventdata, handles)
% hObject    handle to btnLifeTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lifetimeHist(handles.rawdata{1,2}(1:end,1:end), 4096, 1E9 / handles.SYNCrate);


% --- Executes on button press in btnConfocal.
function btnConfocal_Callback(hObject, eventdata, handles)
% hObject    handle to btnConfocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = ExtractImageDAT(1); 

axes(handles.axesRight);
 imagesc(data);

% Save variables for access by other callbacks.
guidata(hObject, handles);


% --- Executes on button press in btnLifeTimePolyROI.
function btnLifeTimePolyROI_Callback(hObject, eventdata, handles)
% hObject    handle to btnLifeTimePolyROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get all handles.
handles = guidata(hObject);

% We will always define the ROI on the left axes.
axes(handles.axesLeft);

% If we previously defined a rectangular ROI, delete it.
if isfield(handles, 'rect')
    delete(handles.rect)
end


I = getimage(gca);

figure

bitmask = roipoly(I);

imshow(bitmask);

%test = handles.rawdata{1,2}(bitmask);

guidata(hObject, handles);


lifetimeHist(handles.rawdata{1,2}(bitmask), 4096, 1E9 / handles.SYNCrate);


% --- Executes on button press in btnLTColor.
function btnLTColor_Callback(hObject, eventdata, handles)
% hObject    handle to btnLTColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lifeTimeColor(handles.rawdata{1,2}(1:end,1:end), 4096, 1E9 / handles.SYNCrate);



function txtShift_Callback(hObject, eventdata, handles)
% hObject    handle to txtShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtShift as text
%        str2double(get(hObject,'String')) returns contents of txtShift as a double


% --- Executes during object creation, after setting all properties.
function txtShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
