classdef ParkingDecision < handle
% Abstract class for ParkingDecisionLinear and ParkingDecisionQuadratic.
% Defines probabilty an agent parks at a specific distance and time. 
    
    properties
        decreasingSlope; % defines the point where
        acceptanceRadiusModel;  
        spatialResolution;
        startSearchRadius = 0;
    end
    
    methods
        function this = ParkingDecision(spatialResolution)
            this.spatialResolution = spatialResolution;
        end
        
        function p = isSearchStarting(this, distanceToDestination)
             p = (distanceToDestination <= this.startSearchRadius || distanceToDestination < 2*this.spatialResolution);  
        end       
    end 
    
    methods(Abstract)
      p = parkProbability(this, elapsedSearchTime, distanceToDestination)
    end
end

