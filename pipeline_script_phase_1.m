% *************************************************************************
% IBSI CHAPTER 2, PHASE 1, PIPELINE SCRIPT
% *************************************************************************
%
% This script is for reproducing the first phase of tests in IBSI 2,
% conducted on various 3D digital phantoms.  
%
% Refer to the IBSI 2 reference manual for details of the tests; here, each
% cell specifies the parameters of the test.
%
% Each phantom image is imported with "import_image" (in Utilities), which 
% can take a filepath as an argument, if you would rather not have to 
% select the relevant phantom image in a dialogue box. As it is, arguments 
% are passed, so no paths have to be hard-coded here. 
%
% Note that this script is desgined for use with the NIfTI versions of the
% phantom images, and also exports in this format.
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
%% ************************************************************************
% Add path for all functions in this repository
addpath(genpath('./'))

% find and change to the location of the phantom images
% (it makes import less painful)
msg = msgbox('Please select the phantom image folder','modal');
uiwait(msg)
phantomDir = uigetdir();
cd(phantomDir)

% locate a suitable place for saving the response images
msg = msgbox('Please select a folder for the response images',...
    'modal');
uiwait(msg)
saveDir = uigetdir();

%% ************************************************************************
% TEST 1a: MEAN FILTER, 3D
% IMAGE: checkerboard 
% PADDING: all 4 types - zero, nearest, periodic, mirror.

% message as a reminder for current phantom type
msg = msgbox('Please select the checkerboard phantom',...
    'modal');
uiwait(msg)

% import image
[image,info] = import_image();

% array for padding type
paddingTypes = {'zero','nearest','periodic','mirror'};

% IBSI test specifies a filter size of 15 (isotropic), in voxels
filterSize = [15,15,15];

% and specify saving name strings
filenames = {'response_1-a-1',...
    'response_1-a-2',...
    'response_1-a-3',...
    'response_1-a-4',};

% loop over padding types, and save the output image
for i = 1:length(paddingTypes)
    
    % do the filtering
    imageFiltered = filter_mean_3D(image,filterSize,paddingTypes{i});
    
    % save this image
    export_image(imageFiltered,info,filenames{i},saveDir)
    
end

%% ************************************************************************
% TEST 1b: MEAN FILTER, 2D
% IMAGE: impulse
% PADDING: zero

% message as a reminder for current phantom type
msg = msgbox('Please select the impulse phantom',...
    'modal');
uiwait(msg)

% import image
[image,info] = import_image();

% array for padding type
padType = 'zero';

% IBSI test specifies a filter size of 15 (isotropic), in voxels
filterSize = [15,15];

% and specify saving name strings
filename = 'response_1-b-1';

% do the filtering
imageFiltered = filter_mean_2D(image,filterSize,padType);
    
% save it
export_image(imageFiltered,info,filename,saveDir)

%% ************************************************************************
% TEST 2a–c: LOG FILTER
% 3 tests:
% 1.
% IMAGE: impulse
% PADDING: zero
% SCALE: 3mm
% CUTOFF: 4*scale
% DIMENSIONALITY: 3
% 2.
% IMAGE: checkerboard
% PADDING: mirror
% SCALE: 5mm
% CUTOFF: 4*scale
% DIMENSIONALITY: 3
% 3.
% IMAGE: checkerboard
% PADDING: mirror
% SCALE: 5mm
% CUTOFF: 4*scale
% DIMENSIONALITY: 2

% set up the parameter combinations
phantomName = {'impulse','checkerboard','checkerboard'};
paddingTypes = {'zero','mirror','mirror'};
scales = {[3,3,3],[5,5,5],[5,5]};
voxelDims = {[2,2,2],[2,2,2],[2,2]};
cutoffs = {[4,4,4],[4,4,4],[4,4]};

% and specify saving name strings
filenames = {'response_2-a','response_2-b','response_2-c'};

% loop over the combinations, filter and save
for i = 1:length(paddingTypes)
    
    % message as a reminder for current phantom type
    msg = msgbox(['Please select the ',phantomName{i},' phantom'],...
        'modal');
    uiwait(msg)

    % import the image
    [image,info] = import_image();
    
    % do the filtering
    imageFiltered = filter_LoG(image,scales{i},voxelDims{i},cutoffs{i},...
        paddingTypes{i});
    
    % save the image
    export_image(imageFiltered,info,filenames{i},saveDir)
    
end

%% ************************************************************************
% TEST 3a - 3b: LAWS FILTER, 3D
% 2 tests, with 3 outputs each:
% 1.
% IMAGE: impulse
% PADDING: zero 
% FILTER COMBINATION: E5L5S5
% OUTPUTS:
%   3-a-1 - single response map
%   3-a-2 - 3D rotation invariance, max pooling
%   3-a-3 - energy map of preceding image (s = 7)
% 2.
% IMAGE: checkerboard
% PADDING: mirror
% FILTER COMBINATION: E3W5R5
% OUTPUTS:
%   3-b-1 - single response map
%   3-b-2 - 3D rotation invariance, max pooling
%   3-b-3 - energy map of preceding image (s = 7)

