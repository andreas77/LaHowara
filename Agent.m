classdef Agent < handle
% Behavioral unit of simulation. This component stores variables for and references to decision making and the agent's intentions.   
    
    properties
        plotHandle;
    end
    
    properties (Access = private)
        id;
        originNode;
        destinationNode;
        tripStartTime;
        actDur; 
        parkingDecisionType;
        routeChooser;
        routeTo;
        routeAway;
        transit;
        
        shortTermMemorySize = 10;
        shortTermParkingMemory; %x, y, occupied, size
        parkingIdsMemory = {};
                
        adaptedRoute;
        startTimeSearchingForParking = -1.0;  
        currentSpeed = 10.0; % m/s
        
        cell;
        
        % for analysis
        parkTime = -99.0;
        parkingLot;
        
        infrastructure;
        
        hasPrivateParking;
    end
    
    methods
        function this = Agent(id, tripStartTime, parkingDecisionType, routeTo, routeAway, actDur, transit, infrastructure, hasPrivateParking)
            this.id = id;
            this.tripStartTime = tripStartTime;
            this.actDur = actDur;
            this.transit = transit;
            this.routeTo = routeTo;
            this.routeAway = routeAway;
            
            if (transit)
                this.originNode = routeAway.getOriginNodeId();
                this.destinationNode = routeAway.getDestinationNodeId();               
            else 
                this.originNode = routeTo.getOriginNodeId();
                this.destinationNode = routeTo.getDestinationNodeId();
            end
            this.parkingDecisionType = parkingDecisionType;
            %this.routeChooser = RandomRouteChoice();
            this.routeChooser = WeightedRandomRouteChoice();
            this.shortTermParkingMemory = repmat([-999999; -999999; 1; 1], 1, this.shortTermMemorySize);
            this.infrastructure = infrastructure;
            this.hasPrivateParking = hasPrivateParking;
        end
                
        function [originNode] = getOriginNode(this)
        % corresponds with start node of route
            originNode = this.originNode;
        end

        function [link] = getNextLink(this, currentNode)
            % either give next link on the route to destination or give next link for parking search
            if (this.startTimeSearchingForParking < 0 && (~this.transit)) % agent has not yet started parking search -> follow routeTo
                 link = this.routeTo.getNextLink(currentNode, this.infrastructure); 
            else
                if (this.parkTime > 0 || this.transit) % agent has left parking lot and is now on the way back home -> follow routeAway
                   link = this.routeAway.getNextLink(currentNode, this.infrastructure); 
                else % agent searches a parking lot
                    destination = this.infrastructure.getNodeById(this.destinationNode).getPosition();
                    linkAlternatives = currentNode.getFromLinks();
                    link = this.routeChooser.chooseLink(currentNode.getPosition(), destination, this.shortTermParkingMemory, linkAlternatives);
                end
            end
            
            %DEBUG
            %link
        end
        
        function [isSearching] = isSearching(this, currentTime)
            isSearching = (this.startTimeSearchingForParking > 0 && currentTime >= this.startTimeSearchingForParking && this.parkTime < 0);
            
            if (~isSearching)
                isSearching = this.tryStartSearching(currentTime); 
            end         
        end 
        
        function setCell(this, cell)
            this.cell = cell;
        end
        
        function [cell] = getCell(this)
            cell = this.cell;
        end
        
        function resetCell(this)
            this.cell = [];
        end
            
        function [agentId] = getId(this)
            agentId = this.id;
        end
        
        function [currentSpeed] = getCurrentSpeed(this)
            currentSpeed = this.currentSpeed;
        end
        
        function setCurrentSpeed(this, speed)
            this.currentSpeed = speed;
        end
        
        function [startSearchTime] = getStartSearchTime(this)
            startSearchTime = this.startTimeSearchingForParking;
        end
        
        function [parkTime] = getParkTime(this)
            parkTime = this.parkTime;
        end
        
        function [searchDur] = getSearchDuration(this)
            searchDur = -99;
            if(this.parkTime > 0 && this.startTimeSearchingForParking > 0)
                searchDur = this.parkTime - this.startTimeSearchingForParking;
            end
        end
        
        function [parkingLot] = getParkingLot(this)
            parkingLot = this.parkingLot;
        end
        
        function [node] = getDestinationNode(this)
            node = this.destinationNode;
        end
        
        function [isTransit] = isTransit(this)
            isTransit = this.transit;
        end
        
        function [leaveParkingLot] = leaveParkingLot(this, currentTime)
            % make this dependent on arrival time + activity duration
            leaveParkingLot = false;
            if (currentTime >= (this.parkTime + this.actDur))
                leaveParkingLot = true;
            end
        end
        
        function [distanceToDestination] = getDistance2Destination(this, parkingLot)
        % returns crow-fly distance to destination from a given parking lot
            destination = this.getDestination(this.infrastructure);
            distanceToDestination = SUtils().length(destination, parkingLot);
        end
        
        function [tripStartTime] = getTripStartTime(this)
            tripStartTime = this.tripStartTime;
        end
       
        function [parkHere] = isParkingLotChosen(this, currentTime, parkingLot)
            % check if free ...
            distanceToDestination = this.getDistance2Destination(parkingLot);
            parkHere = false;

            if(this.isSearching(currentTime))
                p = this.parkingDecisionType.parkProbability(currentTime - this.startTimeSearchingForParking, distanceToDestination);
                parkHere = (rand(1) < p);
            end
            if (parkHere)
                this.parkTime = currentTime;
                this.parkingLot = parkingLot;
                this.cell = [];
            end
        end   

        % called in NLink.parkAgent
        function addParkingLotToMemory(this, parkingLot)
            parkingMemory = [parkingLot.getPosition(); parkingLot.getNrOccupiedSpaces(); parkingLot.getSize()];   
            removedIdx = this.addIdToParkingMemory(parkingLot.getId());
            
            if(isempty(removedIdx))
                this.shortTermParkingMemory = [parkingMemory this.shortTermParkingMemory(:,1:this.shortTermMemorySize-1)];
            else
                this.shortTermParkingMemory = [parkingMemory this.shortTermParkingMemory(:,1:removedIdx-1) this.shortTermParkingMemory(:,removedIdx+1:this.shortTermMemorySize)];
            end
        end

        function [this,idx] = sort(this, varargin)
            [~,idx] = sort([this.tripStartTime], varargin{:});  
            this = this(idx);
        end   
       
        function [hasPrivateParkingSpace] = hasPrivateParkingSpace(this)
            hasPrivateParkingSpace = this.hasPrivateParking;
        end
    end

    methods (Access = private)
        
        function removedIdx = addIdToParkingMemory(this, parkingLotId)
            size = length(this.parkingIdsMemory);
            removedIdx = find(strcmp(this.parkingIdsMemory, parkingLotId));
            
            % move memories one back
            if(isempty(removedIdx))
                if(size >= this.shortTermMemorySize)
                    startIndex = size - 1; %overwrite last item, move all others one back
                else
                    startIndex = size; %move all existin items one back
                end
            else
                startIndex = removedIdx - 1; %move parkingLotId to the front, move all before that one back
            end

            for ind = startIndex : -1 : 1
                this.parkingIdsMemory(ind+1) = this.parkingIdsMemory(ind);
            end

            % add new memory
            this.parkingIdsMemory(1) = {parkingLotId};  
        end
        
        function dest = getDestination(this, infrastructure)
            dest = infrastructure.getNodeById(this.destinationNode);
        end
        
        function isSearching = tryStartSearching(this, currentTime)   
           isSearching = false;
                      
           if (this.transit) % agent never wants to park 
               return;
           end 
           
           if (isempty(this.cell)) % agent is parking or in a waiting queue
               return;
           end
                      
           distanceToDestination = SUtils().length(this.getDestination(this.infrastructure), this.cell);
                                 
           if(this.parkTime < 0) % agent has not yet parked
               if (this.parkingDecisionType.isSearchStarting(distanceToDestination)) % agent wants to start searching now
                 this.startTimeSearchingForParking = currentTime;
                 % here speed during parking search could be adapted
                 % newSpeed = this.getCurrentSpeed() * 0.8;
                 % this.setCurrentSpeed(newSpeed); % adapt speed for parking search
                 isSearching = true;
               end
           end
        end
    end
end