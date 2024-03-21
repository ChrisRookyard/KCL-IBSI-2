function imageFiltered = filter_mean_3D(image,filterSize,padType)

% *************************************************************************
%
% filter_mean_3D:
%   1. convolves the input 3D image ("image") with a mean filter, using the
%   built-in Matlab function "imboxfilt3"
%   2. said filter will be of size specified in "filterSize", which should
%   be specified in voxels, and of length 3(y,x,z)
%   3. the input filterSize should be of odd-integer size in each
%   dimension
%   4. the method of padding is specified in "padType", and should be
%   either "zero", "nearest", "periodic", or "mirror", as specified by IBSI
%   5. the filtered image, "imageFiltered" will be returned, the same size
%   as the input image
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% check dimension of filterSize
if length(filterSize) ~= 3
    error('Filter must be of length 3')
end

% check values of filter size for oddness
if any(rem(filterSize,2) == 0)
    error('Filter sizes must all be odd')
end

% check values of filter size for being integers
if any(rem(filterSize,1) ~= 0)
    error('Filter sizes must be integers')
end

% set up padding type for the filter
padArg = padding_argument(padType);

% filter the image...
% padding is included in the call
% default behaviour of Matlab's "imboxfilt3" function is to mean-filter the
% image (see the optional parameter "NormalizationFactor" in the docs)
imageFiltered = imboxfilt3(image,filterSize,'padding',padArg);
