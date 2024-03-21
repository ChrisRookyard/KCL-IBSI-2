function maskResegmented = resegment(mask,image,resegVals,intervalType)

% *************************************************************************
% RESEGMENT: resegments a mask based on intensity values
% *************************************************************************
%
% INPUTS
%
%   mask, the mask image
%
%   image, the image
%
%   resegVals, a 1-by-2 array for the min and max resegmentation values
%
%   intervalType, a 1-by-2 logical to indicate exclusice (false) or 
%   inclusive (true)
%
% OUTPUTS
%
%   maskResegmented, the binary mask, after resegmentation
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% note that if it is an inclusive interval (i.e. an open interval, we use <
% or >, since this indicates that the bounds specified should be included
% in the resegmentation, and the opposite is true for a closed interval).

maskResegmented = mask;

if ~(isnan(resegVals(1)))
    if intervalType(1)
        maskResegmented(image < resegVals(1)) = 0;
    else
        maskResegmented(image <= resegVals(1)) = 0;
    end
end
if ~(isnan(resegVals(2)))
    if intervalType(2)
        maskResegmented(image > resegVals(2)) = 0;
    else
        maskResegmented(image >= resegVals(2)) = 0;
    end
end