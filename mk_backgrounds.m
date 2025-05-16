%% construct background images

clear

% mricrogl ("masked") is derived from ICBMasym09b ("original") by
% modulating with an unknown binary mask which was smoothed using a
% Gaussian kernel with 2mm FWHM, and subsequent conversion to 8 bit.
%
% We want to recover the binary and smoothed masks to construct new
% templates with white and black backgrounds.

% "ICBM 2009b Nonlinear Asymmetric" at http://nist.mni.mcgill.ca/?p=904
ICBMasym09b = 'mni_icbm152_t1_tal_nlin_asym_09b_hires.nii';
% derived from that  by Chris Rorden, included with MRIcroGL 12/12/2012
mricrogl = 'mni152_2009bet.nii';

% superimpose original and masked to get a common space
figure
V1 = spm_vol(ICBMasym09b);
[Y, XYZ1] = spm_read_vols(V1);
mriPlot({Y, XYZ1})
V2 = spm_vol(mricrogl);
[Y, XYZ2] = spm_read_vols(V2);
mriPlot({Y, XYZ2})
clear Y XYZ2

% access common space data
common = getappdata(gcf, 'mrivis_common');
volc = common{1};
close
clear Y common

% extract original (1) and masked (2)
Y1 = volc(:, :, :, 1);
Y2 = volc(:, :, :, 2);
outside = isnan(Y2);
Y2(outside) = 0;
clear volc

% estimate smoothed mask
mask = Y2 ./ Y1;
clear Y2

% reconstruct binary mask
Bmask = double(mask > 0.5);
clear mask

% construct convolution kernel (point spread function)
FWHM = 2;
alpha = 1 / (FWHM / 2) ^ 2;
GK = 2 .^ (-alpha * sum(XYZ1 .^ 2));
GK = reshape(GK, size(Bmask));
[i, j, k] = ind2sub(size(GK), find(GK == 1));
GK = circshift(GK, 1 - [i j k]);
fGK = real(fftn(GK, size(Bmask)));
fGK = fGK / fGK(1, 1, 1);
clear XYZ1 GK

% reconstruct smoothed mask
sBmask = real(ifftn(fGK .* fftn(Bmask, size(Bmask))));
clear fGK Bmask

% remove wrap-around from brain stem
sBmask(:, :, 345 : end) = 0;
% clean up rounding errors
sBmask(sBmask < 1e-14) = 0;

% construct backgrounds
Y1 = Y1 / 85;
Y1(Y1 > 1) = 1;
black = Y1 .* sBmask;
black = single(reshape(black(~outside), V2.dim));
white = Y1 .* sBmask + (1 - sBmask);
white = single(reshape(white(~outside), V2.dim));

% save 'em
saveMRImage(black, 'icbm152asym09b_black.nii', V2.mat, ...
    'black background from mni_icbm152_t1_tal_nlin_asym_09b_hires')
saveMRImage(white, 'icbm152asym09b_white.nii', V2.mat, ...
    'white background from mni_icbm152_t1_tal_nlin_asym_09b_hires')

