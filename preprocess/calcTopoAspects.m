function aspects = calcTopoAspects(grid,parameters)
%
%% calcTopoAspects computes the cardinal slope facets and flat areas from 
%  a smoothed DEM that is computed internally here. Generally follows Daly
%  et al. (1994)
%
% Arguments:
%
% Input:
%
%  grid,       structure, the raw grid structure
%  parameters, structure, structrure holding preprocessing parameters
%
% Output:
% 
%  aspects, structure, structure containing smoothed DEM, topographic
%                      facets, and smoothed topographic gradient arrays
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

    fprintf(1,'Computing topographic facets\n');

    %define local variable for facets
    intFacet = zeros(size(grid.dem))-999.0;

    %local variable for minimum gradient
    minGradient = parameters.minGradient;

    %local variable for number of facets
    nFacets = 5;

    %local variable for minimum size of facets
    nSmallFacet = parameters.smallFacet/(grid.dx^2);  %set size of smallest sloped facet to grid cells
    nSmallFlat = parameters.smallFlat/(grid.dx^2);    %set size of smallest flat facet to grid cells

    %check filter type and set filter
    if(strcmpi(parameters.demFilterName,'daly'))
        demFilter = [0 0.125 0; 0.125 0.5 0.125; 0 0.125 0];
    else
        error('Unknown Filter type %s\n', char(parameters.demFilterName));
    end

    %set local dem variable
    smoothElev = grid.dem;
    smoothElev(isnan(smoothElev)) = 0;

    %filter DEM using demFilterPasses
    for i = 1:parameters.demFilterPasses
        smoothElev = imfilter(smoothElev,demFilter,'circular');
    end

    %compute the gradients, slope, aspect from the DEM
    %if you are using Matlab and have the mapping toolbox, this will work
