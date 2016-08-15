# Visualization of brain MR images for Matlab

The program displays one or more brain MR images, usually derived from functional
data, in color on top of black and white anatomical brain images. The focused
position as well as a number of display properties can be modified interactively.
Other than the popular program `mricron` (which it emulates) all functionality can
also be accessed programmatically, so that e.g. preparation of figures for
publication can be automated.

The main interface is given by the function `mriPlot`. The functions `mriSetSlices`,
`mriSetMIP`, `mriSetMarker`, `mriBackground`, `mriSetOpacity`, `mriExport`, and
`mriSetCoords` are used to implement the GUI, but can also be called directly.
`mriVolume` provides a unified interface for specifying MR volumes in different
forms for `mriPlot`. For more information, see the Matlab `help` of the respective
function. All other functions are for internal purposes only.


***

This software was developed with Matlab R2015a.
It is copyrighted © 2016 by Carsten Allefeld and released under the terms of the
GNU General Public License, version 3 or later, except for the following portions:

The two background images, `icbm152asym09b_black.nii` and
`icbm152asym09b_white.nii`, were derived from the image\
`mni_icbm152_t1_tal_nlin_asym_09b_hires.nii`,
part of the 'ICBM 2009b Nonlinear Asymmetric' atlas released at
<http://nist.mni.mcgill.ca/?p=904> with the following license:

>   Copyright (C) 1993–2004 Louis Collins, McConnell Brain Imaging Centre,
> Montreal Neurological Institute, McGill University. Permission to use, copy,
> modify, and distribute this software and its documentation for any purpose
> and without fee is hereby granted, provided that the above copyright notice
> appear in all copies. The authors and McGill University make no
> representations about the suitability of this software for any purpose. It is
> provided “as is” without express or implied warranty. The authors are not
> responsible for any data loss, equipment damage, property loss, or injury to
> subjects or patients resulting from the use or misuse of this software
> package.

The file `findobj.m` is copyrighted © 2010 by Yair M. Altman, released at
<https://de.mathworks.com/matlabcentral/fileexchange/14317>

