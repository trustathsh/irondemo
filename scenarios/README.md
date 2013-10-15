irondemo
========
irondemo is a set of shell and Perl scripts as well as some resources, to build a environment containing our IF-MAP based software from scratch.
Development was done by Hochschule Hannover (Hannover University of Applied Sciences and Arts).

Using the scenarios
===================
After you downloaded the sources and build the binaries, you can build the provided scenarios.
Inside the `scripts` directory, you will find the scripts starting with a number `3`.
They will
* copy all needed binaries from the `source` folder into the folder of the specific scenario (according to which scenario-build-script you run)
* copy all resources for that specific scenario from the `resources` folder into the according folders of the needed tools for that scenario (i.e. irond configuration into the irond-folder)

The idea behind that is, that you will end up in folders for every scenario, packed with everything you need for that scenario.
If you make changes in files for that scenario, it won't affect the other scenarios, and you can just archive a scenario-folder and execute it anywhere with the specific versions of the used software.

scenario 1
----------
A device connects to network and the dhcp server sends request for investigation.

Used software:

	* irond
	* irondetect
	* irongui
	* ironcontrol (on virtual device)
	* ifmapcli
	* VisITMeta

scenario 2
----------
A simple example to show some metadata in VisITMeta or ironcontrol.

Used software:

	* irond
	* irongui
	* ironcontrol (on virtual device)
	* ifmapcli
	* VisITMeta
	

Contact
=======
Please contact us via <trust@f4-i.fh-hannover.de> if you have any questions.

---

[1]: https://github.com/trustatfhh/irondemo
[git]: http://git-scm.com/
[java]: http://www.oracle.com/technetwork/java/javase/downloads/index.html
[maven]: http://maven.apache.org/
