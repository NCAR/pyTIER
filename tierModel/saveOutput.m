function saveOutput(outputName,outputVar,grid,metGrid,parameters)
%
%% saveOutput saves the metGrid structure into a netcdf file
%
% Arguments:
%
%  Input:
% 
%   outputName, string   , name of output file
%   metGrid   , structure, structure containing TIER met fields
%
%  Output:
% 
%    None
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
        cmd = sprintf('rm %s',outputName);
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
        
end
