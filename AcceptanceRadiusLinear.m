classdef AcceptanceRadiusLinear
% Computes d_acceptance used in ParkingDecision 
    
    properties
        startAcceptanceRadius;
        timeToDoubleStartRadius;
    end
    
    methods
        function this = AcceptanceRadiusLinear(startRadius, timeToDoubleRadius)
            this.startAcceptanceRadius = startRadius;
            this.timeToDoubleStartRadius = timeToDoubleRadius;
        end
        
        function r = acceptanceRadius(this, elapsedSearchTime)
            r = this.startAcceptanceRadius + (elapsedSearchTime).* this.startAcceptanceRadius./(this.timeToDoubleStartRadius);
        end
    end
    
end

