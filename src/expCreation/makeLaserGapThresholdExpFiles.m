function makeLaserGapThresholdExpFiles(animalID)
%MAKELASERGAPTHRESHOLDEXPFILES creates gap detection experiment files with
% laser stimulation from fixed parameters.

% Author: Lasse Osterhagen
    rng('shuffle')
    a = [.001, .001, .002; .002, .004, .004];
    b = [.008, .008, .016; .016, .032, .032];
    gapLengths = combvec(a, b);

    numExp = length(gapLengths);
    
    animalID = [animalID, '_'];
    randIndex = randperm(numExp);

    for index=1:numExp
        [e1, e2] = makeLaserGapThresholdExp(gapLengths(:,index));
        experimentArray = [createPracticeStartGapTrials(), e1];
        save([animalID, num2str(randIndex(index)), '_1'], 'experimentArray');
        experimentArray = [createPracticeStartGapTrials(), e2];
        save([animalID, num2str(randIndex(index)), '_2'], 'experimentArray');
    end

end
