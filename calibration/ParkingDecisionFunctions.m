close all
clear all

% figure
% x = 0:299;
% rA = 50.0;
% rMax = 250.0;
% 
% 
% % ax^2 + bx + c
% %divisor = (rA-rMax)^2;
% %a = 1/divisor;
% %b = -2*rMax/divisor;
% %c = rMax^2/divisor;
% 
% y(1,1:rA) = 1;
% y(1,rA+1:rMax) = 1/(rA-rMax)^2*x(rA+1:rMax).^2 - 2*rMax/(rA-rMax)^2 *x(rA+1:rMax) + rMax^2/(rA-rMax)^2;
% y(rMax+1:300) = 0;
% 
% plot(x,y)
% 
%QUADRATIC MODEL

% Plot probability for searchTime 0 and 1200
x = (0:2000)';
spatialResolution = 7.5;
initialAcceptanceRadius = 20;
decreasingSlope = 0.001;
timeToDoubleRadius = 1200;

parkDecisionQ = ParkingDecisionQuadratic(spatialResolution, initialAcceptanceRadius, decreasingSlope, timeToDoubleRadius);
parkDecisionQ2 = ParkingDecisionQuadratic(spatialResolution, initialAcceptanceRadius,0.003, 600);
parkDecisionL = ParkingDecisionLinear(spatialResolution, initialAcceptanceRadius, decreasingSlope, timeToDoubleRadius);

times = 0:300:600;

PlotParkingDecision(parkDecisionQ, x, times);
PlotParkingDecision(parkDecisionQ2, x, times);
%PlotParkingDecision(parkDecisionL, x, times);

% Plot probability for different 
%x = 150 * ones(length(elapsedSearchTime), 1);

% 3D plot p_acceptance ---------------------------------------
[times, distance] = meshgrid(0:5:1000, 0:5:600);

parkDecision = ParkingDecisionLinear(spatialResolution, initialAcceptanceRadius, 0.003, 100);
p = parkDecision.parkProbability(times, distance);

set(gca, 'FontSize',16);
surf(distance, times, p);
xlabel('d_{destination} [m]');
ylabel('t_{search} [s]');
title('p_{acctepance}'); 





