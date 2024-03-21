function [resampledImage,oldGrid,newGrid,slicePos] = resample...
    (image,oldVoxelSize,newVoxelSize,imageStartPos,interpolationType)

% *************************************************************************
% RESAMPLE: for resampling of an image volume
% *************************************************************************
%
% INPUTS
%
%   image, the 3D image volume - the type is not assumed - this function
%   checks for double and if not, converts to it
%
%   oldVoxelSize, an array of the current voxel dimensions [y,x,z] of the 
%   input image - note that it is permissible for the z value to be
%   negative, in order to indicate which direction the coordinates go in
%   along this axis - units must match those of newVoxelSize
%
%   newVoxelSize, an array of the desired voxel dimensions [y,x,z] for the 
%   resampled image - units must match those of oldVoxelSize
%
%   imageStartPos,  a vector to indicate the starting value for the first
%   slice of the volume (x,y,z)
%
%   interpolationType, a string to indicate what algorithm should be used
%   for the interpolation - see Matlab documentation for options
%
% OUTPUTS
%
%   resampledImage, the resampled image, with the desired voxel dimensions,
%   of type double
%
%   oldGrid, a cell of the grids {y,x,z} used for the interpolant
%   structure - these are useful if you then want to resample another
%   image, e.g. a binary mask image of an associated ROI
%
%   newGrid, the same as oldGrid, but for the new, resampled image
%
%   slicePos, a vector of slice locations to write to the metadata when
%   saving the file to .dcm later - for the image position (patient)
%   attribute
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% find image volume dimensions
volDim = size(image);

% calculate the grids for interpolation
try
    [newGrid,oldGrid,slicePos] = calculate_new_grid(...
        oldVoxelSize,volDim,imageStartPos,newVoxelSize);
catch errMsg
    error(errMsg.identifier,errMsg.message)
end

% if the third dimension voxel size is negative, then the interpolation
% algorithm won't take the grids - it has to have ascending order, so flip
% the grids, and the image, along its third dimension
if oldVoxelSize(3) < 0
    image = flip(image,3);
    oldGrid{1,3} = flip(oldGrid{1,3},3);
    newGrid{1,3} = flip(newGrid{1,3},3);
end

% make the interpolant object
intrpObj = griddedInterpolant(...
    oldGrid{1,1},oldGrid{1,2},oldGrid{1,3},image,interpolationType);

% do the interpolation to resample
resampledImage = intrpObj(newGrid{1,1},newGrid{1,2},newGrid{1,3});

% flip the grids and the resampled image back
if oldVoxelSize(3) < 0
    resampledImage = flip(resampledImage,3);
    oldGrid{1,3} = flip(oldGrid{1,3},3);
    newGrid{1,3} = flip(newGrid{1,3},3);
end
