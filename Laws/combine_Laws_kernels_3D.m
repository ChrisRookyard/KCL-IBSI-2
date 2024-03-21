function lawsKernel = combine_Laws_kernels_3D(kernelTypes,kernelSizes)

% *************************************************************************
% COMBINE_LAWS_KERNELS_3D: makes a 3D kernel from 3 input, 1D Laws kernels
% *************************************************************************
%
% INPUTS
%
%   kernelTypes, a cell array of 3 strings, from: 'level', 'edge', 'spot', 
%   'wave', or 'ripple'
%
%   kernelSizes, a 3-element vector to indicate the size of the specified 
%   kernels - level, edge, and spot kernels can be of size 3 or 5, while
%   wave or ripple are only available in size 5
%
% OUTPUTS
%
%   lawsKernel, a cell of length 24, containing a 3D Laws kernel in each
%   entry, one for each cube rotation for rotation-invariance
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
% they are stored in one matrix, 3-by-kernel size
% (i.e. a kernel every row)
kernels = cell(3,1);
for i = 1:length(kernels)
    kernels{i,1} = Laws_kernel(kernelTypes{i},kernelSizes(i));
end

% set up the 24 filter combinations (as in IBSI)
% for ease of reading, give each kernel a name
% and order as in the IBSI doc
% original kernels called "og" and inverted "jg"
og1 = kernels{1};
og2 = kernels{2};
og3 = kernels{3};
jg1 = fliplr(og1);
jg2 = fliplr(og2);
jg3 = fliplr(og3);
g = cat(3,...
    [{og1}; {og2};  {og3}],...
    [{jg3}; {og2};  {og1}],...
    [{jg1}; {og2};  {jg3}],...
    [{og3}; {og2};  {jg1}],...
    [{og2}; {og3};  {og1}],...
    [{og2}; {jg3};  {jg1}],...
    [{og2}; {jg1};  {og3}],...
    [{jg1}; {jg2};  {og3}],...
    [{jg2}; {og1};  {og3}],...
    [{jg3}; {jg1};  {og2}],...
    [{jg3}; {jg2};  {jg1}],...
    [{jg3}; {og1};  {jg2}],...
    [{jg2}; {jg1};  {jg3}],...
    [{og1}; {jg2};  {jg3}],...
    [{og2}; {og1};  {jg3}],...
    [{og3}; {jg1};  {jg2}],...
    [{og3}; {jg2};  {og1}],...
    [{og3}; {og1};  {og2}],...
    [{jg1}; {og3};  {og2}],...
    [{jg2}; {og3};  {jg1}],...
    [{og1}; {og3};  {jg2}],...
    [{jg1}; {jg3};  {jg2}],...
    [{jg2}; {jg3};  {og1}],...
    [{og1}; {jg3};  {og2}]);

% run over each combination, and make a 3D filter
lawsKernel = cell(size(g,3),1);
for i = 1:size(g,3)

    % first outer product, gives a 2D result
    % whichever kernel is "top" should go parallel to x axis
    kernel2D = g{2,1,i}' * g{1,1,i};

    % second outer product, gives a 3D result in a roundabout way
    kernel3D = zeros(size(kernel2D,1),length(g{3,1,i}),size(kernel2D,2));
    for j = 1:size(kernel2D,2)
        kernel3D(:,:,j) = kernel2D(:,j) * g{3,1,i};
    end

    % with a permutation to orient kernel as expected
    kernel3D = permute(kernel3D,[1,3,2]);

    % add to the output
    lawsKernel{i,1} = kernel3D;

end
