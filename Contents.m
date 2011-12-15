% Agent-Based Cellular Automaton Cruising-For-Parking Simulation
% Version 1.0 16-Dec-2011
%
% Dependecies: requires XML Toolbox for Matlab http://www.geodise.org Author: Marc Molinari <m.molinari@soton.ac.uk> Revision: 1.1.
%
% Classes:
% AcceptanceRadiuslinear    - Computes d_acceptance used in ParkingDecision
% AcceptanceRadiusQuadratic - Computes d_acceptance used in ParkingDecision
% Agent                     - Behavioral unit of simulation.
% Analyzer                  - Computes statistics after last time step is performed. Called by controller.
% CA                        - Cellular automaton updating infrastructure and population.
% CAServer                  - Helper component managing dynamic data structures for CA (data structures of pointers to infrastructure).
% LCell                     - Basic unit of CA. Consecutive cells constitute a link. Parking lots are attached to cells. (Cell = built-in class)
% SConfig                   - Global object storing configuration parameters read from config.xml provided as argument for controler. (SConfig = built-in class)
% Controller                - Entry point for simulation. Contains main simulation loop.
% Infrastructure            - Holds network consisting of links and nodes.
% InfrastructureCreator     - Creates infrastructure during initialization of CA. Infrastructure is afterwards handed over to CA.
% NLink                     - Component represents network roads. NLink = network link (Link = built-in class)
% NNode                     - Component represents network intersections. NNode = network node (Node = built-in class)
% ParkingDecision           - Abstract class for ParkingDecisionLinear and ParkingDecisionQuadratic (see below). Defines the probability that an agent parks. 
% ParkingDecisionLinear     - The probability an agent parks decreases linearly with distance form the destination.
% ParkingDecisionQuadratic  - The probability an agent parks decreases quadratically with distance from the destination.
% ParkingLot                - Represents (1..n) parking lots associated with a cell. If multiple real parking lots are merged capacity is increased accordingly.
% PopulationCreator         - Creates population during initialization of CA. Population is afterwards handed over to CA.
% IQueue                    - Implements basic queue functionality for link and nodes waiting queues in CAServer. (Queue = built-in class)
% RandomRouteChoice         - Agent decides randomly for next link when leaving intersection (node)
% Route                     - Composed of sequence of nodes.
% RunChessboardScenario     - Script to run a small population of the chessboard sceanario
% ScenarioPlotter           - Plots scenario in real-time and creates a movie
% SpatialElement            - Abstract class for geographical elements specified by coordinates such as links, cells, parking lots and nodes
% SpatialElementDrawer      - Used in first time step of SceanrioPlotter to draw SpatialElements (parking lots, links).
% SUtils                    - Globally used helper functionality such as distance calculations etc.
% WeightedRandomRouteChoice - Specifies next link of agents parking search route. Based on direction to destination and free momeorized parking lots
% XMLReader                 - Basic reader for xml files, interface for xml toolbox.
%
% Folders:
% input/square              - Small-scale scenario
% input/chessboard          - Small-scale scenario
% input/mininetwork         - Small-scale sceanario for calibration
% input/zurichCity          - Real-world inner-city Zurich scenario
% output                    - Simulation results for the chessboard
% toolboxes                 - Containing XML toolbox
% calibration               - Contains functions for calibration of decision models. Not used during simulation.
% doc                       - Installation and running information. Contains readme.txt and report.pdf
%                        
%
% A. Horni, L. Montini, R. Waraich
% Open Source
