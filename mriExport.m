function mriExport(prefix)

% save current views as png files
%
% mriExport(prefix = 'mri')
%
% prefix:   string with which names of files should start
%           can also be used to specify the directory
%
% The function saves three png files corresponding to the
% three views, sagittal, coronal, and axial. The file names also contain
% coordinate information.
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


mri_assert

if nargin == 0
    prefix = 'mri';
end

xyz = getappdata(gcf, 'mrivis_xyz');

ihs = findobj(findobj(gcf, 'Tag', 'aSag'), 'Type', 'image');
if ~isempty(ihs)
    fn = sprintf('%s_sagittal_x=%.5g.png', prefix, xyz(1));
    fprintf('writing %s\n', fn)
    imwrite(flipdim(get(ihs, 'CData'), 1), fn)
end

ihc = findobj(findobj(gcf, 'Tag', 'aCor'), 'Type', 'image');
if ~isempty(ihc)
    fn = sprintf('%s_coronal_y=%.5g.png', prefix, xyz(2));
    fprintf('writing %s\n', fn)
    imwrite(flipdim(get(ihc, 'CData'), 1), fn)
end

iha = findobj(findobj(gcf, 'Tag', 'aAxi'), 'Type', 'image');
if ~isempty(iha)
    fn = sprintf('%s_axial_z=%.5g.png', prefix, xyz(3));
    fprintf('writing %s\n', fn)
    imwrite(flipdim(get(iha, 'CData'), 1), fn)
end

if numel([ihs ihc iha]) < 3
    warning('one or more bitmaps cannot be accessed!')
end

% aInfo = findobj(gcf, 'Tag', 'aInfo');


% Copyright (C) 2016 Carsten Allefeld
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.

