# TIER configuration files

TIER contains two configuration files that specifiy input/output files and directories and two parameter files that control the functionality of TIER via the model parameters. Example configuration and parameter files in the config/ directory give the file format, variable/parameter names, and brief descriptions.

### tierPreprocessControl.txt

This control file specifies the raw input DEM targeted for spatial processing by the TIER preprocessing software.  The input precipitation and temperature data are also used in the preprocessing to define metadata files used in the TIER model.  Finally the preprocessing parameter file is specified here.

Here is an overview of the varibles in the TIER preprocessing control file:

* **rawGridName**, raw domain DEM: This is the raw grid file including lat,lon,elevation,grid information, etc.  Follow the example file in in the grid/ directory when you download the example tarball.
* **outputGridName**, name of output processed grid:  This is the name of the output grid file that contains additional knowledge-based terrain processing fields used as input in the TIER model.
* **stationPrecipPath**, path to precipitation station data:   This is the path to the directory containing the precipitation data.  Follow the example files in the inputStations/ directory in the example tarball.
* **stationPrecipListName**, name of precipitation station list file preprocessing script will create: This is the name of the precipitation station metadata file that is created by the preprocessing script using the precipitation data and the processed grid.
* **stationTempPath**, path to temperature station data:  This is the path to the directory containing the temperature data.  Follow the example files in the inputStations/ directory in the example tarball.
* **stationTempListName**, name of temperature station list file preprocessing script will create: This is the name of the temperature station metadata file that is created by the preprocessing script using the temperature data and the processed grid.
* **preprocessParameterFile**, name of TIER preprocessing parameter file:  This is the name of the TIER preprocessing parameter file that contains all the TIER preprocessing model parameters.

### tierPreprocessParameters.txt

This parameter file determines the behavior of the spatial preprocessing routine.  The user can specify the spatial filter type for terrain smoothing, and other paramters determining facet definition. The user can also set other parameters related to other processed knowledge based geophysical attributes used by TIER.  This currently includes parameters related to the distance to the coast calculations, two-layer atmosphere placement, and topographic position.

Here is an overview of the varibles in the TIER preprocessing parameter file:

* **demFilterName**, filter type (Daly = original Daly et al. 1994 filter) - only option currently implemented:  This defines a smoothing filter to smooth the DEM before facet processing following Daly et al. (1994). Other filter types could be implemented if desired.
* **demFilterPasses**, number of passes to filter raw DEM:  The Daly et al. (1994) filter is run iteratively.  This defines the number of passes.
* **minGradient**, minimum gradient for a pixel to be considered sloped - otherwise it is considered flat:  Facets are only on sloped terrain, flat areas are everywhere else.  This defines the minimum gradient to be considered sloped in units of m/km.
* **smallFacet**, area of smallest sloped facet allowed (km^2): Smallest facet area allowed.  Smaller areas are merged with neighboring facets.
* **smallFlat**, area of smallest flat facet allowed (km^2):  Smallest flat facet area allowed.  Smaller areas are merged with neighboring facets.
* **narrowFlatRatio**, ratio of major/minor axes to merge flat regions (i.e. ridges):  If the flat facet is very narrow (elongated) with a large major/minor axis ratio, treat it as a ridge and merge with neighboring sloped facets.
* **layerSearchLength**, search length (grid cells) to determine local minima in elevation:  This is used in determining the topographic position.  The search length defines the number of grid points (width of a square) to search to find the local minima to set the local topographic position.  See Daly et al. (2002) for more detals.
* **inversionHeight**, depth of layer 1 (inversion layer) in m:  Depth of the lower layer in an idealized 2-layer atmosphere.  The lower layer identifies areas susceptible to temperature inversions and allows for different temperature lapse rates in those areas. See Daly et al. (2002) for more details.

### tierControl.txt

This control file defines the processed input grid file, the input station data and metadata files, which variable is being processed (precip, tmax, tmin), the output file and if TIER will use a user defined input spatial default temperature lapse rate.

Here is an overview of the varibles in the TIER model control file:

* **gridName**, domain file name:  This is the name to the preprocessed domain file
* **variableEstimated**, name of meteorological variable estimated (precip, tmax, tmin)
* **stationFileList**, name of variable specific (e.g. precip or tmax/tmin)  file with list of input station files:  Name of the station metadata file for the specified variable to be processed
* **stationDataPath**, path to station data:  Path to the input station data directory
* **outputName**, name of output file:  Name of the TIER model output file that contains the spatially distributed field, uncertainty information, etc.  
* **parameterFile**, name of TIER parameter file: The name of the TIER model parameter file that contains all the TIER model parameters.
* **defaultTempLapse**, name of default temperature lapse rate file. if not used set as empty string:  Name of input file for specifying user defined spatially variable default temperature lapse rates.

