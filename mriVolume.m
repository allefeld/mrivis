function [vol, XYZ] = mriVolume(vol, mask)

% obtain MRI volume
%
% [vol, XYZ] = mriVolume(vol)
% [vol, XYZ] = mriVolume(vol, mask)
%
% vol can be:
% - filename of img/hdr or nii file
% - 1d numerical array (specifying in-mask voxels only – needs mask)
% - 3d numerical array
% - cell array consisting of array as above and XYZ-data
%
% mask can be:
% - 3d array, logical or numerical
% - filename of img/hdr or nii file (integer data are converted to logical)
%
% for a logical mask, out-of-mask voxels are set to NaN
% for a numerical mask, data are multiplied elementwise with the mask
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


% volume data are given
if ischar(vol)                                  % as filename
    fprintf('loading %s\n', vol)
    gz = ~isempty(regexp(vol, '.gz$', 'once')); % gzipped image?
    if gz
        tfn = gunzip(vol, tempdir);             % gunzip to temporary file
        vol = tfn{1};
    end
    [vol, XYZ] = spm_read_vols(spm_vol(vol));
elseif iscell(vol)                              % as first element of cell array
    XYZ = vol{2};
    vol = vol{1};
end                                             % or directly

if ~exist('mask', 'var')
    mask = [];
end

% if mask data are given then
if ~isempty(mask) && ischar(mask)               % as filename
    fprintf('loading %s\n', mask)
    gz = ~isempty(regexp(mask, '.gz$', 'once')); % gzipped image?
    if gz
        tfn = gunzip(mask, tempdir);             % gunzip to temporary file
        mask = tfn{1};
    end
    V = spm_vol(mask);
    mask = spm_read_vols(V);
    if any(V.dt(1) == [2 4 8 256 512 768])
        % if integer data type, make logical
        mask = logical(mask);
    end
end                                             % or directly

% if volume data are given as 1d, construct full volume via mask
if sum(size(vol) > 1) == 1
    if isempty(mask)
        error('1d data needs mask')
    end
    dummy = nan(size(mask));
    dummy(mask) = vol;
    vol = dummy;
    clear dummy
end

% if there is a mask, apply it
if ~isempty(mask)
    if islogical(mask)
        vol(~mask) = nan;
    else
        vol = vol .* mask;
    end
end
clear mask

% if XYZ data are not given, use voxel space coordinates
if ~exist('XYZ', 'var')
    [R, C, P]  = ndgrid(1 : size(vol, 1), 1 : size(vol, 2), 1 : size(vol, 3));
    XYZ = [R(:)'; C(:)'; P(:)'];
    clear R C P
    fprintf('no space information available\n')
end

if numel(vol) ~= size(XYZ, 2)
    error('volume and XYZ do not match!')
end

% at this point we can be sure to have matching volume and XYZ

% determine coordinate axes
dim = size(vol);
XYZ = reshape(XYZ, [3 dim]);
% enforce right-handed coordinate system
if XYZ(1, 1, 1, 1) > XYZ(1, end, 1, 1)
    vol = flipdim(vol, 1);
    XYZ = flipdim(XYZ, 2);
end
if XYZ(1, 1, 1, 1) > XYZ(1, 1, end, 1)
    vol = flipdim(vol, 2);
    XYZ = flipdim(XYZ, 3);
end
if XYZ(1, 1, 1, 1) > XYZ(1, 1, 1, end)
    vol = flipdim(vol, 3);
    XYZ = flipdim(XYZ, 4);
end
% enforce regular grid
x = XYZ(1, :, ceil(dim(2) / 2), ceil(dim(3) / 2));
y = XYZ(2, ceil(dim(1) / 2), :, ceil(dim(3) / 2));
z = XYZ(3, ceil(dim(1) / 2), ceil(dim(2) / 2), :);
x = linspace(min(x), max(x), dim(1));
y = linspace(min(y), max(y), dim(2));
z = linspace(min(z), max(z), dim(3));
[X, Y, Z] = ndgrid(x, y, z);
XYZ = reshape(XYZ, [3 prod(dim)]);
d = XYZ - [X(:)'; Y(:)'; Z(:)'];
if max(abs(d(:))) >= 10 * eps(max(abs(XYZ(:))))
    warning('data have been forced onto a regular grid!')
    XYZ = [X(:)'; Y(:)'; Z(:)'];
end

fprintf('size: %d %d %d,\t', dim)
fprintf('resolution: %g %g %g\n', diff([x(1 : 2)', y(1 : 2)', z(1 : 2)']))

% at this point we can be relatively sure to have usable volume and XYZ


% Copyright (C) 2016 Carsten Allefeld
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.

