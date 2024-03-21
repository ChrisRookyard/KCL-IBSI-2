function imageFiltered = filter_LoG(image,sigma,voxelDims,cutoff,padType)

% *************************************************************************
% 
% filter_LoG: 
%   1. convolves the input 3D image ("image") with a LoG filter, 
%   2. The filter can be 2D or 3D, indicated by the length of the input
%   parameter sigma. This function uses two Matlab functions: fspecial3, or
%   fspecial, to create the filter, and imfilter.
%   3. the look of the filter is specified in "sigma", which is the
%   standard deviation of the corresponding Gaussian; "sigma" should be a
%   vector (y,x,z)
%   4. moreover, it is not assumed what units sigma will have - therfore,
%   if it is mm, the voxel dimensions should be specified in voxelDims
%   (y,x,z); otheriwse, if it is in voxels, voxelDims should be just [].
%   5. the input "cutoff" should also be a vector (y,x,z), specifying the
%   multiplication of sigma for each dimension, at which the filter will be
%   truncated; it is "d" in the IBSI specification
%   6. the size of the filter, in voxels, is calculated in a function
%   called "calculate_LoG_filter_size" - see that function for more details
%   7. the method of padding is specified in "padType", and should be
%   either "zero", "nearest", "periodic", or "mirror", as specified by IBSI
%   8. the filtered image, "imageFiltered" will be returned, the same size
%   as the input image
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% check dimension of sigma
if ~(any(length(sigma) == [2,3]))
    error('Filter must be of length 2 or 3')
end

% check dimension of cutoff
if ~(any(length(cutoff) == [2,3]))
    error('Cutoff must be of length 2 or 3')
end

% get dimensionality of analysis
dim = length(sigma);

% check the validity of voxelDims input
if ~(isempty(voxelDims))
    if ~(length(voxelDims) == dim)
        error('voxelDims do not match dimension of scale parameter')
    end
end

% units of sigma
if isempty(voxelDims)
    sigmaVoxels = sigma;
else
    sigmaVoxels = convert_mm_to_voxels(voxelDims,sigma);
    sigmaVoxels = abs(sigmaVoxels); % in case of negative slice step
end

% get the filter dimensions, in voxels
filterSize = calculate_LoG_filter_size(sigmaVoxels,cutoff);

% if 2D, fspecial supports only a scalar input for sigma
if dim == 2
    sigmaVoxels = sigmaVoxels(1);
end

% create the filter using either Matlab's fspecial or fspecial3 function
if dim == 2
    logFilter = fspecial('log',filterSize,sigmaVoxels);
else
    logFilter = fspecial3('log',filterSize,sigmaVoxels);
end

% set up padding type for the filter
padArg = padding_argument(padType);

% filter the image...
% padding is included in the call
% we specify the extra argument 'conv' here, so we filter by convolution,
% rather than the default correlation
if dim == 2
    imageFiltered = zeros(size(image));
    for i = 1:size(image,3)
        currentSlice = image(:,:,i);
        filteredSlice = imfilter(currentSlice,logFilter,padArg,'conv');
        imageFiltered(:,:,i) = filteredSlice;
    end
else
    imageFiltered = imfilter(image,logFilter,padArg,'conv');
end
