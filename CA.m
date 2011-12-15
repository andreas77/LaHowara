classdef CA < handle
    %Cellular automaton updating infrastructure and population
    
    properties(Access = private)
        infrastructure;
        population; 
        
        timeStep; 
        startTime;
        endTime;        
        currentTime = 0;
        
        scenarioPlotter;
        showSimulation;
        recordSimulation = false;
        frameCounter = 0;
        recordFrames;
        
        caServer = CAServer(); % handles the CA data structures
        % TODO: we should have a similar class that adapts the
        % infrastrutcure itself. If agents, links, nodes and parking lots
        % do that all together a mess will probably be the result
        % ------------------------------- 
        
        waitingForSimulationQueue = Agent.empty(0,0);
        removeAgentsFromWaitingForSimulationQueue = [];
    end
    
    methods 
        function this = CA(infrastructure, spatialResolution, timeStep, startTime, endTime, showSimulation)
            this.infrastructure = infrastructure;
            this.scenarioPlotter = ScenarioPlotter(spatialResolution);
            this.timeStep = timeStep;
            this.startTime = startTime;
            this.endTime = endTime;
            this.showSimulation = showSimulation;
        end
        
        function init(this, population) 
            this.population = population;
            this.fillWatingForSimQueue();
            this.caServer.init(this.infrastructure);
            this.currentTime = this.startTime;
        end
        
        function simulate(this)
            disp('running simulation loop ...');
            
            scrsz = get(0,'ScreenSize');
            figure('Position',[100.0 100.0 scrsz(3)/2.0 scrsz(4)/2.0])  % [left, bottom, width, height]
            
            while (this.currentTime <= this.endTime)
                this.update();
                this.plot(this.currentTime);
                this.currentTime = this.currentTime + this.timeStep;
                
                if (mod(this.currentTime, 60) == 0)
                    str = sprintf('current time %i %s', this.currentTime / 60.0, ' min after midnight');
                    disp(str);
                end                
            end
        end
            
        function update(this)
            this.moveAgentsToSimForTimeStep();
            this.updateNodes();
            this.updateParkings();
            this.updateLinks();
            this.updateRemainingWaitingQueues();
        end
        
        function plot(this, time)
            if(this.showSimulation && mod(time, this.timeStep) == 0)
                hold on;
                this.scenarioPlotter.plot(this.infrastructure.getLinks(), this.infrastructure.getNodes(), this.population , time);
                if(this.recordSimulation)
                    this.frameCounter = this.frameCounter + 1;
                    this.recordFrames(:,this.frameCounter) = getframe();  
                end 
                pause(0.0001); % remove asap -> slows down sim
            end
        end
        
