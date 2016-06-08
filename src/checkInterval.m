function checkInterval(value)
    %checkInterval checks whether a correct interval in the form (a, b); a<=b
    %is provided. If not, an exception is thrown.
    
    % Author: Lasse Osterhagen

    if value(1) > value(2)
        error(['The lower bound must be lower than the upper ', ...
            'bound and vice versa.']);
    end

end
