function imageFiltered = filter_undecimated_separable_wavelet_3D...
    (image,waveletFilters,waveletCombination,level,padType,poolType)

% *************************************************************************
% FILTER_UNDECIMATED_SEPARABLE_WAVELET: 3D wavelet filtering
% *************************************************************************
%
% INPUTS
%
%   image, the image to be filtered
%
%   waveletFilters, the pre-calculated set of filters (use
%   "prepare_wavelet_filters" — see pipeline scripts for examples)
%
%   waveletCombination, the combination of wavelet approximation and detail
%   over the 3 dimensions, e.g. HLH, to be used
%
%   level, the level of the wavelet - a trous resampling is used between
%   iterations
%
%   padType, the padding for the input image
%
%   the means of orientation pooling - 'max' or 'mean'
%
% OUTPUTS
%
%   imageFiltered, a cell, with first, a 4D array of 3D filtered images, 
%   with the 24 possible orientations going along the 4th dimension, then
%   in the second entry of the cell, the averaged image
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% filter names to search for
filterNames = [...
    'LLL';...
    'LLH';...
    'LHL';...
    'HLL';...
    'LHH';...
    'HLH';...
    'HHL';...
    'HHH'];

% set up padding type for the convolution
padArg = padding_argument(padType);

% initialise output
imageFiltered = cell(2,1);

% loop over levels
for i = 1:level

    % prepare input images
    if i == 1
        inputImage = repmat(image,[1,1,1,24]);
    else
        inputImage = approxImage;
    end
    
    % get the index of the filters to use, for the required combination
    currCombination = waveletCombination{i};
    combinationIdx = find(all(filterNames == currCombination,2));
    currWaveletFilters = waveletFilters{i};
    allFilters = currWaveletFilters{combinationIdx}; %#ok<FNDSB>

    % loop over rotations
    allImages = zeros(size(inputImage));
    for j = 1:24

        % current orientation filter
        currFilter = allFilters(:,:,:,j);

        % current image
        currImage = inputImage(:,:,:,j);

        % convolve
        allImages(:,:,:,j) = imfilter(currImage,currFilter,padArg,'conv');

    end

    % if there is a subsequent level...
    % if not, then average images and return the result
    if i < level
        approxImage = allImages;
    else
        % otherwise assign the latest "allImages" to the output, and
        % average it, too
        imageFiltered{1} = allImages;
        if strcmp(poolType,'mean')
            imageFiltered{2} = mean(allImages,4);
        elseif strcmp(poolType,'max')
            imageFiltered{2} = max(allImages,[],4);
        else
            imageFiltered{2} = NaN;
        end
    end
end
