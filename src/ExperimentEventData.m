classdef ExperimentEventData < event.EventData
    % Holding data for events that should be registered by the LogBook
    
    % Author: Lasse Osterhagen
    
    properties
        % datacell must be a m-by-2 cell matrix containing m attributes
        % (string) - value (any data type) pairs.
        datacell
    end
    
    methods
        
        function this = ExperimentEventData(datacell)
            if size(datacell, 2) ~= 2
                error('Incorrect format of datacell.');
            end
            this.datacell = datacell;
        end
        
    end
    
end
