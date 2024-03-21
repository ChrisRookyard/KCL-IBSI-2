function lawsKernel = Laws_kernel(kernelType,kernelSize)

% *************************************************************************
% LAWS_KERNEL: creates a 1D Laws kernel
% *************************************************************************
%
% INPUTS
%
%   kernelType, a string, one from: 'level', 'edge', 'spot', 'wave', or 
%   'ripple'
%
%   kernelSize, a 3-element vector to indicate the size of the specified 
%   kernel - level, edge, and spot kernels can be of size 3 or 5, while
%   wave or ripple are only available in size 5
%
% OUTPUTS
%
%   lawsKernel, a vector, of values specified in the IBSI manual
%
% *************************************************************************
%
% By Chris Rookyard, Cancer Imaging Dept., King's College London
% 
% *************************************************************************

% return kernel in lawsKernel, depending on which case is in kernelType
switch kernelType
    case 'level'
        if kernelSize == 3
            lawsKernel = (1/sqrt(6))*[1,2,1];
        elseif kernelSize == 5
            lawsKernel = (1/sqrt(70))*[1,4,6,4,1];
        else
            error(['A kernelSize of 3 or 5 must be specified when ',...
                'kernelType is "level"'])
        end
    case 'edge'
        if kernelSize == 3
            lawsKernel = (1/sqrt(2))*[-1,0,1];
        elseif kernelSize == 5
            lawsKernel = (1/sqrt(10))*[-1,-2,0,2,1];
        else
            error(['A kernelSize of 3 or 5 must be specified when ',...
                'kernelType is "edge"'])
        end
    case 'spot'
        if kernelSize == 3
            lawsKernel = (1/sqrt(6))*[-1,2,-1];
        elseif kernelSize == 5
            lawsKernel = (1/sqrt(6))*[-1,0,2,0,-1];
        else
            error(['A kernelSize of 3 or 5 must be specified when ',...
                'kernelType is "spot"'])
        end
    case 'wave'
        if kernelSize == 5
            lawsKernel = (1/sqrt(10))*[-1,2,0,-2,1];
        else
            error(['When kernelType is "wave", the kernelSize is ',...
                'always 5 - please eneter kernelSize as 5'])
        end
    case 'ripple'
        if kernelSize == 5
            lawsKernel = (1/sqrt(70))*[1,-4,6,-4,1];
        else
            error(['When kernelType is "ripple", the kernelSize is ',...
                'always 5 - please eneter kernelSize as 5'])
        end
    otherwise
        error(['"kernelType", must be a string, and either level, edge,'...
            ' spot, wave, or ripple']);
end
