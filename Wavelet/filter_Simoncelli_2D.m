function imageFiltered = filter_Simoncelli_2D(image,level)

% *************************************************************************
% FILTER_SIMONCELLI_2D: 2D Simoncelli filtering
% *************************************************************************
%
% INPUTS
%
%   image, the image to be filtered
%
%   level, the level to which the filtering should be performed
%
% OUTPUTS
%
%   imageFiltered, the filtered image
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% original image size
imDims = size(image);

% Fourier grid
[fy,fx] = ndgrid(-pi:(2*pi)/(imDims(1)-1):pi,...
    -pi:(2*pi)/(imDims(2)-1):pi);

% radial values
radialGrid = sqrt(fy.^2+fx.^2);

% initial value of Vb
Vb = 2*pi; % double real value, so each iteration below, can just halve it

% loop over levels
imageFiltered = cell(1,level);
for i = 1:level

    % halve the Vb
    Vb = Vb/2;

    % values over Fourier grid
    simoncelli = @(Vb,radialVals)...
        (cos((pi/2)*log2((2*radialVals)./Vb)));
    simoncelliVals = simoncelli(Vb,radialGrid);
    simoncelliVals(radialGrid <= Vb/4 | radialGrid >= Vb) = 0;

    % loop over slices
    responseS = zeros(imDims);
    for j = 1:imDims(3)
    
        % get the FFT of the padded image
        imageF = fftn(image(:,:,j));
        imageF = fftshift(imageF); % shift zero frequencies to centre
        
        % multiply the simoncelli filter and image together
        responseF = imageF.*simoncelliVals;
        
        % undo zero-shift of frequencies
        responseF = ifftshift(responseF);
        
        % inverse FT
        responseS(:,:,j) = real(ifftn(responseF));

    end
    
    % add to big output array
    imageFiltered{i} = responseS;

end
