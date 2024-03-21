function [imageFiltered,g] = filter_Gabor...
    (image,scale,wavelength,aspectRatio,orientations,padType,voxelSize)

% *************************************************************************
% 
% filter_Gabor: 
%   1. convolves the input image with gabor filters.
%   2. scale is the standard deviation of Gaussian, in mm, and wavelength
%   should also be given in mm. The sptial frequency bandwidth is
%   calculated from the ratio of wavelength and scale.
%   3. aspect ratio is as defined in IBSI guide.
%   4. orientations can be a vector, defined in radians, as in IBSI. if it
%   is a scalar, then we assume only a rotationally-invariant image is
%   required; otherwise, we average over all orientations, and over
%   orthogonal planes
%   5. The image will be padded with "padType", and should be one of 
%   "zero", "nearest", "periodic", or "mirror", as specified by IBSI.
%   6. "voxelSize is the size of the voxels in mm; we assume isotropy.
%   7. Output is a cell. If rotationally-variant, then the cell is of
%   length one, with one image, the single response map, within it.  If
%   rotationally-invariant, then we have a 4-by-1 cell, with the orthogonal
%   response maps (3 of them), and the pooled rotationally-invariant map.
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% convert wavelength (lambda) and scale (sigma) to pixels
sigma = scale/voxelSize;
lambda = wavelength/voxelSize;

% calculate sigma:lambda ratio
sigLam = sigma/lambda;

% calculate spatial frequency bandwidth, in octaves
calculate_Fb = @(ratio)(log2(((ratio*pi)+(sqrt(log(2)/2)))/...
    ((ratio*pi)-(sqrt(log(2)/2)))));
Fb = calculate_Fb(sigLam);

% set up padding argument to pass to padarray
padArg = padding_argument(padType);

% convert orientation(s) to degrees
theta = orientations*(180/pi);

% convert to clockwise, as is IBSI convention
theta = mod(-theta,360);

% determine invariance or not
if length(orientations) == 1
    invariant = false;
else
    invariant = true;
end

% if variant, loop over slices and done; if invariant, loop over slices,
% orientations, orthogonal arrangment
if ~invariant
    
    % calculate the single orientation gabor filter
    g = gabor(lambda,theta,...
        'SpatialFrequencyBandwidth',Fb,'SpatialAspectRatio',aspectRatio);
    gKernel = g.SpatialKernel;
    centreCods = round(size(gKernel)./2);
    imHalfDims = round(size(image)/2);

    % if the kernel is smaller than half the image, take the whole
    % kernel; otherwise, make it the size of the image.
    if any(centreCods <= imHalfDims(1:2))
        gKernel = gKernel;
    else
        % The way this is calculated is effectively to double the value 
        % of imHalfDims, then to add one to it, so the size of gKernel 
        % ends up odd regardless of whether the value of imHalfDims is 
        % odd or even
        gKernel = ...
            gKernel(centreCods(1)-imHalfDims(1):centreCods(1)+imHalfDims(1),...
            centreCods(2)-imHalfDims(2):centreCods(2)+imHalfDims(2));
    end

    % calculate pad size based on sizes of returned Gabor filters
    %padSize = ceil(size(gKernel,1)/2);
    %padSize = floor(size(g(1).SpatialKernel,1)/2);
    
    % intermediate output
    h = zeros(size(image));
    
    % loop over slices for the one orientation
    for i = 1:size(image,3)
        
        % current slice
        x = image(:,:,i);
        
        % pad it
        %xp = padarray(x,[padSize,padSize],padArg);
        
        % filter it
        hMag = imfilter(x,real(gKernel),padArg,'conv');
        hPhs = imfilter(x,imag(gKernel),padArg,'conv');
        %[hMag,hPhs] = imgaborfilt(xp,g);
        
        % unpad it
        %hMag = hMag(padSize+1:end-padSize,padSize+1:end-padSize);
        %hPhs = hPhs(padSize+1:end-padSize,padSize+1:end-padSize);
        
        % get the modulus
        h(:,:,i) = abs(complex(hMag,hPhs));
        
    end
    
    % put this into the output
    imageFiltered{1,1} = h;
    
else
    
    % prepare output array
    imageFiltered = cell(4,1);
    
    % calculate the variously oriented gabor filters
    g = gabor(lambda,theta,...
        'SpatialFrequencyBandwidth',Fb,'SpatialAspectRatio',aspectRatio);
    imHalfDims = round(size(image)/2);
    gKernels = cell(length(theta),1);
    for k = 1:length(theta)

        gKernel = g(k).SpatialKernel;
        centreCods = round(size(gKernel)./2);

        % if the kernel is smaller than half the image, take the whole
        % kernel; otherwise, make it the size of the image.
        if any(centreCods <= imHalfDims(1:2))
            gKernels{k} = gKernel;
        else
            % The way this is calculated is effectively to double the value 
            % of imHalfDims, then to add one to it, so the size of gKernel 
            % ends up odd regardless of whether the value of imHalfDims is 
            % odd or even
            gKernels{k} = ...
                gKernel(centreCods(1)-imHalfDims(1):centreCods(1)+imHalfDims(1),...
                centreCods(2)-imHalfDims(2):centreCods(2)+imHalfDims(2));
        end
    end
    
    % calculate pad size based on sizes of returned Gabor filters
    %padSize = floor(size(g(1).SpatialKernel,1)/2);
    
    % set up the 3 orthogonal image arrangements
    orthMoves = {image;...
        fliplr(permute(image,[1,3,2]));flipud(permute(image,[3,2,1]))};
    
    % loop over orhtogonals, orientations and slices
    for j = 1:3
        
        % current orthogonal arrangement
        currentImage = orthMoves{j,1};
        
        % intermediate output
        h = zeros([size(currentImage),length(theta)]);
        
        % loop through slices
        for i = 1:size(currentImage,3)
            
            % current slice
            x = currentImage(:,:,i);

            % pad it
            %xp = padarray(x,[padSize,padSize],padArg);

            % loop over Gabor orientations
            for k = 1:length(theta)
                
                % current Gabor filter
                gKernel = gKernels{k};

                % filter image
                hMag = imfilter(x,real(gKernel),padArg,'conv');
                hPhs = imfilter(x,imag(gKernel),padArg,'conv');

                % put modulus into the output
                h(:,:,i,k) = abs(complex(hMag,hPhs));
                
            end

            % filter it (slice per orientation)
            %[hMag,hPhs] = imgaborfilt(xp,g);
            
            % unpad it
            %hMag = hMag(padSize+1:end-padSize,padSize+1:end-padSize,:);
            %hPhs = hPhs(padSize+1:end-padSize,padSize+1:end-padSize,:);
            
            % get modulus and put into output
            %h(:,:,i,:) = permute(abs(complex(hMag,hPhs)),[1,2,4,3]);
            
        end
        
        % average over orientations and put back to original configuration
        averageImage = mean(h,4);
        if j == 2
            averageImage = permute(fliplr(averageImage),[1,3,2]);
        end
        if j == 3
            averageImage = permute(flipud(averageImage),[3,2,1]);
        end
        imageFiltered{j,1} = averageImage;
        
    end
    
    % now, average over all orthogonals
    orthImages = cat(4,...
        imageFiltered{1,1},imageFiltered{2,1},imageFiltered{3,1});
    imageFiltered{4,1} = mean(orthImages,4);
    
end
