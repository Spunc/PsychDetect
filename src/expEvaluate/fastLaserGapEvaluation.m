% Fast evaluation of psychometric function for gap detection experiments
% with multiple blocked trials.

% Author: Lasse Osterhagen

% Unselect practice trials
fh = @(x) ~(isnumeric(x.ID) && x.ID == 0);

% Evaluate log files
fsa = FileBlockedStatsAccumulator('Duration', fh);
blue = fsa.condition.b;
yellow = fsa.condition.y;
[meanBlue, groupBlue] = funcByGroup(blue.dPrime, blue.header, @mean);
[meanYellow, groupYellow] = funcByGroup(yellow.dPrime, yellow.header, @mean);

% Plot results
subjectNo = fsa.files.name{1}(1:4);
semilogx(groupBlue, meanBlue);
hold on
semilogx(groupYellow, meanYellow, 'Color', 'y');
title(['Mean gap detection, subject #', subjectNo]);
xlabel('Gap length in s');
ylabel('d Prime');
legend({'SSFO on', 'SSFO off'}, 'Location', 'SouthEast');
