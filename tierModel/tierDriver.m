%% driver for the Topographically InformEd Regression (TIER) tool

% this tool is built on the concept that geophyiscal attributes contain
% information useful to predict the spatial distribution of meteorological
% variables (e.g. Daly et al. 1994,2002,2007,2008; Thornton et al. 1999; 
% Clark and Slater 2006; Carrera-Hernandez and Gaskin 2007; Tobin et al.
% 2011; Bardossy and Pegram 2013; Newman et al. 2015).

% A pre-processed DEM file (see tierPreprocessing.m) and input station data
% are used to create monthly climatological meteorological fields over a
% domain.  
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
%User determines the controlName
controlName = input('Enter the name of your control file: ', 's');

%read control file
controlVars = readControl(controlName);

%initalize parameters to default values
parameters = initParameters(controlVars.variableEstimated);

%read user defined TIER parameter file
parameters = readParameters(controlVars.parameterFile,parameters);

%read grid file
grid = readGrid(controlVars.gridName);
grid.smoothDemKM = grid.smoothDem/1000;

%allocate space for output variables
metGrid = allocateMetVars(grid.nr,grid.nc);

%read input station data
inputStations = readInputStations(controlVars);

%if temperature and a gridded default slope file is specified, read it
if(strcmpi(controlVars.variableEstimated,'tmax') && ~isempty(controlVars.defaultTempLapse))
    tempDefaultLapse = ncread(controlVars.defaultTempLapse,'tmaxLapse');
    %override user specified choice for the recomputeDefaultTempSlope option
    parameters.recomputeDefaultTempSlope = 'false';
elseif(strcmpi(controlVars.variableEstimated,'tmin') && ~isempty(controlVars.defaultTempLapse))
    tempDefaultLapse = ncread(controlVars.defaultTempLapse,'tminLapse');
    %override user specified choice for the recomputeDefaultTempSlope option
    parameters.recomputeDefaultTempSlope = 'false';
else %else set the temp default lapse rate to spatially constant parameter value
    tempDefaultLapse = ones(grid.nr,grid.nc)*parameters.defaultSlope;
end

%check to see if there are any invalid slopes in the default temperature
%slope if used
if(~isempty(controlVars.defaultTempLapse))
    tempDefaultLapse(tempDefaultLapse < parameters.minSlope) = parameters.minSlope;
    tempDefaultLapse(tempDefaultLapse > parameters.maxSlopeLower & grid.layerMask == 1) = parameters.maxSlopeLower;
    tempDefaultLapse(tempDefaultLapse > parameters.maxSlopeUpper & grid.layerMask == 2) = parameters.maxSlopeUpper;

    %set metGrid default slope to QC'ed spatial lapse 
    metGrid.defaultSlope = tempDefaultLapse;
end


%%
%loop through all grid points and perform regression
for y = 1:grid.nr
    fprintf(1,'Row: %d of %d\n',y,grid.nr);
    for x = 1:grid.nc
        if(grid.mask(y,x) > 0)
            %find nearby stations to current grid point
            nearStations = getNearStations(inputStations.meta.lat,inputStations.meta.lon,inputStations.meta.facet,grid.lat(y,x),...
                                           grid.lon(y,x),grid.facet(y,x),parameters.nMaxNear,parameters.maxDist);

            %compute coastal distance weights
            coastWeights.near = calcCoastWeights(grid.distToCoast(y,x),inputStations.meta.coastDist(nearStations.nearStationInds),parameters.coastalExp);
            coastWeights.facet = calcCoastWeights(grid.distToCoast(y,x),inputStations.meta.coastDist(nearStations.facetStationInds),parameters.coastalExp);

            %compute topographic position weights
            topoPositionWeights.near = calcTopoPositionWeights(grid.topoPosition(y,x),parameters.topoPosMinDiff,parameters.topoPosMaxDiff,...
                                                          parameters.topoPosExp,inputStations.meta.topoPosition(nearStations.nearStationInds));
            topoPositionWeights.facet = calcTopoPositionWeights(grid.topoPosition(y,x),parameters.topoPosMinDiff,parameters.topoPosMaxDiff,...
                                                          parameters.topoPosExp,inputStations.meta.topoPosition(nearStations.facetStationInds));

            %compute layer weights
            layerWeights.near = calcLayerWeights(grid.layerMask(y,x),grid.dem(y,x),inputStations.meta.layer(nearStations.nearStationInds),...
                                            inputStations.meta.elev(nearStations.nearStationInds),parameters.layerExp);
            layerWeights.facet = calcLayerWeights(grid.layerMask(y,x),grid.dem(y,x),inputStations.meta.layer(nearStations.facetStationInds),...
                                            inputStations.meta.elev(nearStations.facetStationInds),parameters.layerExp);

            %compute SYMAP weights
            symapWeights.near = calcSymapWeights(nearStations.staDist(nearStations.nearStationInds),nearStations.staAngles(nearStations.nearStationInds),...
                                            parameters.distanceWeightScale,parameters.distanceWeightExp,parameters.maxDist);
            symapWeights.facet = calcSymapWeights(nearStations.staDist(nearStations.facetStationInds),nearStations.staAngles(nearStations.facetStationInds),...
                                            parameters.distanceWeightScale,parameters.distanceWeightExp,parameters.maxDist);

            %compute final weights
            finalWeights.near = calcFinalWeights(controlVars.variableEstimated,symapWeights.near,coastWeights.near,...
                                                 topoPositionWeights.near,layerWeights.near);
            finalWeights.facet = calcFinalWeights(controlVars.variableEstimated,symapWeights.facet,coastWeights.facet,...
                                                   topoPositionWeights.facet,layerWeights.facet);

            %compute first pass met field on grid
            if(strcmpi(controlVars.variableEstimated,'precip'))
                %compute met fields at current grid point for precipitation
                metPoint = calcPrecip(parameters,grid.smoothDemKM(y,x),parameters.defaultSlope,finalWeights.near,finalWeights.facet,...
                                      symapWeights.near,inputStations.meta.elev(nearStations.nearStationInds),inputStations.meta.elev(nearStations.facetStationInds),...
                                      inputStations.avgVar(nearStations.nearStationInds),inputStations.avgVar(nearStations.facetStationInds));
                                  
                                  
                %set precipitation specific output variables
                metGrid.normSlopeUncert(y,x) = metPoint.normSlopeUncert;
                metGrid.normSlope(y,x)       = metPoint.normSlope;
                
            elseif(strcmpi(controlVars.variableEstimated,'tmax') || strcmpi(controlVars.variableEstimated,'tmin'))
                %compute met fields at current grid point for temperature
                metPoint = calcTemp(parameters,grid.smoothDemKM(y,x),tempDefaultLapse(y,x),grid.layerMask(y,x),finalWeights.near,finalWeights.facet,...
                                      symapWeights.near,inputStations.meta.elev(nearStations.nearStationInds),inputStations.meta.elev(nearStations.facetStationInds),...
                                      inputStations.avgVar(nearStations.nearStationInds),inputStations.avgVar(nearStations.facetStationInds));
            end
            
            %set metGrid values for current grid point
            metGrid.rawField(y,x)             = metPoint.rawField;
            metGrid.intercept(y,x)            = metPoint.intercept;
            metGrid.slope(y,x)                = metPoint.slope;
            metGrid.baseInterpField(y,x)      = metPoint.baseInterpField;
            metGrid.baseInterpElev(y,x)       = metPoint.baseInterpElev;
            metGrid.baseInterpUncert(y,x)     = metPoint.baseInterpUncert;
            metGrid.slopeUncert(y,x)          = metPoint.slopeUncert;
            metGrid.validRegress(y,x)         = metPoint.validRegress;
            
        end %valid mask check
    end %end x-loop
