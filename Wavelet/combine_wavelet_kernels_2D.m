function waveletFilters = combine_wavelet_kernels_2D(Fa,Fd)

% *************************************************************************
% COMBINE_WAVELET_KERNELS_2D: makes a 2D kernel from 2 input wavelets
% *************************************************************************
%
% INPUTS
%
%   Fa and Fd, the approximation and detail filters, respectively
%
% OUTPUTS
%
%   waveletFilters, a cell with an entry for each combination
%   of filters (4), and each entry for that will be 3-D, with the rotations
%   going along the 3rd dimension within each cell entry. 
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% initialise output
waveletFilters = cell(4,1);

% arrange the wavelets in the 4 possible combinations they could go for one
% rotation
waveletOrder = {...
    [Fa;Fa];...
    [Fa;Fd];...
    [Fd;Fa];...
    [Fd;Fd]};

% for each of the above, do the 4 possible orientations
for i = 1:4
    
    % prepare the current filters
    og1 = waveletOrder{i}(1,:);
    og2 = waveletOrder{i}(2,:);
    jg1 = fliplr(og1);
    jg2 = fliplr(og2);
    
    % organise them in their 4 positions
    g = cat(3,...
        [og1; og2],...
        [jg2; og1],...
        [jg1; jg2],...
        [og2; jg1]);
    
    % loop over the 4 combinations, and make a 2D kernel from each
    % temporary holder for each iteration
    theseOrnts = zeros(length(Fa),length(Fa),4);
    for k = 1:4
        
        % first outer product, gives a 2D result
        % whichever kernel is "top" should go parallel to x axis
        kernel2D = g(2,:,k)' * g(1,:,k);
        
        % add to the temporary array
        theseOrnts(:,:,k) = kernel2D;
        
    end
    
    waveletFilters{i,1} = theseOrnts;
    
end
