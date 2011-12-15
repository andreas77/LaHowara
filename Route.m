classdef Route < handle
% Composed of sequence of nodes.    
    properties (Access = private)
        nodes = {};
    end
    
    methods        
        function appendNode(this, nodeId) 
            this.nodes(end + 1) = nodeId;
        end
        
        function setRoute(this, nodeIds)
            this.nodes = nodeIds;
        end
        
        function resetRoute(this) 
            this.nodes = {};
        end
                
        function [link] = getNextLink(this, currentNode, infrastructure)
            link = []; 
            currentNodeId = currentNode.getId();
            nextNodeId = this.getNextNode(currentNodeId);
            
            if (~isempty(nextNodeId))
                link = infrastructure.getLink(currentNodeId, nextNodeId);
            end
        end  
        
        function originNode = getOriginNodeId(this)
            originNode = this.nodes{1};
        end
        
        function destinationNode = getDestinationNodeId(this)
            destinationNode = this.nodes{end};
        end
     end
    
    methods (Access = private)
        function [node] = getNextNode(this, currentNodeId) 
            % working with currentIndex instead of traversing 
            % route again and again is much faster but overwhelmingly complex!
            % We have waiting agents at nodes which  neverthless call
            % getNextLink
            node = [];
            for i = 1:(length(this.nodes) - 1)
                if (strcmp(this.nodes{i}, currentNodeId))
                    node = this.nodes{i + 1};
                end
            end
        end
    end
end