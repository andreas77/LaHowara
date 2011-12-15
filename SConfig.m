classdef SConfig < handle
% Global object storing configuration parameters read from config.xml provided as argument for controler.    
    properties (Access = private)
        populationFile;
        nodesFile;
        linksFile;
        parkingLotsFile;
        timeStep;
        showSimulation;
        outfolder;
        startTime;
        endTime;
        parkingSearchModels;
        createVideo;
        scaleParkingsSizes;
        privateParkingShare;
        scalePopulation;
    end
    
    methods
        function this = SConfig(configFile)
            str = sprintf('Reading config file %s ', configFile);
            disp(str);
            xmlreader = XMLReader(configFile);
            cf = xmlreader.read();            
            this.populationFile = this.getXMLValue(cf, 'populationFile');
            this.nodesFile = this.getXMLValue(cf, 'nodesFile');
            this.linksFile = this.getXMLValue(cf, 'linksFile');
            this.parkingLotsFile = this.getXMLValue(cf, 'parkingLotsFile');
            this.timeStep = this.getXMLValue(cf, 'timeStep');
            this.outfolder = this.getXMLValue(cf, 'outfolder');
            this.startTime = this.getXMLValue(cf, 'startTime');
            this.endTime = this.getXMLValue(cf, 'endTime');
            this.parkingSearchModels = this.getXMLValue(cf,'searchModels');
            this.showSimulation = this.getXMLValue(cf, 'showSimulation');
            this.createVideo = this.getXMLValue(cf, 'createVideo');
            this.scaleParkingsSizes = this.getXMLValue(cf, 'scaleParkingsSizes');
            this.privateParkingShare = this.getXMLValue(cf, 'privateParkingShare');
            this.scalePopulation = this.getXMLValue(cf, 'scalePopulation');
        end
        
        function [file] = getPopulationFile(this) 
            file = this.populationFile;
        end
        
        function [models] = getParkingSearchModels(this)
            models = this.parkingSearchModels;
        end
        
        function [file] = getNodesFile(this) 
            file = this.nodesFile;
        end
        
        function [file] = getLinksFile(this) 
            file = this.linksFile;
        end
        
        function [file] = getParkingLotsFile(this) 
            file = this.parkingLotsFile;
        end
                
        function [timeStep] = getTimeStep(this)
            timeStep = str2double(this.timeStep);
        end
        
        function [outfolder] = getOutFolder(this)
            outfolder = this.outfolder;
        end
        
        function [endTime] = getEndTime(this)
            endTime = str2double(this.endTime);
        end
        
        function [endTime] = getStartTime(this)
            endTime = str2double(this.startTime);
        end
        
        function [showSimulation] = getShowSimulation(this)
            showSimulation = this.convertStrBool(this.showSimulation);
        end
        
        function setPopulationFile(this, populationFile) 
            this.populationFile = populationFile;
        end
        
        function setNetworkFile(this, networkFile) 
            this.networkFile = networkFile;
        end
        
        function setParkingLotsFile(this, parkingLotsFile) 
            this.parkingLotsFile = parkingLotsFile;
        end 
        
        function [createVideo] = getCreateVideo(this)
            createVideo = this.convertStrBool(this.createVideo);
        end
        
        function [scalefactor] = getScaleParkingsSizes(this)
            scalefactor = str2double(this.scaleParkingsSizes);
        end
        
        function [privateParkingShare] = getPrivateParkingShare(this)
            privateParkingShare = str2double(this.privateParkingShare);
        end
        
        function [scalePopulation] = getScalePopulation(this)
            scalePopulation = str2double(this.scalePopulation);
        end
    end
    
    methods(Static) 
        function [value] = getXMLValue(XMLStruct, name)
            value = '-99';
            for k = 1:length(XMLStruct)
                 if (strcmp(XMLStruct(k).param.name, name))
                    value = XMLStruct(k).param.value;
                    break;
                 end
            end
        end
        
        function bool = convertStrBool(str)
            bool = strcmp('true', str);
        end
    end
    
end