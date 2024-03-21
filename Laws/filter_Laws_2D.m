function imageFiltered = filter_Laws_2D...
    (image,lawsKernel,padType,invariant,poolingType,energyFilterSize)

% *************************************************************************
% FILTER_LAWS_2D: convolves an image with one, or many 2D Laws kernel(s)
% *************************************************************************
%
% INPUTS
%
%   image, the image to be filtered, a 3D array
%
%   lawsKernel, a cell array of 2D Laws kernels
%
%   padType, the method for padding the image (and the intermediate pooled 
%   rotationally-invariant image, if rotation invariance is desired) - it
%   should be one of "zero", "nearest", "periodic", or "mirror", as 
%   specified by IBSI
%
%   invariant, a boolean to indicate whether a rotationally-invariant
%   approach is desired; true for yes, false for no
%
%   poolingType, a string to indicate the type of pooling needed if a
%   rotationally-invariant approach is desired - this should be one of 
%   'max' or 'mean'
%
%   energyFilterSize, the size of the mean filter used to calculate the 
%   energy image - the filter will be of size 2 times "energyFilterSize", 
%   and units are assumed to be voxels
%
% OUTPUTS
%
%   imageFiltered, a cell, which, if rotationally-variant, is of length 
%   one, with one image, the single response map, within it; if
%   rotationally-invariant, then it is a 3-by-1 cell, with the original
%   response map, the pooled rotationally-invariant map, and the energy
%   map
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% set up padding type for the filter
padArg = padding_argument(padType);

% regardless of rotation invariance 
% calculate the first response map, h
nSlices = size(image,3);
h1 = zeros(size(image));
for j = 1:nSlices
    h1(:,:,j) = imfilter(image(:,:,j),lawsKernel{1,1},padArg,'conv');
end

% put this first image into the output
imageFiltered{1,1} = h1;

% if rotation invariant, then we're done
% otherwise, carry on to convolve with all other filters and pooling, and
% energy, etc...
if ~invariant
    return
else
    
    % we have the first convolution, so put that into the first part of an
    % intermediate 4D array
    h = zeros([size(image),length(lawsKernel)]);
    h(:,:,:,1) = h1;
    clear h1
    
    % loop over the remaining kernel configurations, get the response maps
    for i = 2:length(lawsKernel)
        for j = 1:nSlices
            h(:,:,j,i) = imfilter(...
                image(:,:,j),lawsKernel{i,1},padArg,'conv');
        end
    end
    
    % now get the orientation-pooled map
    if strcmp(poolingType,'max')
        hPooled = max(h,[],4);
    elseif strcmp(poolingType,'mean')
        hPooled = mean(h,4);
    end
    
    % put this into the second entry of the output
    imageFiltered{2,1} = hPooled;
    
    % calculate the "energy" map, via mean filtering of absolute image
    imageFiltered{3,1} = filter_mean_2D(abs(hPooled),...
        ones(1,2).*((2*energyFilterSize)+1),padType);
    
end
