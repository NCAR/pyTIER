function finalNormSlope = updatePrecipSlope(nr,nc,mask,normSlope,validSlope,defaultSlope,recomputeDefault,filterSize,filterSpread)
%
%% updatePrecipSlope updates the estimated slope (elevation lapse rate)
%                  of precipitation across the grid from the
%                  initial estimate
%
% Arguments:
%
%  Inputs:
%
%   nr, integer,   number of rows in grid
%   nc, integer,   number of columns in grid
%   mask, integer, mask of valid grid points
%   normslope, float, intial normalized slope estimate across grid
%   validSlope, integer, mask of valid regression estimated slopes
%   defaultSlope, float, value of the default normalized precipitation
%                        slope 
%   recomputeDefault,string, string indicating true/false to recompute the
%                        default normalized precipitation slope
%   filterSize, integer, size of low-pass filter in grid points
%   filterSpread, float, variance of low-pass filter
%
%  Outputs:
%
%   finalNormSlope, structure, structure containing the final normalized 
%                              slope for all grid points for precip variables
%
% Author: Andrew Newman, NCAR/RAL
% Email : anewman@ucar.edu
% Postal address:
%     P.O. Box 3000
%     Boulder,CO 80307
% 
% Copyright (C) 2019 University Corporation for Atmospheric Research
%
% This file is part of TIER.
%
% TIER is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% TIER is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TIER.  If not, see <https://www.gnu.org/licenses/>.
%

    %if user specifies to recompute the default slope then do it
    %use only points that had valid regression based slopes
    %ideally this is an improvement over a specified default slope
    if(strcmpi(recomputeDefault,'true'))
        baseSlope = normSlope;
        baseSlope(validSlope~=1) = -999;
        domainMeanSlope = mean(mean(baseSlope(baseSlope ~= -999)));
        baseSlope(baseSlope == -999) = domainMeanSlope;
    else
        baseSlope = normSlope;
        baseSlope(validSlope~=1) = defaultSlope;
    end
    
    %filter and interpolate slopes to entire domain 
    %this is a similar step to the Daly et al. (1994) feathering except it
    %is applied to the precipitation slopes.
    %This is done before feathering, where feathering is a final check for precipitation
    %gradients
    
    %define a mesh of indicies for scattered interpolation of valid points
    %back to a grid
    y = 1:nr;
    x = 1:nc;
    [y2d,x2d] = meshgrid(x,y);

    %find valid grid points
    [i,j] = find(baseSlope > 0);
    %scattered interpolation using griddata
    interpBaseSlope = griddata(i,j,baseSlope(baseSlope>0),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    %compatible with octave
%    interpBaseSlope = fillNaN(interpBaseSlope,x2d,y2d);
    %for Matlab only
    interpBaseSlope = fillmissing(interpBaseSlope,'nearest',1);
    interpBaseSlope = fillmissing(interpBaseSlope,'nearest',2);
    
    %define gaussian low-pass filter
    gFilter = fspecial('gaussian',[filterSize filterSize],filterSpread);

    %filter slope estimate
    filterSlope = imfilter(interpBaseSlope,gFilter,'circular');
    %set unused grid points to missing
    filterSlope(mask<=0) = -999;

    %set output variable
    finalNormSlope = filterSlope;
    
end
