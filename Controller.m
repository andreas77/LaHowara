classdef Controller < handle
% Entry point for simulation. Contains main simulation loop.
    
    properties
        configFile;
        infrastructure;
        population;
        config;
        spatialResolution = 7.5; % [m]. cell size. Reciprocal to jam density as given in Wu and Brilon 1997
    end
    
    properties (Access = private)
        infrastructureAlreadySetup = false;
    end
    
    methods
        function this = Controller(configFile)
            this.configFile = configFile;
        end
        
        function setupInfrastructure(this)
            this.config = SConfig(this.configFile);
                         
            xmlReader = XMLReader(this.config.getNodesFile());
            nodesXML = xmlReader.read();
             
            xmlReader = XMLReader(this.config.getLinksFile());
            linksXML = xmlReader.read();
            
            xmlReader = XMLReader(this.config.getParkingLotsFile());
            parkingXML = xmlReader.read();   
                        
            this.infrastructure = InfrastructureCreator(nodesXML, linksXML, parkingXML, this.spatialResolution).create(this.config.getScaleParkingsSizes());
            this.infrastructureAlreadySetup = true;
        end
        
        function setupPopulation(this)
            xmlReader = XMLReader(this.config.getPopulationFile());
            populationXML = xmlReader.read();
            this.population = PopulationCreator(populationXML, this.config.getParkingSearchModels, this.infrastructure, this.spatialResolution, this.config.getPrivateParkingShare(), this.config.getScalePopulation()).create();
        end
        
        function setup(this)
            
            warning('off', 'MATLAB:oldPfileVersion'); % suppress xml reading warnings about old pcode
            
            if(~this.infrastructureAlreadySetup)
                this.setupInfrastructure();
            else
                %todo clear agents from links.. 
                %todo clear agents from parkingspace???
            end
            this.setupPopulation();          
        end
        
        function simulate(this) 
            tic;
            stream0 = RandStream('mt19937ar','Seed', 0);
            RandStream.setDefaultStream(stream0); % use random streem for reproducability
            
            this.setup;
            ca = CA(this.infrastructure, this.spatialResolution, this.config.getTimeStep(), this.config.getStartTime(), this.config.getEndTime(), this.config.getShowSimulation());
            videoStarted = false;
            if (this.config.getCreateVideo())
                ca.startRecording();
                videoStarted = true;
            end
            close all; % close old simulations and window opend by startRecording() 
            ca.init(this.population);
            ca.simulate();
            if (videoStarted)
                ca.stopAndSaveRecording(strcat(this.config.getOutFolder(), 'simulationRecord.avi'));
            end
            analyzer = Analyzer(this.population, this.infrastructure, this.config.getOutFolder());
            analyzer.run();
            str = sprintf('Simulation finished in %d %s', toc, ' seconds'); 
            disp(str);
       end
    end
end