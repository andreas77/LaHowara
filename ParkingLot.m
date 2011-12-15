classdef ParkingLot < handle & SpatialElement
% Represents (1..n) parking lots associated with a cell. If multiple real parking lots are merged capacity is increased accordingly.
    properties (Access = private)
        size;
        agents = Agent.empty(0,0);
    end
    
    methods
        function this = ParkingLot(id, position_x, position_y, size)  
            this = this@SpatialElement(id, position_x, position_y); 
            this.size = size;
        end 
                
        function [isFree] = isFree(this)
            isFree = (this.size > length(this.agents));
        end
        
        function [isEmpty] = isEmpty(this)
            isEmpty = isempty(this.agents);
        end
        
        function [add] = increaseSizeBy(this, addedSpaces)
            this.size = this.size + addedSpaces;
            add = true;
        end
        
        function addAgent(this, agent)
            this.agents(end + 1) = agent;
        end
        
        function [agents] = getAgents(this)
            agents = this.agents;
        end
        
        function [size] = getSize(this)
            size = this.size;
        end
        
        function [occupied] = getNrOccupiedSpaces(this)
            occupied = length(this.agents);
        end
        
        function [removedAgents] = handleAllAgents(this, currentTime)
            removedAgents = Agent.empty(0,0);
            for i=1:length(this.agents)
                agent = this.agents(i);
                if (agent.leaveParkingLot(currentTime)) 
                    this.removeAgent(agent)
                    removedAgents = [agent removedAgents];
                end
            end
        end   
    end
    
    methods (Access = private)
         function removeAgent(this, agent)
            index = find(this.agents == agent);
            this.agents(index) = [];  
        end
    end
end