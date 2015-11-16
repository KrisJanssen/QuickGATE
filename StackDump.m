function [ ] = StackDump( gmin, gmax, tshift)
profile on
%STACKDUMP Summary of this function goes here
%   Detailed explanation goes here

close all

colormap jet

[file, path] = uigetfile('*.ptu;*.t3r','Select a file');

if path == 0
    return
else
    
    filepath = strcat(path, file);
    [path, name, ext ] = fileparts(filepath)
    
    type = IdentifyFile(filepath);
    
    if strcmp(type, 'PTU')
        [ ImageData, gmin, gmax, SYNCrate, messages ] = ...
            ExtractMultiImagePTU(filepath, gmin, gmax, tshift);
    end
    
end
profile off

profile viewer
end

