function imageFiltered = filter_undecimated_separable_wavelet_2D...
    (image,waveletType,waveletCombination,level,padType)

% *************************************************************************
% FILTER_UNDECIMATED_SEPARABLE_WAVELET: 2D wavelet filtering
% *************************************************************************
%
% INPUTS
%
%   image, the image to be filtered
%
%   waveletType, the type of wavelet to be used
%
%   waveletCombination, the combination of wavelet approximation and detail
%   over the 2 dimensions, e.g. LH, to be used
%
%   level, the level of the wavelet - a trous resampling is used between
%   iterations
%
%   padType, the padding for the input image
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

% filter kernels
[Fa,Fd] = wfilters(waveletType,'d');

% append a zero to the filters if they're even in length
if ~(mod(length(Fa),2))
    Fa = [Fa,0];
    Fd = [Fd,0];
end

% filter names to search for
filterNames = [...
    'LL';...
    'LH';...
    'HL';...
    'HH'];

% set up padding type for the convolution
padArg = padding_argument(padType);

% initialise output
imageFiltered = cell(2,1);

% loop over levels
for i = 1:level
    
    % if we are on any but the first time around, down-sample kernels
    if i == 1
        fa = Fa;
        fd = Fd;
    else
        % first, take off the zero at the end if odd length
        if mod(length(fa),2)
            fa = fa(1:end-1);
            fd = fd(1:end-1);
        end

        % a trous algorithm
        fa = reshape([fa;zeros(1,length(fa))],1,2*length(fa));
        fd = reshape([fd;zeros(1,length(fd))],1,2*length(fd));
        
        % and now put the zero back, if even in length
        if ~(mod(length(fa),2))
            fa = [fa,0]; %#ok<AGROW>
            fd = [fd,0]; %#ok<AGROW>
        end
        
    end
    
    % send these to the 2D filter calculator
    waveletFilters = combine_wavelet_kernels_2D(fa,fd);

    % prepare input images
    if i == 1
        inputImage = repmat(image,[1,1,1,4]);
    else
        inputImage = approxImage;
    end
    
    % get the index of the filters to use, for the required combination
    currCombination = waveletCombination{i};
    combinationIdx = find(all(filterNames == currCombination,2));
    allFilters = waveletFilters{combinationIdx}; %#ok<FNDSB>

    % loop over rotations
    allImages = zeros(size(inputImage));
    for j = 1:4

        % current orientation filter
        currFilter = allFilters(:,:,j);

        % current image
        currImage = inputImage(:,:,:,j);

        % loop over slices
        for k = 1:size(currImage,3)

            % current slice
            currSlice = currImage(:,:,k);

            % convolve
            allImages(:,:,k,j) = imfilter(currSlice,currFilter,padArg,'conv');
        end

    end

    % if there is a subsequent level THIS IS NOT THE APPROXIMATION
    % if not, then average images and return the result
    if i < level
        approxImage = allImages;
    else
        % otherwise assign the latest "allImages" to the output, and
        % average it, too
        imageFiltered{1} = allImages;
        imageFiltered{2} = mean(allImages,4);
    end
end
