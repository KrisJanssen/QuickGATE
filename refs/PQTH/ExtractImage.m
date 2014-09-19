function [ ImageData, gmin, gmax ] = ExtractImage( filepath, gmin, gmax )
%EXTRACTIMAGE allows images to be extracted from PQ .t3r files.
%   Detailed explanation goes here

%% Load some header info for debug display
% Demo for accessing TimeHarp TTTR data files (*.t3r) from MATLAB
% TimeHarp 200, Software version 6.x, Format version 6.0
% Tested with Matlab  6 and 7
% Peter Kapusta, PicoQuant GmbH, February 2009

% NOTE:
% TTTR records are written to [t3r file name].txt 
% we do not keep it in memory because of the huge amout of memory
% this would take in case of large files. Of course you can change this, 
% e.g. if your files are not too big. 
% Otherwise it is best process the data on the fly and keep only the results.


fprintf(1,'\n');

fid=fopen(filepath);


fprintf(1,'================================================================= \n');
fprintf(1,'  Content of %s : \n', filepath);
fprintf(1,'================================================================= \n');
fprintf(1,'\n');


%
% Read the TxtHdr
%

Ident = char(fread(fid, 16, 'char'));
fprintf(1,'Ident: %s\n', Ident);

FormatVersion = deblank(char(fread(fid, 6, 'char')'));
fprintf(1,'Format version: %s\n', FormatVersion);

if not(strcmp(FormatVersion,'6.0'))
   fprintf(1,'\n\n      Warning: This program is for version 6.0 only. Aborted.');
   STOP;
end;



CreatorName = char(fread(fid, 18, 'char'));
fprintf(1,'Creator name: %s\n', CreatorName);

CreatorVersion = char(fread(fid, 12, 'char'));
fprintf(1,'Creator version: %s\n', CreatorVersion);

FileTime = char(fread(fid, 18, 'char'));
fprintf(1,'File creation: %s\n', FileTime);

CRLF = char(fread(fid, 2, 'char'));

Comment = char(fread(fid, 256, 'char'));
fprintf(1,'Comment: %s\n', Comment);


%
% Read the BinHdr
%


NumberOfChannels = fread(fid, 1, 'int32');
fprintf(1,'Number of Channels: %d\n', NumberOfChannels);

NumberOfCurves = fread(fid, 1, 'int32');
fprintf(1,'Number of Curves: %d\n', NumberOfCurves);

BitsPerChannel = fread(fid, 1, 'int32');
fprintf(1,'Bits / Channel: %d\n', BitsPerChannel);

RoutingChannels = fread(fid, 1, 'int32');
fprintf(1,'Routing Channels: %d\n', RoutingChannels);

NumberOfBoards = fread(fid, 1, 'int32');
fprintf(1,'Number of Boards: %d\n', NumberOfBoards);

ActiveCurve = fread(fid, 1, 'int32');
fprintf(1,'Active Curve: %d\n', ActiveCurve);

MeasurementMode = fread(fid, 1, 'int32');
fprintf(1,'Measurement Mode: %d\n', MeasurementMode);

SubMode = fread(fid, 1, 'int32');
fprintf(1,'SubMode: %d\n', SubMode);

RangeNo = fread(fid, 1, 'int32');
fprintf(1,'Range No.: %d\n', RangeNo);

Offset = fread(fid, 1, 'int32');
fprintf(1,'Offset: %d ns \n', Offset);

AcquisitionTime = fread(fid, 1, 'int32');
fprintf(1,'Acquisition Time: %d ms \n', AcquisitionTime);

StopAt = fread(fid, 1, 'int32');
fprintf(1,'Stop at: %d counts \n', StopAt);

StopOnOvfl = fread(fid, 1, 'int32');
fprintf(1,'Stop on Overflow: %d\n', StopOnOvfl);

Restart = fread(fid, 1, 'int32');
fprintf(1,'Restart: %d\n', Restart);

DispLinLog = fread(fid, 1, 'int32');
fprintf(1,'Display Lin/Log: %d\n', DispLinLog);

DispTimeAxisFrom = fread(fid, 1, 'int32');
fprintf(1,'Display Time Axis From: %d ns \n', DispTimeAxisFrom);

DispTimeAxisTo = fread(fid, 1, 'int32');
fprintf(1,'Display Time Axis To: %d ns \n', DispTimeAxisTo);

DispCountAxisFrom = fread(fid, 1, 'int32');
fprintf(1,'Display Count Axis From: %d\n', DispCountAxisFrom); 

DispCountAxisTo = fread(fid, 1, 'int32');
fprintf(1,'Display Count Axis To: %d\n', DispCountAxisTo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:8
DispCurveMapTo(i) = fread(fid, 1, 'int32');
DispCurveShow(i) = fread(fid, 1, 'int32');
fprintf(1,'-------------------------------------\n');
fprintf(1,'            Curve No: %d\n', i-1);
fprintf(1,'               MapTo: %d\n', DispCurveMapTo(i));
fprintf(1,'                Show: %d\n', DispCurveShow(i));
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:3
ParamStart(i) = fread(fid, 1, 'float');
ParamStep(i) = fread(fid, 1, 'float');
ParamEnd(i) = fread(fid, 1, 'float');
fprintf(1,'-------------------------------------\n');
fprintf(1,'        Parameter No: %d\n', i-1);
fprintf(1,'               Start: %d\n', ParamStart(i));
fprintf(1,'                Step: %d\n', ParamStep(i));
fprintf(1,'                 End: %d\n', ParamEnd(i));
end;
fprintf(1,'-------------------------------------\n');
fprintf(1,'\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


RepeatMode = fread(fid, 1, 'int32');
fprintf(1,'Repeat Mode: %d\n', RepeatMode);

RepeatsPerCurve = fread(fid, 1, 'int32');
fprintf(1,'Repeat / Curve: %d\n', RepeatsPerCurve);

RepatTime = fread(fid, 1, 'int32');
fprintf(1,'Repeat Time: %d\n', RepatTime);

RepeatWait = fread(fid, 1, 'int32');
fprintf(1,'Repeat Wait Time: %d\n', RepeatWait);

ScriptName = setstr(fread(fid, 20, 'char'));
fprintf(1,'Script Name: %s\n', ScriptName);


%
% Read the BoardHdr
%

fprintf(1,'\n');
fprintf(1,'\n');
fprintf(1,'-------------------------------------\n');
fprintf(1,'            Board Header:            \n');
fprintf(1,'-------------------------------------\n');
fprintf(1,'\n');

HardwareIdent = char(fread(fid, 16, 'char'));
fprintf(1,'Hardware Identifier: %s\n', HardwareIdent);

HardwareVersion = char(fread(fid, 8, 'char'));
fprintf(1,'Hardware Version: %s\n', HardwareVersion);

Board_BoardSerial = fread(fid, 1, 'int32');
fprintf(1,'Board Serial Number: %d\n', Board_BoardSerial);

Board_CFDZeroCross = fread(fid, 1, 'int32');
fprintf(1,'CFD Zero Cross: %d mV\n', Board_CFDZeroCross);

Board_CFDDiscriminatorMin = fread(fid, 1, 'int32');
fprintf(1,'CFD Discriminator Min.: %d mV\n', Board_CFDDiscriminatorMin);

Board_SYNCLevel = fread(fid, 1, 'int32');
fprintf(1,'SYNC Level: %d mV\n', Board_SYNCLevel);

Board_CurveOffset = fread(fid, 1, 'int32');
fprintf(1,'Curve Offset: %d\n', Board_CurveOffset);

Board_Resolution = fread(fid, 1, 'float');
fprintf(1,'Resolution: %5.6f ns\n', Board_Resolution);


%
% Read the TTTRHdr
%


TTTRGlobclock = fread(fid, 1, 'int32');
fprintf(1,'TTTR Global Clock: %d ns\n', TTTRGlobclock);

ExtDevices = fread(fid, 1, 'int32');
fprintf(1,'Ext Devices: %d\n', ExtDevices);

Reserved1 = fread(fid, 1, 'int32');
fprintf(1,'Reserved1: %d\n', Reserved1);

Reserved2 = fread(fid, 1, 'int32');
fprintf(1,'Reserved2: %d\n', Reserved2);

Reserved3 = fread(fid, 1, 'int32');
fprintf(1,'Reserved3: %d\n', Reserved3);

Reserved4 = fread(fid, 1, 'int32');
fprintf(1,'Reserved4: %d\n', Reserved4);

Reserved5 = fread(fid, 1, 'int32');
fprintf(1,'Reserved5: %d\n', Reserved5);

SYNCRate = fread(fid, 1, 'int32');
fprintf(1,'SYNC Rate: %d Hz\n', SYNCRate);

AverageCFDRate = fread(fid, 1, 'int32');
fprintf(1,'Average CFD Rate: %d cps\n', AverageCFDRate);

StopAfter = fread(fid, 1, 'int32');
fprintf(1,'Stop After: %d ms \n', StopAfter);

StopReason = fread(fid, 1, 'int32');
fprintf(1,'Stop Reason: %d\n', StopReason);

NumberOfRecords = uint32(fread(fid, 1, 'int32'));
fprintf(1,'Number Of Records: %d\n', NumberOfRecords);

SpecHeaderLength = fread(fid, 1, 'int32');
fprintf(1,'Special Header Length: %d x 4 bytes\n', SpecHeaderLength);

%Special header for imaging 
SpecHeader = fread(fid, SpecHeaderLength, 'int32');

Ofltime = 0;
Photon = 0;
Overflow = 0;
Marker = 0;

%% The actual rendering

% Read the actual data from disk as uint32.
Data = uint32(fread(fid, 'uint32'));
fclose(fid);

% Extract rudimentary info from the data:
% 1) Time tag is an int representation of the event in terms of macro time.
% 2) Channel holds the REVERSE start-stop channel (i.e.) time bin.
% 3) Route holds routing information (no shit!)
% 4) Valid holds information on the type of data in Channel (1 = photon).
TimeTag = bitand(Data(:),65535);              %the lowest 16 bits
Channel = bitand(bitshift(Data(:),-16),4095); %the next 12 bits
Route   = bitand(bitshift(Data(:),-28),3);    %the next 2 bits
Valid   = logical(bitand(bitshift(Data(:),-30),1));    %the next bit

