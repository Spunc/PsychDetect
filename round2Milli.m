function outval = round2Milli(inval)
% Round a double value < 1 beginning at the 4th figure

% Author: Lasse Osterhagen

    outval = (round(inval*1000))*.001;
    
end
