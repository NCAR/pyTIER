function metPoint = calcPrecip(parameters,gridElev,defaultSlope,finalWeightsNear,finalWeightsFacet,symapWeights,stationElevNear,stationElevFacet,stationVarNear,stationVarFacet)
%
%% calcPrcp computes the first pass TIER estimate of precipitation
%
% Summary: This algorithm generally follows Daly et al. (1994,2002,2007,2008) and
% others.  However, here the regression estimated parameters
% and the grid point elevation to compute the precipitation is not done.
% Instead, the baseInterp estimate is used at all grid points as the intercept
% and the weighted linear regression slope is used to adjust the baseInterp
% estimate up or down based on the elevation difference between the grid
% and the baseInterp weighted station elevation.  This approach gives similar
% results and is effectively an elevation adjustment to a baseInterp estimate
% where the baseInterp weights here are computed using all knowledge based
% terms in addition to the SYMAP distance & angular isolation weights
% Other modifications from the above cited papers are present and
% summarized below.
   

% Specific modifications/notes for initial precipitation implementation 
% (eq. 2, Daly et al. 2002):
% 1) Here there are only 4-directional facets and flat (see tierPreprocessing.m for details)
%    1 = N
%    2 = E
%    3 = S
%    4 = W
%    5 = Flat
% 2) no elevation weighting factor
% 3) cluster weighting factor using symap type weighting
% 4) no topographic facet weighting factor

