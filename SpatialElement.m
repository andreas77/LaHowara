 classdef SpatialElement < handle 
 % Abstract class for geographical elements specified by coordinates such as links, cells, parking lots and nodes
    properties (Access = private)
        id;
        position;
    end
    
    methods
        function this = SpatialElement(id, position_x, position_y)
            this.id = id;
            % setting the wrong type can cost you hours! That is why I 
            % prefer strongly typed languages. Rapid prototyping is 10^6 times
            % compensated by debugging
            if ischar(position_x)
                position_x = str2double(position_x);
            end
            if ischar(position_y)
                position_y = str2double(position_y);
            end
            this.position = [position_x; position_y];
        end   
        
        function [x] = getPosition(this)
            x = this.position;
        end
        
        function [id] = getId(this)
            id = this.id;
        end
    end
end