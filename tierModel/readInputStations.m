function inputStations = readInputStations(controlVars)
% 
%% readInputStations reads the input point station metadata
% and station data for TIER
% TIER - Topographically InformEd Regression
%
% Arguments:
%
% Input:
%
%  stationFileList, string, the name of the station metadata file
%  stationDataPath, string, path to location of station data
%  controlVars, structure, structure holding control variables
%
% Output:
%
%  inputStations, structure, structure holding input station data, metdata, etc
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

    %open station list file
    fid = fopen(controlVars.stationFileList);
    %read station list with meta data
    meta = textscan(fid,'%s %f %f %f %d %f %d %f %s','delimiter',',','headerlines',2); 
    %define structures
    inputStations.meta.staId = meta{1};
    inputStations.meta.lat = meta{2};
    inputStations.meta.lon = meta{3};
    inputStations.meta.elev = meta{4};
    inputStations.meta.facet = meta{5};
    inputStations.meta.coastDist = meta{6};
    inputStations.meta.layer = meta{7};
    inputStations.meta.topoPosition = meta{8};
    inputStations.meta.staName = meta{9};
    
    %close file
    fclose(fid);

    %set number of stations
    nSta = length(inputStations.meta.staName);

    %convert elevation to km
    inputStations.meta.elev = inputStations.meta.elev/1000.0;

    %allocate inputStations structure
    inputStations.avgVar = zeros(nSta,1);
    
    if(strcmpi(controlVars.variableEstimated,'precip'))
        metVar = 'prcp';
    elseif(strcmpi(controlVars.variableEstimated,'tmax') || strcmpi(controlVars.variableEstimated,'tmin'))
        metVar = lower(controlVars.variableEstimated);
    end

    %read data
    for i = 1:nSta
        fprintf(1,'Loading: %s\n',char(inputStations.meta.staName(i)));
        %create file name string
        fname = sprintf('%s/%s.nc',controlVars.stationDataPath,char(inputStations.meta.staName(i)));

        %read station data
        inputStations.avgVar(i) = ncread(fname,metVar);
    end

end
