function mriSetMarker(marker)

% switch position marker on, off, or toggle
%
% mriSetMarker(marker)
% mriSetMarker
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


mri_assert

if nargin == 0
    marker = ~getappdata(gcf, 'mrivis_marker');
end

setappdata(gcf, 'mrivis_marker', marker)

mri_update


% Copyright (C) 2016 Carsten Allefeld
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.

