function [ ImageData, gmin, gmax, SYNCRate, messages ] = ExtractImageDAT( filepath, channel )
%EXTRACTIMAGE allows images to be extracted from PQ .t3r files.
%   Parameters:
%   
%   filepath:   string representing the full path to a .t3r file
%   gmin:       lower bound gating time in ns
%   gmax:       upper bound gating time in ns
%
%   Output:
%
%   ImageData:  pixelsX * pixelsY * 501 array of gated image data and full
%               start-stop times, grouped per pixel
%   gmin:       Actually applied lower bound gating time in ns (coerced)
%   gmax:       Actually applied upper bound gating time in ns (coerced)
%   messages:   Some information on the processed file

%% The actual rendering

fid=fopen(filepath);

fseek(fid, 98, 'bof');
ScanAxes = fread(fid,1,'uint16')
ImageWidthPx = fread(fid,1,'uint16')
ImageHeightPx =fread(fid,1,'uint16')
ImageDepthPx = fread(fid,1,'uint16')
XOverScanPx = fread(fid,1,'uint16')
YOverScanPx = fread(fid,1,'uint16')
ZOverScanPx = fread(fid,1,'uint16')
TimePPixel = fread(fid,1,'double')
XScanSizeNm = fread(fid,1,'double')
YScanSizeNm = fread(fid,1,'double')
ZScanSizeNm = fread(fid,1,'double')
InitXNm = fread(fid,1,'double')
InitYNm = fread(fid,1,'double')
InitZNm = fread(fid,1,'double')
iDataType = fread(fid,1,'uint16')
Channels = fread(fid,1,'uint16')
dBorderWidthX = fread(fid,1,'double')

fclose(fid);

headerlength = 4100/4;
T_data = T(headerlength+1:end);
data_length = length(T_data)/2;
T_data1 = T_data(1:data_length);
T_data2 = T_data(data_length+1:data_length*2);

d=sqrt(data_length);

if channel == 1
    z = reshape(T_data1,d,d)';
elseif channel == 2
    z = reshape(T_data2,d,d)';
end
    
out.im1 = z;
out.pathname = fullpath_filename;
out.name = filename;

% messages = strcat(...
%     sprintf('\nStatistics:\n'),...
%     sprintf('\n%u photon records', size(find(Valid),1)),...
%     sprintf('\n%u overflows', NoOfOverflows),...
%     sprintf('\n%u Line markers\n', pixels),...
%     sprintf('\n%5.2f (ms) Pixel Dwell time\n', double(PixelDuration) * 100E-6),...
%     sprintf('\n%5.2f (ns) MIN rev Start-Stop\n', MinimumReverseStartStop_ns),...
%     sprintf('\n%5.2f (ns) MAX rev Start-Stop\n', MaximumReverseStartStop_ns),...
%     sprintf('\n%5.2f (ns) MIN Start-Stop\n', MinimumStartStop_ns),...
%     sprintf('\n%5.2f (ns) MAX Start-Stop\n', MaximumStartStop_ns));

%profile viewer
%profile off
end