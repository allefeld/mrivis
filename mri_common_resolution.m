function dc = mri_common_resolution(ds, ns, mce)

% find common step size for blending images
%
% dc = mri_res(ds, ns, mce)
%
% ds:       single step sizes [mm]
% lengths:  single lengths [voxels]
% mce:      maximum combined extent [mm]
% dc:       recommended common step size
%
%
% This file is part of the development version of mrivis, see
% https://github.com/allefeld/mrivis


% A vector of length n with a step size of d covers an extent e = d * n. If
% we upsample to a smaller step size dc, the new vector has a length of
% about   = round(d / dc * n). If the upsampling is done via
% nearest neighbor, the new vector has constant sequences of lengths
% floor(d / dc) and ceil(d / dc) which alternate in such a way that the
% mean sequence length is d / dc exactly for infinite length. Within the
% finite length m, we want the upsampled vector to consist of constant
% sequences of one length only, which is lp = round(d / dc). To fill m
% elements with this length, we need ceil(m / lp) constant sequences before
% the first sequence of the other length, lo. This means the other length
% may occur at a relative frequency of
%     1 / (ceil(m / lp) + 1)
% at the most. Since
%     f * lo + (1 - f) * lp = d / dc,
% that frequency is
%     f = abs(d / dc - lp).
% It follows the condition
%     abs(d / dc - lp) < 1 / (ceil(m / lp) + 1)
% and consequently
%     abs(d / dc - lp) * ceil(m / lp) < 0.5
% and approximately
%     abs(d / dc - lp) * n < 0.5.
% The expression on the left is an estimate of the number of sequences with
% the other lenght, lo.

% Well, it appears this criterion is too strict, so we follow an optimization
% approach:

ds = ds(:)';
ns = ns(:)';

% We consider only those candidate dcs
% - where d / dc is exactly integer for at least one d
% - where a given maximum bitmap size is not exceeded
% - and which are not larger than any of the ds.
pixelMax = 5000;
dcMin = mce / pixelMax;
dcs = unique(ds' * (1 ./ (1 : ceil(max(ds) / dcMin))));
dcs = dcs(dcs >= dcMin);
dcs = dcs(dcs <= min(ds));

% compute properties for all combinations of ds and dcs
r = (1 ./ dcs) * ds;                % ratio to be approximated
lp = round(r);                      % preferred sequence length
f = abs(r - lp);                    % rel. frequency of other sequence length
af = bsxfun(@times, f, ns);         % abs. frequency of other sequence length

% criterion: total number of other sequence lengths, weighted by severity
crit = sum(af ./ lp, 2);            

% select the largest dc with the optimal criterion
dc = max(dcs(crit == min(crit)));

if nargout == 0
    semilogx(dcs, crit, '.')
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

