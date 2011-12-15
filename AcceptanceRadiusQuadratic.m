classdef AcceptanceRadiusQuadratic < handle
% Computes d_acceptance used in ParkingDecision 
    
    properties
        startAcceptanceRadius;
        timeToDoubleStartRadius;
    end
    
    methods
        function this = AcceptanceRadiusQuadratic(startRadius, timeToDoubleRadius)
            this.startAcceptanceRadius = startRadius;
            this.timeToDoubleStartRadius = timeToDoubleRadius;
        end
        
        function r = acceptanceRadius(this, elapsedSearchTime)
            r = this.startAcceptanceRadius + (elapsedSearchTime).^2 * this.startAcceptanceRadius./(this.timeToDoubleStartRadius).^2;
        end
    end
    
end

