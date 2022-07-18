function height = computeHeight(pressure)
%
%% a small function to compute height above mean sea level using the standard atmosphere
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

    % constants for pressure variation with altitude (https://en.wikipedia.org/wiki/Atmospheric_pressure)
    p_o = 101325; %Pa, standard sea level pressure
    lapse = 0.0065; %K/m, standard lapse rate
    c_p = 1004.68506; %(J/kg*K) constant-pressure specific heat of air
    t_o = 288.15; %K standard sea level temperature
    g = 9.80665; %m/s^2 surface gravitational acceleration
    mAir = 0.02896969; %kg/mol molar mass of air
    r_o = 8.31582991; %J/(mol*K) universal gas constant

    
    height = ( log(pressure/p_o)*t_o*r_o)/(-g*mAir);
    
end
