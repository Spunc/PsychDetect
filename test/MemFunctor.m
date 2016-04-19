classdef MemFunctor < handle
%MEMFUNCTOR saves arguments and results of function calls
%   MemFunctor is a kind of decorator for a function. The constructor takes
%   a function handle to a primary function. A call to func() replaces the
%   primary function. Beyond providing the same functionality as the
%   primary function, it saves the argument and the result list of all
%   function calls to cell arrays.

% Author: Lasse Osterhagen
    
    
properties (SetAccess = private)
    % The wrapped function
    f
    % Cell array of arguments to called function
    arguments
    % Cell array of results from function
    results
end

methods

    function this = MemFunctor(f)
        this.f = f;
        this.arguments = cell.empty;
        this.results = cell.empty;
    end

    function varargout = func(this, varargin)
        % Evaluate function
        c = cell(1, nargout);
        if nargout > 0
            [c{:}] = this.f(varargin{:});
        else
            this.f(varargin{:});
        end
        varargout = c;

        % Save arguments and results
        this.arguments{end+1} = varargin;
        this.results{end+1} = c;
    end

end
    
end
