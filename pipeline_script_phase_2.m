% *************************************************************************
% IBSI CHAPTER 2, PHASE 2, PIPELINE SCRIPT
% *************************************************************************
%
% This script is for reproducing the second phase of tests in IBSI 2,
% conducted on a CT image.  
%
% Refer to the IBSI 2 reference manual for details of the tests; here, each
% cell specifies the parameters of the test.
%
% This script assumes you have the IBSI CT image downloaded, and also the 
% template submission csv file, to which the outputs are written.
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
%% ************************************************************************
% Add path for all functions in this repository
addpath(genpath('./'))

% import the CT and mask image once, here. They'll be renamed and used in 
% each and every subsequent cell.
msg = msgbox('Please select the CT image NIfTI folder','modal');
uiwait(msg)
image = import_image();

msg = msgbox('Please select the mask image NIfTI folder','modal');
uiwait(msg)
mask = import_image();

% also import the image metadata here, once
msg = msgbox('Now please select the image DICOM folder','modal');
uiwait(msg)
imagePath = uigetdir();
[imageMetaData,slicePos,~,~] =...
    load_image_metadata(imagePath,[]);

% load the results csv file, to add to as we work through
msg = msgbox('Please select the csv results file','modal');
uiwait(msg)
[csvFile,csvPath] = uigetfile('*.csv');
output = readcell([csvPath,csvFile]);

% some parameters are constant throughout:
% z-starting position for resampling
imageStartPos = slicePos(1,:);

% resegmentation intensity values
resegVals = [-1000,400];
intervalType = logical([1,1]);

% voxel dimensions
voxelDims = [imageMetaData(1).PixelSpacing;diff(slicePos(1:2,3))]';

% new voxel dimensions
newVoxelDims = [1,1,-1];

% interpolation types
imageInterpolationType = 'spline';
maskInterpolationType = 'linear';

% we can also do the resampling and resegmentation just once:
% resample the image
[resampledImage,~,~,~] = resample...
    (image,voxelDims,newVoxelDims,imageStartPos,imageInterpolationType);

% round the resampled image intensities to nearest integer
resampledImage = round(resampledImage);

% resample the mask
[resampledMask,~,~,~] = resample...
    (mask,voxelDims,newVoxelDims,imageStartPos,maskInterpolationType);

% round the mask values
resampledMask = round(resampledMask);

% resegment the mask - for config A (no resampling) and for B (resampled)
maskResegA = resegment(mask,image,resegVals,intervalType);
maskResegB = resegment(resampledMask,resampledImage,resegVals,intervalType);

%% ************************************************************************
% TEST 1A: CONFIG A, NO FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 5;

