classdef CAServer < handle  
% Handles the helper data structures of the CA. Does not adapt the
% infrastructure itself.

    properties (Access = private)
        % occupied data structures: pointers to the infrastructure for efficient handling -----
        % do not iterate over link cells but over agents for efficiency reasons
        occupiedLinkCells_Queue =  containers.Map();  %id = link id     
        occupiedNodes = {}; % test if faster than NNode.empty(0,0); % iterate over occupied nodes only
        occupiedParkingLots = ParkingLot.empty(0,0); % iterate over occupied parking lots only       
        waitingForNodes_Queue = containers.Map(); % id = node id
        
        removeNodeIndices = [];
        removeAgentsFromLinkQueue = [];
        removeKeys = {};
    end
    
    methods
      function this = CAServer()
      end
        
      function init(this, infrastructure)      
         nodes = infrastructure.getNodes();
         keys = nodes.keys();
         for i = 1:numel(keys) % could also use nodes.Count here
            key = keys{i};
            node = nodes(key);
            if (node.hasAgent())
                this.addOccupiedNode(node); %this.occupiedNodes{end + 1} = node;
            end
         end
      end % function
      
      function enterLink(this, link, agent)
          if (~isKey(this.occupiedLinkCells_Queue, link.getId())) 
             this.occupiedLinkCells_Queue(link.getId()) = IQueue(Agent.empty(0,0)); 
          end
          linkagentqueue = this.occupiedLinkCells_Queue(link.getId());
          linkagentqueue.addElement(agent);
          this.leaveNode(link.getFromNode());
      end
      
      function leaveNode(this, node)
          removed = false;
          for idx = 1 : length(this.occupiedNodes)
              if this.occupiedNodes{idx} == node
                  removed = true;
                this.removeNodeIndices = [idx this.removeNodeIndices];
              end  
          end
          %DEBUG
          if ~removed
              error = 'leaveNode, node not found';
              disp(error);
          end
      end
      
      function finishNodes(this)
          this.occupiedNodes(this.removeNodeIndices) = []; % TODO: is this correct?
          this.removeNodeIndices = [];
      end
      
      function [nodes] = getOccupiedNodes(this) 
          nodes = this.occupiedNodes;
      end 
      
      function [node] = getOccupiedNode(this, index)
          node = this.occupiedNodes{index};
      end
      
      function [key] = getLinkQueuesKey(this, index)
          keys = this.occupiedLinkCells_Queue.keys();
          key = keys{index};
      end
      
      function [s] = getLinkQueuesSize(this)
          s = this.occupiedLinkCells_Queue.Count;
      end
      
      function [s] = getOccupiedNodesSize(this)
            s = length(this.occupiedNodes);
      end
      
      function [queue] = getLinkAgentQueue(this, key)
          queue = this.occupiedLinkCells_Queue(key);
      end
      
      function [queue] = getNodeAgentQueue(this, key)
          queue = this.waitingForNodes_Queue(key);
      end
      
      function [l] = getNodeWaitingQueueLength(this)
          l = this.waitingForNodes_Queue.Count;
      end
      
      function [key] = getWaitingQueuesKey(this, index)
          keys = this.waitingForNodes_Queue.keys();
          key = keys{index};
      end
            
      function finishLinks(this, infrastructure)
          removeKeyIndices = [];
          keys = this.occupiedLinkCells_Queue.keys();
          for i = 1:length(keys)
              link = infrastructure.getLinkById(keys{i});
              if (link.getNumberOfAgentsOnLinkOrInParkings() == 0)
                    removeKeyIndices = [i removeKeyIndices];
              end
          end
          for i = 1:length(removeKeyIndices)
            remove(this.occupiedLinkCells_Queue, keys{removeKeyIndices(i)});
          end
          removeKeyIndices = [];
      end
      
      function updateParkings(this, currentTime, infrastructure)
          % check if an agent wants to leave parking.
          % TODO: this should be made faster somehow. Not yet an idea how.
          % Maybe agents should notify observer, when they are ready to
          % leave. -> pushing instead of polling. -> event-based instead of
          % time-teps based
           removedAgents = Agent.empty(0,0);
           emptyParkingLotsIndices = [];
           for i=1:length(this.occupiedParkingLots)
               parkingLot = this.occupiedParkingLots(i);
               removedAgents = [parkingLot.handleAllAgents(currentTime) removedAgents]; % TODO: not nice to have this call here, as it changes the infrastructure!
               if (parkingLot.isEmpty()) 
                   index = find(this.occupiedParkingLots == parkingLot);
                   emptyParkingLotsIndices = [i emptyParkingLotsIndices];                                    
               end
           end
           this.occupiedParkingLots(emptyParkingLotsIndices) = [];
            
           for i = 1:length(removedAgents) % add agents that left parking lot to the waiting queue of their destination node
               agent = removedAgents(i);
               this.addAgentToWaitungQueue(agent.getDestinationNode(), agent);
           end
      end   
            
      function parkAgent(this, key, parkingLot)
          if (isempty(find(this.occupiedParkingLots == parkingLot))) % parking lot is not yet in ca datastructure 
            this.occupiedParkingLots(end + 1) = parkingLot;                         
          end 
          linkagentqueue = this.getLinkAgentQueue(key);          
          this.removeAgentsFromLinkQueue = [linkagentqueue.getCurrentIndex() + 1 this.removeAgentsFromLinkQueue];  
      end      
      
      function moveAgentFromLinkToNode(this, key, toNode)
        linkagentqueue = this.getLinkAgentQueue(key);
        this.removeAgentsFromLinkQueue = [linkagentqueue.getLastIndex() this.removeAgentsFromLinkQueue];
        this.addOccupiedNode(toNode); %this.occupiedNodes{end + 1} = toNode; % node cannot be occupied        
      end
      
      function finishLinkQueue(this, key)
         linkagentqueue = this.getLinkAgentQueue(key);
         linkagentqueue.removeElements(this.removeAgentsFromLinkQueue);
         this.removeAgentsFromLinkQueue = [];
      end
      
      function [agent] = moveAgentFromWaitingQueueToNode(this, node)
          agent = [];
           if (isKey(this.waitingForNodes_Queue, node.getId()))
               queue = this.waitingForNodes_Queue(node.getId());
               agent = queue.getLastElement();
               this.addOccupiedNode(node); %this.occupiedNodes{end + 1} = node; % node was empty before
               queue.removeLastElement();
               if (~queue.hasElements())  % if waiting queue is now empty remove the queue from the waiting queues in finishWaitingQueues()
                   this.removeKeys{end + 1} = node.getId();
               end
           end
      end 
      
      function finishWaitingQueues(this)
          if (~isempty(this.removeKeys))
            remove(this.waitingForNodes_Queue, this.removeKeys); 
            this.removeKeys = {};
          end
      end
      
      function addAgentToWaitungQueue(this, nodeId, agent)       
          if (~isKey(this.waitingForNodes_Queue, nodeId))
              this.waitingForNodes_Queue(nodeId) = IQueue(Agent.empty(0,0));
          end
          queue = this.waitingForNodes_Queue(nodeId);
          queue.addElement(agent);         
      end
    end
    
    methods (Access = private)      
        function addOccupiedNode(this, node)
            %disp('DEBUG add node')
            this.occupiedNodes{end+1} = node;
        end
    end
end


