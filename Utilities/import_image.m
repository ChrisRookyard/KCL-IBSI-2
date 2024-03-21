function [image,info] = import_image(varargin)

% *************************************************************************
% 
% import_image: 
%   1. imports a user-chosen image, or from the input filepath
%   2. re-arranges the dimension of the image (swapping the 2nd with the
%   1st, to match IBSI specification)
%   3. converts the data type to double precision floating point
%   4. then returns the image to the workspace 
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

if nargin == 0
    
    % find the image file
    [imageFile,imagePath] = uigetfile('*.nii.gz');

    % import the image volume and the metadata
    image = niftiread([imagePath,imageFile]);
    info = niftiinfo([imagePath,imageFile]);

elseif nargin == 1
    
    % import the image volume and the metadata
    image = niftiread(varargin{1});
    info = niftiinfo(varargin{1});

elseif nargin > 1

    error('Too many input arguments')

end

% change the order of the dimensions
permutation = [2,1,3];
image = permute(image,permutation);

% change to double precision floating point
image = double(image);
