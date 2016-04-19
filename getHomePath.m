function homePath = getHomePath()
%GETHOMEPATH returns the full path to the current user's home directory.
%   The last character of the returned string is always the file seperator
%   character.

% Author: Lasse Osterhagen

if ispc % Windows
    homePath = [getenv('HOMEDRIVE'), getenv('HOMEPATH'), filesep];
else % Unix
    homePath = [getenv('HOME'), filesep];
end

end

