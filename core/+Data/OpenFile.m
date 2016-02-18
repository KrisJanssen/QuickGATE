function [ filepath, imdata ] = OpenFile()
%OPENFILE opens a file at a specific location and returns an image.

[file, path] = uigetfile('*.ptu','Select a file');

if path == 0
    return
else
    
    filepath = strcat(path, file);
    imdata = Data.ImageFactory(filepath);
    
end

end

