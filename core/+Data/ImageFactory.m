function image = ImageFactory( path )
%IMAGEFACTORY Summary of this function goes here
%   Detailed explanation goes here

[pathstr,name,ext] = fileparts(path)

switch ext
    case '.ptu'
        image = Data.PTUImageData(path);
    otherwise
        error('Unsupported data type!')
end

end

