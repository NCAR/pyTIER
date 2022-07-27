function parameters = initPreprocessParameters()
%
%% initPreprocessParameters initalizes TIER parameters to defaults
% TIER - Topographically InformEd Regression
%
% Arguments:
%
%  Output:
%   
%   parameters, structure, structure holding all TIER preprocessing 
%   parameters
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

    %initialize all parameters to initial default value
    parameters.demFilterName = 'Daly';          %string
    parameters.demFilterPasses = 80;            %number
    parameters.minGradient = 0.003;             %km/km
    parameters.smallFacet = 500;                %km^2
    parameters.smallFlat = 1000;                %km^2
    parameters.narrowFlatRatio = 3.1;           %ratio
    parameters.coastSearchLength = 200;         %km
    parameters.layerSearchLength = 10;          %grid cells
    parameters.inversionHeight = 250;           %m

end            
