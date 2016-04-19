% Script for manually testing the feeder device

% Author: Lasse Osterhagen

a = ArduinoDevice();
pause(2);
feederPin = 12;
for index=1:5
    a.send(feederPin, 1);
    pause(0.01);
    a.send(feederPin, 0);
    pause(3);
end

