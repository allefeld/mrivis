function mri_update

% update figure
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


% prevent callbacks from calling this function while it is already executing
persistent busy
busy = 1;

% get data
common = getappdata(gcf, 'mrivis_common');
if isempty(common)
    return
end
data = getappdata(gcf, 'mrivis_data');
xyz = getappdata(gcf, 'mrivis_xyz');
type = getappdata(gcf, 'mrivis_type');
background = getappdata(gcf, 'mrivis_background');
marker = getappdata(gcf, 'mrivis_marker');
opacity = getappdata(gcf, 'mrivis_opacity');

% prepare common volume
volc = common{1};
xc = common{2};
yc = common{3};
zc = common{4};
mvolcSag = common{5};
mvolcCor = common{6};
mvolcAxi = common{7};
N = size(volc, 4);
dimc = size(volc);
dimc = dimc(1 : 3);
dc = diff(xc(1 : 2));

% update current coordinates
ijk = round((xyz - [xc(1), yc(1), zc(1)]) / dc) + 1;
ijk(ijk < 1) = 1;
ijk(ijk > dimc) = dimc(ijk > dimc);
icc = ijk(1);
jcc = ijk(2);
kcc = ijk(3);
xyz = [xc(icc), yc(jcc), zc(kcc)];
setappdata(gcf, 'mrivis_xyz', xyz)

