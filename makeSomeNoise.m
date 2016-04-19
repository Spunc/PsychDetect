function noise=makeSomeNoise(calib, Fs, level, dur, cutoff, gate)
%MAKESOMENOISE creates bandpass noise of a specified level
%   Arguments
%   calib - calibration struct
%   Fs - sample frequency
%   level - target level
%   dur - duration in seconds
%   cutoff - passband frequencies: [low high]
%   gate - onset/offset gate duration
%
% revised version of llMakeNoise which makes a true BBN, not a comb
% stimulus
%
% Make a noise stimulus and then filter it with high and low cutoff frequencies
% within the limits specified by calib.freq. We use a Butterworth filter
% of fifth order to achieve -30 dB/octave rolloff, and set the cutoff
% frequencies to be one octave away from the edges of the frequency range.
%
% Author: Linden Lab?

tax = (0:dur*Fs-1)/Fs;
randnoise = rand(size(tax))-0.5;
Nyquist = Fs/2;
Wn = [cutoff(1), cutoff(2)]/Nyquist;
butterord = 5;
[b,a] = butter(butterord,Wn);
bandnoise = filtfilt(b,a,randnoise);

% Set the RMS level of the noise stimulus to be 1/sqrt(2) times the mean
% calib.voltage in the passband to get a noise which should have RMS equivalent to
% calib.refdB.
startPassbandIdx = knnsearch(calib.freq', cutoff(1));
stopPassbandIdx = knnsearch(calib.freq', cutoff(2));
passbandIdx = startPassbandIdx:stopPassbandIdx;
% Edit by Lasse Osterhagen: As calib.voltage is a RMS-amplitude, the row
% below seems to be incorrect. The RMS-amplitude should not be divided by
% the square root of 2.
% bandnoise_ref = bandnoise./(sqrt(mean(bandnoise.^2))) * (mean(calib.voltage(passbandIdx))/sqrt(2));
bandnoise_ref = bandnoise./(sqrt(mean(bandnoise.^2))) * mean(calib.voltage(passbandIdx));

% Adjust the RMS voltage to give desired level rather than refdB level.
noise = bandnoise_ref * 10^((level-calib.refdB)/20);

% Check for voltages that are out of range.
if any(noise)>9.5
    error('Some noise samples too loud -- will clip!');
end;

% Add gating if desired.
if gate~=0
    idx=tax<gate;
    noise(idx)=noise(idx).*sin(2*pi/gate/4*(0:(sum(idx)-1))./Fs).^2;
    idx=tax>dur-gate;
    noise(idx)=noise(idx).*sin(2*pi/gate/4*(0:(sum(idx)-1))./Fs+3*pi/2).^2;
end
