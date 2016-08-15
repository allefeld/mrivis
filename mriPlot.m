function mriPlot(vol, mask, clim, cmap)

% plot MRI volume
%
% mriPlot(vol, mask = [], clim, cmap)
%
% vol, mask:    in the format of mriVolume; mask can be omitted or []
% clim:         three-element vector [crit, cmin, cmax]
%               forms [], [crit], [cmin, cmax] are also accepted
%               default: [min, min, max] of data
% cmap:         colormap in Matlab format; values in [cmin, cmax] are mapped
%               onto colors through interpolation
%
% See also mriVolume, mriSetSlices, mriSetMIP, mriSetMarker, mriBackground,
% mriSetOpacity, mriExport, and mriSetCoords .
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


% read and normalize data
if ~exist('mask', 'var')
    mask = [];
end
[vol, XYZ] = mriVolume(vol, mask);

% save memory
vol = single(vol);

% transform XYZ to extent / delta format
dim = size(vol);
XYZ = reshape(XYZ, [3 dim]);
extent = [XYZ(1, [1 end], 1, 1)', squeeze(XYZ(2, 1, [1 end], 1)), squeeze(XYZ(3, 1, 1, [1 end]))];
delta = diff([XYZ(1, [1 2], 1, 1)', squeeze(XYZ(2, 1, [1 2], 1)), squeeze(XYZ(3, 1, 1, [1 2]))]);
clear XYZ

% determine clim
dmin = min(vol(isfinite(vol)));
dmax = max(vol(isfinite(vol)));
if ~exist('clim', 'var') || isempty(clim)   % []
    clim = [dmin, dmin, dmax];
elseif numel(clim) == 1                     % [crit]
    clim = [clim, dmin, dmax];
elseif numel(clim) == 2                     % [cmin, cmax]
    clim = [dmin, clim];
end
fprintf('using threshold %g, limits [%g, %g]\n', clim)

mri_assert
data = getappdata(gcf, 'mrivis_data');
N = size(data, 1) + 1;

% determine colormap
% list of equidistant hues, pure colors first
hues = [(0 : 2) / 3, (1 :2: 5) / 6, (1 :2: 11) / 12, (1 :2: 23) / 24, (1 :2: 47) / 48];
if ~exist('cmap', 'var') || isempty(cmap)
    % if no colormap is specified, take the first from a list of pure-hue
    % colormaps which is not already used
    for i = 1 : numel(hues)
        cmap = [0 0 0 ; hsv2rgb([hues(i) 1 1])];
        if isempty(data) || ~any(cellfun(@(x)(isequal(x, cmap)), data(:, 5)))
            break
        end
    end
end
% generate colorbar image
cb = mri_colorize(ones(8, 1) * (0 :0.03: 1), [0 0 1], cmap);
fn = [tempname '.png'];
imwrite(cb, fn)

data{N, 1} = vol;
data{N, 2} = extent;
data{N, 3} = delta;
data{N, 4} = clim;
data{N, 5} = cmap;
data{N, 6} = fn;

setappdata(gcf, 'mrivis_data', data)

% don't update yet if called from mriBackground
stack = dbstack;
if (numel(stack) > 1) && isequal(stack(2).name, 'mriBackground'), return, end

mri_common_volume
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

