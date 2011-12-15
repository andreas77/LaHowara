classdef Infrastructure < handle
% Component holds network consisting of links and nodes, where links are composed of cells which have parking lots attached. 
% Thus, class provides access to all of supply side. 
    
    properties
        links; % containers.Map() of links referenced by id
        nodes; % containers.Map() of nodes referenced by id
    end
    
    methods
        function this = Infrastructure(nodes, links)
            this.nodes = nodes;
            this.links = links;
        end
        
        function [m] = getLinks(this) 
        % returns containers.Map of links
            m = this.links;
        end
        
        function [nodes] = getNodes(this) 
        % returns containers.Map of nodes
            nodes = this.nodes;
        end
        
        function [node] = getNodeById(this, id) 
            node = this.nodes(id);
        end
        
        function [node] = getLinkById(this, id) 
            node = this.links(id);
        end
        
        function setNodeById(this, id, node)
            this.nodes(id) = node;
        end
        
        function [link] = getLink(this, startNodeId, endNodeId)
            % extract link from infrastructure by start and end node
            %
            % startNode -------------------------------------> endNode
            %              l = startNode.getFromLinks()[i]
            %                                                  l.getToNode()
            link = [];
            endNode = this.getNodeById(endNodeId);
            startNode = this.getNodeById(startNodeId);
            fromLinks = startNode.getFromLinks();
            for i = 1:length(fromLinks) % search the link in fromlinks which has endNode as toNode
                l = fromLinks(i);
                if (l.getToNode() == endNode)
                    link = l;
                end
            end
        end
        
    end
end