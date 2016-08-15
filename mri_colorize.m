function [im, mask] = mri_colorize(im, clim, cmap)

% transform data into truecolor image
%
% [im, mask] = mri_colorize(im, clim, cmap)
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


% apply threshold & determine mask
im(im < clim(1)) = nan;
mask = ~isnan(im);

% apply color limits
im = (im - clim(2)) / (clim(3) - clim(2));
im(im < 0) = 0;
im(im > 1) = 1;

% interpolate from colormap
im = interp1(linspace(0, 1, size(cmap, 1)), cmap, im);

% out-of-mask values appear black
im(isnan(im)) = 0;


% % alternative look-up-table code
% % faster by a factor 3-4, but this does not seem to impact UI responsivity
% % disadvantage: works only for smooth colormaps
% 
% % determine colormap entries
% ind = round(0.5 + size(cmap, 1) * im / (1 + eps));
% % remove NaNs
% ind(isnan(ind)) = 1;
% % look up in colormap
% im = cmap(ind, :);
% % out-of-mask values appear black
% im(~mask, :) = 0;
% % construct image
% im = reshape(im, [size(mask), 3]);


% Copyright (C) 2016 Carsten Allefeld
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.

