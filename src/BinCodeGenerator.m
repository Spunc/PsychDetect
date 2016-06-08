classdef BinCodeGenerator < handle
    % BinCodeGenerator can create binary code from (7-bit ASCII) char arrays.
    % The binary code can then be sent to a sound card for asynchronous
    % communication.
    % Each char is represented by its binary ASCII code. It is framed by a
    % start bit (1) and a stopbit (0).
    % A binary 1 is coded as two pulses (11), a binary 0 as one pulse (10).
    
    % Author: Lasse Osterhagen

    properties (SetAccess = private)
        % Number of pulses per second (sF / pulsesPS should yield an integer)
        pulsesPS
        % Pulse width in samples
        pulseWidth
        % Sample rate of sound card
        sF = 192e3
    end

    methods

        function this = BinCodeGenerator(pulsesPS, pulseWidth, sF)
            % Construct a BinCodeGenerator([pulsesPS=6000],
            % [pulseWidth=8], [sF=192e3])
            if nargin < 3
                sF = 192e3;
            end
            if nargin < 2
                pulseWidth = 8;
            end
            if nargin < 1
                pulsesPS = 6000;
            end
            this.pulsesPS = pulsesPS;
            this.pulseWidth = pulseWidth;
            this.sF = sF;
        end
        
        function set.pulsesPS(this, value)
            this.checkPulsesPS(this.sF, value);  %#ok<*MCSUP>
            this.checkPulseWidth(this.sF, value, this.pulseWidth);
            this.pulsesPS = value;
        end
        
        function set.pulseWidth(this, value)
            this.checkPulseWidth(this.sF, this.pulsesPS, value);
            this.pulseWidth = value;
        end
        
        function set.sF(this, value)
            this.checkPulsesPS(value, this.pulsesPS);
            this.checkPulseWidth(value, this.pulsesPS, this.pulseWidth);
            this.sF = value;
        end
        
        function checkPulsesPS(~, sFval, pulsesPSval)
            if mod(sFval, pulsesPSval) ~= 0
                error(['Sample frequency divided by pulses per second ', ...
                    'must yield an integer value.']);
            end
        end
        
        function checkPulseWidth(~, sFval, pulsesPSval, pulseWidthval)
        samplesPPulse = sFval/pulsesPSval;
            if samplesPPulse < pulseWidthval
                error(['The number of pulses per second is too high: ', ...
                    'the number of samples per pulse is smaller than ', ...
                    'the pulse width.']);
            end
        end
            

        function resultArr = createCode(this, charArr)
            % createCode(charArr) creates an array of pulses that encodes
            % a char array.
            samplesPPulse = this.sF/this.pulsesPS;
            % Create prototype binary 1 and binary 0
            one = zeros(1, 2*samplesPPulse);
            one(1:this.pulseWidth) = 1;
            zero = one;
            one(samplesPPulse+1:samplesPPulse+this.pulseWidth) = 1;

            % Create result array
            samplesPBit = 2*samplesPPulse;
            samplesPChar = samplesPBit*9;
            totalNumSamples = length(charArr)*samplesPChar;
            resultArr = zeros(1, totalNumSamples);
            arrIndex = 1;
            for charIndex=1:length(charArr)
                dec = double(charArr(charIndex));
                if dec > 127
                    error('Character is not in ASCII range');
                end
                % Create start bit
                resultArr(arrIndex:arrIndex+samplesPBit-1) = one;
                arrIndex = arrIndex+samplesPBit;
                % Create char bits
                bin = dec2bin(dec, 7);
                for binIndex=1:length(bin)
                    if bin(binIndex) == '1'
                        resultArr(arrIndex:arrIndex+samplesPBit-1) = one;
                    else
                        resultArr(arrIndex:arrIndex+samplesPBit-1) = zero;
                    end
                    arrIndex = arrIndex+samplesPBit;
                end
                % Create stop bit
                resultArr(arrIndex:arrIndex+samplesPBit-1) = zero;
                arrIndex = arrIndex+samplesPBit;
            end
        end

    end

end
