function throwIncorrectEventError(callingFunction, event)
% THROWINCORRECTEVENTERROR throws an ExperimentState:IncorrectEvent exception.
%   This function is used by all LogbookStates to throw an exception if the
%   following event is not allowed given the current event.

% Author: Lasse Osterhagen

msgID = ['ExperimentState:IncorrectEvent:', callingFunction];
msg = ['Incorrect following event: ', event];
throw(MException(msgID, msg));
