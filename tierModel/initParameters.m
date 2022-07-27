function parameters = initParameters(varEstimated)
%
%% initParameters initalizes TIER parameters to defaults
% TIER - Topographically InformEd Regression
%
% Arguments:
%
%  Output:
%   
%   parameters, structure, structure holding all TIER parameters
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

    %initialize all parameters to initial default value
    parameters.nMaxNear = 7;                           %number
    parameters.nMinNear = 3;                           %number
    parameters.maxDist = 250;                          %km
    parameters.minSlope = 0.5;                         %normalized for precipitation
    parameters.maxInitialSlope = 4.25;                 %normalized
    parameters.maxFinalSlope = 3.0;                    %normalized
    parameters.maxSlopeLower = 0;                      %K/km
    parameters.maxSlopeUpper = 20;                     %K/km
    parameters.defaultSlope = 1.3;                     %normalized
    parameters.topoPosMinDiff = 500;                   %m
    parameters.topoPosMaxDiff = 5000;                  %m
    parameters.topoPosExp = 0.75;                      % -
    parameters.coastalExp = 1.0;                       % -
    parameters.layerExp = 0.5;                         % -
    parameters.distanceWeightScale = 16000;            % -
    parameters.distanceWeightExp = 2;                  % -
    parameters.maxGrad = 2.5;                          % normalized slope per grid cell
    parameters.bufferSlope = 0.02;                     % normalized
    parameters.minElev = 100;                          % m
    parameters.minElevDiff = 500;                      % m
    parameters.filterSize = 60;                        % grid cells
    parameters.filterSpread = 40;                      % -
    parameters.covWindow = 10;                         % grid cells
    parameters.recomputeDefaultPrecipSlope = 'false';  %logical
    parameters.recomputeDefaultTempSlope   = 'false';  %logical

    %initialize variables based on meteorological variable being regressed
    if(strcmpi(varEstimated,'precip'))
        %precipitation specific initialization values here 
    elseif(strcmpi(varEstimated,'tmax') || strcmpi(varEstimated,'tmin'))
        %temperature specific initialization values here
        parameters.nMaxNear = 30;                 %number
        parameters.nMinNear = 3;                  %number
        parameters.maxDist = 300;                 %km
        parameters.minSlope = -10;                %K/km
        parameters.maxSlopeLower = 0;             %K/km
        parameters.maxSlopeUpper = 20;            %K/km
        parameters.defaultSlope = -5;             %normalized
        parameters.topoPosMinDiff = 0;            %m 
        parameters.topoPosMaxDiff = 500;          %m
        parameters.topoPosExp = 0.50;             % -
        parameters.coastalExp = 1.0;              % -
        parameters.layerExp = 4.0;                % -
        parameters.distanceWeightScale = 20000;   % - 
    end
end            
