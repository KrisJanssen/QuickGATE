function [ ImageData, gmin, gmax, SYNCRate, summary ] = BuildMultiImageHH2T3( m, gmin, gmax, tshift, fskip, GlobalResolution, ArrivalTimerResolution, SYNCRate, frametype, bidir )
%BuildImageHH2T3 Generate images from HydraHarp 2 T3 data.
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

% The macro time record in the lowest 10 bits
TimeTag = bitand(m.Data(:),1023);

% Start-stop time in the next 15 bits
dTime = bitand(bitshift(m.Data(:),-10),32767);

% Indicator/value of record type (overflow (63)/marker (1 - 15)/photon (0))
% in the next 6 bits
Channel = bitand(bitshift(m.Data(:),-25),63);

% 1 for Overflow and marker, 0 for photons in the final bit.
Special   = logical(bitand(bitshift(m.Data(:),-31),1));

% We will store indices of line markers for later use. To do so, we check
% which records are Special, i.e. do not contain photon arrival data and
% we check that a specific marker value exists. (1 = frame, 2 = line start)
if frametype == 1
    FrameMarkerIndices = [ 1; find(Special & (Channel == 1))];
    NoOfFrames = nnz(FrameMarkerIndices) - 1;
elseif frametype == 2
    FrameMarkerIndices = find(Special & (Channel == 1));
    FrameMarkerIndices = FrameMarkerIndices((1 + fskip):end);
    NoOfFrames = nnz(FrameMarkerIndices) / 2;
end

NoOfFrames = floor(NoOfFrames);

LineMarkerIndices = find( ...
    Special(FrameMarkerIndices(1, 1):FrameMarkerIndices(3, 1)) & ...
    Channel(FrameMarkerIndices(1, 1):FrameMarkerIndices(3, 1)) == 2);

% We assume square images so the number of lines is the number of pixels in
% each dimension (X&Y).
pixels = size(LineMarkerIndices,1) / 2;

% Pre-allocate the image data store, including start stop times.
%
% Simple image data will be in a 2D array of size pixels * pixels. The
% vectors holding individual start stop times per pixel will be placed in a
% cell array. The layout of which is explained below.
ImageData{1, NoOfFrames} = zeros(pixels,pixels);

for frame = 1:NoOfFrames
    
    if frametype == 1
        start = frame;
        stop = start + 1;
    elseif frametype == 2
        start = (frame * 2) - 1;
        stop = start + 2;
    end
    
