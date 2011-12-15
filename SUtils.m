 classdef SUtils 
 % Globally used helper functionality suhc as distance calculations etc.
     
    methods(Static)                 
        function [m] = rotationMatrix(link)
            dPos = link.getFromNode.getPosition() - link.getToNode.getPosition();
            linkLength = SUtils().length(link.getToNode, link.getFromNode);
            cosAlpha = dPos(1)/linkLength;
            sinAlpha = dPos(2)/linkLength;
            m = [cosAlpha, -sinAlpha; sinAlpha, cosAlpha];
        end
        
        %input: spatial elements
        function [l] = length(s0, s1)
           diff = s0.getPosition() - s1.getPosition();
           l = SUtils().vectorLength(diff);           
        end
        
        
        % both starts and ends should be given in the following format:
        % -            -
        %|x1 x2 x3... xn|
        %|y1 y2 y3... yn|
        % -            -
        % output, distances [d1 d2 d3... dn]
        function d = distances(starts, ends)
            d = SUtils().vectorLength(ends - starts);
        end
        
        function l = vectorLength(vector)
           l = sqrt(dot(vector,vector));
        end
        
        %weights have to be positive (order does not matter)
        %gewichte Fall w und Fall v -> [w1 w2 .. wn; v1 v2 .. vn] -> macht
        %sowas sinn? (Funktioniert noch nicht aufgrund find()
        function index = weightedRand(positiveWeights)
            
            % we get NaN here! Wahrscheinlich  dann, wenn wir auf dem
            % Zielknoten hocken.
            w = cumsum(positiveWeights,2)/sum(positiveWeights,2); % [2 1 3] -> [2 3 6] -> [0.33 0.5 1]
            index = find(w > rand(),1); 
        end
        
        function minMaxEnforced = enforceMinMax(functionValues, min, max)
           tooBig = functionValues > max;
           tooSmall = functionValues < min;
           
           minMaxEnforced = functionValues - functionValues.*tooBig + max*tooBig - functionValues.*tooSmall + min*tooSmall;
        end
        
        % converts an array of spatialElements to a position Matrix [x1 y1;
        % x2 y2;..;xn yn]
        function positionMatrix = spatialToPosition(spatialElements)
            positionMatrix=zeros(length(spatialElements),2);
            for k=1:length(spatialElements)
                positionMatrix(k,:) = spatialElements(k).getPosition()';
            end
        end
    end
end