function nearStations = getNearStations(staLat,staLon,staFacet,gridLat,gridLon,gridFacet,nMatch,maxDist)
%
%% getNearStations finds nearby stations for current grid point
%
% Arguments:
%
%  Input:
%
%   yPt, integer, y counter for current grid point
%   xPt, integer, x counter for current grid point
%   staLat, float, vector of station lat
%   staLon, float, vector of station lon
%   staFacet, integer, vector of station integer facets
%   grid, structure, structure containing grid
%   nMatch, integer, value of maximum number of stations to search for
%   maxDist, float, value of maximum radius to search for stations
%
%  Output:
%
%   nearStations, structure, structure containing indicies for stations
%   within search radius and those within that search
%   area on the same topographic facet as the current grid point
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
%
    %compute distance to current grid point for all stations
    [staDist, staAngles] = distance(staLat,staLon,gridLat,gridLon);
    %convert distance to km
    staDist = rad2km(deg2rad(staDist));

    %get station indices from sorted distance (nearMatch)
    [~,distSort] = sort(staDist);
    nearMatch = distSort(1:nMatch);

    %find stations on same topographic facet as current grid point
    matchFacet = find(staFacet == gridFacet);
    %get indicies of stations on same topographic facet
    [~,matchFacetSort]= sort(staDist(matchFacet));
    %take nMatch stations on same facet with consideration of distance
    %from grid point
    stationInds = matchFacet(matchFacetSort(1:nMatch));
    %now cull list based on distance from grid point
    matchDist = staDist(stationInds) <= maxDist;
    %finalize station indices
    facetStationInds = stationInds(matchDist);

    %set output structure
    nearStations.staDist = staDist;
    nearStations.staAngles = staAngles;
    nearStations.nearStationInds = nearMatch;
    nearStations.facetStationInds = facetStationInds;
    
end            