end     %end y-loop
    
%%
%update and compute final fields conditioned on met variable
if(strcmpi(controlVars.variableEstimated,'precip'))
    %re-compute slope estimate
    finalNormSlope = updatePrecipSlope(grid.nr,grid.nc,grid.mask,metGrid.normSlope,metGrid.validRegress,parameters.defaultSlope,...
                                       parameters.recomputeDefaultPrecipSlope,parameters.filterSize,parameters.filterSpread);
    
    %compute final field value
    %feather precipitation generally following Daly et al. (1994)
    metGrid.finalField = featherPrecip(parameters,grid.nr,grid.nc,grid.dx,grid.smoothDemKM,grid.mask,finalNormSlope,...
                                       metGrid.baseInterpField,metGrid.baseInterpElev);
    
    %compute final uncertainty estimate
    finalUncert = calcFinalPrecipUncert(grid,metGrid.baseInterpUncert,metGrid.baseInterpElev,metGrid.normSlopeUncert,...
                                metGrid.baseInterpField,parameters.filterSize,parameters.filterSpread,parameters.covWindow);
    
    %set metGrid variables
    metGrid.finalSlope = finalNormSlope.*metGrid.finalField;
    metGrid.finalSlope(grid.mask<0) = -999; %set final slope value to missing where mask is ocean
    metGrid.totalUncert = finalUncert.totalUncert;
    metGrid.relUncert = finalUncert.relativeUncert;
    metGrid.baseInterpUncert = finalUncert.finalBaseInterpUncert;
    metGrid.slopeUncert = finalUncert.finalSlopeUncert;
    metGrid.defaultSlope = ones(grid.nr,grid.nc)*parameters.defaultSlope;

elseif(strcmpi(controlVars.variableEstimated,'tmax') || strcmpi(controlVars.variableEstimated,'tmin'))
    %re-compute slope estimate
    metGrid.finalSlope = updateTempSlope(grid.nr,grid.nc,grid.mask,grid.layerMask,metGrid.slope,parameters.recomputeDefaultTempSlope,...
                                 metGrid.validRegress,parameters.minSlope,parameters.maxSlopeLower,parameters.maxSlopeUpper,parameters.filterSize,...
                                 parameters.filterSpread);

    %compute final field estimate
    metGrid.finalField = calcFinalTemp(grid.smoothDemKM,grid.mask,metGrid.baseInterpElev,metGrid.baseInterpField,metGrid.finalSlope);
    
    %compute final uncertainty estimate
    finalUncert = calcFinalTempUncert(grid,metGrid.baseInterpUncert,metGrid.baseInterpElev,metGrid.slopeUncert,parameters.filterSize,parameters.filterSpread,parameters.covWindow);

    %set metGrid variables
    metGrid.totalUncert = finalUncert.totalUncert;
    metGrid.relUncert = finalUncert.relativeUncert;
    metGrid.baseInterpUncert = finalUncert.finalBaseInterpUncert;
    metGrid.slopeUncert = finalUncert.finalSlopeUncert;
    metGrid.defaultSlope = tempDefaultLapse;
end

%%
%output
saveOutput(controlVars.outputName,controlVars.variableEstimated,grid,metGrid,parameters);
