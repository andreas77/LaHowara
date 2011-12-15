classdef PopulationCreator < handle
    
    properties
        populationXML;      
        infrastructure;
    end
    
    properties (Access = private)
       spatialResolution;  
       parkingSearchModels ={};
       parkingSearchModelsShare = [];
       parkingSearchModelsCount=[];
       privateParkingShare;
       populationScale = 1.0;
    end
    
    methods
        function this = PopulationCreator(populationXML, parkingSearchModelsXML, infrastructure, spatialResolution, privateParkingShare, populationScale)
            this.spatialResolution = spatialResolution;
            this.populationXML = populationXML;  
            this.infrastructure = infrastructure;
            this.privateParkingShare = privateParkingShare;
            this.createParkingSearchModels(parkingSearchModelsXML); %after spatial Resolution - as it is used in the function!
            this.populationScale = populationScale;
        end
        
        function [agents] = create(this) 
            disp('Creating population ...');
            numberOfAgents = length(this.populationXML);
            agents = Agent.empty(numberOfAgents, 0);
            
            cnt = 0;
            for i=1:numberOfAgents
                for scale = 1:this.populationScale
                    agent = this.createAgent(this.populationXML(i).agent, scale - 1, cnt);
                    if (~isempty(agent))
                        cnt = cnt + 1;
                        agents(cnt) = agent;
                    end 
                end
            end
            
            str = sprintf('   created %i %s', length(agents), ' agents');
            for j=1:length(this.parkingSearchModelsCount)
            %    str = sprintf('%s\n%s : %i [share: %i]', str, class(this.parkingSearchModels{j}), this.parkingSearchModelsCount(j), this.parkingSearchModelsShare(j));
            end
            disp(str);
            str = sprintf('%s %d', 'Private parking share:', this.privateParkingShare);
            disp(str);
        end
        
        function [route] = createRoute(this, routeNodes)
            route = Route();
            
            if(~isempty(routeNodes) && ~strcmp(routeNodes, 'null'))     
                ids = regexp(routeNodes,' ','split');
                route.setRoute(ids);
            end
        end
        
         function agent = createAgent(this, agentStruct, scale, id)
              route_to = agentStruct.route_to;
              route_away = agentStruct.route_away;
              if isempty(route_to) && isempty(route_away) % agents that have no routes at all (stay at home) are not used in this scenario
                   agent = [];
                   return;
              end
              routeAway = this.createRoute(route_away);
              
              parkingDecisionType = [];                 
              actDur = -99; 
              routeTo = [];
                
              transit = false;
              if isempty(route_to) || strcmp(route_to, 'null') 
                   transit = true;
              else 
                parkingDecisionType = this.drawParkingSearchModel();
                routeTo = this.createRoute(route_to);      
                actDur = str2double(agentStruct.actDur);   
              end 
                stripStartTime = str2double(agentStruct.tripStartTime); % + scale + rand();
                
                hasPrivateParking = false;
                if (rand() < this.privateParkingShare)
                   hasPrivateParking = true; 
                end        
                agent = Agent(strcat(int2str(id), agentStruct.id), stripStartTime, parkingDecisionType, routeTo, routeAway, actDur, transit, this.infrastructure, hasPrivateParking);
         end
        
    end
    
    methods (Access = private)
        
        function parkingDecision = drawParkingSearchModel(this)
            index = SUtils().weightedRand(this.parkingSearchModelsShare);
            this.parkingSearchModelsCount(index) = this.parkingSearchModelsCount(index) + 1;
            parkingDecision = this.getParkingSearchModel(this.parkingSearchModels{index});            
        end
        
        function createParkingSearchModels(this, modelsXML)
            for j = 1 : length(modelsXML)
                model = modelsXML(j).model;
                this.parkingSearchModelsShare(j) = str2double(model.share);
                this.parkingSearchModels{j} = model;
            end
            this.parkingSearchModelsCount = zeros(size(this.parkingSearchModelsShare));
        end
        
        function parkingDecision = getParkingSearchModel(this, model)
            %str2double -> inefficient?
            startSearchRadius = randi([str2double(model.minStartSearchRadius), str2double(model.maxStartSearchRadius)], 1);
            if strcmp(model.type, 'ParkingDecisionLinear')
                parkingDecision = ParkingDecisionLinear(this.spatialResolution,str2double(model.initialAcceptanceRadius),str2double(model.slope),str2double(model.timeToDoubleRadius)); 
            elseif strcmp(model.type, 'ParkingDecisionQuadratic')
                parkingDecision = ParkingDecisionQuadratic(this.spatialResolution,str2double(model.initialAcceptanceRadius),str2double(model.slope),str2double(model.timeToDoubleRadius));
            else
                err = MException('PopulationCreator:invalidConfigArgument', sprintf('config - searchModels; Unknown Parking model type: %s', model.type));
                throw(err);
            end
            parkingDecision.startSearchRadius = startSearchRadius;
        end
    end
end