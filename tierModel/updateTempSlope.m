function finalSlope = updateTempSlope(nr,nc,mask,gridLayer,slope,recomputeDefault,defaultSlope,validSlope,minSlope,maxSlopeLower,maxSlopeUpper,filterSize,filterSpread)
%
%% updateTempSlope updates the estimated slope (elevation lapse rate)
%                  of temperature variables across the grid from the
%                  initial estimate
%
% Arguments:
%
%  Inputs:
%
%   nr, integer,   number of rows in grid
%   nc, integer,   number of columns in grid
%   mask, integer, mask of valid grid points
%   slope, float, intial slope estimate across grid
%   defaultSlope, float, default estimate of slope across grid
%   recomputeDefault,string, string indicating true/false to recompute the
%                        default normalized precipitation slope
%   validSlope, integer, mask of valid regression estimated slopes
%   minSlope     , float, minimum valid slope (TIER parameter)
%   maxSlopeLower, float, maximum lower layer valid slope (TIER parameter)
%   maxSlopeUpper, float, maximum upper layer valid slope (TIER parameter)
%   filterSize, integer, size of low-pass filter in grid points
%   filterSpread, float, variance of low-pass filter
%
%  Outputs:
%
%   finalSlope, structure, structure containing the final slope for all
%                          grid points for temp variables
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


    %if user specifies to recompute the default slope and there is
    %no user specified spatially variable lapse rate file (this check is performed in the driver)
    %use only points that had valid regression based slopes
    %ideally this is an improvement over a specified default slope
    if(strcmpi(recomputeDefault,'true') )
        baseSlope = slope;
        baseSlope(validSlope~=1) = -999;
        domainMeanSlope = mean(mean(baseSlope(baseSlope ~= -999)));
        baseSlope(baseSlope == -999) = domainMeanSlope;
    else
        baseSlope = slope;
        if(length(defaultSlope(:,1))>1)
            baseSlope(validSlope~=1) = defaultSlope(validSlope~=1);
        else
            baseSlope(validSlope~=1) = defaultSlope;
        end
    end

    %define a mesh of indicies for scattered interpolation of valid points
    %back to a grid
    y = 1:nr;
    x = 1:nc;
    [y2d,x2d] = meshgrid(x,y);

    %perform 2 scattered interpolations to get final slope, one for layer 1,
    %one for layer2
    
    %find valid points for layer 1
    [i,j] = find(baseSlope >= minSlope & gridLayer == 1);
    %scattered interpolation using griddata
    interpSlopeLayer1 = griddata(i,j,baseSlope(baseSlope>= minSlope & gridLayer == 1),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    %compatible with octave
%    interpSlopeLayer1 = fillNaN(interpSlopeLayer1,x2d,y2d);
    %for Matlab only
    interpSlopeLayer1 = fillmissing(interpSlopeLayer1,'nearest',1);
    interpSlopeLayer1 = fillmissing(interpSlopeLayer1,'nearest',2);
    
    %find valid points for layer 2
    [i,j] = find(baseSlope >= minSlope & gridLayer == 2);
    %scattered interpolation using griddata
    interpSlopeLayer2 = griddata(i,j,baseSlope(baseSlope>= minSlope & gridLayer == 2),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    %compatable with octave
%    interpSlopeLayer2 = fillNaN(interpSlopeLayer2,x2d,y2d);
    %for Matlab only
    interpSlopeLayer2 = fillmissing(interpSlopeLayer2,'nearest',1);
    interpSlopeLayer2 = fillmissing(interpSlopeLayer2,'nearest',2);
    
    %define gaussian low-pass filter
    gFilter = fspecial('gaussian',[filterSize filterSize],filterSpread);
    
    %filter the combined field
    filterSlope = interpSlopeLayer1;
    filterSlope(gridLayer == 2) = interpSlopeLayer2(gridLayer == 2);

    filterSlope = imfilter(filterSlope,gFilter,'circular');

    %check for invalid slopes
    filterSlopeLayer1 = filterSlope;
    filterSlopeLayer1(filterSlopeLayer1 > maxSlopeLower) = maxSlopeLower;
    filterSlopeLayer1(filterSlopeLayer1 < minSlope) = minSlope;
    %set unused points to missing
    filterSlopeLayer1(mask<=0) = -999;
    
    %check for invalid slopes
    filterSlopeLayer2 = filterSlope;
    filterSlopeLayer2(filterSlopeLayer2 > maxSlopeUpper) = maxSlopeUpper;
    filterSlopeLayer2(filterSlopeLayer2 < minSlope) = minSlope;
    %set unused points to missing
    filterSlopeLayer2(mask<=0) = -999;
    
    %combine the two layer estimates into one complete grid
    finalSlope = filterSlopeLayer1;
    finalSlope(gridLayer == 2) = filterSlopeLayer2(gridLayer == 2);
    
end