%         function added = addFrame(this, frame, time)
%             if size(frame.cdata,1) == 0
%                 added = false
%             else
%                
%             end
%         end
        
        function startRecording(this)
            this.recordFrames = moviein(0);
            this.recordSimulation = true;
        end
        
        function stopAndSaveRecording(this, videoName)
            this.recordSimulation = false;
            disp('Storing frames to video. This may take a while.');
            movie2avi(this.recordFrames, videoName,'fps',60);
        end

    end
    
    methods (Access = private)
           
      function fillWatingForSimQueue(this)
        numberOfAgents = length(this.population);
        cnt = 0;
        waitingForSimulationQueueTmp = Agent.empty(0,0);
        for i=1:numberOfAgents
            agent = this.population(i);
            departureTime = agent.getTripStartTime();
            if (departureTime >= this.startTime && departureTime < this.endTime)
                cnt = cnt + 1;
                waitingForSimulationQueueTmp(end + 1) = agent;
            end
        end 
        str = sprintf('Added %i %s', cnt, ' agents to waitingForSimulationQueue');
        disp(str);
        this.waitingForSimulationQueue = sort(waitingForSimulationQueueTmp); % sort array ascending for faster access        
      end
      
      function moveAgentsToSimForTimeStep(this)
          if (~isempty(this.waitingForSimulationQueue)) 
              agent = this.waitingForSimulationQueue(1);
              departureTime =  agent.getTripStartTime(); % get departure time of first agent in queue
              cnt = 1;
              while ((departureTime <= this.currentTime) && (departureTime >= this.startTime) && (departureTime < this.endTime) && (cnt <= length(this.waitingForSimulationQueue)))                    
                  node = this.infrastructure.getNodeById(agent.getOriginNode());
                  this.caServer.addAgentToWaitungQueue(node.getId(), agent); % put all agent in waitng queue. updateRemainingWaitingQueues is called later                
                  this.removeAgentsFromWaitingForSimulationQueue(end + 1) = cnt; % remove agent from waitingForSimQueue in finish
                  
                  if (cnt <  length(this.waitingForSimulationQueue)) % get departure time of next agent
                     agent = this.waitingForSimulationQueue(cnt + 1);
                     departureTime = agent.getTripStartTime(); 
                  end
                  cnt = cnt + 1;
              end
          end
          this.finishWaitingForSimulationQueue();
      end
      
      function finishWaitingForSimulationQueue(this)
          this.waitingForSimulationQueue(this.removeAgentsFromWaitingForSimulationQueue) = [];
          this.removeAgentsFromWaitingForSimulationQueue = [];
      end
         
      function updateNodes(this)
          randomIndices = randperm(this.caServer.getOccupiedNodesSize());
          for i=1:length(randomIndices)
              node = this.caServer.getOccupiedNode(randomIndices(i));
              this.updateNode(node);
          end
          this.caServer.finishNodes();
      end 
      
      function updateNode(this, node)
          agent = node.getAgent();
          link = agent.getNextLink(node); 
          if (isempty(link)) % agent has arrived at final destination -> remove from simulation. 
              % TODO: We have a problem here iff agent is at destination but
              % does not start searching even now . Although behaviorally
              % implausible this is neverthless a possible scenario!
              % temporary solution: forced search start at destination!
              node.setAgent([]);
              this.caServer.leaveNode(node);
          else
              if (link.enter(agent)) % check if this link can be entered (1st cell must be free)
                  node.setAgent([]);              
                  this.caServer.enterLink(link, agent);
              end 
          end
      end
      
      function updateLinks(this)  
          randomIndices = randperm(this.caServer.getLinkQueuesSize()); % randomize key set
          for i=1:length(randomIndices)    
              key = this.caServer.getLinkQueuesKey(randomIndices(i));
              this.updateLink(key);   
          end  
          this.caServer.finishLinks(this.infrastructure);
          this.caServer.finishWaitingQueues();
      end 
      
      function updateLink(this, key)  
          this.moveAgentToIntersection(key);
          this.caServer.finishLinkQueue(key);
          
          this.moveAgentsOnLink(key); 
          this.caServer.finishLinkQueue(key);
      end
      
      % TODO: nicer if linkagentqueues are not leaving the caServer.
      function moveAgentsOnLink(this, key)
          link = this.infrastructure.getLinkById(key);
          linkagentqueue = this.caServer.getLinkAgentQueue(key);         
          linkagentqueue.prepareForIteration();
          
          while (linkagentqueue.hasMoreElements())
                agent = linkagentqueue.getNextElement();
                link.update(agent, this.timeStep, this.currentTime); 
                parkingLot = agent.getParkingLot();
                if (~isempty(parkingLot) && ~agent.leaveParkingLot(this.currentTime)) % agent has parked
                    this.caServer.parkAgent(key, parkingLot);
                end
          end %while
      end
      
      function moveAgentToIntersection(this, key)
          link = this.infrastructure.getLinkById(key); 
          toNode = link.getToNode();
                    
          takeFromLink = (rand(1,1) > 0.5); % randomly draw from links and waiting queue. If no agent is moved by one strategy, try the other.
          
          if (takeFromLink)
              if (link.leave())  % test if last agent wants to and actually can enter intersection.
                 this.caServer.moveAgentFromLinkToNode(key, toNode);
              else % no agent was ready to leave the link
                 this.moveAgentInWaitingQueueToNode(toNode);              
              end
          else 
            if (~this.moveAgentInWaitingQueueToNode(toNode))
                % waiting queue was empty
                if (link.leave()) 
                    this.caServer.moveAgentFromLinkToNode(key, toNode);
                end %if
            end % if
          end  %else
      end % function
          
      function [moved] = moveAgentInWaitingQueueToNode(this, toNode)
          moved = false;             
          if (isempty(toNode.getAgent())) % test if node is free, else do not move agent to node
            agent = this.caServer.moveAgentFromWaitingQueueToNode(toNode);
            if (~isempty(agent))
               toNode.setAgent(agent);
               moved = true;
            end
          end         
      end
      
      function updateParkings(this)
         this.caServer.updateParkings(this.currentTime, this.infrastructure); 
      end     
      
      function updateRemainingWaitingQueues(this) % some of the node waiting queues are updated during link update, the rest (with empty links) is updated here
          randomIndices = randperm(this.caServer.getNodeWaitingQueueLength()); % randomize key set
          for i=1:length(randomIndices)    
              key = this.caServer.getWaitingQueuesKey(randomIndices(i));
              node = this.infrastructure.getNodeById(key);
              this.moveAgentInWaitingQueueToNode(node);
          end
          this.caServer.finishWaitingQueues();
      end     
     end % private functions
end % class

