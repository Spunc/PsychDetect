function checkPositiveNumber( value )
%CHECKPOSITIVENUMBER throws an exception if value is nonnumercal or lower
% than 0.

% Author: Lasse Osterhagen

    if ~(isnumeric(value) && min(value) >= 0)   %works for NaN too
        error('Input is not a valid number >= 0');
    end

end
