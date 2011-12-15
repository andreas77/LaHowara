function [ output_args ] = PlotParkingDecision( parkDecision, x, searchTimes)
%PLOTPARKINGDECISION Summary of this function goes here
%   Detailed explanation goes here

    figure
    hold on;
    set(gca, 'FontSize',16);
    nrSubplots = length(searchTimes);
    lines = ['r' 'c' 'g' 'b' 'y'];
    for i = 1 : nrSubplots
        %subplot(nrSubplots,1,i)
        elapsedSearchTime = searchTimes(i) * ones(length(x), 1);
        p = parkDecision.parkProbability(elapsedSearchTime, x);
         
        lineHandle = plot(x, p, lines(mod(i, length(lines)) + 1), 'LineWidth', 2);
        legend(lineHandle, num2str(i));
       
        s{i}=sprintf('%d %s', searchTimes(i)/60, '[min]');
    end
    legend(s); 
    %title(strcat('Probability of choosing a Parking space at a given time'));
    xlabel('distance to destination [m]');
    ylabel('parking probability [-]');
    hold off;
    
%     figure
%     hold on;
%     probabilities = (0:0.1:1)';
%     times = 300* ones(length(probabilities), 1);
%     distances = parkDecision.acceptedDistance(probabilities, times);
%     plot(probabilities, distances)
%     xlabel('probabilities')
%     ylabel('accepted distance')
%     hold off;

end

