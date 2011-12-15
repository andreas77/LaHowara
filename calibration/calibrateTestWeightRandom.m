%clear all
close all
clc

spatialResolution = 7.5;
% Ziel im Norden [distanzZiel längeS längeW längeO längeN]
caseDefinitions = ...
[...
1000 200 200 200 200;...
1000 200 200 200 500;...
1000 500 200 200 200;...
500 200 200 200 200;...
500 200 200 500 200;...
500 200 200 200 500;...
500 100 500 500 100;...
200 200 200 200 200;...
200 500 200 200 200;...
];

%TODO fill
% shortTermMemory ={{'memLink'}, 0};
wParking = [-250; 100; 1; 2];
oParking = [250; 100; 40; 50];
shortTermMemory = [wParking oParking];

weightedRouteChooser = WeightedRandomRouteChoice();
nrCases = size(caseDefinitions, 1);
originNode = NNode('origin', 0, 0);
for caseNr = 1 : nrCases
	destNode = NNode('destination', 0, caseDefinitions(caseNr, 1));
	S_Node = NNode('S', 0,                         -caseDefinitions(caseNr, 2));
	W_Node = NNode('W', -caseDefinitions(caseNr,3), 0);
	O_Node = NNode('O', caseDefinitions(caseNr, 4), 0);
	N_Node = NNode('N', 0,                         caseDefinitions(caseNr, 5));
	
	sLink = NLink('lS', originNode, S_Node, spatialResolution);
	wLink = NLink('lW', originNode, W_Node, spatialResolution);
	oLink = NLink('lO', originNode, O_Node, spatialResolution);
	nLink = NLink('lN', originNode, N_Node, spatialResolution);
	
	weights(caseNr, :) = weightedRouteChooser.getLinkWeights(originNode.getPosition(), destNode.getPosition(), [], [sLink, wLink, oLink, nLink]);
    weightsWithMem(caseNr, :) = weightedRouteChooser.getLinkWeights(originNode.getPosition(), destNode.getPosition, shortTermMemory, [sLink, wLink, oLink, nLink]);
end

p = weights./repmat(sum(weights,2),1,4) % 4= Anzahl links
pWithMem = weightsWithMem./repmat(sum(weightsWithMem,2),1,4)

%Compare cases -> all statements have to be true
% p(lW) == p(lO) if same length, else p(longer) < p (shorter)
tests = [...
p(1,4) > p(1,1); p(1,2) == p(1,3);...
p(2,4) > p(1,4);...
p(3,1) < p(1,1);...  
]