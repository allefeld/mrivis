# MRI coordinate systems

One has to distinguish coordinate systems (spaces), atlases, and templates.


## Talairach space

Talairach & Tournoux (1988) defined a *coordinate system* of measurements in millimeters, with its origin at the anterior commissure (AC), an x-axis distinguishing left and right, a y-axis going through the posterior commissure (PC), and a vertical z-axis.

They also published an *atlas* of the brain of a single person, laid out with respect to this coordinate system. For the atlas, the coordinate system was complemented by a grid forming a cube fitted to the person's cerebrum, with 8 × 9 × 12 cells, where of the 9 steps along the y-axis the middle one is larger to comprise the whole area between AC and PC. This is the grid shown in the SPM results window.

Another person's brain can be matched to this grid by rotating it first to match the AC–PC line, and then compressing or extending it (using a piecewise linear transform) into the 2 × 3 × 2 main parts of the grid (left / right, in front of AC / between AC and PC / behind PC, above / below the AC–PC line) so that a match of AC and PC as well as the outer cube boundaries is achieved. Coordinates referring to places in a brain such matched to the Talairach & Tournoux grid are called "Talairach coordinates" and can be used to look up the anatomical structure that place belongs to in Talairach & Tournoux's atlas.

Sources:\
– [Brain Voyager: Manual ACPC and Talairach Transformation](http://www.brainvoyager.com/bvqx/doc/UsersGuide/BrainNormalization/ManualACPCAndTalairachTransformation.html>)\
– [Talairach software](http://www.talairach.org/)\
– [Mapping to the Talairach coordinate system](http://mipav.cit.nih.gov/documentation/presentations/talairach.pdf)


## MNI space

Instead of transforming a brain into a standard space based on landmarks only, it is better to try and match more detailed anatomical structures; and instead of matching it to the brain of a single "standard" person it is better to match it to the average anatomy of a large sample of people, a *template*.

The first such template, the MNI-305, was produced at the Montréal Neurological Institute. T1-weighted scans from 305 persons were linearly matched to the Talairach space based on landmarks, and averaged. Then, all scans were linearly matched to that average, and averaged again. Coordinates referring to places in a brain such matched to the MNI-305 template are called "MNI coordinates" and define the MNI space. MNI space is a rough approximation of Talairach space, but coordinates do not coincide perfectly. Different approaches exist to transform between Talairach and MNI coordinates.

The currently most popular template is the MNI-152; it is used by SPM since v99 and was adopted by the International Consortium for Brain Mapping as standard ICBM152. It is the average of T1-weighted MRI scans of 152 normal brains, each of which has been linearly transformed to match the previous template, MNI-305. Coordinates referring to places in a brain matched to the MNI-152 template are therefore also considered MNI coordinates.

Sources:\
– [MNI Average Brain (305 MRI) Stereotaxic Registration Model](http://www.bic.mni.mcgill.ca/ServicesAtlases/MNI305)
– [The MNI brain and the Talairach atlas](http://imaging.mrc-cbu.cam.ac.uk/imaging/MniTalairach)\
– [Linear ICBM Average Brain (ICBM152) Stereotaxic Registration Model](http://www.bic.mni.mcgill.ca/ServicesAtlases/ICBM152Lin)\
– SPM file `spm_templates.man`


## Templates

SPM:
templates/T1.nii    = icbm_avg_152_t1_tal_lin --> 2mm, 8mm FWHM
canonical/avg152T1  = icbm_avg_152_t1_tal_lin --> 2mm, [0, 1.00000005913898], 256 values

mni152_2009bet is included with MRIcroGL, and is presumably a masked version of  mni_icbm152_t1_tal_nlin_asym_09c, or maybe 09a

mni_icbm152_t1_tal_nlin_asym_09a appears to be the closest to icbm_avg_152_t1_tal_lin, albeit by a small margin

http://en.wikibooks.org/wiki/MINC/Atlases/Atlases/History

## Coordinate systems in NifTI and SPM

The NIfTI-1 file format contains information about the transformation from voxel indices to real-world coordinates and about the specific space this transformation attempts to match (its "intent"). It supports three different methods for transformation, using the fields `pixdim`, `qform` and `sform`. The methods include (1) scaling only, (2) scaling and shifting, and (3) a full affine transform. Transformations according to methods 2 and 3 can be specified both in the same file.

When a volume is loaded into SPM, the full affine transform (method 3) is used if present, otherwise there is a fallback onto methods 2 and 1. The preferred transformation is represented in `V.mat`, which is identical to `V.private.mat`, and the corresponding intent in `V.private.mat_intent`. If another transformation is present, it is represented in `V.private.mat0` and `V.private.mat0_intent`. The transformation intent can be `UNKNOWN`, `Scanner`, `Aligned`, `Talairach`, or `MNI152`.

Sources:\
– [NIfTI-1 Data Format: Docs on qform and sform](http://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html)\
– SPM files `spm_vol.m`, `spm_vol_nifti.m`, `@nifti/subsref.m`, and `@nifti/private/getdict.m`.





http://www.amazon.com/The-Human-Cerebral-Cortex-Stereotaxic/dp/0123869382
