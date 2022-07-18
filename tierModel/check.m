clc
clear all

%
%User determines the controlName
% controlName = input('Enter the name of your control file: ', 's');

%read control file
controlVars = readControl('tierControl.txt');

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
        if (grid.mask(y,x) > 0)

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

                %                 gridElev = grid.smoothDemKM(y,x);
                %                 defaultSlope=parameters.defaultSlope;
                %                 finalWeightsNear=finalWeights.near;
                %                 finalWeightsFacet= finalWeights.facet;
                %                 symapWeights=symapWeights.near;
                %                 stationElevNear=inputStations.meta.elev(nearStations.nearStationInds);
                %                 stationElevFacet=inputStations.meta.elev(nearStations.facetStationInds);
                %                 stationVarNear=inputStations.avgVar(nearStations.nearStationInds);
                %                 stationVarFacet=inputStations.avgVar(nearStations.facetStationInds);

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
    metGrid.finalSlope = updateTempSlope(grid.nr,grid.nc,grid.mask,grid.layerMask,metGrid.slope,parameters.recomputeDefaultTempSlope,metGrid.defaultSlope,...
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

outputName=controlVars.outputName;
outputVar=controlVars.variableEstimated;

%size of grid
[nr,nc] = size(metGrid.rawField);

%units check
if(strcmpi(outputVar,'precip'))
    physicalUnits = 'mm/day';
    normSlopeUnits = 'km-1';
    slopeUnits = 'mm/km';
elseif(strcmpi(outputVar,'tmax') || strcmpi(outputVar,'tmin'))
    physicalUnits = 'deg_C';
    slopeUnits = 'deg_C/km';
    normSlopeUnits = 'undefined';
end

%check to see if output file name exists
%if it does remove it and rewrite
if(exist(outputName,'file') > 0)
    %create string for system call
    cmd = sprintf('delete %s',outputName);
    %execute command
    system(cmd);
end

%Save to netcdf file
%add grid fields first
%create file, set dimensions and write elevation
nccreate(outputName,'elevation','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'elevation',grid.dem*1000); %convert back to m
ncwriteatt(outputName,'elevation','name','Domain elevation');
ncwriteatt(outputName,'elevation','long_name','Domain elevation');
ncwriteatt(outputName,'elevation','units','m');

nccreate(outputName,'latitude','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'latitude',grid.lat);
ncwriteatt(outputName,'latitude','name','latitude');
ncwriteatt(outputName,'latitude','long_name','latitude');
ncwriteatt(outputName,'latitude','units','degrees_north');

nccreate(outputName,'longitude','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'longitude',grid.lon);
ncwriteatt(outputName,'longitude','name','longitude');
ncwriteatt(outputName,'longitude','long_name','longitude');
ncwriteatt(outputName,'longitude','units','degrees_west');

nccreate(outputName,'mask','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'mask',grid.mask);
ncwriteatt(outputName,'mask','name','Domain mask');
ncwriteatt(outputName,'mask','long_name','Mask that sets land (1, valid), ocean (-1, met values not computed), and inland lake (0, met values computed)');
ncwriteatt(outputName,'mask','units','-');

%now on to output variables from the TIER model
%rawField
nccreate(outputName,'rawField','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'rawField',metGrid.rawField);
ncwriteatt(outputName,'rawField','name','raw variable output');
ncwriteatt(outputName,'rawField','long_name','Raw variable output before slope and gradient adjustments');
ncwriteatt(outputName,'rawField','units',physicalUnits);

%intercept
nccreate(outputName,'intercept','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'intercept',metGrid.intercept);
ncwriteatt(outputName,'intercept','name','intercept parameter');
ncwriteatt(outputName,'intercept','long_name','Intercept parameter from the variable-elevation regression');
ncwriteatt(outputName,'intercept','units',physicalUnits);

%slope
nccreate(outputName,'slope','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'slope',metGrid.slope);
ncwriteatt(outputName,'slope','name','variable elevation slope');
ncwriteatt(outputName,'slope','long_name','Raw variable elevation slope before slope adjustments');
ncwriteatt(outputName,'slope','units',slopeUnits);

%normalized slope (valid for precipitation only)
%normSlope
nccreate(outputName,'normSlope','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'normSlope',metGrid.normSlope);
ncwriteatt(outputName,'normSlope','name','normalized variable slope');
ncwriteatt(outputName,'normSlope','long_name','normalized variable elevation slope before slope adjustments(valid for precipitation only)');
ncwriteatt(outputName,'normSlope','units',normSlopeUnits);

%baseInterpField
nccreate(outputName,'baseInterpField','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'baseInterpField',metGrid.baseInterpField);
ncwriteatt(outputName,'baseInterpField','name','baseInterp estimate');
ncwriteatt(outputName,'baseInterpField','long_name','baseInterp estimated variable values on grid');
ncwriteatt(outputName,'baseInterpField','units',physicalUnits);

%baseInterpElev
nccreate(outputName,'baseInterpElev','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'baseInterpElev',metGrid.baseInterpElev);
ncwriteatt(outputName,'baseInterpElev','name','Weighted elevation');
ncwriteatt(outputName,'baseInterpElev','long_name','Grid point elevation estimate using station elevations and final weights');
ncwriteatt(outputName,'baseInterpElev','units','m');

%baseInterpUncert
nccreate(outputName,'baseInterpUncert','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'baseInterpUncert',metGrid.baseInterpUncert);
ncwriteatt(outputName,'baseInterpUncert','name','baseInterp uncertainty');
ncwriteatt(outputName,'baseInterpUncert','long_name','Uncertainty estimate from the baseInterp variable estimate');
ncwriteatt(outputName,'baseInterpUncert','units',physicalUnits);

%slopeUncert
nccreate(outputName,'slopeUncert','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'slopeUncert',metGrid.slopeUncert);
ncwriteatt(outputName,'slopeUncert','name','slope uncertainty');
ncwriteatt(outputName,'slopeUncert','long_name','Uncertainty estimate (physical space) resulting from the variable-elevation slope estimate');
ncwriteatt(outputName,'slopeUncert','units',physicalUnits);

%normSlopeUncert (valid for precipitation only)
nccreate(outputName,'normSlopeUncert','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'normSlopeUncert',metGrid.normSlopeUncert);
ncwriteatt(outputName,'normSlopeUncert','name','normalized slope uncertainty');
ncwriteatt(outputName,'normSlopeUncert','long_name','Uncertainty estimate (normalized) resulting from the variable-elevation slope estimate(valid for precipitation only)');
ncwriteatt(outputName,'normSlopeUncert','units',normSlopeUnits);

%defaultSlope
nccreate(outputName,'defaultSlope','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'defaultSlope',metGrid.defaultSlope);
ncwriteatt(outputName,'defaultSlope','name','default slope');
ncwriteatt(outputName,'defaultSlope','long_name','default elevation-variable slope estimate');
ncwriteatt(outputName,'defaultSlope','units',slopeUnits);

%finalSlope
nccreate(outputName,'finalSlope','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'finalSlope',metGrid.finalSlope);
ncwriteatt(outputName,'finalSlope','name','final slope');
ncwriteatt(outputName,'finalSlope','long_name','Final variable elevation slope after slope adjustments');
ncwriteatt(outputName,'finalSlope','units',slopeUnits);

%finalField
nccreate(outputName,'finalField','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'finalField',metGrid.finalField);
ncwriteatt(outputName,'finalField','name','final variable output');
ncwriteatt(outputName,'finalField','long_name','Final variable output after slope and gradient adjustments');
ncwriteatt(outputName,'finalField','units',physicalUnits);

%totalUncert
nccreate(outputName,'totalUncert','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'totalUncert',metGrid.totalUncert);
ncwriteatt(outputName,'totalUncert','name','total uncertainty');
ncwriteatt(outputName,'totalUncert','long_name','total uncertainty in physical units');
ncwriteatt(outputName,'totalUncert','units',physicalUnits);

%relUncert
nccreate(outputName,'relUncert','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'relUncert',metGrid.relUncert);
ncwriteatt(outputName,'relUncert','name','relative uncertainty');
ncwriteatt(outputName,'relUncert','long_name','relative total uncertainty');
ncwriteatt(outputName,'relUncert','units','-');

%validRegress
nccreate(outputName,'validRegress','Dimensions',{'latitude',nr,'longitude',nc},'FillValue',-999.0,'Format','netcdf4');
ncwrite(outputName,'validRegress',metGrid.validRegress);
ncwriteatt(outputName,'validRegress','name','valid regression');
ncwriteatt(outputName,'validRegress','long_name','flag denoting the elevation-variable regression produced a valid slope');
ncwriteatt(outputName,'validRegress','units','-');

%save parameters to output file as well
%write this out as global attributes
ncwriteatt(outputName,'/','nMaxNear',parameters.nMaxNear);
ncwriteatt(outputName,'/','nMinNear',parameters.nMinNear);
ncwriteatt(outputName,'/','maxDist',parameters.maxDist);
ncwriteatt(outputName,'/','minSlope',parameters.minSlope);
ncwriteatt(outputName,'/','maxInitialSlope',parameters.maxInitialSlope);
ncwriteatt(outputName,'/','maxFinalSlope',parameters.maxFinalSlope);
ncwriteatt(outputName,'/','maxSlopeLower',parameters.maxSlopeLower);
ncwriteatt(outputName,'/','maxSlopeUpper',parameters.maxSlopeUpper);
ncwriteatt(outputName,'/','defaultSlope',parameters.defaultSlope);
ncwriteatt(outputName,'/','topoPosMinDiff',parameters.topoPosMinDiff);
ncwriteatt(outputName,'/','topoPosMaxDiff',parameters.topoPosMaxDiff);
ncwriteatt(outputName,'/','topoPosExp',parameters.topoPosExp);
ncwriteatt(outputName,'/','costalExp',parameters.coastalExp);
ncwriteatt(outputName,'/','layerExp',parameters.layerExp);
ncwriteatt(outputName,'/','distanceWeightScale',parameters.distanceWeightScale);
ncwriteatt(outputName,'/','distanceWeightExp',parameters.distanceWeightExp);
ncwriteatt(outputName,'/','maxGrad',parameters.maxGrad);
ncwriteatt(outputName,'/','bufferSlope',parameters.bufferSlope);
ncwriteatt(outputName,'/','minElev',parameters.minElev);
ncwriteatt(outputName,'/','minElevDiff',parameters.minElevDiff);
ncwriteatt(outputName,'/','recomputeDefaultPrecipSlope',char(parameters.recomputeDefaultPrecipSlope));
ncwriteatt(outputName,'/','filterSize',parameters.filterSize);
ncwriteatt(outputName,'/','filterSpread',parameters.filterSpread);
ncwriteatt(outputName,'/','covWindow',parameters.covWindow);