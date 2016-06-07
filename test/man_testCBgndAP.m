% Sript for manually testing ContinuousBgndAudioPlayer

% Author: Lasse Osterhagen

load('cSineBgnAPConfig.mat')
audioPlayer = depInj.createObjFromTree(audioPlayerConfig);
audioPlayer.start();
pause(2);
audioPlayer.stop();
delete(audioPlayer);
