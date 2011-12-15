classdef ParkingDecisionQuadratic < handle & ParkingDecision
    % Defines the probability that an agent parks. The probability
    % decreases quadratically with distance from the destination.
    %   The distance at which a parking probability is 1 is given by the
    %   acceptanceRadiusModel, which increases with time.
    
    properties
        %in ParkingDecision. acceptanceRadiusModel / decreasing slope
    end
    
    methods
        function this = ParkingDecisionQuadratic(spatialResolution, startAcceptanceRadius, decreasingSlopeToRMax, timeToDoubleRadius)
            this = this@ParkingDecision(spatialResolution);
            this.acceptanceRadiusModel = AcceptanceRadiusLinear(startAcceptanceRadius, timeToDoubleRadius);
            this.decreasingSlope = abs(decreasingSlopeToRMax);
        end
        
            
        function p = parkProbability(this, elapsedSearchTime, distanceToDestination)     
                rA = this.acceptanceRadiusModel.acceptanceRadius(elapsedSearchTime); % rA darf nicht 0 sein
                rA = rA + (rA <=0); % set to one mimimum -> nid so wirklich hübsch
                
                rMax = rA + 1/this.decreasingSlope; 
            
                %f2
                p = (distanceToDestination.^2 - (2.*rMax).*distanceToDestination + rMax.^2)./((rA-rMax).^2); %.^ etc -> dann sollte es auch mit Matrizen funktionieren
                
                %ab hier funktionierts nicht mehr mit Matrizen
%                 if(p > 1) 
%                     p = 1;
%                 elseif(p < 0)
%                     p = 0;
%                 end  

                %Matrix Version / function consists of 3 parts f1 -> all 1;
                %f2 -> quadratic; f3 -> all 0
                f1 = (distanceToDestination < rA);   % set values to one, distance < rA
                f3 = (distanceToDestination > rMax); % set Values to zero, where distance > rMax
                p = p - p.*f1 + f1 - p.*f3; %Bsp [ -3 0.5 3] f1 = [0 0 1], f3 = [1 0 0] -> p = [0 0.5 1]   
        end    
        
%         function p = isSearchStarting(this, distanceToDestination)
%             r = 90; %this.acceptedDistance(0.8, 0);
%             p = (distanceToDestination <= r || distanceToDestination < 2*this.spatialResolution); %start searching as soon as radius acceptance is 1  
%         end 
    end
    
    methods(Access = private)
        
        function dist = acceptedDistance(this, parkProbability, elapsedSearchTime)
            % Distance at which a parking is accepted with parkProbability
            % at a given elapsedSearchTime (default = 0)
            % parkProbability / elapsedSearchTime have to be column vectors of same size
            % eg: [0.3; 0.5; 0.7], [300 300 300]
            if nargin < 3
                elapsedSearchTime = 0;
            end
            
            rA = this.acceptanceRadiusModel.acceptanceRadius(elapsedSearchTime);
            rMax = rA + 1/this.decreasingSlope;
            
            dist = sqrt(parkProbability).*(rA - rMax) + rMax;
        end
    end   
end

