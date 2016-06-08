function out = extractCharacterStream(nevStruct, triggerBit)
% extractCharacterStream(nevStruct, [triggerBit = 1] extracts characters
% from the digital input data of a Blackrock NEV-file.
% The output is a 2-by-N cell matrix with the first row representing the
% sample number of the stream starts and the second row the extracted
% characters.

% Author: Lasse Osterhagen

% Default trigger bit = 1;
if nargin < 2
    triggerBit = 1;
end

% Prefix a zero status to the NEV data
unparsedData = [0; nevStruct.Data.SerialDigitalIO.UnparsedData];
timeStamp = [nevStruct.Data.SerialDigitalIO.TimeStamp];

% Find trigger bit changes
bitStatus = bitand(unparsedData, triggerBit);
statusChange = diff(bitStatus);
% Get the time stamps of pulses (bit changed to one)
tStamp = timeStamp(statusChange == 1);
% Calculate sample distances between pulses
d = diff(tStamp);
% The start bit is always a one, which consits of two pulses. The bit
% length (number of samples) is the distance between the first
% pulse of the start bit and the first pulse of the first
% significant bit.
bitLength = d(1) + d(2);
% Threshold for stream starts is two bit lengths
streamStartThreshold = 2*bitLength;
streamStartIndices = [0 find(d>streamStartThreshold)]+1;
lenStreamStartIndices = length(streamStartIndices);
% Prepare out cell with indices of streaming starts
out = cell(2, length(streamStartIndices));
out(1,:) = num2cell(tStamp(streamStartIndices));
% Threshold for zero/one differentiation
pulseThreshold = 0.75*bitLength;

% Parse characters from stream
% Find ones (append a last zero)
dBinary = [d < pulseThreshold 0];
lenDBinary = length(dBinary);
index = 1;
streamIndex = 0;
charBin = '000000000';
charBinIndex = 1;
characters = [];
while index <= lenDBinary
    % Check if is is the start of a new stream
    if ~(streamIndex==lenStreamStartIndices) && ...
        index == streamStartIndices(streamIndex+1)
        if streamIndex > 0
            out{2,streamIndex} = characters;
        end
        streamIndex = streamIndex+1;
        characters = [];
    end
    % It is a 1:
    if dBinary(index)
        if dBinary(index+1)
            charBin(charBinIndex) = '1'; charBinIndex=charBinIndex+1;
            index = index+2;
        else
            % There should be another pulse following
            error(['Error in parsing data at index: ' index]);
        end
    % It is a 0:
    else
        charBin(charBinIndex) = '0'; charBinIndex=charBinIndex+1;
        index = index+1;
    end
    % We finished a character
    if charBinIndex > 9
        characters = strcat(characters, char(bin2dec(charBin(2:8))));
        charBinIndex = 1;
    end
end
% Insert last character stream
out{2,streamIndex} = characters;
end

