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

% Last Modified by GUIDE v2.5 20-Sep-2014 16:32:27

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
handles = guidata(hObject);

 gmin = str2double(get(handles.lowGateLeft, 'string'));
 gmax = str2double(get(handles.highGateLeft, 'string'));

[imdata, gmin, gmax] = ExtractImage(strcat(handles.path, handles.filename), gmin * 1E-9, gmax * 1E-9);
    
    axes(handles.axesLeft);
    imagesc(imdata); 

% --- Executes on button press in btnGateTwo.
function btnGateTwo_Callback(hObject, eventdata, handles)
% hObject    handle to btnGateTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);

 gmin = str2double(get(handles.lowGateRight, 'string'));
 gmax = str2double(get(handles.highGateRight, 'string'));

[imdata, gmin, gmax] = ExtractImage(strcat(handles.path, handles.filename), gmin * 1E-9, gmax * 1E-9);
    
    axes(handles.axesRight);
    imagesc(imdata); 


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We set control positions using normalized (nz) coorsinates.
% Coordinates expressed as:
% origin (0,0) = bottom left
% width, heigt
setpos(handles.btnColor, '0.05nz 0.01nz 0.25nz 0.1nz');
setpos(handles.chkColorBar, '0.35nz 0.01nz 0.25nz 0.1nz');
setpos(handles.btnExport, '0.65nz 0.01nz 0.25nz 0.1nz');

setpos(handles.btnGateOne, '0.25nz 0.12nz 0.2nz 0.1nz');
setpos(handles.lowGateLeft, '0.05nz 0.12nz 0.1nz 0.1nz');
setpos(handles.highGateLeft, '0.15nz 0.12nz 0.1nz 0.1nz');

setpos(handles.btnGateTwo, '0.75nz 0.12nz 0.2nz 0.1nz');
setpos(handles.lowGateRight, '0.55nz 0.12nz 0.1nz 0.1nz');
setpos(handles.highGateRight, '0.65nz 0.12nz 0.1nz 0.1nz');

setpos(handles.axesLeft, '0.05nz 0.3nz 0.4nz 0.6nz');
setpos(handles.axesRight, '0.55nz 0.3nz 0.4nz 0.6nz');

axes(handles.axesRight);
axis square;
axes(handles.axesLeft);
axis square;


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
    handles = guidata(hObject);
    
    handles.filename = file;
    handles.path = path;
    
    [imdata, gmin, gmax] = ...
    ExtractImage(strcat(handles.path, handles.filename), 0, 1);
    
    axes(handles.axesLeft);
    imagesc(imdata); 
    colormap(hot);
    
    axes(handles.axesRight);
    imagesc(imdata); 
    colormap(hot);
    
    % Save variables for access by other callbacks.
    guidata(hObject, handles);
end


% --- Executes on button press in btnColor.
function btnColor_Callback(hObject, eventdata, handles)
% hObject    handle to btnColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colormapeditor


% --- Executes on button press in chkColorBar.
function chkColorBar_Callback(hObject, eventdata, handles)
% hObject    handle to chkColorBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkColorBar
if get(hObject,'Value')
    axes(handles.axesLeft);
    colorbar;
    axis square;
    axes(handles.axesRight);
    colorbar;
    axis square;
else
    axes(handles.axesLeft);
    colorbar('delete');
    axis square;

    axes(handles.axesRight);
    colorbar('delete');
    axis square;
end