% We will store indices of markers only for later use. To do so, we check 
% which records are not valid, i.e. do not contain photon arrival data and 
% we check that a marker value exists.
LineMarkerIndices = find(~Valid & bitand(Channel,7) == 4);

% We assume square images so the number of lines is the number of pixels in
% each dimension.
pixels = size(LineMarkerIndices,1);

% We will construct an array with the absolute (relative to measurement 
% start) time tags.
AbsoluteTimeTag = TimeTag;
NoOfOverflows = 0;

% Reconstruct the absolute time tags along the experiment time axis. We
% need this to reconstruct the actual image. Once we have the absolute
% macro time, we can work out the delta between Frame trigger and the first
% line trigger, i.e. the time it takes to complete a scanline. 
%
% Moreover, having worked out the duration of the scanline, we can
% calculate back from the line marker such that we can easily get rid of
% the photons generated during the return of the galvo.
for i=1:1:NumberOfRecords
    AbsoluteTimeTag(i) = NoOfOverflows * 65536 + TimeTag(i);
    if bitand(Channel(i),2048)
        NoOfOverflows = NoOfOverflows + 1;
    end;
end;

% We get the specific indices of the first frame- and line markers. These
% are the invalid (no photons!) records of type marker with values 4 and 2 
% respectively. 
LineEnd = find(~Valid & bitand(Channel,7) == 4, 1);
LineStart = find(~Valid & bitand(Channel,7) == 2, 1);

