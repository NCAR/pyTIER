## TIER tutorial and example cases

An example domain over the Sierra Nevada along the west coast of USA is provided at (web link TBD).  This example includes configuration and parameter files, the raw domain file, input station data files, and several reference output files for comparisons to make sure TIER is functioning on the users system.

The configuration files will need to be updated for the user defined paths, file names, etc.  The parameter files include default values for this case.  Suggested changes to the parameter files are made in several places in this readme.

To run the example we assume TIER is installed on your system.  

### TIER topographic preprocessing

Once you have the example tarball downloaded and unpacked using tar (e.g. `tar -xvf tierExample.tgz`), set the preprocessing configuration variables in `tierPreprocessControl.txt` to the appropirate paths and file names. See the [Config readme](configReadme.md) for details.
It is suggested that you set the output grid name to something different than the reference output grid file provided.
 
Then the run tierPreprocessing.m in Matlab or Octave.  The preprocessing script will use `tierPreprocessParameters.txt` to define user specified values.  If any parameters do not exist in the parameter file, default values are used (set in `preprocess/preprocess.ipynb in the initPreprocessParameters function`).

The script will print various diagnostics and will generate the output grid file specified in the preprocessing control file.
Once the preprocessing is finished a brief comparison between your and the reference processed grid file is suggested to make sure the various fields are the same.  A program like ncview (http://meteora.ucsd.edu/~pierce/ncview_home_page.html) can be used for this.


### TIER Model

Once the preprocessing is finished, set the configuration variables in `tierControl.txt` to the appropriate paths and files.  See the [Config readme](configReadme.md) for details.

The TIER model can now be run with tierDriver.m in Matlab or Octave.  All three variables can be interpolated: `precip, tmax, or tmin`.
The `tierParameter.txt` file will be used to define the TIER model parameter values.  Again, if any parameters do not exist in this parameter file, default values are used (`tierModel/tierDriver.ipynb in the initPreprocessParameters function`).

Again, various diagnostics will print while the model is running.  The output file will be generated at the user specified location and name.  It is suggested to make sure the output name is different from the provided reference output files.
It is also suggested to note which variable is interpolated (e.g. have precip, tmax, tmin) in the output file name.

Once the TIER model is complete, the user is encouraged to compare their output with the reference files to see if the reference output is reproducible.


## TIER Parameter Variations

There are many methodological decisions made when developing a spatial map of a meteorological variable from sparse observations.  Here we explore a few parameters in the TIER model only to identify changes in the final estimated values and the corresponding uncertainty.

Note that the preprocessing parameters will also impact the final result through changes in the definition of facets, and changes in the other knowledge-based geophysical attributes.  The user is encouraged to explore those parameters as well.

### First
For precipitation, modify the `nMaxNear` parameter from 10 to 13.

This increases the maximum number of stations that can be considered at each grid point by 30%.  In this case the final estimated precipitation is generally changed within +/- 20% of the base case.  There are a few areas with larger relative changes, even in areas of large accumulation.
However, the uncertainty estimate is significantly changed with the additional data for each grid point.  More stations results in a decreased uncertainty estimate across nearly the entire domain.

### Second
For precipitation, modify the `coastalExp` parameter from 0.75 to 1.0.

This decreases the station weighting for stations with dissimilar coastal proximity to the current grid point.

### Third

For tmin, modify the `distanceWeightExp` parameter from 2 to 1.75.  This modifies the shape of the Barnes inverse distance weight curve to have a shallower slope, giving more weight to stations further away.

