 classdef SpatialElementDrawer < handle    
 % Used in first time step of SceanrioPlotter to draw link cells. Cells can only be drawn for very small scenarios.
 
 % TODO: rename to SpatialElementDrawer
    methods(Static)       
        function [p] = draw(position, cellLength, rotMatrix, color, cellWidth)            
            %[UpperLeft UpperRight LowerRight LowerLeft]
            dx = cellLength/2.0;
            dy = cellWidth/2.0;
            
            unrotated = [[-dx; dy],[dx; dy],[dx; -dy],[-dx; -dy]];
            rotated = rotMatrix * unrotated;
            % move to position
            moved = rotated + [position, position, position, position];
            
            x = moved(1,:);
            y = moved(2,:);
            
            p = patch(x, y, color);
        end
    end
end