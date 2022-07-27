function filled = fillNaN(inputMatrix,x2d,y2d)
%
%% A small function to fill missing values with nearest neighbors
%  Created as a workaround for Octave compatiblity with Matlab instead of using the fillMissing function
%
% Arguments:
%
% Input:
%
%  inputMatrix, float, a 2D matrix of values to be filled
%  x2d, integer, a 2D matrix of integer index values created using meshgrid
%  y2d, integer, a 2D matrix of integer index values created using meshgrid
%
% Output:
%
%  filled, float, 2D matrix of inputMatrix and filled values whereever there were NaN values previously
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

    %determine size of matrix
    [nr,nc] = size(inputMatrix);

    %find valid points
    valid = ~isnan(inputMatrix);

    %create 1D vectors with only valid points
    inputMatrix1d = inputMatrix(valid);

    %compute a distance matrix
    distMatrix = sqrt((x2d-(nc/2)).^2+(y2d-(nr/2)).^2);

    %predefine the output matrix
    filled = inputMatrix;

    %loop through all points
    for i = 1:nr
        for j = 1:nc
            %only operate if it is a nan point
            if(isnan(inputMatrix(i,j)))
                %find nearest neighbor
                [~,nnInd] = min(abs(distMatrix(valid)-distMatrix(i,j)));
                %set value to output matrix
                filled(i,j) = inputMatrix1d(nnInd);
             end
         end
     end


end
