function [newGrid,oldGrid,slicePos] = calculate_new_grid(...
                oldVoxelSize,volDim,imageStartPos,newVoxelSize)

% *************************************************************************
% CALCULATE_NEW_GRID: calculate a query grid for gridded interpolation
% *************************************************************************
%
% INPUTS
%
%   oldVoxelSize, the size of the voxels in the image to be resampled,
%   specified as a 3-element vector [y,x,z] - units must match those of
%   newVoxelSize - note that it is permissible for the z value to be
%   negative, in order to indicate which direction the coordinates go in
%   along this axis
%
%   volDim, the dimensions, in voxels, of the image to be resampled,
%   specified again as a 3-element vector [y,x,z]
%
%   imageStartPos, a vector to indicate the starting value for the first
%   slice of the volume (x,y,z)
%
%   newVoxelSize, the size of the voxels in the resampled image,
%   specified as a 3-element vector [y,x,z] - units must match those of
%   oldVoxelSize
%
% OUTPUTS
%
%   newGrid, the grid of coordinates for the resampled image, returned in a
%   1-by-3 cell {y,x,z}
%
%   oldGrid, the grid of coordinates for the image to be resampled, again,
%   returned in a 1-by-3 cell {y,x,z}
%
%   slicePos, a vector of slice locations to write to the metadata when
%   saving the file to .dcm later - for the image position (patient)
%   attribute
%
% NOTES
%
%   this function takes the "align grid centres" approach, where the new 
%   resampling grid is centred over the original image grid. This means 
%   that grid positioning is independent of the location of the origin in 
%   the original image (or better, the direction of axes. The original grid
%   axes have suffix of 'a' and new grid axes have suffix 'b'.
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% original image origin
origin_a = [imageStartPos(2),imageStartPos(1),imageStartPos(3)];

% original voxel coordinates
y_a = (0:oldVoxelSize(1):(volDim(1)-1)*oldVoxelSize(1))+origin_a(1);
x_a = (0:oldVoxelSize(2):(volDim(2)-1)*oldVoxelSize(2))+origin_a(2);
z_a = (0:oldVoxelSize(3):(volDim(3)-1)*oldVoxelSize(3))+origin_a(3);
[Y_a,X_a,Z_a] = ndgrid(y_a,x_a,z_a);

% the number of points in the original grid will be the volume dimensions
points_a = volDim;

% the spacing for the old grid is the original voxel size,
% the spacing for the new grid is the desired voxel size
spacing_a = oldVoxelSize;
spacing_b = newVoxelSize;

% calculate the number needed in the new grid
points_b = ceil(((points_a-1).*spacing_a)./spacing_b)+1;

% SANITY CHECK - for number of sampling points in new grid
if any(points_b > 1000)
    error('calculate_grid:size',...
        'Size of resampling grid is rather large!')
end

% calculate position of origin in the query grid
% NOTE - it is assumed that the total distance covered in the output grid
% will always be greater than in the original grid. This is independent of 
% whether it is down- or up-sampling to get the new grid spacing; it is
% becuase the way the number of points for the new grid are calculated 
% means they will always at least match the size of the original grid.
origin_b = origin_a-(0.5.*(((points_b-1).*spacing_b)...
    -((points_a-1).*spacing_a)));

% ALTERNATIVE from IBSI
% origin_b = 0.5*(points_a-1-((spacing_b/spacing_a)*(points_b-1)));

% new voxel coordinates
y_b = origin_b(1):spacing_b(1):((points_b(1)-1)*spacing_b(1))+origin_b(1);
x_b = origin_b(2):spacing_b(2):((points_b(2)-1)*spacing_b(2))+origin_b(2);
z_b = origin_b(3):spacing_b(3):((points_b(3)-1)*spacing_b(3))+origin_b(3);
[Y_b,X_b,Z_b] = ndgrid(y_b,x_b,z_b);

% SANITY CHECK to ensure grids are centred
y_a_ctr = y_a(1)+((y_a(end)-y_a(1))/2);
y_b_ctr = y_b(1)+((y_b(end)-y_b(1))/2);
x_a_ctr = x_a(1)+((x_a(end)-x_a(1))/2);
x_b_ctr = x_b(1)+((x_b(end)-x_b(1))/2);
z_a_ctr = z_a(1)+((z_a(end)-z_a(1))/2);
z_b_ctr = z_b(1)+((z_b(end)-z_b(1))/2);
if abs(y_a_ctr-y_b_ctr) > 1e-6
    error('calculate_grid:centres','y grid centres do not match')
end
if abs(x_a_ctr-x_b_ctr) > 1e-6
    error('calculate_grid:centres','x grid centres do not match')
end
if abs(z_a_ctr-z_b_ctr) > 1e-6
    error('calculate_grid:centres','z grid centres do not match')
end

% prepare the outputs
oldGrid = {Y_a,X_a,Z_a};
newGrid = {Y_b,X_b,Z_b};
slicePos = ...
    [repmat(x_b(1),length(z_b),1),repmat(y_b(1),length(z_b),1),z_b'];
