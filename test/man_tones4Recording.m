% Play tones for recording

% Author: Lasse Osterhagen

% Prepare gaps to play
levels = 0:5:80;
ta = arrayfun(@(x) ToneStimulus('level', x), levels, 'UniformOutput', false);
ta = [ta{:}];

% Create ContinuousBgndAudioPlayer
load('cBgnAPToneConfig.mat')
a = createObjFromTree(audioPlayerConfig);

pause(1);
a.start();
pause(2);

for index=1:length(ta)
    a.playAudioObject(ta(index))
    pause(1.5)
end

pause(2);
a.stop();

delete(a);
