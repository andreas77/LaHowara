classdef RandomRouteChoice
    %RANDOMROUTECHOICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = RandomRouteChoice()
            %Ev. Seed hier?
        end
        
        function link = chooseLink(this, currentPosition, destination, shortTermMemory, linkAlternatives)
            r = randi(length(linkAlternatives),1);
            link = linkAlternatives(r);
        end
    end
    
end

