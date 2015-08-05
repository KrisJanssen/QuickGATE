function [ ImageData, gmin, gmax, SYNCRate, messages ] = ExtractImageT3R( filepath, gmin, gmax, tshift )
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

% This file is inspred by the "Demo for accessing TimeHarp TTTR data files 
% (*.t3r) from MATLAB" example, as supplied with the TimeHarp 200, 
% Software version 6.x, Format version 6.0
% Tested with Matlab  6 and 7
% Peter Kapusta, PicoQuant GmbH, February 2009

% Adaptation by Kris Janssen, 2014

% NOTE:
% TTTR records are written to [t3r file name].txt 
% we do not keep it in memory because of the huge amout of memory
% this would take in case of large files. Of course you can change this, 
% e.g. if your files are not too big. 
% Otherwise it is best process the data on the fly and keep only the results.
%profile('on', '-detail', 'builtin')

%% Load some header info for debug display to console

fprintf(1,'\n');

fid=fopen(filepath);


fprintf(1,'================================================================= \n');
fprintf(1,'  Content of %s : \n', filepath);
fprintf(1,'================================================================= \n');
fprintf(1,'\n');


%
% Read the TxtHdr
%

Ident = fread(fid, 16, '*char');

FormatVersion = deblank(char(fread(fid, 6, 'char')'));
fprintf(1,'Format version: %s\n', FormatVersion);

if not(strcmp(FormatVersion,'6.0'))
   fprintf(1,'\n\n Warning: This program is for version 6.0 only. Aborted.');
   STOP;
end;



CreatorName = fread(fid, 18, '*char');
fprintf(1,'Creator name: %s\n', CreatorName);

CreatorVersion = fread(fid, 12, '*char');
fprintf(1,'Creator version: %s\n', CreatorVersion);

FileTime = fread(fid, 18, '*char');
fprintf(1,'File creation: %s\n', FileTime);

CRLF = fread(fid, 2, '*char');

Comment = fread(fid, 256, '*char');
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

DispCurveMapTo = zeros(8,1);
DispCurveShow = zeros(8,1);

for i = 1:8
DispCurveMapTo(i) = fread(fid, 1, 'int32');
DispCurveShow(i) = fread(fid, 1, 'int32');
fprintf(1,'-------------------------------------\n');
fprintf(1,'            Curve No: %d\n', i-1);
fprintf(1,'               MapTo: %d\n', DispCurveMapTo(i));
fprintf(1,'                Show: %d\n', DispCurveShow(i));
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ParamStart = zeros(3,1);
ParamStep = zeros(3,1);
ParamEnd = zeros(3,1);

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

ScriptName = fread(fid, 20, '*char');
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

HardwareIdent = fread(fid, 16, '*char');
fprintf(1,'Hardware Identifier: %s\n', HardwareIdent);

HardwareVersion = fread(fid, 8, '*char');
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

% Close the file handle, all data is in memory now.
fclose(fid);
%profile on
% Extract rudimentary info from the data:
% 1) Time tag is an int representation of the event in terms of macro time.
% 2) Channel holds the REVERSE start-stop channel (i.e.) time bin.
% 3) Route holds routing information (no shit!)
% 4) Valid holds information on the type of data in Channel (1 = photon).
%
% All data records are 32 bit numbers. By using AND and SHIFT operations
% with correct values, we can extract sub-bits holding particular
% information.
TimeTag = bitand(Data(:),65535);                        %the lowest 16 bits
Channel = bitand(bitshift(Data(:),-16),4095);           %the next 12 bits
%Route   = bitand(bitshift(Data(:),-28),3);             %the next 2 bits
Valid   = logical(bitand(bitshift(Data(:),-30),1));     %the next bit

% We will store indices of line markers for later use. To do so, we check 
% which records are not valid, i.e. do not contain photon arrival data and 
% we check that a marker value exists.
LineMarkerIndices = find(~Valid & bitand(Channel,7) == 4);

% We assume square images so the number of lines is the number of pixels in
% each dimension (X&Y).
pixels = size(LineMarkerIndices,1);

% Reconstruct the absolute time tags along the experiment time axis (macro 
% time).
%
% The TSPC can only count to 2^16 so if an experiment takes longer, it
% counts the overflows of the macro time counter.
%
% We need the absolute macro time to reconstruct the image. Once we have 
% the absolute macro time, we can work out the delta between Frame trigger 
% and the first line trigger, i.e. the time it takes to complete a scan
% line. 
%
% Moreover, having worked out the duration of the scanline, we can
% calculate back from the line marker such that we can easily get rid of
% the photons generated during the return of the galvo.
%
% Calculated absolute values are still uint32! No need to convert to 'real'
% SI units.

