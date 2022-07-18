function topoPositionWeights = calcTopoPositionWeights(gridTopoPosition,topoPosMinDiff,topoPosMaxDiff,topoPosExp,stationTopoPos)
%
%% calcTopoPositionWeights computes weights for nearby stations as compared 
%  to the current grid point based on the differences in topographic 
%  position as in Daly et al. (2007), JAMC
%
% Arguments:
%
%  Input:
%
%   gridTopoPosition, float, distance to coast of current grid point
%   stationTopoPos, float, vector of topographic position of nearby stations
%   nearStationInds, integer, vector of nearby station indicies
%
%  Output:
%   
%   topoPositionWeights, float, vector holding topographic position weights
%                               for nearby stations
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

    %initialize topographic position vector
    topoPositionWeights = zeros(length(stationTopoPos),1);
    %compute topographic position difference
    topoDiff = abs(stationTopoPos-gridTopoPosition);
    %check if any differences are below min, set to 1 weight
    topoPositionWeights(topoDiff<=topoPosMinDiff) = 1.0;
    %if differences are in between max and min, compute using linear decay
    topoPositionWeights(topoDiff>topoPosMinDiff) = 1./((topoDiff(topoDiff>topoPosMinDiff)/topoPosMinDiff).^topoPosExp);
    %if differences are larger than max, set to zero
    topoPositionWeights(topoDiff>topoPosMaxDiff) = 0.0;
    %normalize topographic position weights
    topoPositionWeights = topoPositionWeights./sum(topoPositionWeights);

end
