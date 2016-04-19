% Sript for manually testing ContinuousBgndAudioPlayer and
% GapStimulusSampleFactory

% Author: Lasse Osterhagen

load('cBgnAPGapConfig.mat')
audioPlayer = createObjFromTree(audioPlayerConfig);
audioPlayer.start();
pause(1);

audioPlayer.playAudioObject(GapStimulus('duration', .02));
pause(1);
audioPlayer.playAudioObject(GapStimulus('duration', .01));
pause(1);
audioPlayer.playAudioObject(GapStimulus('duration', .005));
pause(1);

audioPlayer.stop();
delete(audioPlayer);
