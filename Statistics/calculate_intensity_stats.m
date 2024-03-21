function intensityStats = calculate_intensity_stats(image,mask)

% *************************************************************************
% CALCULATE_INTENSITY_STATS: calculates intensity-based statistics
% *************************************************************************
%
% INPUTS
%
%   image, the image to be analysed
%
%   mask, a binary mask to specify the region of interest
%
% OUTPUTS
%
%   intensity stats, the statistics as specified by IBSI for benchmarking
%   in chapter 2, phase 2. 
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% get the voxels from the image
inVox = image(logical(mask));

% mean
meanIntensity = mean(inVox);

% variance (with non-default normalisation, i.e., divide by N, not N-1)
variance = var(inVox,1);

% skewness
skew = skewness(inVox);

% kurtosis, with 3 taken off it for Fisher correction 
kurt = kurtosis(inVox)-3;

% median
med = median(inVox);

% minimum
minimum = min(inVox);

% 10th percentile
ptileTen = prctile(inVox,10);

% 90th percentile
ptileNty = prctile(inVox,90);

% maximum
maximum = max(inVox);

% IQR
intQrt = iqr(inVox);

% range
rng = range(inVox);

% mean absolute deviation
mnAbs = mad(inVox);

% IQR set
iqrSet = inVox(inVox >= ptileTen & inVox <= ptileNty);

% robust mean deviation
robMnAbs = mad(iqrSet);

% differences of voxel intensities to the median
absDev = abs(inVox-med);

% median absolute deviation
mdAbs = mean(absDev);

% standard deviation
sd = variance^0.5;

% coefficient of variation
coeffVar = sd/meanIntensity;

% 25th percentile
ptile25 = prctile(inVox,25);

% 75th percentile
ptile75 = prctile(inVox,75);

% quartile coefficient of variation
qrtCoeffVar = (ptile75-ptile25)/(ptile75+ptile25);

% energy
energy = sum(inVox.^2);

% root-mean-square
rtMnSq = sqrt(energy/length(inVox));

% add to the output array
intensityStats = [...
    meanIntensity;...
    variance;...
    skew;...
    kurt;...
    med;...
    minimum;...
    ptileTen;...
    ptileNty;...
    maximum;...
    intQrt;...
    rng;...
    mnAbs;...
    robMnAbs;...
    mdAbs;...
    coeffVar;...
    qrtCoeffVar;...
    energy;...
    rtMnSq...
    ];