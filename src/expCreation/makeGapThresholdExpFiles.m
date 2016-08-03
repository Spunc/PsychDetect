function makeGapThresholdExpFiles(subjectID)
%MAKEGAPTHRESHOLDEXPFILE creates gap detection experiment files from fixed
%parameters.
%   Arguments:
%   subjectID - a string identifying the subject for which the session
%       files are constructed.
%
%   All parameters are fixed according to our current practice for
%   obtaining detection thresholds for short gaps in white noise.
%
%   The experimental paradigm used is the method of constant stimuli. The
%   gap detection performance will be measured at six different gap
%   lengths. For the construction of individual experimental sessions, this
%   set is divided into two subsets, with one set containing the three
%   shorter gap lengths and the other set the three longer ones. Within one
%   session, four different gap lengths will be played repeatedly. Two of
%   those gap lengths are from the set of short gaps, the other two are
%   from the set of long gaps.
%   
%   The function creates nine files by means of getting all combinations of
%   possible subsets. Each file contains an experimentArray, which can be
%   used with an ArrayAOGenerator.

% Author: Lasse Osterhagen

    rng('shuffle')
    a = [.001, .001, .002; .002, .004, .004];
    b = [.008, .008, .016; .016, .032, .032];
    gapLengths = combvec(a, b);

    numExp = length(gapLengths);
    
    subjectID = [subjectID, '_'];
    randIndex = randperm(numExp);

    for index=1:numExp
        experimentArray = makeGapThresholdExp(gapLengths(:,index));
        experimentArray = [createPracticeStartGapTrials(), experimentArray];
        save([subjectID, num2str(randIndex(index))], 'experimentArray');
    end

end