% Fast evaluation of psychometric function for tone detection experiments

% Author: Lasse Osterhagen

% Unselect practice trials
fh = @(x) x.ID > 0;

% Evaluate log files
fsa = FileStatsAccumulator('Level', fh);
[out_mean, group] = funcByGroup(fsa.dPrime, fsa.header, @mean);

% Draw plots
subjectNo = fsa.files.name{1}(1:4);
subplot(2,1,1);
boxplot(fsa.dPrime, fsa.header);
title(['Tone detection, subject #', subjectNo]);
xlabel('Tone level in dB');
ylabel('d Prime');
subplot(2,1,2);
plot(group, out_mean);
title('Mean tone detection');
xlabel('Tone level in dB');
ylabel('d Prime');