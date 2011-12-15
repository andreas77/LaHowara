classdef ScenarioPlotter  < handle 
% Plots scenario in real-time and creates a movie
    
    properties
        spatialResolution;
        timeHandle;
        networkInitialized = false;
        agentRadiusXY; 
        nodeRadiusXY;
    end
    
    methods
        function this = ScenarioPlotter(spatialResolution)
            this.spatialResolution = spatialResolution;
            radius = this.spatialResolution;
            agentRadius = radius * 0.3;
            this.agentRadiusXY = [agentRadius agentRadius];
            this.nodeRadiusXY = [radius radius];
        end
        
        function plot(this, links, nodes, population, currentTime) 
            % TODO: split function here for networkInitialized check
            if ~this.networkInitialized
                this.drawCellsAndParkingLots(links);
                this.drawNodes(nodes);
            end
            
            this.drawAgents(population, nodes, currentTime);
            
            x = xlim; y = ylim;  
            timeStr = ['t=  ', num2str(currentTime), ' s  '];
            if(isempty(this.timeHandle))
                this.timeHandle = text(x(2) * 0.95, y(2) * 0.95 , timeStr);
                set(this.timeHandle, 'HorizontalAlignment','right');
            else
                set(this.timeHandle, 'String', timeStr); 
            end
            this.networkInitialized = true;
            
            set(gca, 'FontSize',16);
            xlabel('[m]');
            ylabel('[m]');
        end
    end
    
    methods (Access = private)                  
    	function drawCellsAndParkingLots(this, links)    
            if ~this.networkInitialized
                keys = links.keys();     
                width = 7.5;
                parkingLotLength = 1.5*width;
                parkingColour = ones(1,3)*0.7;

                for i=1:numel(keys)
                    key = keys{i};              
                    link = links(key);
                    cells = links(key).getCells();           

                    rotMatrix = SUtils().rotationMatrix(link);

                    fromPosition = link.getFromNode().getPosition();
                    linkVector = link.getToNode().getPosition() - fromPosition;
                    linkPosition = fromPosition + 0.5.*linkVector;
                    linkLength = SUtils().vectorLength(linkVector);
                    
                    moveParking = [0 1;-1 0]*(width/linkLength*linkVector); % rotMinus90
                    SpatialElementDrawer().draw(linkPosition, linkLength, rotMatrix, 'w', width);

                    for j=1:length(cells)
                        cell = cells(j);
                        % draw link and parking lots
                        if (~isempty(cell.getParkingLot())) 
                            position = cell.getParkingLot.getPosition()+moveParking;
                            SpatialElementDrawer().draw(position, parkingLotLength, rotMatrix, parkingColour, width); 
                        end
                    end  
                end
            end
        end 
      
        function drawAgents(this, population, nodes, currentTime)
            % draw agents
            pLength = length(population);
            for i = 1 : pLength 
                agent = population(i);
                cell = agent.getCell();
                if(~isempty(cell))                          
                    this.drawAgent(cell.getPosition()', agent, currentTime)
                else
                    this.removeAgentFromPlot(agent);                    
                end
            end
            
            keys = nodes.keys();
            for i = 1:numel(keys) % could also use nodes.Count here. TODO: check performance
                key = keys{i};
                if (nodes(key).hasAgent())
                    position = nodes(key).getPosition()';
                    agent = nodes(key).getAgent();
                    drawAgent(this, position, agent, currentTime);
                end
            end  %for       
        end
      
        %position -> [x y] agentRadius -> [rX rY]
        function drawAgent(this, position, agent, currentTime)
            % set color dependent on action of agent
            color = this.getAgentColor(agent, currentTime);
            if(isempty(agent.plotHandle))
                agent.plotHandle = rectangle('Position',[position - this.agentRadiusXY, 2*this.agentRadiusXY],'Curvature',[1,1], 'FaceColor', color); 
            else
                set(agent.plotHandle, 'Position',[position - this.agentRadiusXY, 2*this.agentRadiusXY], 'FaceColor', color)
            end
        end
      
        function drawNodes(this, nodes)       
            keys = nodes.keys();
            for i = 1:numel(keys) % could also use nodes.Count here. TODO: check performance
                key = keys{i};
                position = nodes(key).getPosition()';
                if ~this.networkInitialized
                    rectangle('Position',[position - this.nodeRadiusXY, 2*this.nodeRadiusXY],'Curvature',[1,1], 'FaceColor','w');
                end
            end  %for     
        end % function
    end % methods
    
    methods(Static)
        function [color] = getAgentColor(agent, currentTime)
            color = 'b';
            if (agent.isSearching(currentTime))
                color = 'r';
            end
            if (agent.getParkTime() > 0)
                color = ones(1,3)*0.8;
            end
            if (agent.isTransit())
                color = 'y';
            end
        end
      
        function removeAgentFromPlot(agent)
            if ~isempty(agent.plotHandle)
                delete(agent.plotHandle)
                agent.plotHandle = [];
            end
        end
    end
end % classdef