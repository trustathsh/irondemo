irondemo
========
irondemo is a set of shell and Perl scripts as well as some resources, to build a environment containing our IF-MAP based software from scratch.
Development was done by Hochschule Hannover (Hannover University of Applied Sciences and Arts).

Prerequisites
=============
Prior to use irondemo, you must download and install the following software:
* [Git][git]
* a [Java JDK (1.7)][java]
* and [Maven 3][maven]

At the moment, irondemo supports Linux and Mac OS X. (We will change the existing Shell scripts to Perl in the future to also support Windows system).


Structure
========
It mainly consists of several folders, with the following content/functionality:

config/
-------
Contains information about how to get and build the different software packages; currently supports: 
	* ifmapj (and examples)
	* ifmapj-examples
	* ifmapcli
	* irond
	* irongui
	* irondetect
	* irondhcp
	* ironvas
	* and VisITMeta

scripts/
--------
Contains scripts to download all sources, build them, create the provided scenarios (by copying all needed binaries and resources to the specific folder unter *scenarios*), as well as scripts to install Android SDK, create a virtual Android machine and administrate this (start, stop, install our Android-based software, ...)

scenarios/
----------
Contains scripts to *play* different scenarios with our tools; the scripts are numbered and will start all components and create the metadata needed for that specific scenario

resources/
----------
Contains resources needed for the scenarios (configurations, etc.)

sources/
--------
Here all sourcecode and the compiled binaries will reside; is created during first run of the `1_update_sources.pl` script.

Building
========
To use irondemo, simply download it via 

	$ git clone https://github.com/trustatfhh/irondemo.git

and run the first two scripts in the `scripts` directory; 

	$ perl 01_update_sources.pl
	$ perl 02_build_sources.pl

you will end up with compiled versions of our software within the `sources` folder.

Using the scenarios
===================
After you downloaded the sources and build the binaries, you can build the provided scenarios.
Inside the `scripts` directory, you will find the scripts starting with a number `3`.
They will
* copy all needed binaries from the `source` folder into the folder of the specific scenario (according to which scenario-build-script you run)
* copy all resources for that specific scenario from the `resources` folder into the according folders of the needed tools for that scenario (i.e. irond configuration into the irond-folder)

The idea behind that is, that you will end up in folders for every scenario, packed with everything you need for that scenario.
If you make changes in files for that scenario, it won't affect the other scenarios, and you can just archive a scenario-folder and execute it anywhere with the specific versions of the used software.

Update the sources
==================
Simply re-run the scripts mentioned in Building, and you will have the latest **stable** versions of our software downloaded and build.

If you want to use the new versions with the scenarios, make sure you re-run the proper `build the scenario` script, as it will copy the binary into the specific scenario folder.


Contact
=======
Please contact us via <trust@f4-i.fh-hannover.de> if you have any questions.

---

[1]: https://github.com/trustatfhh/irondemo
[git]: http://git-scm.com/
[java]: http://www.oracle.com/technetwork/java/javase/downloads/index.html
[maven]: http://maven.apache.org/