### tierParameters.txt

This parameter file controls the TIER model behavior.  There are parameters for all of the various knowledge-based components of TIER.

Here is an overview of the varibles in the TIER model parameter file:

* **nMaxNear**, maximum number of nearby stations to consider for the TIER model:  This defines the maximum number of stations used in the various TIER weighting components.
* **nMinNear**, minimum number of nearby stations needed for slope regression:  This defines the minimum number of stations required to perform the elevation-station weighted linear regression (e.g. Daly et al. 1994).
* **maxDist**, maximum distance to consider stations (km):  Maximum distance from current grid point a station can be to be included in the model.
* **minSlope**, minimum valid slope value (normalized for precipitation; physical units for temperature): Threshold for the minimum allowable slope for the elevation-variable relationship (typically around 0-0.5 for precipitation, -10 K/km for temperature - which is the adiabatic lapse rate) 
* **maxInitialSlope**, maximum valid initial pass normalized slope for precipitation: Maximum normalized slope for precipitation on the first pass.  Precipitation is solved iteratively and larger slopes are allowed on the first pass.
* **maxFinalSlope**, maximum valid final adjusted normalized slope for precipitation:  Maximum normalized slope for the final precipitation field.  After the initial precipitation guess, the slope and precipitation fields are smoothed, which will reduce noise and spurious slope values, thus the maximum allowed is typically reduced.
* **maxSlopeLower**, maximum valid slope for temperature (K/km) in lower atmospheric layer (inversion layer; allows for strong inversions):  Maximum slope for temperature in the inversion layer.  Typically this is a large positive value to allow for strong inversions.
* **maxSlopeUpper**, maximum valid slope for temperature (K/km) in upper layer (free atmosphere; up to isothermal allowed):  Maximum slope in the 'free' atmosphere layer.  Typically there are few if any inversions in the free atmosphere, sometimes it is around isothermal, thus 0 is recommended for the upper layer maximum slope.
* **defaultSlope**, default slope value (normalized for precipitation; physical units for temperature): Default slope value for precipitation or temperature if the regression cannot find a valid value (e.g. Daly et al. 1994).  This is overridden if the user specifies an input temperature lapse rate file.  The updatePrecipSlope function also overrides the spatially constant default slope defined here.
* **topoPosMinDiff**, minimum elevation (m) difference used to adjust topographic position weights (m) (Daly et al. 2007)
* **topoPosMaxDiff**, maximum elevation (m) difference for stations to receive topographic position weighting (m) (Daly et al. 2007)
* **topoPosExp**, exponent to adjust topographic position weighting function (Daly et al. 2007)
* **coastalExp**, exponent to adjust distance to coast weighting function (Daly et al. 2002)
* **layerExp**, exponent to adjust atmospheric layer weighting function (Daly et al. 2002)
* **distanceWeightScale**, scale parameter in Barnes (1964) distance weighting function used in SYMAP base interpolation
* **distanceWeightExp**, exponent in Barnes (1964) distance weighting function used in SYMAP base interpolation
* **maxGrad**, maximum allowable normalized precipitation slope gradient between grid cells (Daly et al. 1994)
* **bufferSlope**, a buffer parameter when computing precipitaiton slope feathering
* **minElev**, minimum elevation (m) considered when feathering precipitation (m): Feathering generally follows Daly et al. (1994) but that specific implementation is unknown.  This is included here to prevent excessive feathering in low (typically flat) areas
* **minElevDiff**, minimum elevation (m) difference across grid cells considered for feathering precipitation (m): Again added here specifically to only feather precipitation in complex terrain.
* **recomputeDefaultPrecipSlope**, logical string to indicate re-estimation of the default slope using domain specific information
* **recomputeDefaultTempSlope**, logical string to indicate re-estimation of the default slope using domain specific information
* **filterSize**, size of low pass filter (grid points) used in computing updated slopes and uncertainty estimates: Filter parameters for low pass filtering of initial noisy slope and uncertainty estimates.  This controls the Gaussian filter width in grid points.  Larger values increase the smoothing.
* **filterSpread**, spread of low-pass filter power used in computing updated slopes and uncertainty estimates: The spread of the Gaussian filter.  Larger values increase the smoothing.
* **covWindow**, window (grid cells) for local covariance calculation for the SYMAP and slope uncertainty components.  Used in the final uncertainty estimation routine