% The line duration in as an integer time tag.
LineDuration = AbsoluteTimeTag(LineEnd) - AbsoluteTimeTag(LineStart);

% The duration of a pixel.
PixelDuration = round(LineDuration / pixels);

% Pre-allocate the image data store.
ImageData = zeros(pixels,pixels);

% Gating variables.

% Check we have sensible values for gating.
if gmin >= gmax
    return
end

MinimumBin = double(min(Channel(logical(Valid))));
MaximumBin = double(max(Channel(logical(Valid))));

AbsoluteMaxGate_ns = MinimumBin * Board_Resolution * 1E-09;

% If we exceed the maximally possible gating time, coerce to that value.
if gmax > AbsoluteMaxGate_ns
    gmax = AbsoluteMaxGate_ns;
end

% Photons that are closer than ca. 800 bins will actually be referenced to
% the next pulse so we need to substract 1.0/SYNCRate from their channel
% value.
ChannelCorrected_s = double(Channel);

for i=1:1:NumberOfRecords
    RevStartStopTime_s = double(Channel(i)) * Board_Resolution * 1E-09;
    if RevStartStopTime_s > 1.0 / SYNCRate
        ChannelCorrected_s(i) = 2.0 / SYNCRate - RevStartStopTime_s;
    else
        ChannelCorrected_s(i) = 1.0 / SYNCRate - RevStartStopTime_s;
    end
end;

% We get a logical indexer for the gating condition.
GatingLogical = ...
    (gmin <= ChannelCorrected_s) & ...
    (gmax >= ChannelCorrected_s);

% We will construct image pixel values by counting the number of photon
% records that fall in a certain time bin of duration PixelDuration. For
% the purpose, we will use find(). This can be time consuming and
% therefore, we would like to only search for such pixels in the actual
% line we are currently on.
%
% The very first line starts at frame marker and runs to the first line
% marker.
CurrentLineStart = LineStart;

% Cycle through the lines.
for i=1:1:pixels
    
    %Cycle through the pixels in each line.
    for j=1:1:pixels
        % The end time of pixel.
        pend = AbsoluteTimeTag(LineMarkerIndices(i)) - ...
            (PixelDuration * (j - 1));
        
        % The start time of pixel.
        pstart = AbsoluteTimeTag(LineMarkerIndices(i)) - ...
            (PixelDuration * j);
        
        CurrentLineEnd = LineMarkerIndices(i);
        
        % The records that are on the current line.
        LineData = AbsoluteTimeTag(CurrentLineStart:CurrentLineEnd);
        LineGatingLogical = GatingLogical(CurrentLineStart:CurrentLineEnd);
        
        ImageData(i, pixels - j + 1) = size(find(LineData < pend & LineData > pstart & LineGatingLogical),1); 
    end
    
    CurrentLineStart = LineMarkerIndices(i);
    
end

fprintf(1,' Ready!\n');
fprintf(1,'\nStatistics:\n');
fprintf(1,'\n%u photon records', Photon);
fprintf(1,'\n%u overflows', Overflow);
fprintf(1,'\n%u markers', Marker);

end