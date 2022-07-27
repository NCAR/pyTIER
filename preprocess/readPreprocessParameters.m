function parameters = readPreprocessParameters(parameterFile,parameters)
%
%% readPreprocessParameters reads a text parameter file for TIER preprocessing
%  and overrides the default values if parameters are present
%  in parameter file
%
% TIER - Topographically InformEd Regression
%
% Arguments:
%
% Input:
%
%  parameterFile, string, the name of the TIER preprocessing parameter file
%  parameters, structure, structure holding all TIER preprocessing parameters
%
% Output:
%
%  parameters, structure, structure holding all TIER preprocessing parameters
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

    %open parameter file
    fid = fopen(parameterFile);
    %read data
    data = textscan(fid,'%s %s %s','headerlines',1,'delimiter',',');
    %close control file
    fclose(fid);
    
    %run through all lines in parameter file
    for i = 1:length(data{1})
        %test string name and place in appropriate named variable
        switch(char(data{1}(i)))
            case('demFilterName')
                %filter type (Daly = original Daly et al. 1994 filter), only option currently implemented
                parameters.demFilterName = strtrim(data{2}(i));
            case('demFilterPasses')
                %number of passes to filter raw DEM
                parameters.demFilterPasses = str2double(strtrim(data{2}(i)));
            case('minGradient')
                %minimum gradient for a pixel to be considered sloped, otherwise it is considered flat
                parameters.minGradient = str2double(strtrim(data{2}(i)));
            case('smallFacet')
                %area of smallest sloped facet allowed (km^2)
                parameters.smallFacet = str2double(strtrim(data{2}(i)));
            case('smallFlat')
                %area of smallest flat facet allowed (km^2)
                parameters.smallFlat = str2double(strtrim(data{2}(i)));
            case('narrowFlatRatio')
                %ratio of major/minor axes to merge flat regions (i.e. ridges)
                parameters.narrowFlatRatio = str2double(strtrim(data{2}(i)));
            case('layerSearchLength')
                %search length (grid cells) to determine local minima in elevation
                parameters.layerSearchLength = str2double(strtrim(data{2}(i)));
            case('inversionHeight')
                %depth of layer 1 (temperature inversion layer) in m
                parameters.inversionHeight = str2double(strtrim(data{2}(i)));
            otherwise
                %throw error if unknown string
                error('Unknown parameter name : %s',char(data{1}(i)));
        end
    end
end            
