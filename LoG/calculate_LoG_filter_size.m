function filterSize = calculate_LoG_filter_size(sigmaVoxels,cutoff)

% *************************************************************************
% 
% calculate_LoG_filter_size: 
%   1. calculates the filter size, in voxels, for a LoG filter, based on
%   the IBSI specification.
%   2. inputs should be of the same length (y,x,z).
%   3. and "sigmaVoxels", as the name suggests, should be in voxel units.
%   4. the returned filter size will be of the same length as the inputs,
%   and in voxel units.
%   5. the IBSI-specified calculation ensures that the size of the filter
%   will always be of odd integer values.
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% do the calculate for the filter size (M in the IBSI specification)
filterSize = 1+(2*floor((cutoff.*sigmaVoxels)+0.5));
