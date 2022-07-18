function finalTemp = calcFinalTemp(dem,mask,baseInterpElev,baseInterpTemp,finalSlope)
%
%% calFinalTemp computes the final temperature grid after all adjustments
%
% Arguments:
%
%  Inputs:
%
%   dem,  float  , grid dem
%   mask, integer, mask of valid grid points
%
%   baseInterpElev, float, elevation of baseInterp weighted stations for baseInterp
%                     estimate
%   baseInterpTemp, float, baseInterp estimated temperature
%   finaSlope, float, grid of final slope estimates after any previous 
%                     adjustments 
%
%  Outputs:
%
%   finalTemp, structure, structure containing the final temperature
%                         estimate across the grid
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

    %compute final temp using all finalized estimates
    finalTemp = finalSlope.*(dem-baseInterpElev) + baseInterpTemp;
    %set unused grid points to missing
    finalTemp(mask<0) = -999;

end
