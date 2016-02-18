classdef FileManager < handle
    %FILEMANAGER The FM Model.
    %   TODO: Add.
    
    properties (SetObservable = true)
        files;
    end
    
    properties (Access = private)
        map;
    end
    
    methods
        
        function obj = FileManager()
            obj.map = containers.Map;
        end
        
        function OpenFile(obj, file)
            
            [filepath, ~] = Data.OpenFile();
            obj.map(num2str(obj.map.Count + 1)) = filepath;
            obj.files = values(obj.map);
        end
        
    end
    
end

