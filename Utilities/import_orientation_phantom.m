function import_orientation_phantom()

% *************************************************************************
% 
% import_orientation_phantom: 
%   1. imports the IBSI orientation phantom
%   2. checks the dimensions of it, and re-arranges them if needed
%   3. and then checks the values 
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% find the orientation phantom file
[imageFile,imagePath] = uigetfile('*.nii.gz');

% import the image volume
image = niftiread([imagePath,imageFile]);

% check the dimensions of the image against those specified (y,x,z)
dimSpec = [48,32,64];
dimReal = size(image);
dimCheck = dimSpec == dimReal;
disp(['Dimensions check: ',num2str(dimCheck)])

% ...clearly, x and y need swapping
permutation = [2,1,3];
imageReOriented = permute(image,permutation);
disp(['Applying permutation of: ',num2str(permutation)])

% do the dimensions check again...
dimReOriented = size(imageReOriented);
dimCheckReOriented = dimSpec == dimReOriented;
disp(['Dimensions check: ',num2str(dimCheckReOriented)])

% now check the values - the most distal value should have value 141
valueSpecDistal = 141;
valueRealDistal = imageReOriented(end,end,end);
valueCheckDistal = valueSpecDistal == valueRealDistal;
disp(['Value check distal: ',num2str(valueCheckDistal)])

% and check the value at the origin, too
valueSpecOrigin = 0;
valueRealOrigin = imageReOriented(1,1,1);
valueCheckOrigin = valueSpecOrigin == valueRealOrigin;
disp(['Value check origin: ',num2str(valueCheckOrigin)])