#!/usr/bin/perl
#--------------------------------------
# name: clean_sources.pl
# version 0.1
# date 04-06-2013
# autor Trust@FHH
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

my(@projects, $command, %return);

$command = "mvn clean";

chdir('..');
opendir(SOURCES, "sources");

@projects = grep ! /^\./, readdir(SOURCES);

foreach (@projects) {
  print "[CLEAN-SCRIPT] Find project: " . $_ . ", clean...\n\n";
  chdir('./sources/' . $_);
  $return{$_} = system("$command");
  print "\n";
  print "[CLEAN-SCRIPT] ...clean finished, " . $return{$_} . "\n\n";
  chdir('../../');
}

for my $key ( keys %return) {
  my $value = $return{$key};
  if($value != "0"){
    print "WARNING! Project: " . $key . ", has failed!\n";
  }else {
    print "Project: " . $key . ", is clean.\n";
  }
}

closedir(SOURCES);