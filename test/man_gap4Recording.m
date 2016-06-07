% Play gaps for recording

% Author: Lasse Osterhagen

% Prepare gaps to play
gaps = .00015*2.^(0:10);
ga = arrayfun(@(x) GapStimulus('duration', x), gaps, 'UniformOutput', false);
ga = repmat([ga{:}], 1, 2);

% Create ContinuousBgndAudioPlayer
load('cBgnAPGapConfig.mat')
a = depInj.createObjFromTree(audioPlayerConfig);

pause(1);
a.start();
pause(2);

for index=1:length(ga)
    a.playAudioObject(ga(index))
    pause(1)
end

pause(2);
a.stop();

delete(a);
