irondemo
========
irondemo is intended to make creation of demonstration and testing environments for if-map software easy and consistent, it is developed by the [Trust@HsH research group][trustathsh] at Hochschule Hannover (Hannover University of Applied Sciences and Arts).

NOTE: This is an alpha-release - might still contain a couple of bugs.

Prerequisites
=============
In order to use irondemo, you will need the following software installed on your system:
* [Git][git]
* a [Java JDK (1.7)][java]
* and [Maven 3][maven]
* [Perl 5][perl]
* The following Perl modules:
	-Module::Install
	-File::Spec
	-Getopt::Long
	-File::Basename
	-Pod::Usage

irondemo should work on any unix based system as well as Microsoft Windows. If you experience problems on your platform, please report.

Structure
========
Irondemo's directory structure is organized as follows:

config/
-------
Contains irondemo's project config file **projects.yaml**, that contains instructions how to retrieve and built different tools (called *projects* ) which can be combined to create different *scenarios*. Theoretically any third party tool can be integrated pretty easily. Feel free to get in touch if you want your tool to be included in the default configuration file. Currently the default configuration includes: 
	* ifmapj
	* ifmapj-examples
	* ifmapcli
	* irond
	* irongui
	* irondetect
	* irondhcp
	* ironvas
	* visitmeta

The **modules.yaml** configuration file contains configuration properties for executable *modules* used in irondemo. Modules define vocabulary to be used in *agendas*, i.e. they carry out operations that you can use to put together a demonstration, simulation, test case ... you name it. You can easily build your own modules, just take a look at our modules in the /scripts/lib/ directory for examples or get in touch if you need help.

The **scenarios** subdirectory contains one yaml file per scenario that contains instructions which projects a scenario uses, which resources need to be copied, etc.

scripts/
--------
Contains the irondemo main script and (as of now) the irondemo perl module that takes care of most of irondemo's tasks - we might migrate the latter to CPAN at some point.

scenarios/
----------
This is where the scenarios get assembled. Each scenario is constructed in a dedicated subdirectory for the sake of isolation.

resources/
----------
Contains the scenarios' resources such as config files for various tools, etc.

sources/
--------
Sourcecode and the compiled binaries of projects reside here.

Building
========
Download:
	$ git clone https://github.com/trustatfhh/irondemo.git

Install dependencies:
	$ cd <irondemo root>/scripts/lib/TrustAtHsH-Irondemo/
	$ perl Makefile.PL
	$ make installdeps

Fetch and build the projects' sources:
	$ cd <irondemo root>/scripts/
	$ perl irondemo.pl update_projects
	$ perl irondemo.pl build_projects

Using the scenarios
===================
After downloading and compiling the sources, you can build the scenarios. Call `$ irondemo.pl build_scenarios <scenario>` providing the name of the scenario you would like to built (which is identical to the name of its config file without the file ending). The corresponding scenario will be assembled in the scenarios directory.

Updating the sources
====================
Just re-run the last step of the instructions for building irondemo. This will update the sources and build them. You will need to also rebuilt any scenarios using the projects that got updated if you want them to make use of the new versionsn.

More Information
================
Try `$ irondemo.pl --man` or just ask the devs ;)

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
