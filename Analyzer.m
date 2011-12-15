classdef Analyzer < handle
% Computes statistics after last time step is performed. Called by controller.    
    properties (Access = private)
        population;
        infrastructure;
        outfolder;          % output folder
    end
    
    methods
        function this = Analyzer(population, infrastructure, outfolder)
            this.population = population;
            this.infrastructure = infrastructure;
            this.outfolder = outfolder;
        end
        
        function run(this) 
            if (~exist(this.outfolder,'dir'))
             mkdir(this.outfolder);
            end
            xSearchTime = [];
            yDistanceToDest = [];
            fid = fopen(sprintf('%s %s', this.outfolder, 'summary.txt'), 'w');   
            fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\n', 'agent_id', 'startSearchTime', 'parkTime', 'searchTime', 'distanceToDestination', 'parkingLotId');
            for i=1:length(this.population)
                agent = this.population(i);
                
                if (agent.isTransit()) % exlude transit agents from analysis
                    continue; 
                end
                
                searchTime = agent.getSearchDuration();
                distanceToDestination = -99.0;
                parkingLotId = '--';
                if (~isempty(agent.getParkingLot()))
                    distanceToDestination = agent.getDistance2Destination(agent.getParkingLot());
                    parkingLotId = agent.getParkingLot().getId();
                    xSearchTime = [searchTime xSearchTime];
                    yDistanceToDest = [distanceToDestination yDistanceToDest];
                end
                fprintf(fid, '%s\t %d\t %d\t %d\t %d\t %s\n', agent.getId(), agent.getStartSearchTime(), agent.getParkTime(), searchTime, distanceToDestination, parkingLotId);
            end           
            fclose(fid);
            
            figure
            hold on
            plot(xSearchTime, yDistanceToDest, 'x', 'MarkerSize', 10, 'LineWidth', 2);
            xlabel('search time [s]') 
            ylabel('distance to destination [m]')
            hold off
        end
    end
end