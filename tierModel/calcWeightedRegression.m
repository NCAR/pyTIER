function linearFit = calcWeightedRegression(stationElev,stationVar,stationWeights)
%
%% calcWeightedRegression computes a weighted linear regression of station
%  data against elevation.  Weight vector determines weight of each station
%  in the regression.  Here they are computed as the combination of the
%  component geophysical weights (e.g. coastal, layer, SYMAP).  Following
%  Daly et al. (1994,2002)
%
% Arguments:
%
%  Input:
%
%   stationElev, float, vector of elevation of nearby stations
%   stationDist, float, vector of distance to nearby stations
%   stationVar, float, vector containing meteorological variable values from
%                  stations
%   stationWeights, float,vector of station weights
%
%  Output:
%   
%   linearFit, float, vector holding the two coefficients of the weighted
%                     linear regression
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

    %create weighted linear regression matricies
    n = length(stationElev);
    X = [ones(size(stationElev)) stationElev];
    W = eye(n,n);
    diagInd = 1:n;
    inds = sub2ind([n,n],diagInd,diagInd);
    W(inds) = stationWeights;

    %compute weighted linear regression
    linearFit = (((X'*W*X)^-1)*X'*W*stationVar)';
    
    %change order of coefficients for convenience
    linearFit = circshift(linearFit,-1,2);

end