%    [aspect,~,gradNorth,gradEast] = gradientm(grid.lat',grid.lon',smoothElev');
    
    %workaround for Octave compatibility
    %this gives slightly different aspect and facet results from the
    %gradientm function in Matlab, but overall is very similar
    [gradEast,gradNorth] = gradient(smoothElev',grid.dx*1000); %convert km to m
    aspect = 270-(360/(2*pi))*atan2(gradNorth,gradEast);
    aspect(aspect>360) = aspect(aspect>360)-360;

    %transpose aspect, gradients
    aspect = aspect';
    gradNorth = gradNorth';
    gradEast = gradEast';
    
    %define flat facets
    flat = abs(gradNorth)<minGradient & abs(gradEast)<minGradient;

    %define cardinal direction facets
    north = aspect>315 | aspect <=45;
    east = aspect>45 & aspect<=135;
    south = aspect>135 & aspect<=225;
    west = aspect>225 & aspect <= 315;

    intFacet(north) = 1;
    intFacet(east) = 2;
    intFacet(south) = 3;
    intFacet(west) = 4;
    intFacet(flat) = 5;

    %character array of facets
    for i = 1:max(intFacet)
        switch i
            case 1
                charFacets{i} = 'North';
            case 2
                charFacets{i} = 'East';
            case 3
                charFacets{i} = 'South';
            case 4
                charFacets{i} = 'West';
            case 5
                charFacets{i} = 'Flat';
            otherwise
                error('Unknown Facet');
        end
    end

    %merge small facets
    %find all objects for each aspect and merge small ones into nearby larger
    %Facets using 4- (flat) or 8-connectivity (slopes)
    for i = 1:nFacets
        fprintf(1,'Merging Facet %s\n',char(charFacets{i}));
        if(i < nFacets)
            connectivity = 8;
        else
            connectivity = 4;
        end
        binary = intFacet;
        binary(binary~=i) = 0;
        binary(binary==i) = 1;

        imageObjects = bwlabel(binary,connectivity);
        stats{i} = regionprops(imageObjects,'Area','BoundingBox','MinorAxisLength','MajorAxisLength');

        %merge all small objects into non-flat slopes
        %need to have at least nSmall grid cells to make an actual facet
        %merge into the first facet that is not flat starting west, then south,
        %then east, then north
        if(i < nFacets)
            minSize = nSmallFacet;
        else %flats need to be larger as small flats may behave like nearby slopes
            minSize = nSmallFlat;
        end
        %number of objects for current facet
        nobj = length(stats{i});
        for n = 1:nobj
            %if the current object is too small
            if(stats{i}(n).Area < minSize)
                %find the west and south side bounding points
                westPoints =  [round(stats{i}(n).BoundingBox(1)) round(stats{i}(n).BoundingBox(1)+stats{i}(n).BoundingBox(3))];
                southPoints = [round(stats{i}(n).BoundingBox(2)) round(stats{i}(n).BoundingBox(2)+stats{i}(n).BoundingBox(4))];


                %if the bounding point is outside the grid size, set to grid max
                %dimensions for columns and rows
                if(max(westPoints)>grid.nc)
                    westPoints(2) = grid.nc;
                end
                if(max(southPoints)>grid.nr)
                    southPoints(2) = grid.nr;
                end

                %define north and east bounding points
                northPoints = southPoints;
                eastPoints = westPoints;


                %find the grid cells along the four bounding lines
                westPixels = intFacet(round(stats{i}(n).BoundingBox(2)),westPoints(1):westPoints(2) );
                southPixels = intFacet(southPoints(1):southPoints(2),round(stats{i}(n).BoundingBox(1)));
                %north and east bounding points are defined by the opposite of the 
                %west and south bounding points
                eastPixels = intFacet(southPoints(2),eastPoints(1):eastPoints(2));
                northPixels = intFacet(northPoints(1):northPoints(2),westPoints(2));

                %find the mode of the facets on the bounding lines
                modeWest = mode(westPixels);
                modeEast = mode(eastPixels);
                modeSouth = mode(southPixels);
                modeNorth = mode(northPixels);

                %find the grid cells of the current facet object
                inds = find(imageObjects==n);

                %merge current object into appropriate facet based on bounding
                %line most common facet
                if(modeWest ~= 5 && modeWest ~= i)
                    intFacet(inds) = modeWest; %merge into west-facing slope
                elseif(modeSouth ~=5 && modeSouth ~= i )
                    intFacet(inds) = modeSouth; %merge into south-facing slope
                elseif(modeEast ~=5 && modeEast ~= i)
                    intFacet(inds) = modeEast; %merge into east-facing slope
                elseif(modeNorth ~=5 && modeNorth ~= i)
                    intFacet(inds) = modeNorth; %merge into north-facing slope
                else  %if object cannot merge into slope, default merge into flat
                    intFacet(inds) = 5; %merge into flat area
                end  

            end %end object size if-statement
        end %end object loop
    end %end facet loop


    % merge narrow flat areas that are a likely ridge
    % assume these behave like nearby slopes
    % merge into slopes on the south and west sides only
    fprintf(1,'Merging narrow flats\n');

    %create a binary image of only flat pixels
    i = 5;
    binary = intFacet;
    binary(binary~=i) = 0;
    binary(binary==i) = 1;
    %identify connected pixels
    imageObjects = bwlabel(binary,connectivity);
    %generate statistics about all object features
    flats = regionprops(imageObjects,'Area','BoundingBox','MinorAxisLength','MajorAxisLength','Orientation');

    %loop through all flat objects
    for i = 1:length(flats)
        %if they are very narrow
        if(flats(i).MajorAxisLength/flats(i).MinorAxisLength > parameters.narrowFlatRatio)
            %find the west and south side bounding points
            westPoints =  [floor(flats(i).BoundingBox(1)) floor(flats(i).BoundingBox(1)+flats(i).BoundingBox(3))];
            southPoints = [floor(flats(i).BoundingBox(2)) floor(flats(i).BoundingBox(2)+flats(i).BoundingBox(4))];

            westPoints(westPoints==0)=1;
            southPoints(southPoints==0)=1;
            flats(i).BoundingBox(flats(i).BoundingBox<1)=1;
            

            %find what facets the bounding line grid cells belong to            
            westPixels = intFacet(floor(flats(i).BoundingBox(2)),westPoints(1):westPoints(2) );
            southPixels = intFacet(southPoints(1):southPoints(2),floor(flats(i).BoundingBox(1)));

            %find the mode of the facets on the west and south sides
            modeWest = mode(westPixels);
            modeSouth = mode(southPixels);

            %find current object grid points
            inds = find(imageObjects==i);

            %merge if the mode of the south pixels is not flat and if the
            %current flat is oriented less than 45 degrees
            if(abs(flats(i).Orientation)<=45 && modeSouth ~= 5)
                %merge into South slope
                intFacet(inds) = modeSouth;
            else  %else merge into whatever is along the west bounding box
                %merge into West slope
                intFacet(inds) = modeWest;
            end

        end %end ratio if-statement
    end %end flat loop

    %set smoothElev non-land pixels to missing
    smoothElev(grid.mask<=0) = -999;
    gradNorth(grid.mask<=0) = -999;
    gradEast(grid.mask<=0) = -999;

    intFacet(grid.mask<=0) = -999;

    %define output varibles
    aspects.smoothDEM = smoothElev;
    aspects.gradNorth = gradNorth;
    aspects.gradEast = gradEast;
    aspects.facets = intFacet;


end %end function
