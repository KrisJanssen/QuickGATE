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

% Last Modified by GUIDE v2.5 23-Sep-2014 18:19:42

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
addpath('refs');
addpath('refs/PQTH');
addpath('refs/uipos');
addpath('Utility');

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
axes(handles.axesRight);
img  = getframe(gca);
imwrite(img.cdata,['MyImage_'  datestr(clock,'ddmmyyyyHHMMSSAM') '.png'],'png')

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
[file, path] = uigetfile('*.t3r','Select the timeharp file');

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


% --- Executes on button press in chkColorBar.
function chkColorBar_Callback(hObject, eventdata, handles)
% hObject    handle to chkColorBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkColorBar
if get(hObject,'Value')
    axes(handles.axesLeft);
    colorbar('northoutside');
    axis square;
    axes(handles.axesRight);
    colorbar('northoutside');
    axis square;
else
    axes(handles.axesLeft);
    colorbar('delete');
    axis square;

    axes(handles.axesRight);
    colorbar('delete');
    axis square;
end


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

% The start-stop data is in the output of the render operation as a 3D
% matrix of dimensions : (pixelsX, pixelsY, 501) with the actual image data
% in (pixelsX, pixelsY, 1) and all start stop times in (:,:,2:501). We will
% now put the start-stop times for the ROI only in a linear array.
buffersize = pos(1,3) * pos(1,4) * 500;

startstops = zeros(buffersize, 1);

for i=pos(1,2):pos(1,2) + pos(1,4) - 1
   for j=pos(1,1):pos(1,1) + pos(1,3) - 1
       startstops((((i * j) - 1) * 500) + 1:(i * j * 500)) = handles.rawdata(i,j,2:end);
   end
end

% Only keep non-zero values and express them in ns.
startstop_ns = startstops(find(startstops)) * 1E9;

% Store the handle to the just-defined ROI.
handles.rect = h;
guidata(hObject, handles);

% Plot the histogram.
figure;
hist(startstop_ns,100);

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

function updateUI(hObject, imdata, gmin, gmax, output, updateaxes)

% Get all handles.
handles = guidata(hObject);

switch updateaxes
    case 'left'
        axes(handles.axesLeft);
        imagesc(imdata); 
        colormap(hot);
        set(handles.lowGateLeft, 'string', sprintf('%5.2f', gmin));
        set(handles.highGateLeft, 'string', sprintf('%5.2f', gmax));
 gmax = str2double(get(handles.highGateLeft, 'string'));
    case 'right'
        axes(handles.axesRight);
        imagesc(imdata);
        colormap(hot);
        set(handles.lowGateRight, 'string', sprintf('%5.2f', gmin));
        set(handles.highGateRight, 'string', sprintf('%5.2f', gmax));
    otherwise
        axes(handles.axesLeft);
        imagesc(imdata); 
        colormap(hot);
        set(handles.lowGateLeft, 'string', sprintf('%5.2f', gmin));
        set(handles.highGateLeft, 'string', sprintf('%5.2f', gmax));
        
        axes(handles.axesRight);
        imagesc(imdata);
        colormap(hot);
        set(handles.lowGateRight, 'string', sprintf('%5.2f', gmin));
        set(handles.highGateRight, 'string', sprintf('%5.2f', gmax));
end

% Show output to the user.
set(handles.txtOutput, 'string', output);

function [ gmin, gmax ] = render(hObject, updateaxes)
profile('on', '-detail', 'builtin')
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

[ ImageData, gmin, gmax, messages ] = ...
    ExtractImage(strcat(handles.path, handles.file), gmin, gmax);

updateUI(hObject, ...
    ImageData(:,:,1), ...
    gmin, ...
    gmax, ...
    messages, ...
    updateaxes);

handles.rawdata = ImageData;

guidata(hObject, handles);

profile off
profile viewer
