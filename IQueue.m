classdef IQueue < handle
% Implements basic queue functionality for link and nodes waiting queues in CAServer    
    properties (Access = private)
        queue;
        currentIndex;
    end
    
    methods
        function this = IQueue(queue)
            this.queue = queue;
            this.currentIndex = 0;
        end
        
        function prepareForIteration(this)
           this.currentIndex = length(this.queue); 
        end
        
        function [hasMoreElements] = hasMoreElements(this)
            hasMoreElements = false;
            if (this.currentIndex >= 1)
               hasMoreElements = true; 
            end
        end
        
        function [index] = getCurrentIndex(this)
            index = this.currentIndex;
        end
        
        function [lastIndex] = getLastIndex(this)
            lastIndex = length(this.queue);
        end
        
        function [agent] = getElement(this, index)
            agent = this.queue(index);
        end
                
        function [agent] = getNextElement(this)
            agent = this.queue(this.currentIndex);
            this.currentIndex = this.currentIndex - 1;
        end 
        
        function addElement(this, el)
            this.queue = [el this.queue];
            this.currentIndex = this.currentIndex + 1;
        end
        
        function [lastElement] = getLastElement(this)
            lastElement = this.queue(length(this.queue));
        end
        
        function [hasElements] = hasElements(this)
            hasElements = (~isempty(this.queue));
        end
               
        function removeElements(this, indices)
            this.queue(indices) = [];
        end
        
        function removeLastElement(this)          
            this.queue(length(this.queue)) = [];
            this.currentIndex = this.currentIndex - 1;
        end
         
        function removeElement(this, el)
            for i=1:length(this.queue)
                if (strcmp(el.getId(), this.queue(i).getId()))
                    this.queue(i) = [];
                    this.currentIndex = this.currentIndex - 1;
                end
            end
        end
    end
end