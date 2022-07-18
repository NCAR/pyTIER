function grid = readGrid(gridName)
% 
%% readGrid reads a netcdf grid file for the TIER code
% TIER - Topographically InformEd Regression
%
% Arguments:
%
% Input:
%
%  gridName, string, the name of the grid file
%
% Output:
%
%  grid, structure, structure holding DEM, geophysical attributes
%                   and related variables
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
 
    %read latitude and longitude
    grid.lat = ncread(gridName,'latitude');
    grid.lon = ncread(gridName,'longitude');
    %grid spacing
    gridUnits = ncreadatt(gridName,'dx','units');
    if(strcmpi(gridUnits,'degrees'))
        grid.dx = ncread(gridName,'dx');
        %convert to km (roughly)
        
        %grid lower left lat,lon
        startLon = ncread(gridName,'startx'); 
        startLat = ncread(gridName,'starty');

        %find grid point distance in km approximately
        gridDist = distance(startLat,startLon,startLat+grid.dx,startLon+grid.dx);
        kmPerLat = rad2km(deg2rad(gridDist));
        
        %grid distance in km roughly
        grid.dx = (grid.dx*kmPerLat)/sqrt(gridDist.^2);
        
    elseif(strcmpi(gridUnits,'km'))
        grid.dx = ncread(gridName,'dx');
    elseif(strcmpi(gridUnits,'m'))
        grid.dx = ncread(gridName,'dx')/1000; %convert m to km
    else
        error('Unknown grid dx units: %s\n',gridUnits);
    end
    %read valid grid point mask
    grid.mask = ncread(gridName,'mask');
    %read DEM
    grid.dem = ncread(gridName,'elev');
    %read smoothed DEM
    grid.smoothDem = ncread(gridName,'smooth_elev');
    %read distance to coast
    grid.distToCoast = ncread(gridName,'dist_to_coast');
    %read inversion layer
    grid.layerMask = ncread(gridName,'inversion_layer');
    %read topographic position
    grid.topoPosition = ncread(gridName,'topo_position');

    %convert DEM to km
    grid.dem = grid.dem/1000.0;

    %read slope facet
    grid.facet = ncread(gridName,'facet');
    %double check missing data points, reset very low DEM values to missing
    grid.facet(grid.dem < -100) = -999;

    %set grid size variables
    [grid.nr,grid.nc] = size(grid.lat);


end
