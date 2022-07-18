function metGrid = allocateMetVars(nr,nc)
%
%% allocateMetVars allocates memory for met variables
%
% Arguments:
%
%  Input:
%
%   nr, integer, number of rows in grid
%   nc, integer, number of columns in grid
%
%  Output:
%
%   metGrid, structure, structure housing all grids related to
%                       met field generation
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

    %allocate space for grids
    metGrid.rawField         = zeros(nr,nc)*NaN;
    metGrid.intercept        = zeros(nr,nc)*NaN;
    metGrid.slope            = zeros(nr,nc)*NaN;
    metGrid.normSlope        = zeros(nr,nc)*NaN;
    metGrid.baseInterpField  = zeros(nr,nc)*NaN;
    metGrid.baseInterpElev   = zeros(nr,nc)*NaN;
    metGrid.baseInterpUncert = zeros(nr,nc)*NaN;
    metGrid.slopeUncert      = zeros(nr,nc)*NaN;
    metGrid.normSlopeUncert  = zeros(nr,nc)*NaN;
    metGrid.defaultSlope     = zeros(nr,nc)*NaN;
    metGrid.finalSlope       = zeros(nr,nc)*NaN;
    metGrid.finalField       = zeros(nr,nc)*NaN;
    metGrid.totalUncert      = zeros(nr,nc)*NaN;
    metGrid.relUncert        = zeros(nr,nc)*NaN;
    metGrid.validRegress     = zeros(nr,nc)*NaN;

end            
