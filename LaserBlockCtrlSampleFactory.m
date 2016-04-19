classdef LaserBlockCtrlSampleFactory < AudioObjectSampleFactory
%LASERBLOCKCTRLSAMPLEFACTORY creates samples from a LaserBlockCtrl.

% Author: Lasse Osterhagen

properties
    % Sample frequency
    sF
    % Number of channels needed (inclusive sound channel, exclusive
    % trigger channel)
    numChannels
end

methods
    
    function this = LaserBlockCtrlSampleFactory(sF_config, numChannels)
        % LaserBlockCtrlSampleFactory(sF, numChannels)
        % Arguments:
        % sF - sample frequency
        % numChannels - number of audio output channels to provide
        %
        % LaserBlockCtrlSampleFactory(config)
        % Arguments:
        % config - a configuration struct with all parameters as
        %   fieldnames
        if nargin == 1
            assert(isstruct(sF_config), ...
                'LaserBlockCtrlSampleFactory:ValueError', ...
                'Single argument must be a struct.');
            sF = sF_config.sF;
            numChannels = sF_config.numChannels;
        else
            sF = sF_config;
        end
        this.sF = sF;
        this.numChannels = numChannels;        
    end
    
    function numSamples = calcRequiredSamples(this, laserBlockCtrl)
        numSamples = round(this.sF*laserBlockCtrl.duration);
    end
    
    function outMatrix = makeAudioObjectSamples(this, laserBlockCtrl,  ...
            rawSamples)
        if laserBlockCtrl.channel > this.numChannels
            throw(MException('LaserBlockCtrlSampleFactory:ValueError', ...
                ['Target laser channel for LaserBlockCtrl is higher ', ...
                'numChannels.']));
        end
        numLaserSamples = this.calcRequiredSamples(laserBlockCtrl);
        if length(rawSamples) < numLaserSamples
            throw(MException('LaserBlockCtrlSampleFactory:ValueError', ...
                'Length of rawSamples shorter than required.'));
        end
        outMatrix = zeros(this.numChannels, length(rawSamples));
        outMatrix(1,:) = rawSamples;
        outMatrix(laserBlockCtrl.channel,1:numLaserSamples) = ...
            laserBlockCtrl.dcAmplitude;
    end
end

end

