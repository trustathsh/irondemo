scenario 1
==========
This scenario simulates a smartphone that connects to a network and retrieves an ip-address via
dhcp. An app on the smartphone (simulated by ifmapcli) publishes information about the installed 
app. Irondhcp (simulated by ifmapcli) publishes information about the client along with a request
for investigation. Ironvas (simulated by ifmapcli) that subscribes to request for investigation 
metadata performs a vulnerability scan and publishes the results. Irondetect evaluates the 
information about the smartphone (properties of certain apps, open port) and raises an alarm that
indicates that the smartphone contains a malicious app. Irongui and/or visitmeta can be used to
visualize the data on the MAP-Server.

Used software:

	* irond
	* irondetect
	* irongui
	* ifmapcli
	* visitmeta


Simulated by ifmapcli:

	* ironvas
	* irondhcp
	* ESUKOM Android IF-MAP Client
