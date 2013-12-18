irondemo
========
irondemo uses a set Perl scripts to build different scenarios/demo environments for the iron* software suite, various IF-MAP tools developed by the [Trust@HsH research group][trustathsh] at Hochschule Hannover (Hannover University of Applied Sciences and Arts).

NOTE: This is an alpha-release - might still contain a couple of bugs.

Prerequisites
=============
In order to use irondemo, you will need the following software installed on your system:
* [Git][git]
* a [Java JDK (1.7)][java]
* and [Maven 3][maven]
* [Perl 5][perl]
* The following Perl modules:
	-Archive::Extract
	-YAML

Irondemo should run on any unix based system as well as Microsoft Windows. If you experience problems on your platform, please report.

Structure
========
Irondemo's directory structure is organized as follows:

config/
-------
Contains irondemo's main config file projects.yaml, that contains instructions how to retrieve and build the iron* suite's sources. Currently includes: 
	* ifmapj
	* ifmapj-examples
	* ifmapcli
	* irond
	* irongui
	* irondetect
	* irondhcp
	* ironvas
	* visitmeta
Also contains one file per scenario that contains instructions how the scenario is assembled.

scripts/
--------
Contains the irondemo scripts to download and build the sources and assemble the scenarios.

scenarios/
----------
This is the place where the scenarios are assembled. Contains a dedicated subdirectory for each scenario.

resources/
----------
Contains the scenarios' resources such as config files for various tools, etc.

sources/
--------
Sourcecode and the compiled binaries reside here; is created during first run of the `update_sources.pl` script.

Building
========
To use irondemo, simply download it via 

	$ git clone https://github.com/trustatfhh/irondemo.git

and run `update_sources.pl` and `build_sources.pl` script from the `scripts` directory; 
you will end up with compiled versions of our software within the `sources` folder.

Using the scenarios
===================
After downloading and compiling the sources, you can build the scenarios. Simply call the `build_scenarios.pl` script from the scripts` directory providing the name of the scenario (which is identical to its config file). This will result in the scenario being assembled in the scenarios directory.

Updating the sources
==================
Simply re-run the scripts mentioned in Building, and you will have the latest **stable** versions of our software downloaded and build.

If you want to use the new versions with the scenarios, make sure you reconstruct the scenarios using the `build_scenarios.pl` script as well.


Contact
=======
Feel free to get in touch with us at <trust@f4-i.fh-hannover.de> to post feedback, ask for help or report bugs.

---

[1]: https://github.com/trustatfhh/irondemo
[git]: http://git-scm.com/
[java]: http://www.oracle.com/technetwork/java/javase/downloads/index.html
[maven]: http://maven.apache.org/
[perl]: http://www.perl.org/
[trustathsh]: http://trust.f4.hs-hannover.de
