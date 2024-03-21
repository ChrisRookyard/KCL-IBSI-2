function [imageMetaData,slicePos,sliceUIDs,sortedSliceInstanceNumbers] =...
    load_image_metadata(imagePath,numSlicesToLoad)

% *************************************************************************
% LOAD_IMAGE_METADATA: to load image metadata
% *************************************************************************
%
% INPUTS
%
%   imagePath, a full path to the image in question (to the folder of the
%   scans)
%
% OUTPUTS
%
%   imageMetaData, the slice-by-slice metadata
%
%   slicePos, a matrix, for ease of reference, of the slice positions
%
%   sliceUIDs, a list of the UID for each slice
%
%   sortedSliceInstanceNumbers, a list of the slice numbers
%
%   numSlicesToLoad, leave if empty if all are wanted, or a scalar
%
% NOTES
%
%   the slice metadata are imported in ascending order in instance number
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
%
% *************************************************************************

% load the image metadata, slice-by-slice
sliceFiles = dir(imagePath);
sliceFiles = {sliceFiles.name}';
sliceFiles(ismember(sliceFiles,{'.','..'})) = [];
sliceFiles(ismember(sliceFiles,{'.DS_Store','._.DS_Store'})) = [];
if isempty(numSlicesToLoad)
    nSlices = length(sliceFiles);
else
    nSlices = numSlicesToLoad;
    % try to ensure that slice files are at least the first of the series,
    % if the number imported is specified
    sliceFiles = sort(sliceFiles);
end
sliceInstanceNumbers = zeros(nSlices,1);
sep = filesep();
for j = 1:nSlices
    filename = [imagePath,sep,sliceFiles{j,1}];
    sliceInfo = dicominfo(filename);
    sliceInstanceNumbers(j) = sliceInfo.InstanceNumber;
end

% taken from line 103, "get_valid_data()" in FAST:
% *********************************************************************
% sort the slices with instance number
%   if(struc_params.flip_scan == 1)
%       [ind_slc_sorted idx] = sort(ind_slcs, 'descend');
%   else
%       [ind_slc_sorted idx] = sort(ind_slcs, 'ascend');
%   end
% *********************************************************************
% ...we assume, given that the default from "set_options()" is to make
% this field, flip_scan, equal to zero, that here, it is false.  Note
% that in set_options(), flip_scan_1 and flip_scan_2 are actually set,
% but later, in a call to load_scans(), which calls, get_valid_data(),
% the field flip_scan is set to equal flip_scan_1

% so, sort slices by instance number (ascending)...
[sortedSliceInstanceNumbers,reSortIdx] = ...
    sort(sliceInstanceNumbers, 'ascend');

% then import each slice and slice position data
imageMetaData = struct([]);
slicePos = zeros(nSlices,3);
sliceUIDs = cell(nSlices,1);
for j = 1:nSlices
    currIdx = reSortIdx(j);
    currMeta = dicominfo(...
        [imagePath,sep,sliceFiles{currIdx,1}]);

    % check all field names match
    if j > 1
        newFields = fieldnames(currMeta);
        presentFields = fieldnames(imageMetaData);

        notInNew = ~(ismember(presentFields,newFields));
        notInPresent = ~(ismember(newFields,presentFields));

        currMeta = rmfield(...
            currMeta,newFields(notInPresent));
        imageMetaData = rmfield(...
            imageMetaData,presentFields(notInNew));
    end


    % then add to output variables
    imageMetaData = [imageMetaData;currMeta]; %#ok<AGROW>
    slicePos(j,:) = currMeta.ImagePositionPatient';
    sliceUIDs{j,1} = currMeta.SeriesInstanceUID;
end
end
