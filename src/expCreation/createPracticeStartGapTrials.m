function practiceTrials = createPracticeStartGapTrials(numPracticeTrials)
%CREATEPRACTICESTARTTRIALS creates trials for a practice run.
%   Arguments:
%   num - the number of practice trials to generate
if nargin < 1
    numPracticeTrials = 2;
end
practiceGapDuration = 0.05 + 0.01*randn(1, numPracticeTrials);
practiceDelays = 1.25+rand(1, numPracticeTrials)*.75;

packedPractice = arrayfun(@(x,y) GapStimulus(0, x, 'duration', y), ...
    practiceDelays, practiceGapDuration, 'UniformOutput', false);
practiceTrials = [packedPractice{:}];
