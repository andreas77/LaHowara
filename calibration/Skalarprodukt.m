close all
clear all

alpha = 0:360;
x = cosd(alpha);
y = sind(alpha);

figure
plot(x,y);
pos=[x',y'];
ploty = pos*[1;0];
ploty2 = pos* [2;0];
ploty3 = (2.*pos) * [1;0];
ploty4 = (2.*pos) *[2;0];

figure
hold on
plot(alpha, ploty);
plot(alpha, ploty2, 'rX-');
plot(alpha, ploty3, 'g');
plot(alpha, ploty4, 'm');
legend('Einheitskreis *[1;0]', 'Einheitskreis *[2;0]','2*Einheitskreis *[1;0]','2*Einheitskreis *[2;0]')
hold off

figure
dy = ploty(2:361)-ploty(1:360);
plot(alpha(1:360), dy)


clear all