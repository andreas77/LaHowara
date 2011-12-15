% Script to run a small population of the chessboard sceanario

clear chessCtrl
close all
clc

% Simulate chessboard configuration
chessCtrl = Controller('input/chessboard/configSmall.xml');
chessCtrl.simulate()
