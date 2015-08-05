function [ ImageData, gmin, gmax, SYNCRate, messages ] = ExtractImagePTU( filepath, gmin, gmax, tshift )
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
global fid
global TTResultFormat_TTTRRecType;
global TTResult_NumberOfRecords; % Number of TTTR Records in the File;
global TTResult_SyncRate;        % The laser Sync rate
global MeasDesc_Resolution;      % Resolution for the Dtime (T3 Only)
global MeasDesc_GlobalResolution;

TTResultFormat_TTTRRecType = 0;
TTResult_NumberOfRecords = 0;
MeasDesc_Resolution = 0;
MeasDesc_GlobalResolution = 0;


%% Start reading header data
fid=fopen(filepath);

fprintf(1,'\n');
Magic = fread(fid, 8, '*char');
if not(strcmp(Magic(Magic~=0)','PQTTTR'))
    error('Magic invalid, this is not an PTU file.');
end;
Version = fread(fid, 8, '*char');
fprintf(1,'Tag Version: %s\n', Version);

% there is no repeat.. until (or do..while) construct in matlab so we use
% while 1 ... if (expr) break; end; end; to read right up to the end of the
% header.
while 1
    % read Tag Head
    TagIdent = fread(fid, 32, '*char'); % TagHead.Ident
    TagIdent = (TagIdent(TagIdent ~= 0))'; % remove #0 and more more readable
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
%     if strcmp(EvalName, 'TTResult_SyncRate')
%         TTResult_SyncRate = TagInt;
%     end
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

% Read the actual data from disk as uint32.
Data = uint32(fread(fid, 'uint32'));

% Close the file handle, all data is in memory now.
fclose(fid);

%% Render the data
global cnt_ph;
global cnt_ov;
global cnt_ma;
cnt_ph = 0;
cnt_ov = 0;
cnt_ma = 0;
% choose right decode function
switch TTResultFormat_TTTRRecType;
    case rtHydraHarpT3
        [ ImageData, gmin, gmax, SYNCRate, messages ] = BuildImage( ...
            Data, gmin, gmax, tshift, MeasDesc_GlobalResolution, MeasDesc_Resolution, TTResult_SyncRate);
    case {rtHydraHarp2T3, rtTimeHarp260NT3, rtTimeHarp260PT3}
        isT2 = false;
        [ ImageData, gmin, gmax, SYNCRate, messages ] = BuildImage( ...
            Data, gmin, gmax, tshift, MeasDesc_GlobalResolution, MeasDesc_Resolution, TTResult_SyncRate);
    otherwise
        error('Illegal RecordType!');
end;

end