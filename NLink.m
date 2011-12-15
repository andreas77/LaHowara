classdef NLink < handle 
% Component represents network roads.
    properties
        id;
        toNode;
        fromNode;
        cells; % vector of cells
        nAgents = 0;
        spatialResolution;
        maxSpeed = 50.0 / 3.6; % 50km/h
        minSpeed;
    end
    
    methods
        function this = NLink(id, fromNode, toNode, spatialResolution)
            this.id = id;
            this.fromNode = fromNode;
            this.toNode = toNode;
            this.spatialResolution = spatialResolution;
            this.minSpeed = this.spatialResolution + 2.0;
        end
                        
        function [successful] = leave(this)
          successful = false;
          lastCell = this.getLastCell();
          if (lastCell.hasAgent() && ~(this.toNode.hasAgent()))
             % update infrastructure
             agent = lastCell.getAgent();
             this.toNode.setAgent(agent);             
             agent.resetCell(); 
             lastCell.reset(); 
             this.nAgents = this.nAgents - 1;
             successful = true;
          end
        end
                        
        function update(this, agent, timeStep, currentTime)    
            currentCell = agent.getCell(); % so there is an agent in that cell
            
            % find cell which is reached with v * Delta(t) or head of gap            
            nextCell = this.getNextCell(agent, timeStep, currentTime); % find cell of agent
            currentCell.reset();
            if (isempty(agent.getParkingLot()) || agent.leaveParkingLot(currentTime)) % agent is on the road
                nextCell.setAgent(agent);
            end
            agent.setCell(nextCell); 
        end
                
        function [successful] = enter(this, agent)
            successful = false;       
            firstCell = this.cells(1);            
            if (~firstCell.hasAgent()) % first cell has no agent    
                this.cells(1).setAgent(agent); % put agent into first cell
                this.nAgents = this.nAgents + 1;
                agent.setCell(this.cells(1));
                successful = true;
            end
        end      
                    
        function [cells] = getCells(this) 
            cells = this.cells;
        end
        
         function [fromNode] = getFromNode(this) 
            fromNode = this.fromNode;
         end
        
         function [toNode] = getToNode(this) 
            toNode = this.toNode;
         end
         
         function [id] = getId(this)
             id = this.id;
         end;
         
         function [nAgents] = getNumberOfAgentsOnLinkOrInParkings(this)
             nAgents = this.nAgents;
         end
         
         function [lastCell] = getLastCell(this)
             lastCell = this.cells(length(this.cells));
         end
         
         function [cell] = getCell(this, id)
             if (id > length(this.cells))
                 id = length(this.cells);
             end
             cell = this.cells(id);
         end
        
         function [cells] = createCells(this) 
             linkLength = SUtils().length(this.fromNode, this.toNode);
             numberOfCells = ceil(linkLength / this.spatialResolution);
             this.cells = LCell.empty(numberOfCells, 0); 
             
             dxy = (this.toNode.getPosition() - this.fromNode.getPosition())./numberOfCells;
             
             dxy_norm = dxy/norm(dxy);
             p = [- dxy_norm(2); dxy_norm(1)];
             
             cellLength = linkLength / numberOfCells;
             xIndex = 1;
             yIndex = 2;
             for i = 1:numberOfCells   
                 position = this.fromNode.getPosition() + (i-0.5)*dxy - p; % add half of the cell length. position is mid point of cell!
                 this.cells(i) = LCell(i, position(xIndex), position(yIndex), cellLength);
             end            
             cells = this.cells;
         end
    end
    
    methods (Access = private)   
        function [cell] = getNextCell(this, agent, timeStep, currentTime)
            currentIndex = agent.getCell().getId();
            nextIndex = min(currentIndex + floor(agent.getCurrentSpeed() * timeStep / this.spatialResolution), length(this.cells)); % min(id, id(link length))
            nextCellIndex = this.moveOrParkInGap(currentIndex + 1, nextIndex, agent, currentTime, timeStep); % start at next cell not current cell
            cell = this.getCell(nextCellIndex);
        end
        
        function [index] = moveOrParkInGap(this, startIndex, endIndex, agent, currentTime, timeStep)
            index = endIndex;                      
            for i = startIndex:endIndex 
                cell = this.getCell(i);
                if (~cell.hasAgent()) % cell is reachable
                    index = i;
                    if (this.isParking(agent, cell, currentTime))
                       break;
                    end
                    if (i + 1 < length(this.cells) && ~this.getCell(i + 1).hasAgent()) % next cell is also free
                        newSpeed = max(this.minSpeed, min(agent.getCurrentSpeed() + this.spatialResolution / timeStep + rand(), this.maxSpeed - rand()));
                        agent.setCurrentSpeed(newSpeed); % step 1 and 2 of NaSch 
                    end
                else
                    index = i - 1; % go to last free cell of gap
                    newSpeed = max(this.minSpeed, min((index - startIndex + 1) / timeStep *  this.spatialResolution - rand(), this.maxSpeed - rand())); % + 1 as we start at agent's current position + 1! -> (startIndex - 1 - startIndex + 1) if agent should not move
                    agent.setCurrentSpeed(newSpeed); % step 2 and 3 of NaSch
                    break;
                end
            end
        end
        
        function [successful] = isParking(this, agent, cell, currentTime)
            successful = false;
            
            if (~isempty(agent.getParkingLot())) % agent has already parked
                return;
            end
                                   
            if (~isempty(cell.getParkingLot()) && cell.getParkingLot().isFree() && this.isAgentParkingHere(agent, cell.getParkingLot(), currentTime))
                cell.reset();
                parkingLot = cell.getParkingLot();
                parkingLot.addAgent(agent); 
                successful = true;
                % str = sprintf('%s %i', parkingLot.getId(), parkingLot.getSize());
                % disp(str);
            end
        end
        
        function [park] = isAgentParkingHere(this, agent, parkingLot, currentTime)
            agent.addParkingLotToMemory(parkingLot); % TODO: check if parking link is free and add to good or bad list
            park = agent.isParkingLotChosen(currentTime, parkingLot); % here parking lot is assigned to agent with prob.
        end
    end
end