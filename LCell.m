classdef LCell < handle & SpatialElement 
% Basic unit of CA. Consecutive cells constitute a link. Parking lots are attached to cells
    properties 
        hasAgent = false;
    end
        
    properties (Access = private)
        agentInCell;
        parkingLot;
        length;
    end
    
    methods
        function this = LCell(id, position_x, position_y, length)
            this = this@SpatialElement(id, position_x, position_y);
            if ischar(length)
                length = str2double(position_y);
            end
            this.length = length;
        end
                               
        function [m] = setAgent(this, agentInCell) 
            this.agentInCell = agentInCell;
            this.hasAgent = true;
            m = true;
        end
        
        function reset(this) 
            this.agentInCell = [];
            this.hasAgent = false;
        end
                
        function [m] = setParkingLot(this, parkingLot)
            this.parkingLot = parkingLot;
            m = true;
        end
        
        function [parkingLot] = getParkingLot(this)
            parkingLot = this.parkingLot;
        end
        
        function [length] = getLength(this)
            length = this.length;
        end
        
        function [agent] = getAgent(this)
            agent = this.agentInCell;
        end
    end
end