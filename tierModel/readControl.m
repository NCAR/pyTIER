function controlVars = readControl(controlName)
%
%% readControl reads a text control file for TIER
% TIER - Topographically InformEd Regression
%
% Arguments:
%
% Input:
%
%  controlName, string, the name of the grid file
%
% Output:
% 
%  controlVars, structure, stucture holding all control variables
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

    %open control file
    fid = fopen(controlName);
    %read data
    data = textscan(fid,'%s %s %s','headerlines',1,'delimiter',',');
    %close control file
    fclose(fid);
    
    %run through all lines in control file
    for i = 1:length(data{1})
        %test string name and place in appropriate named variable
        switch(strtrim(char(data{1}(i))))
            case 'gridName'
                controlVars.gridName = strtrim(char(data{2}(i)));
            case 'stationFileList'
                controlVars.stationFileList = strtrim(char(data{2}(i)));
            case 'stationDataPath'
                controlVars.stationDataPath = strtrim(char(data{2}(i)));
            case 'outputName'
                controlVars.outputName = strtrim(char(data{2}(i)));
            case 'parameterFile'
                controlVars.parameterFile = strtrim(char(data{2}(i)));
            case 'variableEstimated'
                controlVars.variableEstimated = strtrim(char(data{2}(i)));
            case 'defaultTempLapse'
                controlVars.defaultTempLapse = strtrim(char(data{2}(i)));
            otherwise
                %throw error if unknown string
                error('Unknown control file option: %s',char(data{1}(i)));
        end
    end
    
end
