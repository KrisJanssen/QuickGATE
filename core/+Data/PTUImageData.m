classdef PTUImageData < Data.TCSPCImageData
    %PTUIMAGEDATA TCSPC image data from PQ PTU files.
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
       
        type = 'PTU';
        
    end
    
    methods
        
        % We need to explicitly call the superclass constructor.
        function obj = PTUImageData(path)
            
            obj@Data.TCSPCImageData(path);
            
        end
  
    end
    
    methods
        
        function data = getframe(obj, idx, tshift)

            data = {};
            
            try
                fid = fopen(obj.path);
            catch
                error('File not found!');
            end
            
            Magic = fread(fid, 8, '*char');
            
            if not(strcmp(Magic(Magic~=0)','PQTTTR'))
                error('Magic invalid, this is not a PTU file.');
            else
                [ data, NoOfFrames, ~, ~ ] =  obj.ExtractImagePTU( fid, idx, tshift );
            end;

        end
        
    end
    
    methods (Access = private)
        
        function [ ImageData, messages ] = ExtractImagePTU(obj, fid, idx, tshift )
            % Read PicoQuant Unified TTTR Files
            % This code is based on an example written by Marcus Sackrow,
            % PicoQUant GmbH, December 2013.
            
            %% Some constants
            
            % PTU files contain "header tags" as a structured way to represent
            % essential measurement information. Each tag has a type which is encoded
            % in the following way:
            
            tyEmpty8      = hex2dec('FFFF0008');
            tyBool8       = hex2dec('00000008');
            tyInt8        = hex2dec('10000008');
            tyBitSet64    = hex2dec('11000008');
            tyColor8      = hex2dec('12000008');
            tyFloat8      = hex2dec('20000008');
            tyTDateTime   = hex2dec('21000008');
            tyFloat8Array = hex2dec('2001FFFF');
            tyAnsiString  = hex2dec('4001FFFF');
            tyWideString  = hex2dec('4002FFFF');
            tyBinaryBlob  = hex2dec('FFFFFFFF');
            
            % RecordTypes
            rtPicoHarpT3     = hex2dec('00010303');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $03 (T3), HW: $03 (PicoHarp)
            rtPicoHarpT2     = hex2dec('00010203');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $02 (T2), HW: $03 (PicoHarp)
            rtHydraHarpT3    = hex2dec('00010304');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $03 (T3), HW: $04 (HydraHarp)
            rtHydraHarpT2    = hex2dec('00010204');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $02 (T2), HW: $04 (HydraHarp)
            rtHydraHarp2T3   = hex2dec('01010304');% (SubID = $01 ,RecFmt: $01) (V2), T-Mode: $03 (T3), HW: $04 (HydraHarp)
            rtHydraHarp2T2   = hex2dec('01010204');% (SubID = $01 ,RecFmt: $01) (V2), T-Mode: $02 (T2), HW: $04 (HydraHarp)
            rtTimeHarp260NT3 = hex2dec('00010305');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $03 (T3), HW: $05 (TimeHarp260N)
            rtTimeHarp260NT2 = hex2dec('00010205');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $02 (T2), HW: $05 (TimeHarp260N)
            rtTimeHarp260PT3 = hex2dec('00010306');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $03 (T3), HW: $06 (TimeHarp260P)
            rtTimeHarp260PT2 = hex2dec('00010206');% (SubID = $00 ,RecFmt: $01) (V1), T-Mode: $02 (T2), HW: $06 (TimeHarp260P)
            
            %% Globals for subroutines
            
            % TODO: I don't like the use of globals. Check if this cannot be solved in
            % a more elegant way.
            global TTResultFormat_TTTRRecType;
            global TTResult_NumberOfRecords; % Number of TTTR Records in the File;
            global TTResult_SyncRate;        % The laser Sync rate
            global MeasDesc_Resolution;      % Resolution for the Dtime (T3 Only)
            global MeasDesc_GlobalResolution;
            
            TTResultFormat_TTTRRecType = 0;
            TTResult_NumberOfRecords = 0;
            MeasDesc_Resolution = 0;
            MeasDesc_GlobalResolution = 0;
            
%             fprintf(1,'\n');
%             Magic = fread(fid, 8, '*char');
%             if not(strcmp(Magic(Magic~=0)','PQTTTR'))
%                 error('Magic invalid, this is not an PTU file.');
%             end;

            Version = fread(fid, 8, '*char');
            fprintf(1,'Tag Version: %s\n', Version);
            
            % there is no repeat.. until (or do..while) construct in matlab so we use
            % while 1 ... if (expr) break; end; end; to read right up to the end of the
            % header.
            while 1
                % read Tag Head
                TagIdent = fread(fid, 32, '*char'); % TagHead.Ident
                
                % TagIdent is initiallly a column vector. Flip it.
                TagIdent = (TagIdent(TagIdent ~= 0))';
                TagIdx = fread(fid, 1, 'int32');    % TagHead.Idx
                TagTyp = fread(fid, 1, 'uint32');   % TagHead.Typ
                % TagHead.Value will be read in the
                % right type function
                if TagIdx > -1
                    EvalName = [TagIdent '(' int2str(TagIdx + 1) ')'];
                else
                    EvalName = TagIdent;
                end
                fprintf(1,'\n   %-40s', EvalName);
                % check Typ of Header
                switch TagTyp
                    case tyEmpty8
                        fread(fid, 1, 'int64');
                        fprintf(1,'<Empty>');
                    case tyBool8
                        TagInt = fread(fid, 1, 'int64');
                        if TagInt==0
                            fprintf(1,'FALSE');
                            eval([EvalName '=false;']);
                        else
                            fprintf(1,'TRUE');
                            eval([EvalName '=true;']);
                        end
                    case tyInt8
                        TagInt = fread(fid, 1, 'int64');
                        fprintf(1,'%d', TagInt);
                        eval([EvalName '=TagInt;']);
                    case tyBitSet64
                        TagInt = fread(fid, 1, 'int64');
                        fprintf(1,'%X', TagInt);
                        eval([EvalName '=TagInt;']);
                    case tyColor8
                        TagInt = fread(fid, 1, 'int64');
                        fprintf(1,'%X', TagInt);
                        eval([EvalName '=TagInt;']);
                    case tyFloat8
                        TagFloat = fread(fid, 1, 'double');
                        fprintf(1, '%e', TagFloat);
                        eval([EvalName '=TagFloat;']);
                    case tyFloat8Array
                        TagInt = fread(fid, 1, 'int64');
                        fprintf(1,'<Float array with %d Entries>', TagInt / 8);
                        fseek(fid, TagInt, 'cof');
                    case tyTDateTime
                        TagFloat = fread(fid, 1, 'double');
                        fprintf(1, '%s', datestr(datenum(1899,12,30)+TagFloat)); % display as Matlab Date String
                        eval([EvalName '=datenum(1899,12,30)+TagFloat;']); % but keep in memory as Matlab Date Number
                    case tyAnsiString
                        TagInt = fread(fid, 1, 'int64');
                        TagString = fread(fid, TagInt, '*char');
                        TagString = (TagString(TagString ~= 0))';
                        fprintf(1, '%s', TagString);
                        if TagIdx > -1
                            EvalName = [TagIdent '(' int2str(TagIdx + 1) ',:)'];
                        end;
                        eval([EvalName '=TagString;']);
                    case tyWideString
                        % Matlab does not support Widestrings at all, just read and
                        % remove the 0's (up to current (2012))
                        TagInt = fread(fid, 1, 'int64');
                        TagString = fread(fid, TagInt, '*char');
                        TagString = (TagString(TagString ~= 0))';
                        fprintf(1, '%s', TagString);
                        if TagIdx > -1
                            EvalName = [TagIdent '(' int2str(TagIdx + 1) ',:)'];
                        end;
                        eval([EvalName '=TagString;']);
                    case tyBinaryBlob
                        TagInt = fread(fid, 1, 'int64');
                        fprintf(1,'<Binary Blob with %d Bytes>', TagInt);
                        fseek(fid, TagInt, 'cof');
                    otherwise
                        error('Illegal Type identifier found! Broken file?');
                end;
                
                if strcmp(TagIdent, 'Header_End')
                    break
                end
            end
            fprintf(1, '\n----------------------\n');
            
            %% Check recordtype
            global isT2;
            
            switch TTResultFormat_TTTRRecType;
                case rtPicoHarpT3
                    isT2 = false;
                    fprintf(1,'PicoHarp T3 data\n');
                case rtPicoHarpT2
                    isT2 = true;
                    fprintf(1,'PicoHarp T2 data\n');
                case rtHydraHarpT3
                    isT2 = false;
                    fprintf(1,'HydraHarp V1 T3 data\n');
                case rtHydraHarpT2
                    isT2 = true;
                    fprintf(1,'HydraHarp V1 T2 data\n');
                case rtHydraHarp2T3
                    isT2 = false;
                    fprintf(1,'HydraHarp V2 T3 data\n');
                case rtHydraHarp2T2
                    isT2 = true;
                    fprintf(1,'HydraHarp V2 T2 data\n');
                case rtTimeHarp260NT3
                    isT2 = false;
                    fprintf(1,'TimeHarp260N T3 data\n');
                case rtTimeHarp260NT2
                    isT2 = true;
                    fprintf(1,'TimeHarp260N T2 data\n');
                case rtTimeHarp260PT3
                    isT2 = false;
                    fprintf(1,'TimeHarp260P T3 data\n');
                case rtTimeHarp260PT2
                    isT2 = true;
                    fprintf(1,'TimeHarp260P T2 data\n');
                otherwise
                    error('Illegal RecordType!');
            end;
            
            % Read the actual data (non-header content) from disk as uint32.
            Data = uint32(fread(fid, 'uint32'));
            
            % Close the file handle, all data is in memory now.
            fclose(fid);
            
            %% Render the data.
            % MeasDesc_GlobalResolution is the macro time resolution
            % MeasDesc_Resolution is the arrival time resolution
            switch TTResultFormat_TTTRRecType;
                case rtHydraHarp2T3
                    [ ImageData, messages ] = obj.BuildImageHH2T3( ...
                        Data, idx, tshift, MeasDesc_GlobalResolution, MeasDesc_Resolution, TTResult_SyncRate, 2);
                otherwise
                    error('Illegal RecordType!');
            end;
            
        end
        
        function [ ImageData, messages ] = BuildImageHH2T3(obj, Data, frame, tshift, GlobalResolution, ArrivalTimerResolution, SYNCRate, frametype )
            
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
            TimeTag = bitand(Data(:),1023);
            
            % Start-stop time in the next 15 bits
            dTime = bitand(bitshift(Data(:),-10),32767);
            
            % Indicator/value of record type (overflow (63)/marker (1 - 15)/photon (0))
            % in the next 6 bits
            Channel = bitand(bitshift(Data(:),-25),63);
            
            % 1 for Overflow and marker, 0 for photons in the final bit.
            Special   = logical(bitand(bitshift(Data(:),-31),1));
            
            % We will store indices of line markers for later use. To do so, we check
            % which records are Special, i.e. do not contain photon arrival data and
            % we check that a specific marker value exists. (1 = frame, 2 = line start)
            if frametype == 1
                FrameMarkerIndices = [ 1; find(Special & (Channel == 1))];
                NoOfFrames = nnz(FrameMarkerIndices) - 1;
            elseif frametype == 2
                FrameMarkerIndices = find(Special & (Channel == 1));
                NoOfFrames = nnz(FrameMarkerIndices) / 2;
            end
            
            if frame > NoOfFrames
                error('No such frame!')
            end
            
            if frametype == 1
                start = frame;
                stop = start + 1;
            elseif frametype == 2
                start = (frame * 2) - 1;
                stop = start + 1;
            end
            
            LineMarkerIndices = find( ...
                Special(FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)) & ...
                Channel(FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)) == 2);
            
            % We assume square images so the number of lines is the number of pixels in
            % each dimension (X&Y).
            pixels = size(LineMarkerIndices,1) / 2;
            
            % Since we know the frame we are working in, we can safely work on that
            % data only. Particularly since the LineMarker indices will already be
            % numbered relative to this limited range of records.
            TimeTag = TimeTag((FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)));
            dTime = dTime((FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)));
            Channel = Channel((FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)));
            Special   = Special((FrameMarkerIndices(start, 1):FrameMarkerIndices(stop, 1)));
            
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
            Overflows = zeros(size(Channel,1),1);
            Overflows(Channel == 63) = 1;
            
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
            AbsoluteTimeTag = cumsum(uint32(Overflows) .* (TimeTag .* uint32(T3WRAPAROUND)));
            AbsoluteTimeTag(~Overflows) = AbsoluteTimeTag(~Overflows) + TimeTag(~Overflows);
            
            % Get the count of overflows as NoOfOverflows
            NoOfOverflows = sum(Overflows);
            
            % There is a marker in te first pixel of a line and in the last one. These
            % will be the firs and second element in the trigger array.
            LineDuration = AbsoluteTimeTag(LineMarkerIndices(2)) - AbsoluteTimeTag(LineMarkerIndices(1));
            
            % The duration of a pixel. Since the line ending trigger fires in the last
            % pixel, the duration between the rising edge of line start and the rising
            % edge of line end is actually the duration of lines per pixel minus 1.
            PixelDuration = double(LineDuration) / double(pixels-1);
            
            % It might be that, not all reverse start-stop time bins of the TCSPC will
            % be filled. Moreover, some bins might contain photons with apparent
            % arrival times that appear to exceed the SYNC period.
            % We will check these values now such that we can act accordingly later on
            % or at the very least report them to the user.
            MinimumBin = double(min(dTime(~Special)));
            MaximumBin = double(max(dTime(~Special)));
            
            % For debug
            %rawChannelExcel = dTime(~Special);
            
            % Calculate the real start stop time range for reporting.
            MinimumReverseStartStop_ns =  MinimumBin * ArrivalTimerResolution;
            MaximumReverseStartStop_ns =  MaximumBin * ArrivalTimerResolution;
            
            % Convert arrival time in ticks of the hardware counter to real-world
            % seconds (SI units!)
            dTime_s = ...
                (double(dTime) * ArrivalTimerResolution) - ...
                (MinimumBin * ArrivalTimerResolution);
            
            % For debug purposes.
            % figure
            % hist(double(ChannelCorrected_s(~Special)) * 1E9,65536);
            % [ counts, centers ] = hist(double(ChannelCorrected_s(~Special)) * 1E9,65536);
            % countsclean = transpose(counts(find(counts)));
            % centersclean = transpose(centers(find(counts)));
            % title('Corrected channel data histogram (ns)')
            
            % Calculate the real start stop time range for reporting.
            MinimumStartStop_ns =  double(min(dTime_s(~Special))) * 1.0E9;
            MaximumStartStop_ns =  double(max(dTime_s(~Special))) * 1.0E9;
            
            % We will construct image pixel values by counting the number of photon
            % records that fall in a certain time bin of duration PixelDuration. For
            % the purpose, we will use find(). This can be time consuming and
            % therefore, we would like to only search for such pixels in the actual
            % line we are currently on.
            %
            % The very first line starts at frame marker and runs to the first line
            % marker.
            CurrentLineStart = LineMarkerIndices(1);
            
            % Pre-allocate the image data store, including start stop times.
            %
            % Simple image data will be in a 2D array of size pixels * pixels. The
            % vectors holding individual start stop times per pixel will be placed in a
            % cell array. The layout of which is explained below.
            ImageData = cell(pixels, pixels);
            
            % For correct pixel parsing, we create an array of pixel indices.
            PixelIndices = uint32( [ 1:pixels ]' );
            
            % Keep track of lines during processing.
            CurrentLine = 1;
            
            % Cycle through the lines.
            for i=1:2:2*(pixels - 1)
                
                CurrentLineEnd = LineMarkerIndices(i + 1);
                
                % The records that are on the current line. Limiting operations to
                % these records might speed up operations.
                LineData = AbsoluteTimeTag(CurrentLineStart:CurrentLineEnd);
                LineValid = Special(CurrentLineStart:CurrentLineEnd);
                LineChannelCorrected_s = dTime_s(CurrentLineStart:CurrentLineEnd);
                
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
                
                % We next want to group start stop times per pixel. So here, we do not
                % need gating. We will also use the bin numbers instead of their
                % contents. Indeed, PixelIndex holds the pixel number of each valid
                % record in the current line.
                [ ~ , PixelIndex ] = histc(LineData(~LineValid), PixelEnd);
                
                % The PixelIndex (bins) are 0 based, so we add one for later array
                % indexing.
                PixelIndex = uint32(PixelIndex + 1);
                
                % We will now aggregate the valid channel values by the pixel to which
                % they belong in a cell array. If a certain bin index is not present,
                % an empty cell will be inserted, unless we are at the end, then
                % nothing will be added.
                PixelLifeTimes = accumarray(PixelIndex, LineChannelCorrected_s(~LineValid), [], @(x) {x});
                
                % This is line data so make a row cell array.
                PixelLifeTimes = PixelLifeTimes';
                
                % Store the lifetimes.
                ImageData(CurrentLine,1:length(PixelLifeTimes)) = PixelLifeTimes;
                
                % Proceed to the next line marker.
                CurrentLineStart = LineMarkerIndices(i + 2);
                CurrentLine = CurrentLine + 1;
                
            end
            
            messages = strcat(...
                sprintf('\nStatistics:\n'),...
                sprintf('\n%u photon records', size(find(Special),1)),...
                sprintf('\n%u overflows', NoOfOverflows),...
                sprintf('\n%u Line markers\n', pixels),...
                sprintf('\n%5.2f (ms) Pixel Dwell time\n', double(PixelDuration) * GlobalResolution * 1E3),...
                sprintf('\n%5.2f (ns) MIN rev Start-Stop\n', MinimumReverseStartStop_ns),...
                sprintf('\n%5.2f (ns) MAX rev Start-Stop\n', MaximumReverseStartStop_ns),...
                sprintf('\n%5.2f (ns) MIN Start-Stop\n', MinimumStartStop_ns),...
                sprintf('\n%5.2f (ns) MAX Start-Stop\n', MaximumStartStop_ns));
            
            % profile viewer
            % profile off
            
        end
        
        
        
    end
    
end

