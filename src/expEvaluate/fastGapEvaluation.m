% Fast evaluation of psychometric function for gap detection experiments

% Author: Lasse Osterhagen

% Unselect practice trials
fh = @(x) x.ID > 0;

% Evaluate log files
fsa = FileStatsAccumulator('Duration', fh);
[out_mean, group] = funcByGroup(fsa.dPrime, fsa.header, @mean);

% Draw plots
subjectNo = fsa.files.name{1}(1:4);
subplot(2,1,1);
boxplot(fsa.dPrime, fsa.header);
title(['Gap detection, subject #', subjectNo]);
xlabel('Gap length in s');
ylabel('d Prime');
subplot(2,1,2);
semilogx(group, out_mean);
title('Mean gap detection');
xlabel('Gap length in s');
ylabel('d Prime');