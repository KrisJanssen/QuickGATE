function [ ] = StackDump( gmin, gmax, tshift, fskip, bidir)
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
    %filepath = '/Users/Kris/Desktop/Test/corr_000.ptu'
    [path, name, ext ] = fileparts(filepath)
    
    type = IdentifyFile(filepath);
    
    if strcmp(type, 'PTU')
        [ ImageData, gmin, gmax, SYNCrate, messages ] = ...
            ExtractMultiImagePTU(filepath, gmin, gmax, tshift, fskip, bidir);
    end
    
end
profile off

profile viewer
end

