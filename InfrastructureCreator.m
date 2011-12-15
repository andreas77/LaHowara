classdef InfrastructureCreator < handle
% Creates infrastructure during initialization of CA. Infrastructure is afterwards handed over to CA.
    properties
        nodesXML;
        linksXML;
        parkingLotsXML;
        spatialResolution;
    end
    
    properties (Access = private)
        allCells;
        allCellsKDTree;
    end
    
    methods
        function this = InfrastructureCreator(nodesXML, linksXML, parkingLotsXML, spatialResolution)
            this.nodesXML = nodesXML;
            this.linksXML = linksXML;
            this.parkingLotsXML = parkingLotsXML;
            this.spatialResolution = spatialResolution;
        end
        
        function [infrastructure] = create(this, parkingLotSizeScaleFactor) 
            disp('Creating infrastructure ...');
            nodes = this.createNodes();
            links = this.createLinks(nodes);
            
            this.createLinkCells(links);
            numberOfParkingLots = this.appendParkingLots(parkingLotSizeScaleFactor);
            infrastructure = Infrastructure(nodes, links);
        end
    end
    
    methods (Access = private)   
      function [nodes] = createNodes(this) 
          nnodes = length(this.nodesXML);
          nodes = containers.Map();
          for i = 1:nnodes
              node = NNode(this.nodesXML(i).node.id, this.nodesXML(i).node.x, this.nodesXML(i).node.y);
              nodes(this.nodesXML(i).node.id) = node;
          end
          str = sprintf('   created %i %s', length(nodes), 'nodes');
          disp(str);
      end
        
      function [links] = createLinks(this, nodes) 
          nlinks = length(this.linksXML);
          links = containers.Map();
          for i = 1:nlinks
              fromNode = nodes(this.linksXML(i).link.fromNode);
              toNode = nodes(this.linksXML(i).link.toNode);
              link = NLink(this.linksXML(i).link.id, fromNode, toNode, this.spatialResolution);
              fromNode.addFromLink(link);
              toNode.addToLink(link);
              links(this.linksXML(i).link.id) = link;
          end
          str = sprintf('   created %i %s', length(links), 'links');
          disp(str);
      end
          
      function createLinkCells(this,links)         
          keys = links.keys();
          for i = 1:numel(keys) % could also use links.Count here
              key = keys{i};
              cells = links(key).createCells();
              this.allCells = [this.allCells cells];
          end
          this.allCellsKDTree = createns(SUtils.spatialToPosition(this.allCells), 'NSMethod', 'kdtree');
          str = sprintf('      created %i %s', length(this.allCells), ' cells');
          disp(str);
      end
      
      function [numberOfParkingLots] = appendParkingLots(this, parkingLotSizeScaleFactor)
          % matlabpool local; % run on multiple cores
          totalSize = 0;
          for j=1:length(this.parkingLotsXML)
              parkingLotStruct = this.parkingLotsXML(j).parkinglot;
              size = round(parkingLotSizeScaleFactor * str2double(parkingLotStruct.size));
              totalSize = totalSize + size;
              [idx, ~] = knnsearch(this.allCellsKDTree, [str2double(parkingLotStruct.x), str2double(parkingLotStruct.y)], 'IncludeTies', true);
              
              if(length(idx{1}) == 2 && size > 1)
                  %split on two-way streets
                  sizea = round(size/2.0);
                  sizeb = floor(size/2.0);
                  % assign sizea & sizeb randomly to the two links
                  cellIndex = randi(length(idx{1}),1);
                  cella = this.allCells(idx{1}(cellIndex));
                  cellb = this.allCells(idx{1}(3-cellIndex)); % cellAIndex + cellBIndex = 2 + 1 (oder 1+2);
                  this.appendParkingLot(cella, strcat(parkingLotStruct.id,'_a'), sizea);
                  this.appendParkingLot(cellb, strcat(parkingLotStruct.id,'_b'), sizeb);
              else
                  % randomly choose cell if several found (almost always 2
                  % because of 2-way streets
                  cellIndex = randi(length(idx{1}),1);
                  closestCell = this.allCells(idx{1}(cellIndex));% idx(cellIndex) if 'IncludeTies' set to false
                  this.appendParkingLot(closestCell, parkingLotStruct.id, size);
              end
          end
          numberOfParkingLots = length(this.parkingLotsXML);
          str = sprintf('Added %i %s %i % s', numberOfParkingLots, 'parking lots with a total of', totalSize, 'spaces');
          disp(str);
          % matlabpool close;          
      end
      
      function appendParkingLot(this, cell, parkingLotId, size)
          position = cell.getPosition();
          parkingLot = cell.getParkingLot();
          if isa(parkingLot, 'ParkingLot')
              parkingLot.increaseSizeBy(size);
          else 
              cell.setParkingLot(ParkingLot(parkingLotId, position(1), position(2), size));
          end
      end
    end
end