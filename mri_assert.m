function mri_assert

% ensure assumptions
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


% do we have a figure? if not, create it
if isempty(get(0, 'CurrentFigure'))
    figure
    set(gcf, 'Name', 'mrivis')
end

% does the figure have mrivis data stuctures? if not, create them
if isempty(getappdata(gcf, 'mrivis_type'))
    setappdata(gcf, 'mrivis_data', {})
    setappdata(gcf, 'mrivis_type', 'slices')
    setappdata(gcf, 'mrivis_background', false)
    setappdata(gcf, 'mrivis_marker', true)
    setappdata(gcf, 'mrivis_opacity', 1)
    setappdata(gcf, 'mrivis_xyz', [0 0 0])
end


% Copyright (C) 2016 Carsten Allefeld
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.