% diagnostic features
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(image,maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 1B: CONFIG B, NO FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 6;

% diagnostic features
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(resampledImage,maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 2A: CONFIG A, MEAN FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 7;

% 2D mean filter
filterSize = [5,5];
padType = 'mirror';
imageFiltered = filter_mean_2D(image,filterSize,padType);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered,maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 2B: CONFIG B, MEAN FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 8;

% 3D mean filter
filterSize = [5,5,5];
padType = 'mirror';
imageFiltered = filter_mean_3D(resampledImage,filterSize,padType);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered,maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 3A: CONFIG A, LOG FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 9;

% 2D LoG filter
sigma = [1.5,1.5];
cutoff = [4,4];
padType = 'mirror';

% because 2D analysis here, just pass first two elements of voxelDims
imageFiltered = filter_LoG(image,sigma,voxelDims(1:2),cutoff,padType);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered,maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 3B: CONFIG B, LOG FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 10;

% 3D LoG filter
sigma = [1.5,1.5,1.5];
cutoff = [4,4,4];
padType = 'mirror';
imageFiltered = filter_LoG(resampledImage,sigma,newVoxelDims,cutoff,padType);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered,maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 4A: CONFIG A, LAWS FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 11;

% 2D Laws filter
kernelTypes = {'level','edge'};
kernelSize = [5,5];
invariant = true;
poolingType = 'max';
energyFilterSize = 7;
lawsKernel = combine_Laws_kernels_2D(kernelTypes,kernelSize);
padType = 'mirror';
imageFiltered = filter_Laws_2D...
        (image,lawsKernel,padType,invariant,poolingType,energyFilterSize);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{3},maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 4B: CONFIG B, LAWS FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 12;

% 3D Laws filter
kernelTypes = {'level','edge','edge'};
kernelSize = [5,5,5];
invariant = true;
poolingType = 'max';
energyFilterSize = 7;
lawsKernel = combine_Laws_kernels_3D(kernelTypes,kernelSize);
padType = 'mirror';
imageFiltered = filter_Laws_3D...
        (resampledImage,lawsKernel,padType,invariant,poolingType,energyFilterSize);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{3},maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 5A: CONFIG A, GABOR FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 13;

% pixel size
pixelSize = voxelDims(1);

% filter the image
scale = 5;
wavelength = 2;
aspectRatio = 3/2;
orientations = 0:pi/8:pi-pi/8;
padType = 'mirror';
[imageFiltered,~] = filter_Gabor...
    (image,scale,wavelength,aspectRatio,...
    orientations,padType,pixelSize);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{1},maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 5B: CONFIG B, GABOR FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 14;

% pixel size
pixelSize = newVoxelDims(1);

% filter the image
scale = 5;
wavelength = 2;
aspectRatio = 3/2;
orientations = 0:pi/8:pi-pi/8;
padType = 'mirror';
[imageFiltered,g] = filter_Gabor...
    (resampledImage,scale,wavelength,aspectRatio,...
    orientations,padType,pixelSize);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{4},maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 6A: CONFIG A, DAUBECHIES 3 FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 15;

% parameters
waveletType = 'db3';
waveletCombination = {'LH'};
level = 1;
padType = 'mirror';

% get the filtered image
imageFiltered = filter_undecimated_separable_wavelet_2D...
    (image,waveletType,waveletCombination,level,padType);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{2},maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 6B: CONFIG B, DAUBECHIES 3 FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 16;

% parameters
waveletType = 'db3';
waveletCombination = {'LLH'};
level = 1;
padType = 'mirror';
poolType = 'mean';

% for 3D, get the wavelet filters in advance
waveletFilters = prepare_wavelet_filters(waveletType,level);

% get the filtered image
imageFiltered = filter_undecimated_separable_wavelet_3D...
    (resampledImage,waveletFilters,waveletCombination,level,padType,poolType);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{2},maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 7A: CONFIG A, DAUBECHIES 3 FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 17;

% parameters
waveletType = 'db3';
waveletCombination = {'LL','HH'};
level = 2;
padType = 'mirror';

% get the filtered image
imageFiltered = filter_undecimated_separable_wavelet_2D...
    (image,waveletType,waveletCombination,level,padType);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{2},maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 7B: CONFIG B, DAUBECHIES 3 FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 18;

% parameters
waveletType = 'db3';
waveletCombination = {'LLL','HHH'};
level = 2;
padType = 'mirror';
poolType = 'mean';

% for 3D, get the wavelet filters in advance
waveletFilters = prepare_wavelet_filters(waveletType,level);

% get the filtered image
imageFiltered = filter_undecimated_separable_wavelet_3D...
    (resampledImage,waveletFilters,waveletCombination,level,padType,poolType);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{2},maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 8A: CONFIG A, SIMONCELLI FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 19;

% level for Simoncelli (specify maximum to be returned)
level = 1;

% filter
imageFiltered = filter_Simoncelli_2D(image,level);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{1},maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 8B: CONFIG B, SIMONCELLI FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 20;

% level for Simoncelli (specify maximum to be returned)
level = 1;

% filter
imageFiltered = filter_Simoncelli_3D(resampledImage,level);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{1},maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 9A: CONFIG A, SIMONCELLI FILTER
% config A has no interpolation, but does have resegmentation, and
% filtering, when required, is slice-wise (2D)

% column to add to in output array
outputCol = 21;

% level for Simoncelli (specify maximum to be returned)
level = 2;

% filter
imageFiltered = filter_Simoncelli_2D(image,level);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,image,maskResegA);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{2},maskResegA);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% TEST 9B: CONFIG B, SIMONCELLI FILTER
% config B requires interpolation, resegmentation, and
% filtering, when required, is 3D

% column to add to in output array
outputCol = 22;

% level for Simoncelli (specify maximum to be returned)
level = 2;

% filter
imageFiltered = filter_Simoncelli_3D(resampledImage,level);

% diagnostic features
% on unfiltered image
diagnosticFeatures = ...
    calculate_diagnostic_features(mask,resampledImage,maskResegB);

% intensity statistics
intensityStats = calculate_intensity_stats(imageFiltered{2},maskResegB);

% assign to output array
outputCell = mat2cell([diagnosticFeatures;intensityStats],ones(23,1));
output(2:end,outputCol) = outputCell;

%% ************************************************************************
% WRITE OUTPUT TO FILE

% locate a suitable place for saving the response images
msg = msgbox('Please select a folder for saving the output results csv',...
    'modal');
uiwait(msg)
saveDir = uigetdir();
writecell(output,[saveDir,filesep(),'phase_2_results.csv'])
