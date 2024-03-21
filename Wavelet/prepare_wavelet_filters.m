function waveletFilters = prepare_wavelet_filters(waveletType,level)

% *************************************************************************
% PREPARE_WAVELET_FILTERS: returns a cell array of wavelet filters in 3D
% *************************************************************************
%
% INPUTS
%
%   wavelet type — the type of wavelet to be used
%
%   level - and the level to go to
%
% OUTPUTS
%
%   waveletFilters, i-by-1 cell array, where i is the level, and in each
%   entry:
%       a cell with an entry for each combination of filters(8), and each 
%       entry for that will be 4-D, with the rotations going along the 4th 
%       dimension within each cell entry.
%
% NOTE
%
%   this function is used to make producing 3D kernels a one-off, since it
%   takes a while. For 2D, the filters do not need to be produced in
%   advance, and the "filter_undecimated_separable_wavelet_2D" function can
%   be called with the waveletType.
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% filter kernels
[Fa,Fd] = wfilters(waveletType,'d');

% append a zero to the filters if they're even in length
if ~(mod(length(Fa),2))
    Fa = [Fa,0];
    Fd = [Fd,0];
end

% loop over levels and combine kernels for filters
waveletFilters = cell(level,1);
for i = 1:level

    % if we are on any but the first time around, down-sample kernels
    if i == 1
        fa = Fa;
        fd = Fd;
    else
        % first, take off the zero at the end if odd length
        if mod(length(fa),2)
            fa = fa(1:end-1);
            fd = fd(1:end-1);
        end

        % a trous algorithm
        fa = reshape([fa;zeros(1,length(fa))],1,2*length(fa));
        fd = reshape([fd;zeros(1,length(fd))],1,2*length(fd));
        
        % and now put the zero back, if even in length
        if ~(mod(length(fa),2))
            fa = [fa,0]; %#ok<AGROW>
            fd = [fd,0]; %#ok<AGROW>
        end
        
    end
    
    % send these to the filter calculator
    waveletFilters{i} = combine_wavelet_kernels_3D(fa,fd);
end