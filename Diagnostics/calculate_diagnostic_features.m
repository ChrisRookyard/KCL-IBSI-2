function diagnosticFeatures = ...
    calculate_diagnostic_features(maskPre,imagePost,maskPost)

% *************************************************************************
% CALCULATE DIAGNOSTIC FEATURES: finds diagnostic features of an ROI
% *************************************************************************
%
% INPUTS
%
%   maskPre, the mask image, before resegmentation and interpolation
%
%   imagePost, the image, after resegmentation and interpolation
%
%   maskPost, the mask image, after resegmentation and interpolation
%
% OUTPUTS
%
%   diagnosticFeatures, a 1-by-5 array of the diagnostic features:
%       number of voxels in the ROI before reseg. and interp.
%       number of voxels in the ROI after    ---   "   ---
%       mean intensity in the ROI after      ---   "   ---
%       maximum intensity in ROI after       ---   "   ---
%       minimum intensity in ROI after       ---   "   ---
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% voxel counts
numVoxelsPre = sum(maskPre(:) == 1);
numVoxelsPost = sum(maskPost(:) == 1);

% get the voxels from the image 
inVox = imagePost(logical(maskPost));

% calculate the mean, max, and min
meanIntensity = mean(inVox);
maxIntensity = max(inVox);
minIntensity = min(inVox);

% put them all together
diagnosticFeatures = [numVoxelsPre;numVoxelsPost;meanIntensity;...
    maxIntensity;minIntensity];
