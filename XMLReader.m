classdef XMLReader 
% Basic reader for xml files, interface for xml toolbox.
    properties
        file;
    end
    
    methods
        function this = XMLReader(file)
            this.file = file;
        end
        
        function [struct] = read(this)
            try
                struct = xml_parse(fileread(this.file));
            catch e
                 error(e.message);
            end
        end
    end
end