% set up the parameter combinations
phantomName = {'impulse','checkerboard'};
paddingTypes = {'zero','mirror'};

% kernel combinations
kernelTypeCombinations = ...
    {{'edge','level','spot'};{'edge','wave','ripple'}};

% kernel sizes
kernelSizeCombinations = {[5,5,5];[3,5,5]};

% energy filter size
energyFilterSize = 7;

% invariant or not?
invariant = true;

% and specify saving name strings
filenames = {'response_3-a-1','response_3-a-2','response_3-a-3';...
    'response_3-b-1','response_3-b-2','response_3-b-3'};

for i = 1:length(paddingTypes)
    
    % message as a reminder for current phantom type
    msg = msgbox(['Please select the ',phantomName{i},' phantom'],...
        'modal');
    uiwait(msg)

    % import the image
    [image,info] = import_image();
    
    % combine these for a 3D filter
    kernelTypes = kernelTypeCombinations{i,1};
    kernelSizes = kernelSizeCombinations{i,1};
    lawsKernel = combine_Laws_kernels_3D(kernelTypes,kernelSizes);
    
    % filter the image
    padType = paddingTypes{i};
    poolingType = 'max';
    imageFiltered = filter_Laws_3D...
        (image,lawsKernel,padType,invariant,poolingType,energyFilterSize);

    % save the three images
    for j = 1:3
        export_image(imageFiltered{j},info,filenames{i,j},saveDir)
    end
end

%% ************************************************************************
% TEST 3c: LAWS FILTER, 2D
% 1 test, with 3 outputs:
% IMAGE: checkerboard
% PADDING: mirror
% FILTER COMBINATION: L5S5
% OUTPUTS:
%   3-c-1 - single response map
%   3-c-2 - 2D rotation invariance, max pooling
%   3-c-3 energy map of preceding image (s = 7)

% set up the parameter combinations
paddingTypes = {'mirror'};

% kernel combinations
kernelTypeCombinations = ...
    {{'level','spot'}};

% kernel sizes
kernelSizeCombinations = {[5,5]};

% energy filter size
energyFilterSize = 7;

% invariant or not?
invariant = true;

% and specify saving name strings
filenames = {'response_3-c-1','response_3-c-2','response_3-c-3'};

for i = 1:length(paddingTypes)

    % message as a reminder for current phantom type
    msg = msgbox('Please select the checkerboard phantom',...
        'modal');
    uiwait(msg)
    
    % import the image
    [image,info] = import_image();
    
    % combine these for a 3D filter
    kernelTypes = kernelTypeCombinations{i,1};
    kernelSizes = kernelSizeCombinations{i,1};
    lawsKernel = combine_Laws_kernels_2D(kernelTypes,kernelSizes);
    
    % filter the image
    padType = paddingTypes{i};
    poolingType = 'max';
    imageFiltered = filter_Laws_2D...
        (image,lawsKernel,padType,invariant,poolingType,energyFilterSize);
    
    % save the three images
    for j = 1:3
        export_image(imageFiltered{j},info,filenames{j},saveDir)
    end
end

%% ************************************************************************
% TEST 4: GABOR FILTER
% 2 tests, with 2 outputs each:
% 1.
% IMAGE: impulse
% PADDING: zero
% SIGMA: 10mm
% LAMBDA: 4mm
% GAMMA: 0.5
% OUTPUTS:
%   4-a-1 - single, 2D modulus response map, in-plane orientation = pi/3
%   4-a-2 - 2D rotation invariance, orientation delta = pi/4, mean pooling,
%       plus averaging over orthogonal planes
% 2.
% IMAGE: sphere
% PADDING: mirror
% SIGMA: 20mm
% LAMBDA: 8mm
% GAMMA: 5/2
% OUTPUTS:
%   4-b-1 - single, 2D modulus response map, in-plane orientation = 5pi/4
%   4-b-2 - 2D rotation invariance, orientation delta = pi/8, mean pooling,
%       plus averaging over orthogonal planes

% set up the parameter combinations
% call "filter_Gabor" function once per image (i.e. 4 times in total), 
% since it doesn't return a 2D modulus response map for a single 
% orientation if it is run in invariant mode, so create an entry for
% each parameter for each image...
phantomName = {'impulse','impulse','sphere','sphere'};
paddingTypes = {'zero','zero','mirror','mirror'};
scales = [10,10,20,20];
wavelengths = [4,4,8,8];
aspectRatios = [0.5,0.5,5/2,5/2];
orientationsAll = {pi/3;...
    0:pi/4:pi-pi/4;...
    5*pi/4;...
    0:pi/8:pi-pi/8};
voxelSize = 2;

% and specify saving name strings
filenames = {'response_4-a-1','response_4-a-2',...
    'response_4-b-1','response_4-b-2'};

