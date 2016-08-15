function uic = uiHtmlBox(text, varargin)

% create an 'edit' uicontrol and modify it to display HTML text
%
% uic = uiHtmlBox(text, 'Name', Value, ...)
%
% The text to be displayed can be specified (and later changed) via the
% 'String' property.
%
% uic:  the Matlab uicontrol handle
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


% create 'edit' uicontrol
uic = uicontrol('Style', 'edit', 'Max', 2, varargin(1 :2: end), varargin(2 :2: end));

if nargin == 0
    text = '';
end

% set it up to display HTML and set contents
jsp = findjobj(uic);
jsp.setBorder(javax.swing.border.EmptyBorder(0,0,0,0))
jvp = jsp.getViewport;
je = jvp.getComponent(0);
je.setContentType('text/html');
je.setText(text);
je.setEditable(false)

if nargout == 0
    clear uic je jsp
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

