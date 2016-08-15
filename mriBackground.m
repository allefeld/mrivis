function mriBackground(vol, mask, clim, cmap)

% set anatomical background image
%
% mriBackground(vol, mask, clim, cmap)
% mriBackground black
% mriBackground white
% mriBackground none
% mriBackground two-tone
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


if ~exist('vol', 'var'), vol = 'black'; end
if ~exist('mask', 'var'), mask = []; end
if ~exist('clim', 'var'), clim = []; end
if ~exist('cmap', 'var'), cmap = [0 0 0 ; 1 1 1]; end

% select standard background from label
newbg = true;
if ischar(vol)
    switch vol
        case 'black'
            vol = which('icbm152asym09b_black.nii.gz');
        case 'white'
            vol = which('icbm152asym09b_white.nii.gz');
        case 'none'
             newbg = false;
%             [X, Y, Z] = ndgrid([0 1], [0 1], [0 1]);
%             vol = {nan(2, 2, 2), [X(:), Y(:), Z(:)]'};
%             clim = [0 0 1];
        case 'two-tone'
            vol = which('icbm152asym09b_black.nii.gz');
            [vol, XYZ] = mriVolume(vol);
            vol = {vol > 0.61, XYZ};
            cmap = [1 1 1 ; 0 0 0];
    end
end

if newbg
    % plot background as regular volume
    mriPlot(vol, mask, clim, cmap)
end

data = getappdata(gcf, 'mrivis_data');

% remove old background if present
if getappdata(gcf, 'mrivis_background');
    data(1, :) = [];
end

if newbg
    % move last volume into position 1
    data = data([end, 1 : end - 1], :);
end

setappdata(gcf, 'mrivis_data', data)
setappdata(gcf, 'mrivis_background', newbg)

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

