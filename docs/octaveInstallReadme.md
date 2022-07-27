# To run TIER with Octave

## Install Octave on your local machine

 * Mac: Prepackaged disk images can be found at: https://octave-app.org/Download.html or Octave can be installed using homebrew (https://brew.sh/).

 * Linux: Various Linux distributions support octave using apt or dnf for Red Hat (https://wiki.octave.org/Octave_for_GNU/Linux). 

 * Windows: Binaries are available at :https://ftp.gnu.org/gnu/octave/windows/ See: https://wiki.octave.org/Octave_for_Microsoft_Windows for more details

## Install Packages
Once Octave is installed properly there are three packages required to run TIER.  These are the mapping, image, and netcdf packages.  These can be installed in Octave using:

        pkg install -forge package_name

 * Or see: https://octave.org/doc/v4.4.1/Installing-and-Removing-Packages.html
 * Available packages for Octave can be found at: https://octave.sourceforge.io/packages.php

## Configure Octave
For each startup the user needs to load the packages and add TIER to your path using addpath before running TIER, or modify ~/.octaverc to contain:

        pkg load netcdf
        pkg load mapping
        pkg load image
        addpath(genpath("path/To/TIER"))

## 4) Run TIER


# Compatibility testing:

Tested on a Mac running HighSierra OS10.13.6 using Octave binaries for x86_64-apple-darwin15.6.0, Octave v4.4.1.

Binaries from https://octave-app.org/Download.html

### Package testing:

mapping v1.2.1
image v2.10.0
netcdf v1.0.12

