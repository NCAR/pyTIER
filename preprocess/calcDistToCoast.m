function distToCoast = calcDistToCoast(grid,searchLength)
%
%% calcDistToCoast computes the distance to the nearest ocean masked grid 
%  cell using the input grid DEM and mask.  Uses a search length of
%  searchLength km.  Any grid cells that do not have ocean within that
%  search length have the distanceToCoast set to searchLength.  Generally
%  follows Daly et al. (2002)
%
% Arguments:
%
% Input:
%
%  grid,     structure, the raw grid structure
%  searchLength, float, the maximum search distance to compute coastal
%                       distance
%
% Output:
% 
%  distToCoast, array, array of coastal distances for domain, computed at
%                      valid land pixels only
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

    %Note this is a time consuming routine as written.  There are likely
    %opportunities for speed-up for large domains.

    %print status
    fprintf(1,'Computing distance to coast\n');

    %find all land points in domain
    landPts = grid.mask > 0;
    %lat of land points
    latLand = grid.lat(landPts);
    %lon of land points
    lonLand = grid.lon(landPts);
    %how many land points
    lenLand = length(lonLand);
    %array indices of land points
    landInds = find(grid.mask > 0);

    %define output variable, set to missing
    distToCoast = zeros(grid.nr,grid.nc)-999.0;

    %find all (if any) ocean pixels
    oceanValid = grid.mask == -1;
    latOcean = grid.lat(oceanValid);
    lonOcean = grid.lon(oceanValid);

    
    if(~isempty(oceanValid))
        %loop through all land points

        for pt = 1:lenLand
            %create i,j array index of current land point
            [i,j] = ind2sub([grid.nr,grid.nc],landInds(pt));

            dists = distance(latLand(pt),lonLand(pt),latOcean,lonOcean);
            %convert dists from arc length (degrees) to km (approximately)
            %about 60 nmi in 1 degree of arc length, 1 nm = 1.852 km
            dists = dists*60.0*1.852;

            %find nearest ocean pixels
            dists = sort(dists);
            distToCoast(i,j) = dists(1);

        end  %end land points loop

        %find maximum distance computed
        maxDist = max(distToCoast(grid.mask == 1));

        %set all non-computed valid land points to maxDist 
        distToCoast(grid.mask == 1 & distToCoast == -999) = maxDist;
    else
        distToCoast = distToCoast + 999;
    end
end
