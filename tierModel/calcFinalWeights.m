function finalWeights = calcFinalWeights(varEstimated,symapWeights,coastWeights,topoPositionWeights,layerWeights)
%
%% calcLayerWeights computes the weights of stations to the current grid
%  point.  Estimates a 2-layer atmosphere (inversion and free) based on
%  topography.  Helpful identifying inversion areas as defined in 
%  Daly et al. (2002, Climate Res.), section 7
%
% Arguments:
%
%  Input:
%
%   varEstimated, string, met variable being estimated
%   symapWeights, float, vector of SYMAP weights
%   coastWeights, float, vector of distance to coast weights
%   topoPositionWeights, float, vector of topographic position weights
%   layerWeights, float, vector of inversion layer weights
%
%  Output:
%   
%   finalWeights, float, vector holding final weights for nearby stations
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

    %inversion layer and topographic position weighting (layerWeights 
    %and topoPosition) not used for precipitation
    if(strcmpi(varEstimated,'precip'))
        finalWeights = symapWeights.*coastWeights;
    elseif(strcmpi(varEstimated,'tmax') || strcmpi(varEstimated,'tmin'))
        finalWeights = symapWeights.*coastWeights.*topoPositionWeights.*layerWeights;
    else
        error('Unrecognized variable: %s',varEstimated);
    end
    %normalize final weights
    finalWeights = finalWeights./sum(finalWeights);

    %prevent badly conditioned weight matrices in the regression
    %set minium weight to a small number that is still large enough for 
    %numerics to compute
    finalWeights(finalWeights<1e-6) = 1e-6;
    
end
