function symapWeights = calcSymapWeights(staDist,staAngles,distanceWeightScale,distanceWeightExp,maxDist)
%
%% calcSymapWeights computes weights for nearby stations following the
%  concept of the SYMAP algorithm (Shepard 1984).  Uses Barnes (1964) type
%  distance weights instead of the exact SYMAP method.  Angular weighting
%  is from Shepard (1984).
%
% Arguments:
%
%  Input:
%
%   staDist, float, vector of station distances to current grid point
%   staAngles, float, vector of station angles from current grid point
%   distanceWeightScale, float, input TIER parameter
%   maxDist, float, input TIER parameter of maximum search distance
%
%  Output:
%   
%  symapWeights,float, vector holding SYMAP weights of nearby stations
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

    %set number of stations
    nMatch = length(staDist);
    
    %to radians
    toRad = pi/180.0;
    
    %compute mean from nearest N stations using Barnes (1964) type distance weights
    %Set the scale factor to depends on mean distance of nearby stations
    meanDist = mean(staDist);
    scale = distanceWeightScale*(meanDist/(maxDist));

    %compute initial distance weights
    distanceWeights = exp(-(staDist.^distanceWeightExp/scale));

    %directional isolation (Shepard 1984)
    %set angular isolation weight variable
    angleWeight = zeros(nMatch,1);
    %run through stations compute angle and isolation from other stations
    for i = 1:nMatch
        cosThetaSta = zeros(nMatch,1);
        for j = 1:nMatch
            %angle of station in radians from next station
            cosThetaSta(j) = cos((staAngles(i)-staAngles(j))*toRad);
        end
        %total angular isolation weight
        angleWeight(i) = sum(distanceWeights(i)*(1-cosThetaSta));

    end
    
    %increment integer vector: 1 to nMatch 
    inds = 1:nMatch;
    
    %compute weights as a combination of distance and directional isolation
    symapWeights = distanceWeights.^2.*( 1+(angleWeight./sum(angleWeight(setxor(inds,i)))) );
    %normalize weights
    symapWeights = symapWeights./sum(symapWeights);

end
