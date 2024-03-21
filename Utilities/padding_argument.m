function padArg = padding_argument(padType)

% *************************************************************************
% 
% padding_argument: 
%   1. simply returns the argument to pass to various subsequent
%   convolution algorithms, depending on the input in "padType"
%   2. this function just makes things easier, since IBSI has different
%   names to Matlab for the different padding options
%   3. "padType" should be a string, and be either 'zero', 'nearest',
%   'periodic', or 'mirror', which correspond to scalar 0, 'replicate',
%   'circular, or 'symmetric' in Matlab's terms
% 
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% return padding argument in padArg, depending on which case is in padType
switch padType
    case 'zero'
        padArg = 0;
    case 'nearest'
        padArg = 'replicate';
    case 'periodic'
        padArg = 'circular';
    case 'mirror'
        padArg = 'symmetric';
    otherwise
        error(['"padType", must be a string, and either zero, nearest,',...
            ' periodic, or mirror']);
end
