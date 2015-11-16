function [ filepath, imfile ] = OpenFile()
%OPENFILE Summary of this function goes here
%   Detailed explanation goes here


[file, path] = uigetfile('*.ptu','Select a file');

if path == 0
    return
else
    
    filepath = strcat(path, file);
    imfile = Data.ImageFactory(filepath);
    
end

end

