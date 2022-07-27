function ellipsoid = defineEllipsoid(ellipsoidName)
% 
% defineEllipsoid creates a matlab referenceEllipsoid structure.
% This function was created as a workaround to the referenceEllipsoid function in Matlab for use in Octave.
% Right now only WGS84 is defined, but users can add ellipsoids as they see fit.
%
% Arguments: 
%
% Input:
%
%  ellipsoidName, string, name of reference ellipsoid
%
% Output:
%
%  ellipsoid, structure, matlab reference ellipsoid structure
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

  %trim any whitespace, move to uppercase
  ellipsoidName = strtrim(upper(ellipsoidName));
  
  %define ellipsoid structure
  switch ellipsoidName
      case 'WGS84'
          ellipsoid.Code = 7030;
          ellipsoid.Name = 'World Geodetic System 1984';
          ellipsoid.LengthUnit = 'meter';
          ellipsoid.SemimajorAxis = 6378137;
          ellipsoid.SemiminorAxis = 6356752.31424518;
          ellipsoid.InverseFlattening = 298.257223563;
          ellipsoid.Eccentricity = 0.0818191908426215;
          ellipsoid.Flattening = 0.003352810664747;
          ellipsoid.ThirdFlattening = 0.001679220386384;
          ellipsoid.MeanRadius = 6.371008771415059e+06;
          ellipsoid.SurfaceArea = 5.100656217240886e+14;
          ellipsoid.Volume = 1.083207319801408e+21;
      otherwise
          error('Ellipsoid not supported, currently only the WGS84 ellipsoid is supported');
  end

end