% Get a 'logical' array indicating overflow.
Overflows = bitand(Channel,2048) ~= 0;

% AbsoluteTimeTag can be calculated in a vectorized fashion.
% If Overflows is:
% [ 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 1 0 0 ]
% cumsum will yield:
% [ 0 0 1 1 1 1 1 2 2 2 2 2 3 3 3 3 4 4 4 ]
% We need to shift this by one position to the right since the overflow
% only needs to be applied starting from the record following its
% occurence:
% [ P P O P P P P O P P P P O P P P O P P ] (P = photon, O = overflow).
% The shift:
% [ 0 0 0 1 1 1 1 1 2 2 2 2 2 3 3 3 3 4 4 4 ]
% We then only need to multiply by 65536.
AbsoluteTimeTag = ...
    uint32([0 ; cumsum(Overflows(1:end-1).*65536)]) + TimeTag;

% Get the count of overflows as NoOfOverflows
NoOfOverflows = sum(Overflows);

% We get the specific indices of the FIRST (hence the find (..., 1) frame- 
% and line markers. These are the INVALID (no photons!) records of type 
% marker with values 4 and 2 respectively. 
LineEnd = find(~Valid & bitand(Channel,7) == 4, 1);
FrameStart = find(~Valid & bitand(Channel,7) == 2, 1);

% We therefore need to look up the corresponding index in "AbsoluteTimeTag" 
% because we are interested in absolute time. 
LineDuration = AbsoluteTimeTag(LineEnd) - AbsoluteTimeTag(FrameStart);

% The duration of a pixel.
PixelDuration = round(LineDuration / pixels);

% Gating variables.

% Check we have sensible values for gating. If not, flip them around/coerce 
% them.
if gmin >= gmax
    PixelChannelCorrected_s = gmin;
    gmin = gmax;
    gmax = PixelChannelCorrected_s;
else
    if gmin == gmax
        gmax = gmin + 0.1;
    end  
end

% In reality, not all reverse start-stop time bins of the TCSPC will be 
% filled. Moreover, some bins will contain photons with apparent arrival 
% times that greatly exceed the SYNC period.
% We will check these values now such that we can act accordingly later on
% Or at the very least report them to the user.
MinimumBin = double(min(Channel(Valid)));
MaximumBin = double(max(Channel(Valid)));

% For debug
rawChannelExcel = Channel(Valid);

% Correct Channel
% Channel = Channel - uint32(MinimumBin);
% [ Y, X ] = hist(double(Channel(Valid)),4096);
% X = X(find(Y))';
% Y = Y(find(Y))';
% % alculate the real start stop time range for reporting.
MinimumReverseStartStop_ns =  MinimumBin * Board_Resolution;
MaximumReverseStartStop_ns =  MaximumBin * Board_Resolution;

% Photons that are closer than a minimum start-stop time will actually be 
% referenced to 'third' pulse, relative to the pulse that triggered the 
% photon. To get 'real', 'forward' start-stop times, we need to perform
% some corrections. If a specific s-s time falls within the SYNC period, we
% substract its value from SYNC period to get the 'forward' s-s value. If
% its value is larger than SYNC period, we substract the reverse s-s- time
% from TWICE the SYNC period. The SYNC period is available as SYNCRATE in
% Hz, so we need to take into account proper conversions of time (s vs ns).
ChannelCorrected_s = double(Channel);

RevStartStopTime_s = (double(Channel) * Board_Resolution * 1.0E-09) - (MinimumBin * Board_Resolution * 1.0E-09);

% For debug purposes.
% figure
% hist(double(RevStartStopTime_s(Valid)) * 1E9,4096);
% title('shift channel data histogram (ns)')

% For debug purposes.
% figure
% plot(double(Channel(Valid)));
% title('Raw channel data (Reverse start-stop)')
% figure
% hist(double(Channel(Valid)),4096);
% title('Raw channel data histogram (Reverse start-stop)')

ChannelCorrected_s(RevStartStopTime_s >= 1.0 / SYNCRate) = ...
    2.0 / SYNCRate - RevStartStopTime_s(RevStartStopTime_s >= 1.0 / SYNCRate);

ChannelCorrected_s(RevStartStopTime_s <= 1.0 / SYNCRate) = ...
    1.0 / SYNCRate - RevStartStopTime_s(RevStartStopTime_s <= 1.0 / SYNCRate);

% For debug purposes.
% figure
[ counts, centers ] = hist(double(ChannelCorrected_s(Valid)) * 1E9,4096);
countsclean = transpose(counts(find(counts)));
centersclean = transpose(centers(find(counts)));
% title('Corrected channel data histogram (ns)')

% Calculate the real start stop time range for reporting.
MinimumStartStop_ns =  double(min(ChannelCorrected_s(Valid))) * 1.0E9;
MaximumStartStop_ns =  double(max(ChannelCorrected_s(Valid))) * 1.0E9;

% Now that we finally have 'forward' start stop times, which have an actual
% physical meaning, we can get a logical indexer signifying compliance 
% with the gating condition. Again we convert gating times in ns to s. We
% are greedy with this check (we include gmin and gmax itself.
GatingLogical = ...
    (gmin * 1E-09 <= ChannelCorrected_s) & ...
    (gmax * 1E-09 >= ChannelCorrected_s);

% We will construct image pixel values by counting the number of photon
% records that fall in a certain time bin of duration PixelDuration. For
% the purpose, we will use find(). This can be time consuming and
% therefore, we would like to only search for such pixels in the actual
% line we are currently on.
%
% The very first line starts at frame marker and runs to the first line
% marker.
CurrentLineStart = FrameStart;

% Pre-allocate the image data store, including start stop times. 
%
% Simple image data will be in a 2D array of size pixels * pixels. The
% vectors holding individual start stop times per pixel will be placed in a 
% cell array. The layout of which is explained below.
ImageData = { zeros(pixels,pixels) , cell(pixels, pixels) };

% For correct pixel parsing, we create an array of pixel indices which is
% front to back.
PixelIndices = uint32(flipud( [ 1:pixels ]'));

% Cycle through the lines.
for i=1:pixels
    
    CurrentLineEnd = LineMarkerIndices(i);
    
    % The records that are on the current line. Limiting operations to
    % these records might speed up operations.
    LineData = AbsoluteTimeTag(CurrentLineStart:CurrentLineEnd);
    LineValid = Valid(CurrentLineStart:CurrentLineEnd);
    LineGatingLogical = GatingLogical(CurrentLineStart:CurrentLineEnd);
    LineChannelCorrected_s = ChannelCorrected_s(CurrentLineStart:CurrentLineEnd);
    
    % Pixel generation is basically the same as constructing a histogram 
    % with edges on the pixel end timepoints.
    
    % First we calculate all pixel end time tags which are the time tags of
    % the line marker minus a multiple of the pixel duration. We are
    % processing back from the end of line pixel, that is why PixelIndices
    % is reversed.
    % Values range from linemarker - 399 * PixelDuration to 
    %                   linemarker - 000 * PixelDuration
    PixelEnd = ...
        AbsoluteTimeTag(LineMarkerIndices(i)) - (PixelIndices - 1) * PixelDuration;
    
    % We now bin the photonrecords that fall within the gating boundaries 
    % by these pixel end times.
    ImageData{1,1}(i, :, 1) = histc(LineData(LineGatingLogical & LineValid), PixelEnd);
    
    % We next want to group start stop times per pixel. So here, we do not
    % need gating. We will also use the bin numbers instead of their
    % contents. Indeed, PixelIndex holds the pixel number of each valid
    % record in the current line.
    [ ~ , PixelIndex ] = histc(LineData(LineValid), PixelEnd);
    
    % The PixelIndex (bins) are 0 based, so we add one for later array
    % indexing.
    PixelIndex = uint32(PixelIndex + 1);
    
    % We will now aggregate the valid channel values by the pixel to which
    % they belong in a cell array. If a certain bin index is not present,
    % an empty cell will be inserted, unless we are at the end, then
    % nothing will be added.
    PixelLifeTimes = accumarray(PixelIndex, LineChannelCorrected_s(LineValid), [], @(x) {x});
    
    % This is line data so make a row cell array.
    PixelLifeTimes = PixelLifeTimes';
    
    % Store the lifetimes.
    ImageData{1,2}(i,1:length(PixelLifeTimes)) = PixelLifeTimes;
    
    % Proceed to the next line marker.
    CurrentLineStart = LineMarkerIndices(i);
    
end

messages = strcat(...
    sprintf('\nStatistics:\n'),...
    sprintf('\n%u photon records', size(find(Valid),1)),...
    sprintf('\n%u overflows', NoOfOverflows),...
    sprintf('\n%u Line markers\n', pixels),...
    sprintf('\n%5.2f (ms) Pixel Dwell time\n', double(PixelDuration) * 100E-6),...
    sprintf('\n%5.2f (ns) MIN rev Start-Stop\n', MinimumReverseStartStop_ns),...
    sprintf('\n%5.2f (ns) MAX rev Start-Stop\n', MaximumReverseStartStop_ns),...
    sprintf('\n%5.2f (ns) MIN Start-Stop\n', MinimumStartStop_ns),...
    sprintf('\n%5.2f (ns) MAX Start-Stop\n', MaximumStartStop_ns));

% profile viewer
% profile off
end
