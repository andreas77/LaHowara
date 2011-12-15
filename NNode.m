 classdef NNode < handle & SpatialElement  
 % Class represents network intersections.
 
    properties (Access = private)
        toLinks = NLink.empty(0,0);      % links to this node
        fromLinks = NLink.empty(0,0);    % links away from this node
        currentAgent;                   % agent, which is currently on the intersection
    end
    
    methods
        function this = NNode(id, position_x, position_y)
            this = this@SpatialElement(id, position_x, position_y);
        end  
        
        function [hasAgent] = hasAgent(this)
            hasAgent = false;
            if (~isempty(this.currentAgent)) 
                hasAgent = true;
            end
        end
        
        function addToLink(this, link)
            this.toLinks(end + 1) = link;
        end
        
        function addFromLink(this, link)
            this.fromLinks(end + 1) = link;
        end
        
        function setAgent(this, agent)
            this.currentAgent = agent;
        end
        
        function [agent] = getAgent(this)
            agent = this.currentAgent;
        end
        
        function [toLinks] = getToLinks(this)
            toLinks = this.toLinks;
        end
        
        function [fromLinks] = getFromLinks(this)
            fromLinks = this.fromLinks;
        end
    end
end