function coastWeights = calcCoastWeights(gridDistanceToCoast,stationDistanceToCoast,coastalExp)
%
%% calcCoastWeights computes weights for stations as compared to the 
%  current grid point based on the differences in coastal distance
%
% Arguments:
%
%  Input:
%
%   gridDistanceToCoast, float, distance to coast of current grid point
%   stationDistanceToCoast, float, distance to coast for nearby stations
%
%  Output:
%   
%   coastWeights, float, vector holding coastal weights for nearby stations
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
    tiny = 1e-5;

    %distance to coast weighting (e.g. Daly et al. 2002)
    coastWeights = 1.0./((abs(gridDistanceToCoast-stationDistanceToCoast)+tiny).^(coastalExp));
    %check for values > 1
    coastWeights(coastWeights>1) = 1.0;
    %normalize weights
    coastWeights = coastWeights./sum(coastWeights);

end
