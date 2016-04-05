classdef FileManager < handle
    %FILEMANAGER The FM Model.
    %   TODO: Add.
    
    properties (SetObservable = true)
        changedfile;
        files;
        selected;
        visible;
    end
    
    properties (Access = private)
        list;
    end
    
    events
        FileOpened
        FileClosed
    end
    
    methods
        
        function obj = FileManager()
            
            obj.list = mcodekit.list.dl_list();
            
        end
        
        function CloseFile(obj, idx)
            obj.changedfile = idx;
            obj.list.remove_key(idx);
            
            obj.UpdateFiles();
            
            notify(obj, 'FileClosed');
        end
        
        function OpenFile(obj)
            
            [filepath, ~] = Data.OpenFile();
            fileinfo = struct('path', filepath, 'visible', 1);
            
            obj.list.append_key(fileinfo);
            
            obj.UpdateFiles();
            
            obj.changedfile = obj.list.length;
            
            notify(obj, 'FileOpened');
            
        end
      
    end
    
    methods (Access = private)
        
        function UpdateFiles(obj)
            
            filestmp = {obj.list.length};
            visibletmp = [obj.list.length];
            
            idx = 1;
            iterator = obj.list.get_iterator(); 
            
            while (iterator.has_next())
                infotmp = iterator.next();
                filestmp{idx} = infotmp.path;
                visibletmp(idx) = infotmp.visible;
                idx = idx + 1;
                
            end
            
            obj.files = filestmp;
            obj.visible = visibletmp;
            
        end
        
    end
    
end

