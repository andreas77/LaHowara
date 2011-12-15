classdef WeightedRandomRouteChoice
% Specifies next link of agents parking search route. Based on direction to destination and free momeorized parking lots
    
    methods
        % LinkAlternatives has to be a one dimensional array
        function [link] = chooseLink(this, currentPosition, destination, shortTermMemory, linkAlternatives)
            %choose NLink
            i = SUtils().weightedRand(this.getLinkWeights(currentPosition, destination, shortTermMemory, linkAlternatives));
            link = linkAlternatives(i);
            
        end
        
        function linkWeights = getLinkWeights(this, currentPosition, destination, shortTermMemory, linkAlternatives)
            vectorToDestination = destination-currentPosition;
            distanceToDestination = SUtils().vectorLength(vectorToDestination);
            
            [linkFroms, linkTos] = this.convertLinkAlternativesToPosArrays(linkAlternatives);
            linkVectors = linkTos - linkFroms;
            linkIds = this.getLinkIds(linkAlternatives);
            % No link has p(link) = 0
            linkWeights = ones(size(linkAlternatives)); 
            
            % direction weight [0...2]
            linkWeights = linkWeights + 2*this.directionWeights(linkVectors, vectorToDestination, distanceToDestination);
            
            % link length weight 
            linkWeights = linkWeights + this.linkLengthWeights(linkFroms, linkTos, destination, distanceToDestination);
            
            % parking Memory weight
            linkWeights = linkWeights + this.shortTermParkingMemoryWeights(currentPosition, linkVectors, shortTermMemory);
            
            % Short Term Memory Weight -> for link memory
            % linkWeights = linkWeights + this.shortTermMemoryWeights(linkIds, shortTermMemory);
        end
       
        
    end
    
    methods (Access = private)
        
        function [linkFroms, linkTos] = convertLinkAlternativesToPosArrays(this, linkAlternatives)
             for i = 1:length(linkAlternatives)
                linkTos(1:2,i) = linkAlternatives(i).getToNode().getPosition();
                linkFroms(1:2,i) = linkAlternatives(i).getFromNode().getPosition();
             end
        end
        
        function linkIds = getLinkIds(this, linkAlternatives)
            for i = 1 : length(linkAlternatives)
                linkIds(i) = str2double(linkAlternatives(i).getId());
            end
        end
        
        function wLinkLength = linkLengthWeights(this, linkFroms, linkTos, destination, distanceToDestination)
           
            wLinkLength = zeros(1, size(linkTos, 2)); % kein Gewicht wenn on the node?... nicht gut.. lange Links weniger bevorzugen ev. Ausschluss von sehr langen links?
           
           %Distance after completion of the link to the destination
           if(distanceToDestination~=0) 
               distancesAfterLink = SUtils().distances( repmat(destination,1,size(linkTos,2)), linkTos);
               % get rid of zeros making them small (1) 
               % Resulting high weights are handled by min, max
               distancesAfterLink = distancesAfterLink + (distancesAfterLink <= 0);
               
               %Was wenn on destination node?
               maxWeight = distanceToDestination/100.0; % TODO sinnvoll?
               minWeight = 0;
               wLinkLength = SUtils().enforceMinMax(distanceToDestination./distancesAfterLink, minWeight, maxWeight);              
           end
        end
        
        function wShortTermParkingMemory = shortTermParkingMemoryWeights(this, currentPosition, linkVectors, shortTermMemory)
           if ~isempty(shortTermMemory) && size(shortTermMemory,1) == 4
               weightOfThePreferredLink = 2;

               parkingDistances = SUtils.distances(repmat(currentPosition, 1, size(shortTermMemory, 2)), shortTermMemory(1:2, :));
               sortedMem = sortrows([parkingDistances; shortTermMemory]')';

               % use 10 nearest + those less than 100m further away
               if(size(sortedMem, 2) > 5)
                   maxValue = sortedMem(1,5) + 100;
                   col = find(sortedMem(1,:) > maxValue, 1);
                   if(~isempty(col))
                       sortedMem = sortedMem(:, 1:col-1);
                   end
               end

               % use max free spaces
               %occupationRate = sortedMem(4,:)./sortedMem(5,:); %occupiedPlaces / size
               freeSpaces = sortedMem(5,:) - sortedMem(4,:);
               [maxV, indexOfMaxV] = max(freeSpaces);

               preferredParkingLotPositionVector = sortedMem(2:3, indexOfMaxV) - currentPosition;

               dotProducts = [];
               preferredVectorLength = SUtils.vectorLength(preferredParkingLotPositionVector);
               linkLengths = SUtils.vectorLength(linkVectors);
               for l = 1 : length(linkVectors)
                   dotProducts(1, l) = dot(preferredParkingLotPositionVector, linkVectors(:,l))/(preferredVectorLength*linkLengths(l));
               end


               wShortTermParkingMemory = weightOfThePreferredLink * (dotProducts >= max(dotProducts));
           else
               disp('no short term memory or wrong size (4,x) expected : ' + size(shortTermMemory,1) + ',' + size(shortTermMemory,2));
               wShortTermParkingMemory = zeros(1, size(linkVectors, 2));
           end
        end
        
        function wShortTermMemory = shortTermMemoryWeights(this, linkIds, shortTermMemory)
            % TODO
            parkingCategories = [10 2 0]; % Limits absteigend ordnen! 4 Kategorien: >10, 10-3, 2-1, 0
            weights = [3 2 1]; % > 10-> 3, 10-3 -> 2,2-1-> 1 , 0 -> 0
            noInformationWeight = 2;
            
            parkingWeights = zeros(size(linkIds));
            for k = 1: length(linkIds)
                linkId = linkIds(k);
                %index = find(shortTermMemory(1,:)==linkId, 1);
                index = find(strcmp(shortTermMemory, linkId));
                if(isempty(index))
                    parkingWeights(k) = -noInformationWeight; % weights are negative until all weights set
                else
                    parkingWeights(k) = shortTermMemory(2,index);
                end
            end

            for i = 1:length(parkingCategories)
                bigger = parkingWeights > parkingCategories(i);
                parkingWeights = parkingWeights - (parkingWeights+weights(i).*bigger); % >categorie wird auf -weight gesetzt
            end
     
            wShortTermMemory = -parkingWeights;
        end
        
        % Wertebereich 0...2*multiplicator
        function wDirection = directionWeights(this, linkVectors, vectorToDestination, distanceToDestination)
            multiplicator = 10;
            
            wDirection = zeros(1, size(linkVectors,2));
            
            % no direction preferred if we are on the destination node,
            % else:
            if(distanceToDestination~=0)
                for i = 1 : size(linkVectors,2)
%                 for i = 1:numel(linkAlternatives)
%                     to = linkAlternatives(i).getToNode().getPosition();
%                     from = linkAlternatives(i).getFromNode().getPosition();
%                     linkVector = to - from;
                    linkVector = linkVectors(:,i);
                    % ---------------
                    wDirection(i) = multiplicator*(1 + (dot(linkVector, vectorToDestination)/(distanceToDestination * SUtils().vectorLength(linkVector)))); 
                    
                    % + 1 to ensure positive values (0...2).

                    % Please re-check if all values >= 0 -
                    % Skalarprodukt darf nicht kleiner -1 sein...
                    % höchstens Rundungsproblem???

                    % Habe das gerade nicht mehr präsent: Bis 180 Grad ist Skalarprodukt anwendbar oder? 
                    % für jedes Vektorpaar anwendbar -> ist symmetrisch
                    % -> was gut ist 10°, -10° ist das gleiche                        
                end
            end 
        end
    end
end

