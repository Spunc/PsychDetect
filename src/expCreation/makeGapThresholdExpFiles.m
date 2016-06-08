function makeGapThresholdExpFiles(animalID)
%MAKEGAPTHRESHOLDEXPFILE creates experimentArrays from fixed parameters.
%   This function creates an experimentArray to be used with an
%   ArrayAOGenerator in a psychophysics experiment to determine the
%   detection threshold of gaps in noise.
%   All parameters are fixed accoring to our current practice.

    rng('shuffle')
    a = [.001, .001, .002; .002, .004, .004];
    b = [.008, .008, .016; .016, .032, .032];
    gapLengths = combvec(a, b);

    numExp = length(gapLengths);
    
    animalID = [animalID, '_'];
    randIndex = randperm(numExp);

    for index=1:numExp
        experimentArray = makeGapThresholdExp(gapLengths(:,index));
        experimentArray = [createPracticeStartGapTrials(), experimentArray];
        save([animalID, num2str(randIndex(index))], 'experimentArray');
    end

end