% loop and do the processing
for i = 1:length(paddingTypes)

    % message as a reminder for current phantom type
    msg = msgbox(['Please select the ',phantomName{i},' phantom'],...
        'modal');
    uiwait(msg)
    
    % import the image
    [image,info] = import_image();
    
    % filter the image
    [imageFiltered,g] = filter_Gabor...
        (image,scales(i),wavelengths(i),aspectRatios(i),...
        orientationsAll{i},paddingTypes{i},voxelSize);
    
    % whether rotationally-invariant or not, the image to be saved will be
    % the last entry in the returned "imageFiltered" cell array
    imageToSave = imageFiltered{end};
    
    % fix orientation issue
    imageToSave = permute(imageToSave,[2,1,3]);
    
    % save the image
    export_image(imageToSave,info,filenames{i},saveDir)
    
end

%% ************************************************************************
% TEST 5: DAUBECHIES 2
% 1 test, with 2 outputs:
% IMAGE: impulse
% PADDING: zero
% DIMENSIONALITY: 3
% OUTPUTS:
%   5-a-1 - undecimated LHL map, 1st level
%   5-a-2 - rotation invariant with average pooling

% parameters
waveletType = 'db2';
waveletCombination = {'LHL'};
level = 1;
padType = 'zero';
poolType = 'mean';

% message as a reminder for current phantom type
msg = msgbox('Please select the impulse phantom',...
    'modal');
uiwait(msg)

% import image
[image,info] = import_image();

% get the wavelet filters
waveletFilters = prepare_wavelet_filters(waveletType,level);

% get the filtered image
imageFiltered = filter_undecimated_separable_wavelet_3D...
    (image,waveletFilters,waveletCombination,level,padType,poolType);

% save the two images
variantImage = imageFiltered{1}(:,:,:,1);
invariantImage = imageFiltered{2};
export_image(variantImage,info,'response_5-a-1',saveDir)
export_image(invariantImage,info,'response_5-a-2',saveDir)

%% ************************************************************************
% TEST 6: COIFFLET 1
% 1 test, with 2 outputs:
% IMAGE: sphere
% PADDING: periodic
% DIMENSIONALITY: 3
% OUTPUTS:
%   6-a-1 - undecimated HHL map, 1st level
%   6-a-2 - rotation invariant with average pooling

% parameters
waveletType = 'coif1';
waveletCombination = {'HHL'};
level = 1;
padType = 'periodic';
poolType = 'mean';

% message as a reminder for current phantom type
msg = msgbox('Please select the sphere phantom',...
    'modal');
uiwait(msg)

% import image
[image,info] = import_image();

% get the wavelet filters
waveletFilters = prepare_wavelet_filters(waveletType,level);

% get the filtered image
imageFiltered = filter_undecimated_separable_wavelet_3D...
    (image,waveletFilters,waveletCombination,level,padType,poolType);

% save the two images
% and specify saving name strings
variantImage = imageFiltered{1}(:,:,:,1);
invariantImage = imageFiltered{2};
export_image(variantImage,info,'response_6-a-1',saveDir)
export_image(invariantImage,info,'response_6-a-2',saveDir)

%% ************************************************************************
% TEST 7: HAAR
% 1 test, with 2 outputs:
% IMAGE: checkerboard
% PADDING: mirror
% DIMENSIONALITY: 3
% OUTPUTS:
%   undecimated LLL map, 2nd level, rotation invariant average pooling
%   undecimated HHH map, 2nd level, rotation invariant average pooling

% parameters
waveletType = 'haar';
waveletCombination = {{'LLL','LLL'},{'LLL','HHH'}};
level = 2;
padType = 'mirror';
poolType = 'mean';

% filenames to save to
filenames = {'response_7-a-1','response_7-a-2'};

% message as a reminder for current phantom type
msg = msgbox('Please select the checkerboard phantom',...
    'modal');
uiwait(msg)

% import image
[image,info] = import_image();

% get the wavelet filters
waveletFilters = prepare_wavelet_filters(waveletType,level);

for i = 1:length(waveletCombination)

    % get the filtered image
    imageFiltered = filter_undecimated_separable_wavelet_3D...
        (image,waveletFilters,waveletCombination{i},level,padType,poolType);

    % save the filtered image
    invariantImage = imageFiltered{2};
    export_image(invariantImage,info,filenames{i},saveDir)
            
end

%% ************************************************************************
% TEST 8: SIMONCELLI
% 1 test, 3 outputs:
% IMAGE: checkerboard
% PADDING: periodic
% DIMENSIONALITY: 3
% OUTPUTS:
%   1st level
%   2nd level
%   3rd level

% parameters
padType = 'periodic';
level = 3;

% filenames to save to
filenames = {'response_8-a-1','response_8-a-2','response_8-a-3'};

% message as a reminder for current phantom type
msg = msgbox('Please select the checkerboard phantom',...
    'modal');
uiwait(msg)

% import image
[image,info] = import_image();

% filter
imageFiltered = filter_Simoncelli_3D(image,level);

% save outputs
for i = 1:level
    imageToSave = imageFiltered{i};
    filename = filenames{i};
    export_image(imageToSave,info,filename,saveDir)
end
