function export_image(image,info,filename,saveDir)

% *************************************************************************
% 
% export_image: 
%   1. exports a NIfTI image, with metadata info, to file filename
%   2. it is assumed that the metadata to write are:
%       Datatype
%       PixelDimensions
%       SpaceUnits
%       ImageSize
%       Description (left empty — Matlab gets cross if it's not there)
%       Version
%       Qfactor
%       TimeUnits
%       SliceCode
%       FrequencyDimension
%       PhaseDimension
%       SpatialDimension
%   3. the image is saved compressed
%   4. user is asked where to save unless saveDir is specified
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% identify a place to save the output images
%saveDir = uigetdir();

% select fields from info
infoOut = struct(...
    'Datatype',class(image),...
    'PixelDimensions',info.PixelDimensions,...
    'SpaceUnits',info.SpaceUnits,...
    'ImageSize',size(image),...
    'Description','',...
    'Version',info.Version,...
    'Qfactor',info.Qfactor,...
    'TimeUnits',info.TimeUnits,...
    'SliceCode',info.SliceCode,...
    'FrequencyDimension',info.FrequencyDimension,...
    'PhaseDimension',info.PhaseDimension,...
    'SpatialDimension',info.SpatialDimension);

% reverse the permutation applied on import
image = permute(image,[2,1,3]);

% save this image
niftiwrite(image,[saveDir,'/',filename],infoOut,...
    'Compressed',true)