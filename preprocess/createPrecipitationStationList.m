function createPrecipitationStationList(controlVars,grid)
%
%% createPrecipitationStationList creates the precipitation station list 
% used in TIER processing
% TIER - Topographically InformEd Regression
%
% Arguments:
%
% Input:
%
%  controlVars, structure, structure containing preprocessing control variables
%  grid,        structure, structure containing DEM variables
%
% Output:
%
%  none, function writes to a file
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
 
    %print status
    fprintf(1,'Compiling precipitation station list\n');
    
    %define local variables
    nr = grid.nr;
    nc = grid.nc;

    %find nearest grid point
    %transform grid to 1-d arrays for computational convenience
    lon1d = reshape(grid.lon,[nr*nc 1]);
    lat1d = reshape(grid.lat,[nr*nc 1]);
    dem1d = reshape(grid.aspects.smoothDEM,[nr*nc 1]);
    facet1d = reshape(grid.aspects.facets,[nr*nc 1]);
    distToCoast1d = reshape(grid.distToCoast,[nr*nc 1]);
    layerMask1d = reshape(grid.positions.layerMask,[nr*nc 1]);
    topoPosition1d = reshape(grid.positions.topoPosition,[nr*nc 1]);

    %create list of stations in directory
    listString = sprintf('%s/*.nc',controlVars.stationPrecipPath);
    fileList = dir(listString);
    %number of stations
    nSta = length(fileList);
    %read lat,lon from station timeseries file
    for f = 1:nSta
        stationName = sprintf('%s/%s',controlVars.stationPrecipPath,fileList(f).name);
        station.lat(f) = ncread(stationName,'latitude');
        station.lon(f) = ncread(stationName,'longitude');
    end

    %open output station list file
    sidOut = fopen(controlVars.stationPrecipListName,'w');

    %print header to output file
    fprintf(sidOut,'NSITES %d\n',nSta);
    fprintf(sidOut,'#STNID\tLAT\tLON\tELEV\tASP\tDIST_COAST\tINVERSION\tTOPO_POS\tSTN_NAME\n');

    %loop through all stations and find the nearest grid point for geophysical
    %attributes
    for i = 1:nSta
        stationId = strtok(fileList(i).name(),'.');
        %compute distances and indices of nearest grid points
        [~,ix] = sort(sqrt((lat1d-station.lat(i)).^2 + (lon1d-station.lon(i)).^2));

        %if nearest grid point is valid
        if(facet1d(ix(1)) > -999)
            %output geophysical attributes to station file
            fprintf(sidOut,'%s, %9.5f, %11.5f, %7.2f, %d, %8.3f, %d, %8.3f, %s\n',char(stationId),station.lat(i),station.lon(i),...
                             dem1d(ix(1)),facet1d(ix(1)),distToCoast1d(ix(1)),layerMask1d(ix(1)),topoPosition1d(ix(1)),char(stationId));
        else %if not valid
            %find the nearest valid point for all attributes
            nearestValid = find((facet1d(ix) > -999) == 1);

            %output geophysical attributes to station file
            fprintf(sidOut,'%s, %9.5f, %11.5f, %7.2f, %d, %8.3f, %d, %8.3f, %s\n',char(stationId),station.lat(i),station.lon(i),...
                            dem1d(ix(nearestValid(1))),facet1d(ix(nearestValid(1))),distToCoast1d(ix(nearestValid(1))),...
                            layerMask1d(ix(nearestValid(1))),topoPosition1d(ix(nearestValid(1))),char(stationId));     
        end
    end
    %close output list file
    fclose(sidOut);

end
