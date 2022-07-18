# TIER output netcdf file

The TIER model will create a netcdf-4 output file.  This file contains the final distributed metorological field along with uncertainty estimates, and many intermediate variables that may (or may not) be of interest to the user.

The key output variables are:

* **finalField**: This is the final spatially distributed meteorological field
* **totalUncert**:  This is the total estimated uncertainty from the TIER model in physical units (mm or K).  The total uncertainty is a combination of the base SYMAP interpolation and the elevation-slope uncertainty with an accounting for spatial covariance between the two components.
* **relUncert**:  This is the relative uncertainty.
* **symapUncert**:  This is the estimated uncertainty from the base SYMAP spatial interpolation in physical units (mm or K).
* **slopeUncert**:  This is the estimated uncertainty from the TIER elevation-slope weighted regression in physical units (mm or K).


The other fields are intermediate variables that are generated through the various TIER model steps and are briefly described in the following summary of the output file.  Their meaning can also be found throughout the TIER code and in the TIER paper (Newman 2019)

```
netcdf exampleOutput {
dimensions:
	latitude = 128 ;
	longitude = 136 ;
variables:
	double rawField(longitude, latitude) ;
		rawField:_FillValue = -999. ;
		rawField:name = "raw variable output" ;
		rawField:long_name = "Raw variable output before slope and gradient adjustments" ;
		rawField:units = "mm/day" ;
	double intercept(longitude, latitude) ;
		intercept:_FillValue = -999. ;
		intercept:name = "intercept parameter" ;
		intercept:long_name = "Intercept parameter from the variable-elevation regression" ;
		intercept:units = "mm/day" ;
	double slope(longitude, latitude) ;
		slope:_FillValue = -999. ;
		slope:name = "variable elevation slope" ;
		slope:long_name = "Raw variable elevation slope before slope adjustments" ;
		slope:units = "mm/km" ;
	double normSlope(longitude, latitude) ;
		normSlope:_FillValue = -999. ;
		normSlope:name = "normalized variable slope" ;
		normSlope:long_name = "normalized variable elevation slope before slope adjustments(valid for precipitation only)" ;
		normSlope:units = "km-1" ;
	double symapField(longitude, latitude) ;
		symapField:_FillValue = -999. ;
		symapField:name = "SYMAP estimate" ;
		symapField:long_name = "SYMAP estimated variable values on grid" ;
		symapField:units = "mm/day" ;
	double symapElev(longitude, latitude) ;
		symapElev:_FillValue = -999. ;
		symapElev:name = "SYMAP weighted elevation" ;
		symapElev:long_name = "Grid point elevation estimate using station elevations and SYMAP weights" ;
		symapElev:units = "m" ;
	double symapUncert(longitude, latitude) ;
		symapUncert:_FillValue = -999. ;
		symapUncert:name = "SYMAP uncertainty" ;
		symapUncert:long_name = "Uncertainty estimate from the SYMAP variable estimate" ;
		symapUncert:units = "mm/day" ;
	double slopeUncert(longitude, latitude) ;
		slopeUncert:_FillValue = -999. ;
		slopeUncert:name = "slope uncertainty" ;
		slopeUncert:long_name = "Uncertainty estimate (physical space) resulting from the variable-elevation slope estimate" ;
		slopeUncert:units = "mm/day" ;
	double normSlopeUncert(longitude, latitude) ;
		normSlopeUncert:_FillValue = -999. ;
		normSlopeUncert:name = "normalized slope uncertainty" ;
		normSlopeUncert:long_name = "Uncertainty estimate (normalized) resulting from the variable-elevation slope estimate(valid for precipitation only)" ;
		normSlopeUncert:units = "km-1" ;
	double defaultSlope(longitude, latitude) ;
		defaultSlope:_FillValue = -999. ;
		defaultSlope:name = "default slope" ;
		defaultSlope:long_name = "default elevation-variable slope estimate" ;
		defaultSlope:units = "mm/km" ;
	double finalSlope(longitude, latitude) ;
		finalSlope:_FillValue = -999. ;
		finalSlope:name = "final slope" ;
		finalSlope:long_name = "Final variable elevation slope after slope adjustments" ;
		finalSlope:units = "mm/km" ;
	double finalField(longitude, latitude) ;
		finalField:_FillValue = -999. ;
		finalField:name = "final variable output" ;
		finalField:long_name = "Final variable output after slope and gradient adjustments" ;
		finalField:units = "mm/day" ;
	double totalUncert(longitude, latitude) ;
		totalUncert:_FillValue = -999. ;
		totalUncert:name = "total uncertainty" ;
		totalUncert:long_name = "total uncertainty in physical units" ;
		totalUncert:units = "mm/day" ;
	double relUncert(longitude, latitude) ;
		relUncert:_FillValue = -999. ;
		relUncert:name = "relative uncertainty" ;
		relUncert:long_name = "relative total uncertainty" ;
		relUncert:units = "-" ;
	double validRegress(longitude, latitude) ;
		validRegress:_FillValue = -999. ;
		validRegress:name = "valid regression" ;
		validRegress:long_name = "flag denoting the elevation-variable regression produced a valid slope" ;
		validRegress:units = "-" ;
}
```