% 5) number of stations and facet weighting:
% the nMaxNear nearest stations are always used to determine the base
% precip value, then only stations on the correct facet are
% used to determine the elevation-variable relationship (slope).  
% facet weighting where stations on same facet but with other facets 
% inbetween get less weight is not considered.  All stations on the same 
% facet get the same "facet" weight
% 6) default lapse rates are updated after first pass to remove the
% spatially constant default lapse rate constraint (updatePrecipSlope.m)
%
% Arguments:
%
%  Input:
%
%   parameters  , structure, structure holding all TIER parameters
%   gridElev    , float    , elevation of current grid point
%   defaultSlope, float    , default normalized precipitation slope at
%                            current grid point as current grid point
%   finalWeights,       float, station weights for nearby stations
%   finalWeightsFacet, float, station weights for nearby stations on same
%                              slope facet
%   symapWeights,      float , symap station weights for nearby stations
%   stationElevNear,   float , station elevations for nearby stations
%   stationElevFacet, float , station elevations for nearby stations on
%                              same slope facet as current grid point
%   stationVarNear   , float , station values for nearby stations
%   stationVarFacet , float , sataion values for nearby stations on same 
%                              slope facet as current grid point
%
%  Output:
%
%   metPoint, structure, structure housing all grids related to
%                        precipitation for the current grid point
%
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
    %define tiny
    tiny = 1e-15;
    %define large;
    large = 1e15;
    
    %set local min station parameter
    nMinNear = parameters.nMinNear;
    
    %local slope values
    minSlope = parameters.minSlope;
    maxSlope = parameters.maxInitialSlope;

    %initalize metPoint structure
    metPoint.rawField             = NaN;
    metPoint.intercept            = NaN;
    metPoint.slope                = NaN;
    metPoint.normSlope            = NaN;
    metPoint.baseInterpField      = NaN;
    metPoint.baseInterpElev       = NaN;
    metPoint.baseInterpUncert     = NaN;
    metPoint.slopeUncert          = NaN;
    metPoint.normSlopeUncert      = NaN;
    metPoint.intercept            = NaN;
    metPoint.validRegress         = NaN;
    
    %first estimate the 'baseInterp' value at grid point, but use full knowledge
    %based weights if possible. this serves as the base estimate with no 
    %weighted linear elevation regression
   
    %if the final weight vector is invalid, default to symap weights only
    if(isnan(finalWeightsNear(1)))
        %compute baseInterp precipitaiton
        metPoint.baseInterpField = sum(symapWeights.*stationVarNear)/sum(symapWeights);
        %compute mean elevation of baseInterp stations
        metPoint.baseInterpElev = sum(symapWeights.*stationElevNear)/sum(symapWeights);
        %estimate uncertainty using standard deviation of leave-one-out
        %estimates
        nsta = length(symapWeights);
        combs = nchoosek(1:nsta,nsta-1);
        metPoint.baseInterpUncert = std(sum(symapWeights(combs).*stationVarNear(combs),2)./sum(symapWeights(combs),2));
    else %estimate simple average using final weights
        metPoint.baseInterpField = sum(finalWeightsNear.*stationVarNear)/sum(finalWeightsNear);
        metPoint.baseInterpElev = sum(finalWeightsNear.*stationElevNear)/sum(finalWeightsNear);
        %estimate uncertainty using standard deviation of leave-one-out
        %estimates
        nsta = length(finalWeightsNear);
        combs = nchoosek(1:nsta,nsta-1);
        metPoint.baseInterpUncert = std(sum(finalWeightsNear(combs).*stationVarNear(combs),2)./sum(finalWeightsNear(combs),2));
    end

    %if there are more than nMinNear stations, proceed with
    %weighted elevation regression
    if(length(stationElevFacet) >= nMinNear)
        %create weighted linear regression relationship
        linFit = calcWeightedRegression(stationElevFacet,stationVarFacet,finalWeightsFacet);
        %define normalized slope estimate
        elevSlope = linFit(1)/mean(stationVarFacet);
        
        %Run through station combinations and find outliers to see if we
        %can get a valid met var - elevation slope
        if(elevSlope < minSlope || elevSlope > maxSlope)
            %number of stations considered on current grid point facet
            nSta = length(stationVarFacet);
            %variable to track slope changes when estimating slope in
            %weighted regression
            maxSlopeDelta = 0;

            %set combinations for the number of combinations possbile 
            %selecting nSta-1 stations given nSta stations
            combs = nchoosek(1:nSta,nSta-1);
            %counter to track number of valid slopes
            cnt = 1;
            %initalize variable to hold valid slopes
            combSlp = zeros(1,1);
            %step through combinations
            for c = 1:length(combs(:,1))
                %define station attributes matrix (X) for regression 
                X = [ones(size(stationElevFacet(combs(c,:)))) stationElevFacet(combs(c,:))];

                %if X is square
                if(size(X,1)==size(X,2))
                    %if well conditioned
                    if(rcond(X)>tiny)
                        %compute weighted regression
                        tmpLinFit = calcWeightedRegression(stationElevFacet(combs(c,:)),stationVarFacet(combs(c,:)),...
                                                           finalWeightsFacet(combs(c,:)));
                        %set normalized slope variable
                        elevSlopeTest = tmpLinFit(1)/mean(stationVarFacet(combs(c,:)));
                        %compute change in slope from initial estimate
                        slopeDelta = abs(elevSlope - elevSlopeTest);
                    else %if X not well conditioned, set to unrealistic values
                        elevSlopeTest = large;
                        slopeDelta = -large;
                    end
                else
                    %compute weighted regression
                    tmpLinFit = calcWeightedRegression(stationElevFacet(combs(c,:)),stationVarFacet(combs(c,:)),...
                                                       finalWeightsFacet(combs(c,:)));
                    %set normalized slope variable
                    elevSlopeTest = tmpLinFit(1)/mean(stationVarFacet(combs(c,:)));
                    %compute change in slope from initial estimate
                    slopeDelta = abs(elevSlope - elevSlopeTest);
                end
                %if the recomputed slope is valid and has the largest slope
                %change, this specific case is the best estimate removing
                %the largest outlier in terms of estimated slope
                if(elevSlopeTest > minSlope && elevSlopeTest < maxSlope && slopeDelta > maxSlopeDelta)
                    removeOutlierInds = combs(c,:);
                    maxSlopeDelta = slopeDelta;
                    %add valid slope to vector
                    combSlp(cnt) = elevSlopeTest;
                    %increment counter
                    cnt = cnt + 1;
                %catch the rest of the recomputed slopes that are valid
                elseif(elevSlopeTest > minSlope && elevSlopeTest < maxSlope)
                    %add valid slope to vector
                    combSlp(cnt) = elevSlopeTest;
                    %increment counter
                    cnt = cnt + 1;
                end
            end %end of combination loop
                
            %if two or more valid combination of stations
            %estimate uncertainty of slope at grid point using standard
            %deviation of estimates
            if((cnt-1) >= 2)
                metPoint.normSlopeUncert = std(combSlp);                
            end
            
            %if there was a valid outlier removal combination, use the 
            %'best' combination
            if(maxSlopeDelta>0)
                %compute regression estimate
                linFit = calcWeightedRegression(stationElevFacet(removeOutlierInds),stationVarFacet(removeOutlierInds),...
                                                finalWeightsFacet(removeOutlierInds));
                
                %override the regression intercept with the baseInterp estimate
                linFit(2) = metPoint.baseInterpField;
                
                if(isnan(linFit(1)))
                    linFit(1) = defaultSlope*metPoint.baseInterpField;
                    tmpField = polyval(linFit,gridElev-metPoint.baseInterpElev);
                else
                    tmpField = polyval(linFit,gridElev-metPoint.baseInterpElev);
                end
                metPoint.rawField = tmpField;
                metPoint.slope = linFit(1);
                metPoint.normSlope = linFit(1)/mean(stationVarFacet(removeOutlierInds));
                metPoint.intercept = linFit(2);
                metPoint.validRegress = 1;
            else
                linFit(1) = defaultSlope*metPoint.baseInterpField;
                linFit(2) = metPoint.baseInterpField;
                
                metPoint.rawField = polyval(linFit,gridElev-metPoint.baseInterpElev);
                metPoint.normSlope  = linFit(1)/mean(stationVarFacet);
                metPoint.slope      = linFit(1);
                metPoint.intercept  = linFit(2);
            end
        %if regression coefficients are invalid
        elseif(isnan(linFit(1)))
            linFit(1) = defaultSlope*metPoint.baseInterpField;
            linFit(2) = metPoint.baseInterpField;
            
            metPoint.rawField  = polyval(linFit,gridElev-metPoint.baseInterpElev);
            metPoint.slope     = linFit(1);
            metPoint.normSlope = linFit(1);
            metPoint.intercept = linFit(2);
        else
            
            linFit(2) = metPoint.baseInterpField;
            
            metPoint.rawField = polyval(linFit,gridElev-metPoint.baseInterpElev);
            metPoint.slope     = linFit(1);
            metPoint.intercept = linFit(2);
            metPoint.normSlope = linFit(1)/mean(stationVarFacet);
            metPoint.validRegress = 1;

            %run through station combinations to estimate uncertainty in
            %slope estimate
            nSta = length(stationVarFacet);
            combs = nchoosek(1:nSta,nSta-1);
            cnt = 1;
            combSlp = zeros(1,1);
            for c = 1:length(combs(:,1))
                X = [ones(size(stationElevFacet(combs(c,:)))) stationElevFacet(combs(c,:))];
                
                %if X is square
                if(size(X,1)==size(X,2))
                    %if X is well conditioned
                    if(rcond(X) > tiny)
                        tmpLinFit = calcWeightedRegression(stationElevFacet(combs(c,:)),stationVarFacet(combs(c,:)),...
                                                               finalWeightsFacet(combs(c,:)));
                        elevSlopeTest = tmpLinFit(1)/mean(stationVarFacet(combs(c,:)));
                    else %if not well conditioned, set variables to unrealistic values
                        elevSlopeTest = large;
                    end
                else
                    tmpLinFit = calcWeightedRegression(stationElevFacet(combs(c,:)),stationVarFacet(combs(c,:)),...
                                                           finalWeightsFacet(combs(c,:)));
                    elevSlopeTest = tmpLinFit(1)/mean(stationVarFacet(combs(c,:)));
                end

                if(elevSlopeTest > minSlope && elevSlopeTest < maxSlope)
                    combSlp(cnt) = elevSlopeTest;
                    cnt = cnt + 1;
                end
            end
            
            %if two or more valid combination of stations
            %estimate uncertainty of slope at grid point using standard
            %deviation of estimates
            if((cnt-1) >= 2)
                metPoint.normSlopeUncert = std(combSlp);
            end
        end
    %only one station within range on Facet - revert to nearest with default slope
    elseif(length(stationVarFacet) == 1)  

        linFit(1) = defaultSlope*metPoint.baseInterpField;
        linFit(2) = metPoint.baseInterpField;
        
        metPoint.rawField = polyval(linFit,gridElev-metPoint.baseInterpElev);
        metPoint.slope     = linFit(1);
        metPoint.intercept = linFit(2);
        metPoint.normSlope = linFit(1)/metPoint.baseInterpField;
    %less than nMinNear stations within range - attempt regression anyway
    elseif(length(stationVarFacet) < nMinNear && ~isempty(stationVarFacet))  

        linFit = calcWeightedRegression(stationElevFacet,stationVarFacet,finalWeightsFacet);

        elevSlope = linFit(1)/mean(stationVarFacet);

        if(elevSlope < minSlope || elevSlope > maxSlope || isnan(elevSlope))
            linFit(1) = defaultSlope*metPoint.baseInterpField;
            linFit(2) = metPoint.baseInterpField;
            
            metPoint.normSlope = linFit(1)/metPoint.baseInterpField;
            metPoint.slope     = linFit(1);
            metPoint.intercept = linFit(2);
        else
            
            metPoint.intercept = metPoint.baseInterpField;
            metPoint.slope = linFit(1);
            metPoint.normSlope = linFit(1)/metPoint.baseInterpField;

        end
        %override intercept
        linFit(2) = metPoint.baseInterpField;

        metPoint.rawField = polyval(linFit,gridElev-metPoint.baseInterpElev);

    else %no original stations in distance search...

        linFit(1) = defaultSlope*metPoint.baseInterpField;
        linFit(2) = metPoint.baseInterpField;
        
        metPoint.rawField = polyval(linFit,gridElev-metPoint.baseInterpElev);
        metPoint.slope     = linFit(1);
        metPoint.intercept = linFit(2);
        metPoint.normSlope = linFit(1)/metPoint.baseInterpField;

    end %end enough stations?

end