% generate overlays and background
imSag = 0;
imCor = 0;
imAxi = 0;
ovSag = false;
ovCor = false;
ovAxi = false;
for l = 1 : N
    % extract orthogonal views
    switch type
        case 'mip'
            slSag = mvolcSag(:, :, l);
            slCor = mvolcCor(:, :, l);
            slAxi = mvolcAxi(:, :, l);
        case 'slices'
            slSag = squeeze(volc(icc, :, :, l));
            slCor = squeeze(volc(:, jcc, :, l));
            slAxi = squeeze(volc(:, :, kcc, l));
        otherwise
            error('unknown visualization type "%s"!', type)
    end
    % transform into truecolor images
    [slSag, mSag] = mri_colorize(slSag', data{l, 4}, data{l, 5});
    [slCor, mCor] = mri_colorize(slCor', data{l, 4}, data{l, 5});
    [slAxi, mAxi] = mri_colorize(slAxi', data{l, 4}, data{l, 5});
    % determine overlaid areas
    if (l ~= 1) || ~background
        ovSag = ovSag | mSag;
        ovCor = ovCor | mCor;
        ovAxi = ovAxi | mAxi;
    end
    if (l ~= 1) || ~background
        % combine additively
        imSag = imSag + slSag;
        imCor = imCor + slCor;
        imAxi = imAxi + slAxi;
    else
        % store
        bgSag = slSag;
        bgCor = slCor;
        bgAxi = slAxi;
    end
end
% combine overlays and background
if background
    imSag = bsxfun(@times, bgSag, 1 - ovSag * opacity) ...
        + bsxfun(@times, imSag, ovSag * opacity);
    imCor = bsxfun(@times, bgCor, 1 - ovCor * opacity) ...
        + bsxfun(@times, imCor, ovCor * opacity);
    imAxi = bsxfun(@times, bgAxi, 1 - ovAxi * opacity) ...
        + bsxfun(@times, imAxi, ovAxi * opacity);
end
% prevent color overflow
mc = max([imSag(:) ; imCor(:) ; imAxi(:)]);
if mc > 1
    imSag = imSag / mc;
    imCor = imCor / mc;
    imAxi = imAxi / mc;
    warning('overflowing color has been downscaled!')
end

% prepare information pane
info{1} = sprintf('<style>');
info{end + 1} = sprintf('td, th { padding: 0pt; text-align:right; margin-right: 10pt }');
info{end + 1} = sprintf('td { width: 80pt;  }');
info{end + 1} = sprintf('th { font-weight: normal; }');
info{end + 1} = sprintf('table { margin-bottom: 20pt; }');
info{end + 1} = sprintf('</style>');
info{end + 1} = sprintf('<table><tr><th>xyz:</th><td>%.5g</td><td>%.5g</td><td>%.5g</td></tr></table>', xyz);
info{end + 1} = sprintf('<table>');
for l = 1 : N
    info{end + 1} = sprintf('<tr><td style="width: 100pt">%.5g</td><th><img style="vertical-align: baseline" src="file:%s"></th><th>%.3g</th><th>%.3g</th><th>%.3g</th></tr>', ...
        volc(icc, jcc, kcc, l), data{l, 6}, data{l, 4});                                    %#ok<AGROW>
end
info{end + 1} = sprintf('</table>');

% show orthogonal views
rx = range(xc);
ry = range(yc);
rz = range(zc);
marg = 0.2 * (rx + rz + ry) / 3;
fpos = get(gcf, 'Position');
width = rx + ry + 3 * marg;
height = rz + ry + 3 * marg;
fac = min(fpos(3 : 4) ./ [width height]) ./ fpos(3 : 4);
% sagittal
aSag = findobj(gcf, 'Tag', 'aSag');
if isempty(aSag), aSag = axes; else axes(aSag), end
pos = [rx + 2 * marg, ry + 2 * marg, ry, rz] .* [fac fac];
pos(2) = pos(2) + (1 - height * fac(2));
pos = round(pos .* fpos([3 4 3 4]));
set(aSag, 'Units', 'pixels', 'Position', pos)
imSag = imresize(imSag, pos([4 3]));
imSag(imSag < 0) = 0;
imSag(imSag > 1) = 1;
image(yc, zc, imSag)
if marker
    line(xyz(2), xyz(3), 'Marker', 's', 'Color', [0.5 0.5 1], 'LineStyle', 'none')
end
axis xy
set(aSag, 'TickDir', 'out')
set(aSag, 'Tag', 'aSag')
% coronal
aCor = findobj(gcf, 'Tag', 'aCor');
if isempty(aCor), aCor = axes; else axes(aCor), end
pos = [marg, ry + 2 * marg, rx, rz] .* [fac fac];
pos(2) = pos(2) + (1 - height * fac(2));
pos = round(pos .* fpos([3 4 3 4]));
set(aCor, 'Units', 'pixels', 'Position', pos)
imCor = imresize(imCor, pos([4 3]));
imCor(imCor < 0) = 0;
imCor(imCor > 1) = 1;
image(xc, zc, imCor)
if marker
    line(xyz(1), xyz(3), 'Marker', 's', 'Color', [0.5 0.5 1], 'LineStyle', 'none')
end
axis xy
set(aCor, 'TickDir', 'out')
set(aCor, 'Tag', 'aCor')
% axial
aAxi = findobj(gcf, 'Tag', 'aAxi');
if isempty(aAxi), aAxi = axes; else axes(aAxi), end
pos = [marg, marg, rx, ry] .* [fac fac];
pos(2) = pos(2) + (1 - height * fac(2));
pos = round(pos .* fpos([3 4 3 4]));
set(aAxi, 'Units', 'pixels', 'Position', pos)
imAxi = imresize(imAxi, pos([4 3]));
imAxi(imAxi < 0) = 0;
imAxi(imAxi > 1) = 1;
image(xc, yc, imAxi)
if marker
    line(xyz(1), xyz(2), 'Marker', 's', 'Color', [0.5 0.5 1], 'LineStyle', 'none')
end
axis xy
set(aAxi, 'TickDir', 'out')
set(aAxi, 'Tag', 'aAxi')
% information pane
pos = [rx + 2 * marg, marg, ry, ry] .* [fac fac];
pos(2) = pos(2) + (1 - height * fac(2));
pos(3) = 1;     % hide scrollbar   % - (rx + 3 * marg) * fac(1);
aInfo = findobj(gcf, 'Tag', 'aInfo');
if isempty(aInfo)
    uiHtmlBox([info{:}], 'Units', 'normalized', 'Position', pos, ...
        'BackgroundColor', get(gcf, 'Color'), 'Tag', 'aInfo');
else
    set(aInfo, 'Units', 'normalized', 'Position', pos)
    set(aInfo, 'String', [info{:}])
end

% set up interactivity
persistent dragging
if isempty(dragging), dragging = false; end
% figure size changes: adjust layout
set(gcf, 'ResizeFcn', @figresized)
    function figresized(~, ~)
        mri_update
    end
% mouse button down: turn "dragging" on and update coords
set(gcf, 'WindowButtonDownFcn', @buttondown)
    function buttondown(~, ~)
        dragging = true;
        mousemoved
    end
% mouse button up: turn "dragging" off
set(gcf, 'WindowButtonUpFcn', @buttonup)
    function buttonup(~, ~)
        dragging = false;
    end
% mouse moved: update coords
set(gcf, 'WindowButtonMotionFcn', @mousemoved)
    function mousemoved(~, ~)
        % if "dragging" is off, mouse movement does not change current coords
        if ~dragging, return, end
        % if an update is already underway, ignore the mouse event
        if busy, busy = busy + 1; return, end
        cp = get(aSag, 'CurrentPoint');
        cp = cp(1, 1 : 2);
        xl = get(aSag, 'XLim');
        yl = get(aSag, 'YLim');
        if (cp(1) >= xl(1)) && (cp(1) <= xl(2)) ...
                && (cp(2) >= yl(1)) && (cp(2) <= yl(2))
            xyz(2 : 3) = cp;
            mriSetCoords(xyz)
            return
        end
        cp = get(aCor, 'CurrentPoint');
        cp = cp(1, 1 : 2);
        xl = get(aCor, 'XLim');
        yl = get(aCor, 'YLim');
        if (cp(1) >= xl(1)) && (cp(1) <= xl(2)) ...
                && (cp(2) >= yl(1)) && (cp(2) <= yl(2))
            xyz([1 3]) = cp;
            mriSetCoords(xyz)
            return
        end
        cp = get(aAxi, 'CurrentPoint');
        cp = cp(1, 1 : 2);
        xl = get(aAxi, 'XLim');
        yl = get(aAxi, 'YLim');
        if (cp(1) >= xl(1)) && (cp(1) <= xl(2)) ...
                && (cp(2) >= yl(1)) && (cp(2) <= yl(2))
            xyz(1 : 2) = cp;
            mriSetCoords(xyz)
            return
        end
    end
% toolbar
set(gcf, 'ToolBar','none');
tb = findobj(gcf, 'Tag', 'mrivisT');
if isempty(tb)
    tb = uitoolbar(gcf, 'Tag', 'mrivisT');
end
persistent buttons
if isempty(buttons)
    buttons = double(imread('mri_buttons.png')) / 255;
    buttons(repmat(sum(buttons, 3) == 3, [1 1 3])) = nan;
    buttons = reshape(buttons, 16, 17, [], 3);
    buttons(:, 17, :, :) = [];
end
buttoncallbacks = {'mriSetSlices', 'mriSetMIP', 'mriSetMarker', ...
    'mriBackground black', 'mriBackground none', 'mriBackground white', 'mriBackground two-tone', ...
    'mriSetOpacity(0)', 'mriSetOpacity(0.5)', 'mriSetOpacity(1)', ...
    'mriExport'};
pts = get(tb, 'Children');
if isempty(pts)
    for i = 1 : numel(buttoncallbacks)
        h = uipushtool(tb, 'CData', squeeze(buttons(:, :, i, :)));
        set(h, 'ClickedCallback', buttoncallbacks{i}, ...
            'TooltipString', buttoncallbacks{i})
    end
end

% busy
busy = 0;

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

