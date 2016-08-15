function mri_common_volume

% determine common volume for all images
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


data = getappdata(gcf, 'mrivis_data');
N = size(data, 1);

% determine sizes, extents, and resolutions of overlayed images
dim = cellfun(@size, data(:, 1), 'UniformOutput', false);
extent = data(:, 2);
delta = data(:, 3);

% determine common extent and resolution
ec = cat(3, extent{:});
ec = [min(ec(1, :, :), [], 3); max(ec(2, :, :), [], 3)];
dc = mri_common_resolution([delta{:}], [dim{:}], max(diff(ec)));
dimc = round(diff(ec) / dc) + 1;

% determine common axes
xc = (0 : dimc(1) - 1) * dc + ec(1, 1);
yc = (0 : dimc(2) - 1) * dc + ec(1, 2);
zc = (0 : dimc(3) - 1) * dc + ec(1, 3);

% generate common volume
volc = nan([dimc N], 'single');
for l = 1 : N
    % transformation of indices
    i = round((xc - extent{l}(1, 1)) / delta{l}(1)) + 1;
    j = round((yc - extent{l}(1, 2)) / delta{l}(2)) + 1;
    k = round((zc - extent{l}(1, 3)) / delta{l}(3)) + 1;
    
    % if background, initialize with mean corner value
    if (l == 1) && getappdata(gcf, 'mrivis_background')
        cornerval = data{1, 1}([1 end], [1 end], [1 end]);
        volc(:, :, :, 1) = mean(cornerval(:));
    end
    
    % "nearest neighbor" interpolation
    iind = (i >= 1) & (i <= dim{l}(1));
    jind = (j >= 1) & (j <= dim{l}(2));
    kind = (k >= 1) & (k <= dim{l}(3));
    volc(iind, jind, kind, l) = data{l, 1}(i(iind), j(jind), k(kind));
end

% precompute maximum intensity projection
mvolcSag = squeeze(max(volc, [], 1));
mvolcCor = squeeze(max(volc, [], 2));
mvolcAxi = squeeze(max(volc, [], 3));

setappdata(gcf, 'mrivis_common', {volc, xc, yc, zc, mvolcSag, mvolcCor, mvolcAxi})

% r = nancov(reshape(volc, [], N));
% r = diag(1 ./ sqrt(diag(r))) * r * diag(1 ./ sqrt(diag(r)))


% Copyright (C) 2016 Carsten Allefeld
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.

