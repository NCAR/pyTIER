function layerWeights = calcLayerWeights(gridLayer,gridElev,stationLayer,stationElev,layerExp)
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
%   gridLayer, float, grid layer for current grid point
%   gridElev, float, grid elevation for current grid point
%   stationLayer, integer, layer of nearby stations
%   stationElev, float, elevation of nearby stations
%   layerExp, float, TIER parameter; exponent in weighting function
%
%  Output:
%   
%   layerWeights, float, vector holding layer weights for nearby stations
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

    %define a tiny float
    tiny = 1e-6;

    %find nearby stations that match the grid layer
    layerMatch = stationLayer==gridLayer;

    %initalize weight variable
    layerWeights = zeros(length(stationLayer),1);

    %set station weight in same layer to 1
    layerWeights(layerMatch) = 1.0;
    %compute weights for stations in other layer, based on vertical
    %distance difference
    layerWeights(~layerMatch) = 1./((abs(gridElev-stationElev(~layerMatch)+1.0)+tiny).^layerExp);
    %no station in other layer can have a weight >= 1.0
    layerWeights(layerWeights>=1) = 0.99;
    %normalize weights
    layerWeights = layerWeights./sum(layerWeights);


end
