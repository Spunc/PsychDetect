function makeToneThresholdExpFiles(subjectID)
%MAKETONETHRESHOLDEXPFILES creates tone detection experiment files from fixed
%parameters.
%   Arguments:
%   subjectID - a string identifying the subject for which the session
%       files are constructed.
%
%   All parameters are fixed according to our current practice for
%   obtaining detection thresholds for tones in white noise.
%
%   The experimental paradigm used is the method of constant stimuli. The
%   tone detection performance will be measured at six different tone
%   levels. For the construction of individual experimental sessions, this
%   set is divided into two subsets, with one set containing the three
%   lower level tones and the other set the three higher level ones. Within
%   one session, four different tone levels will be played repeatedly. Two
%   of those levels are from the set of short levels, the other two are
%   from the set of high gaps.
%   
%   The function creates nine files by means of getting all combinations of
%   possible subsets. Each file contains an experimentArray, which can be
%   used with an ArrayAOGenerator.

% Author: Lasse Osterhagen

frequency = 10e3;
duration = 0.5;

rng('shuffle')
a = [30, 30, 40; 40, 50, 50];
b = [60, 60, 70; 70, 80, 80];
toneLevels = combvec(a, b);

numExp = length(toneLevels);

subjectID = [subjectID, '_'];
randIndex = randperm(numExp);

for index=1:numExp
    experimentArray = makeToneThresholdExp(frequency, duration, toneLevels(:,index));
    experimentArray = [createPracticeTrials(frequency, duration), experimentArray];
    save([subjectID, num2str(randIndex(index))], 'experimentArray');
end

end

function practiceTrials = createPracticeTrials(frequency, duration)
% Create two easy practice trials for the beginning of the experiment
practiceTrials(2) = ToneStimulus(0, 1+rand*1.5, 'duration', duration, ...
    'frequency', frequency, 'level', 70+rand*12);
practiceTrials(1) = ToneStimulus(0, 1+rand*1.5, 'duration', duration, ...
    'frequency', frequency, 'level', 70+rand*12);
end