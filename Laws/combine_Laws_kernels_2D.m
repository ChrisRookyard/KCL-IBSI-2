function lawsKernel = combine_Laws_kernels_2D(kernelTypes,kernelSizes)

% *************************************************************************
% COMBINE_LAWS_KERNELS_2D: makes a 2D kernel from 2 input, 1D Laws kernels
% *************************************************************************
%
% INPUTS
%
%   kernelTypes, a cell array of 2 strings, from: 'level', 'edge', 'spot', 
%   'wave', or 'ripple'
%
%   kernelSizes, a 2-element vector to indicate the size of the specified 
%   kernels - level, edge, and spot kernels can be of size 3 or 5, while
%   wave or ripple are only available in size 5
%
% OUTPUTS
%
%   lawsKernel, a cell of length 4, containing a 2D Laws kernel in each
%   entry, one for each square rotation for rotation-invariance
%
% NOTES
%
%   there is not an option for rotation-variance because it is simply the
%   first entry in the returned cell
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% check that kernelSize and specified kernels are appropriate
if any((strcmp(kernelTypes,'wave') | strcmp(kernelTypes,'ripple'))...
        & kernelSizes == 3)
    error('Wave or ripple kernels must be of length 5')
end

% 1D kernels using function "laws_kernel"
% they are stored in one matrix, 2-by-kernel size
% (i.e. a kernel every row)
kernels = cell(2,1);
for i = 1:length(kernels)
    kernels{i,1} = Laws_kernel(kernelTypes{i},kernelSizes(i));
end

% set up the four filter combinations (as in IBSI)
% for ease of reading, give each kernel a name
% and order as in the IBSI doc
% original kernels called "og" and inverted "jg"
og1 = kernels{1};
og2 = kernels{2};
jg1 = fliplr(og1);
jg2 = fliplr(og2);
g = cat(3,...
    [{og1}; {og2}],...
    [{jg2}; {og1}],...
    [{jg1}; {jg2}],...
    [{og2}; {jg1}]);

% run over each combination, and make a 2D filter
lawsKernel = cell(size(g,3),1);
for i = 1:size(g,3)

    % first outer product, gives a 2D result
    % whichever kernel is "top" should go parallel to x axis
    kernel2D = g{2,1,i}' * g{1,1,i};

    % add to the output
    lawsKernel{i,1} = kernel2D;

end
