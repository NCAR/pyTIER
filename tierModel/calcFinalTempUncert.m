function finalUncert = calcFinalTempUncert(grid,baseInterpUncert,baseInterpElev,slopeUncert,filterSize,filterSpread,covWindow)
%
%% calcFinalTempUncert computes the final uncertainty for temperature variables
%
% Arguments:
%
%  Inputs:
%
%   grid, structure, structure containing grid information
%   baseInterpUncert, float, intiial baseInterp uncertainty estimate across grid
%   slopeUncert, float, initial estimate of slope uncertainty across grid
%   filterSize, integer, size of low-pass filter in grid points
%   filterSpread, float, variance of low-pass filter
%   covWindow, float, size (grid points) of covariance window
%
%  Outputs:
%
%   finalUncert, structure, structure containing total and relative
%                           uncertainty for met var
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

    %define a mesh of indicies for scattered interpolation of valid points
    %back to a grid
    y = 1:grid.nr;
    x = 1:grid.nc;
    [y2d,x2d] = meshgrid(x,y);

    %find valid points for baseInterp uncertainty
    [i,j] = find(~isnan(baseInterpUncert));
    %scattered interpolation using griddata
    interpBaseInterp = griddata(i,j,baseInterpUncert(~isnan(baseInterpUncert)),x2d,y2d,'linear');
    %fill missing values with nearest neighbor
    %compatible with octave
%    interpBaseInterp = fillNaN(interpBaseInterp,x2d,y2d);
    %for Matlab only
    interpBaseInterp = fillmissing(interpBaseInterp,'nearest',1);
    interpBaseInterp = fillmissing(interpBaseInterp,'nearest',2);
    
    %find valid points for slope uncertaintty
    [i,j] = find(slopeUncert >= 0);
    %scattered interpolation using griddata
    interpSlope = griddata(i,j,slopeUncert(slopeUncert>=0),x2d,y2d,'linear');
    interpSlope = interpSlope.*abs(baseInterpElev-grid.smoothDem);
    %fill missing values with nearest neighbor
    %compatible with octave
%    interpSlope = fillNaN(interpSlope,x2d,y2d);
    %for Matlab only
    interpSlope = fillmissing(interpSlope,'nearest',1);
    interpSlope = fillmissing(interpSlope,'nearest',2);
    
    %gaussian low-pass filter
    gFilter = fspecial('gaussian',[filterSize filterSize],filterSpread);
    
    %filter uncertainty estimates
    finalBaseInterpUncert = imfilter(interpBaseInterp,gFilter,'circular');
    finalSlopeUncert = imfilter(interpSlope,gFilter,'circular');
    
    %replace nonvalid mask points with NaN
    finalBaseInterpUncert(grid.mask<=0) = NaN;
    finalSlopeUncert(grid.mask<=0) = NaN;
    
    %estimate the total and relative uncertainty in physical units 
    %define a local covariance vector
    localCov = zeros(size(finalBaseInterpUncert))*NaN;

    %step through each grid point and estimate the local covariance between
    %the two uncertainty components using covWindow to define the size of the local covariance estimate
    %covariance influences the total combined estimate
    for i = 1:grid.nr
        for j = 1:grid.nc
            %define indicies aware of array bounds
            iInds = [max([1 i-covWindow]),min([grid.nr i+covWindow])];
            jInds = [max([1 j-covWindow]),min([grid.nc j+covWindow])];

            %compute local covariance using selection of valid points
            %get windowed area
            subBaseInterp = finalBaseInterpUncert(iInds(1):iInds(2),jInds(1):jInds(2));
            subSlope = finalSlopeUncert(iInds(1):iInds(2),jInds(1):jInds(2));
            %compute covariance for only valid points in window
            c = cov(subBaseInterp(~isnan(subBaseInterp)),subSlope(~isnan(subSlope)),0);
            %pull relevant value from covariance matrix
            localCov(i,j) = c(1,length(c(1,:)));
        end
    end

    %compute the total estimates 
    finalUncert.totalUncert = finalSlopeUncert+finalBaseInterpUncert+2*sqrt(abs(localCov));
    finalUncert.relativeUncert = zeros(size(finalUncert.totalUncert))*NaN;

    %set novalid gridpoints to missing
    finalBaseInterpUncert(grid.mask<=0) = -999;
    finalSlopeUncert(grid.mask<=0) = -999;
    finalUncert.totalUncert(grid.mask<=0) = -999;
    finalUncert.relativeUncert(grid.mask<=0) = -999;    

    %define components in output structure
    finalUncert.finalBaseInterpUncert = finalBaseInterpUncert;
    finalUncert.finalSlopeUncert = finalSlopeUncert;


end
