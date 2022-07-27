function positions = calcPositions(grid,searchLength,inversionHeight)
%
%% calcPositions computes the topographic position of each grid cell and 
% determines what layer of the atmosphere (inversion or free) each grid cell
% lies in
%
% Arguments:
%
% Input:
%
%  grid,        structure, the raw grid structure
%  searchLength     float, search length (grid cells) for local DEM
%                          calculations
%  inversionHeight, float, height of inversions (m). grid cells with
%                          topographic position above inversionHeight are 
%                          in free atmosphere, those below are in areas 
%                          prone to inversions
%
% Output:
% 
%  positions, structure, structure containing topographic position and
%                        inversion layer arrays
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
%

    fprintf(1,'Computing topographic positions\n');

    %run through all grid points, determine local inversion height, which grid
    %points might be in an inversion if present (e.g. layer 1 & 2 temperature
    %atmosphere in Daly et al. 2002)

    %pass 1 - find minimum elevation for all cells within search radius
    %(searchLength)

    %define minElev array
    minElev = zeros(grid.nr,grid.nc);
    %define inversion layer mask
    positions.layerMask = zeros(grid.nr,grid.nc)-999.0;

    %define local dem variable;
    dem = grid.dem;

    %loop over all grid points
    for i = 1:grid.nr
        for j = 1:grid.nc
            %if we are at a valid land point
            if(grid.mask(i,j) == 1)
                %find row range indices
                rRange = [max([1 i-searchLength]) min([i+searchLength grid.nr])];
                %find column range indices
                cRange = [max([1 j-searchLength]) min([j+searchLength grid.nc])];
                %find valid DEM points within search box
                demValid = grid.mask(rRange(1):rRange(2),cRange(1):cRange(2)) == 1;
                %subset dem using search box
                demSub = dem(rRange(1):rRange(2),cRange(1):cRange(2));
                %find minimum valid land elevation in box
                minElev(i,j) = min(demSub(demValid));
            end %end land mask if-statement
        end %end column loop
    end %end row loop

    % pass 2 - now find the mean of the min_elev grid, add inversion height, 
    %then determine layer-1 or 2 for full-res elevation

    %define meanElev, inversionBase and topoPosition arrays
    meanElev = zeros(grid.nr,grid.nc);
    inversionBase = meanElev;
    positions.topoPosition = meanElev-999.0;

    %loop over all grid points
    for i = 1:grid.nr
        for j = 1:grid.nc
            %if we are at a valid land point
            if(grid.mask(i,j) == 1)
                %find row range indices
                rRange = [max([1 i-searchLength]) min([i+searchLength grid.nr])];
                %find column range indices
                cRange = [max([1 j-searchLength]) min([j+searchLength grid.nc])];
                %find valid DEM points within search box
                demValid = grid.mask(rRange(1):rRange(2),cRange(1):cRange(2)) == 1;
                %subset minElev array using search box
                demSub = minElev(rRange(1):rRange(2),cRange(1):cRange(2));
                %find mean of minElev subset over valid land dem cells
                meanElev(i,j) = mean(demSub(demValid));
                %compute inversion base
                inversionBase(i,j) = inversionHeight + meanElev(i,j);
                %compute topograpic position
                positions.topoPosition(i,j) = dem(i,j) - meanElev(i,j);

            end %end land mask if-statement
        end %end column loop
    end %end row loop


    %set atmospheric layers (1= inversion layer, 2=free atmosphere);
    positions.layerMask(dem<=inversionBase) = 1;
    positions.layerMask(dem>inversionBase) = 2;

end