%     LineMarkerIndices = find( ...
%         Special(FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)) & ...
%         Channel(FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)) == 2);
    
    % Since we know the frame we are working in, we can safely work on that
    % data only. Particularly since the LineMarker indices will already be
    % numbered relative to this limited range of records.
    TimeTagTemp = TimeTag((FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)));
    dTimeTemp = dTime((FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)));
    ChannelTemp = Channel((FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)));
    SpecialTemp   = Special((FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)));
    
    % Current frame.
    LineMarkerIndices = find( ...
        SpecialTemp & ...
        ChannelTemp == 2);
    
    CurrentFrameIndices = find( ...
        SpecialTemp & ...
        ChannelTemp == 1);
    
    % Reconstruct the absolute time tags along the experiment time axis (macro
    % time).
    %
    % The TSPC can only count to T3WRAPAROUND so if an experiment takes longer,
    % it counts the overflows of the macro time counter.
    %
    % We need the absolute macro time to reconstruct the image. Once we have
    % the absolute macro time, we can work out the delta between two
    % consecutive line triggers.
    %
    % Calculated absolute values are still uint32! No need to convert to 'real'
    % SI units.
    
    % Get a 'logical' array indicating overflow. Overflow is encoded as value
    % 63 in the Channel data but a logical array is nicer to work with
    % downstream.
    Overflows = zeros(size(ChannelTemp,1),1);
    Overflows(ChannelTemp == 63) = 1;
    
    % AbsoluteTimeTag (macro time) can be calculated in a vectorized fashion.
    %
    % If overflow happens, TimeTag will contain the number of roll-overs of the
    % macro time count register. For any roll-over record, the true macro time
    % can be calculated as follows:
    % AbsoluteTimeTag = AbsoluteTimeTag + TimeTag * T3WRAPAROUND.
    %
    % HOWEVER, for markers and photons, TimeTag holds the number of macro time
    % 'ticks' of that particular event relative to the global macro time count.
    % Thus, TimeTag values for marker or photon records have a slightly
    % different meaning.
    % Therefore, to get the real macro time of a marker or a photon one needs
    % to add the value of TimeTag for that event to AbsoluteTimeTag but this
    % addition should NOT be permanently added to AbsoluteTimeTag for the
    % calculation of later events.
    %
    % The above calculation can effectively be vectorized by doing an element
    % wise multiplication of Overflow, TimeTag and T3WRAPAROUND and construction
    % of a cumulative sum of that result.
    %
    % If Overflows is:
    % [ 1 1 0 0 1 1 0 ]
    % If TimeTag is:
    % [ 1023 1023 23 500 1023 500 10 ]
    % We get Overflows .* TimeTag .* T3WRAPAROUND (constant 1024):
    % [ 1047552 1047552 0 0 1047442 512000 0 ]
    % Yields:
    % Result = [1047552 2095104 2095104 2095104 3142546 3654546 3654546]
    % This is the correct monotone increase of macro time count.
    % To reconstruct the actual macro time for the events corresponding to
    % Overflow == 0 we can do:
    % Result(~Overflow) = Result(~Overflow) + TimeTag(~Overflow) which is eq
    % to:
    % [1047552 2095104 2095104 + 23 2095104 + 500 3142546 3654546 3654546 + 10]
    AbsoluteTimeTag = cumsum(uint32(Overflows) .* (TimeTagTemp .* uint32(T3WRAPAROUND)));
    AbsoluteTimeTag(~Overflows) = AbsoluteTimeTag(~Overflows) + TimeTagTemp(~Overflows);
    
    % Get the count of overflows as NoOfOverflows
    NoOfOverflows = sum(Overflows);
    
    % There is a marker in te first pixel of a line and in the last one. These
    % will be the firs and second element in the trigger array.
    LineDuration = AbsoluteTimeTag(LineMarkerIndices(2)) - AbsoluteTimeTag(LineMarkerIndices(1));
    FrameDuration = AbsoluteTimeTag(CurrentFrameIndices(2,1)) - AbsoluteTimeTag(CurrentFrameIndices(1,1));
    InterFrameDuration = AbsoluteTimeTag(CurrentFrameIndices(3,1)) - AbsoluteTimeTag(CurrentFrameIndices(1,1));
    
    % The duration of a pixel. Since the line ending trigger fires in the last
    % pixel, the duration between the rising edge of line start and the rising
    % edge of line end is actually the duration of lines per pixel minus 1.
    PixelDuration = double(LineDuration) / double(pixels-1);
    
    frameTime = double(FrameDuration) * GlobalResolution
    frameRate = 1.0 / (double(InterFrameDuration) * GlobalResolution)
    dwellTime = PixelDuration * GlobalResolution
    
    % Check we have sensible values for gating. If not, flip them around/coerce
    % them. If the are coerced it is obviously important to send them back out
    % to the user, hence the out parameters.
    if gmin >= gmax
        PixelChannelCorrected_s = gmin;
        gmin = gmax;
        gmax = PixelChannelCorrected_s;
    else
        if gmin == gmax
            gmax = gmin + 0.1;
        end
    end
    
    % It might be that, not all reverse start-stop time bins of the TCSPC will
    % be filled. Moreover, some bins might contain photons with apparent
    % arrival times that appear to exceed the SYNC period.
    % We will check these values now such that we can act accordingly later on
    % or at the very least report them to the user.
    MinimumBin = double(min(dTimeTemp(~SpecialTemp)));
    MaximumBin = double(max(dTimeTemp(~SpecialTemp)));
    
    % For debug
    %rawChannelExcel = dTime(~Special);
    
    % Calculate the real start stop time range for reporting.
    MinimumReverseStartStop_ns =  MinimumBin * ArrivalTimerResolution;
    MaximumReverseStartStop_ns =  MaximumBin * ArrivalTimerResolution;
    
    % Convert arrival time in ticks of the hardware counter to real-world
    % seconds (SI units!)
    dTime_s = ...
        (double(dTimeTemp) * ArrivalTimerResolution) - ...
        (MinimumBin * ArrivalTimerResolution);
    
    % For debug purposes.
    % figure
    % hist(double(ChannelCorrected_s(~Special)) * 1E9,65536);
    % [ counts, centers ] = hist(double(ChannelCorrected_s(~Special)) * 1E9,65536);
    % countsclean = transpose(counts(find(counts)));
    % centersclean = transpose(centers(find(counts)));
    % title('Corrected channel data histogram (ns)')
    
    % Calculate the real start stop time range for reporting.
    MinimumStartStop_ns =  double(min(dTime_s(~SpecialTemp))) * 1.0E9;
    MaximumStartStop_ns =  double(max(dTime_s(~SpecialTemp))) * 1.0E9;
    
    % Now that we finally have 'forward' start stop times, which have an actual
    % physical meaning, we can get a logical indexer signifying compliance
    % with the gating condition. Again we convert gating times in ns to s. We
    % are greedy with this check (we include gmin and gmax itself.
    GatingLogical = ...
        (gmin * 1E-09 <= dTime_s) & ...
        (gmax * 1E-09 >= dTime_s);
    
    % We will construct image pixel values by counting the number of photon
    % records that fall in a certain time bin of duration PixelDuration. For
    % the purpose, we will use find(). This can be time consuming and
    % therefore, we would like to only search for such pixels in the actual
    % line we are currently on.
    %
    % The very first line starts at frame marker and runs to the first line
    % marker.
    CurrentLineStart = LineMarkerIndices(1);
    
    % For correct pixel parsing, we create an array of pixel indices.
    PixelIndices = uint32( [ 1:pixels ]' );
    
    % Keep track of lines during processing.
    CurrentLine = 1;
    
    evenodd = 1;
    
    % Cycle through the lines.
    for i=1:2:2*(pixels - 1)
        
        CurrentLineEnd = LineMarkerIndices(i + 1);
        
        % The records that are on the current line. Limiting operations to
        % these records might speed up operations.
        LineData = AbsoluteTimeTag(CurrentLineStart:CurrentLineEnd);
        LineValid = SpecialTemp(CurrentLineStart:CurrentLineEnd);
        LineGatingLogical = GatingLogical(CurrentLineStart:CurrentLineEnd);
        
        % Pixel generation is basically the same as constructing a histogram
        % with edges on the pixel end timepoints.
        
        % First we calculate all pixel end time tags which are the time tags of
        % the line marker minus a multiple of the pixel duration. We are
        % processing back from the end of line pixel, that is why PixelIndices
        % is reversed.
        % Values range from linemarker - 399 * PixelDuration to
        %                   linemarker - 000 * PixelDuration
        PixelEnd = ...
            AbsoluteTimeTag(CurrentLineStart) + (PixelIndices * PixelDuration) + (tshift / GlobalResolution);
        
        % We now bin the photonrecords that fall within the gating boundaries
        % by these pixel end times.
            
        if (bidir && mod(evenodd, 2) == 0)
            %ImageData{1,frame}(CurrentLine, :) = histc(LineData(LineGatingLogical & ~LineValid), PixelEnd);
            ImageData{1,frame}(CurrentLine, :) = flip(histc(LineData(LineGatingLogical & ~LineValid), PixelEnd));
        else
            ImageData{1,frame}(CurrentLine, :) = histc(LineData(LineGatingLogical & ~LineValid), PixelEnd);
        end
        
        % Proceed to the next line marker.
        CurrentLineStart = LineMarkerIndices(i + 2);
        CurrentLine = CurrentLine + 1;
        
        evenodd = evenodd + 1;
        
    end
    
    summary = strcat(...
        sprintf('\nStatistics:\n'),...
        sprintf('\n%u photon records', size(find(SpecialTemp),1)),...
        sprintf('\n%u overflows', NoOfOverflows),...
        sprintf('\n%u Line markers\n', pixels),...
        sprintf('\n%5.2f (ms) Pixel Dwell time\n', double(PixelDuration) * GlobalResolution * 1E3),...
        sprintf('\n%5.2f (ns) MIN rev Start-Stop\n', MinimumReverseStartStop_ns),...
        sprintf('\n%5.2f (ns) MAX rev Start-Stop\n', MaximumReverseStartStop_ns),...
        sprintf('\n%5.2f (ns) MIN Start-Stop\n', MinimumStartStop_ns),...
        sprintf('\n%5.2f (ns) MAX Start-Stop\n', MaximumStartStop_ns));
end

% profile viewer
% profile off

end

