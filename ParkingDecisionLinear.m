classdef ParkingDecisionLinear < handle & ParkingDecision
    % Defines the probability that an agent parks. The probability
    % decreases linearly with distance from the destination.
    %   The distance at which a parking probability is 1 is given by the
    %   acceptanceRadiusModel, which increases with time.
    
    properties
       %in ParkingDecision. acceptanceRadiusModel / decreasing slope
    end
    
    methods
        function this = ParkingDecisionLinear(spatialResolution, startAcceptanceRadius, decreasingSlope, timeToDoubleRadius)
            this = this@ParkingDecision(spatialResolution);
            this.acceptanceRadiusModel = AcceptanceRadiusLinear(startAcceptanceRadius,timeToDoubleRadius); %AcceptanceRadiusQuadratic(startAcceptanceRadius, timeToDoubleRadius);
            this.decreasingSlope = decreasingSlope;
        end
        
            
        function p = parkProbability(this, elapsedSearchTime, distanceToDestination)
           
            p = 1-this.decreasingSlope.*(distanceToDestination - this.acceptanceRadiusModel.acceptanceRadius(elapsedSearchTime));
    %                 if(p > 1)
    %                     p = 1;
    %                 elseif(p < 0)
    %                     p = 0;
    %                 end       
            tooBig = (p>1); % set values to one, where value too big
            tooSmall = (p<0); % set Values to zero, where value too small
            p = p - p.*tooBig + tooBig - p.*tooSmall; %Bsp [ -3 0.5 3] tooBig = [0 0 1], tooSmall = [1 0 0] -> p = [0 0.5 1] 
            
        end        
    end   
end

