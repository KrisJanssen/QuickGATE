function [ type ] = IdentifyFile( filepath )
%IDENTIFYFILE Summary of this function goes here
%   Small routine to correctly identify the file origin.

% Open the file for reading.
fid = fopen(filepath);

% Read the start of the file.
Ident = transpose(fread(fid, 16, '*char'));

% Close the file handle, all data is in memory now.
fclose(fid);

if strcmp(Ident, 'TimeHarp 200')
    type = 'TH200';
elseif strcmp(Ident(1:6), char('PQTTTR'))
    type = 'PTU';
else
    error('Magic invalid, this is not a known file.');
end

