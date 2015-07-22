function [ ImageData, gmin, gmax, SYNCRate, messages ] = BuildImage( Data, gmin, gmax, GlobalResolution, SYNCRate )
%BUILDIMAGE Summary of this function goes here
%   Detailed explanation goes here

%% The actual rendering
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

% The overflow counter wrap-around value.
T3WRAPAROUND = 1024;

% The macro time record
TimeTag = bitand(Data(:),1023);                             %the lowest 10 bits

% Reverse start-stop time
dTime = bitand(bitshift(Data(:),-10),32767);                %the next 15 bits

% Indicator/value of record type (overflow (63)/marker (1 - 15)/photon (0))
Channel = bitand(bitshift(Data(:),-25),63);                 %the next 6 bits

% 1 for Overflow and marker, 0 for photons
Special   = logical(bitand(bitshift(Data(:),-31),1));       %the next bit

% We will store indices of line markers for later use. To do so, we check 
% which records are Special, i.e. do not contain photon arrival data and 
% we check that a specific marker value exists. (1 = frame, 2 = line start)
FrameMarkerIndices = find(Special & (Channel == 1));

% For the moment, we look at the first frame only.
LineMarkerIndices = find(Special(1:FrameMarkerIndices(2,1)) & (Channel(1:FrameMarkerIndices(2,1)) == 2));


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

% Get a 'logical' array indicating overflow. Overflow is encoded as value
% 63 in the Channel data.
Overflows = bitand(Channel,63) ~= 0;

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
%
% At each overflow event, the counter might have rolled over multiple
% times. The amount of roll-overs is stored in TimeTag. Therefore, we need
% to calculate the correction BEFORE the cumulative sum to reconstruct
% macrotime for each record.
AbsoluteTimeTag = uint32([0 ; cumsum(uint32(Overflows) .* (TimeTag .* T3WRAPAROUND))]);
AbsoluteTimeTag = AbsoluteTimeTag(1:end-1);

% Get the count of overflows as NoOfOverflows
NoOfOverflows = sum(Overflows);

% We get the specific indices of the FIRST (hence the find (..., 1) frame- 
% and line markers. These are the INVALID (no photons!) records of type 
% marker with values 1 and 2 respectively. 
LineEnd = find(Special & Channel == 2, 1);
FrameStart = find(Special & Channel == 1, 1);

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
MinimumBin = double(min(dTime(~Special)));
MaximumBin = double(max(dTime(~Special)));

% For debug
%rawChannelExcel = dTime(~Special);

% Correct Channel
% Channel = Channel - uint32(MinimumBin);
% [ Y, X ] = hist(double(Channel(Valid)),4096);
% X = X(find(Y))';
% Y = Y(find(Y))';
% % alculate the real start stop time range for reporting.
MinimumReverseStartStop_ns =  MinimumBin * GlobalResolution;
MaximumReverseStartStop_ns =  MaximumBin * GlobalResolution;

% Photons that are closer than a minimum start-stop time will actually be 
% referenced to 'third' pulse, relative to the pulse that triggered the 
% photon. To get 'real', 'forward' start-stop times, we need to perform
% some corrections. If a specific s-s time falls within the SYNC period, we
% substract its value from SYNC period to get the 'forward' s-s value. If
% its value is larger than SYNC period, we substract the reverse s-s- time
% from TWICE the SYNC period. The SYNC period is available as SYNCRATE in
% Hz, so we need to take into account proper conversions of time (s vs ns).
ChannelCorrected_s = double(dTime);

RevStartStopTime_s = ...
    (double(dTime) * GlobalResolution * 1.0E-09) - ...
    (MinimumBin * GlobalResolution * 1.0E-09);

% For debug purposes.
%figure
%hist(double(RevStartStopTime_s(~Special)) * 1E9,4096);
%title('shift channel data histogram (ns)')

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
[ counts, centers ] = hist(double(ChannelCorrected_s(Special)) * 1E9,4096);
countsclean = transpose(counts(find(counts)));
centersclean = transpose(centers(find(counts)));
% title('Corrected channel data histogram (ns)')

% Calculate the real start stop time range for reporting.
MinimumStartStop_ns =  double(min(ChannelCorrected_s(Special))) * 1.0E9;
MaximumStartStop_ns =  double(max(ChannelCorrected_s(Special))) * 1.0E9;

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
    LineValid = Special(CurrentLineStart:CurrentLineEnd);
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
    sprintf('\n%u photon records', size(find(Special),1)),...
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

