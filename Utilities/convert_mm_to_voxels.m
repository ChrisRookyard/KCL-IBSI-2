function voxelUnits = convert_mm_to_voxels(voxelDims,mmValues)

% *************************************************************************
% 
% convert_mm_to_voxels: 
%   1. is really simple - it is here in case it'll be useful in a pipeline
%   when everything else gets more complicated
%   2. the inputs should be of the same length; it is assumed that this
%   function will be used primarily for converting filter speicfications,
%   in mm, to voxel units, so it is likely that the inputs will have 2
%   (y,x) or 3 (y,x,z) values
%   3. then, it is assumed that the user wants a voxel-unit value for each
%   dimension, so the output, "voxelUnits", is of the same length as the
%   inputs
%
%% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
%% ************************************************************************

% check the length of the inputs matches
if length(voxelDims) ~= length(mmValues)
    error('The lengths of inputs voxelDims and mmValues should be equal')
end

% then calculate the voxel unit values
voxelUnits = mmValues./voxelDims;
