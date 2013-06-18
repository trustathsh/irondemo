#! /usr/bin/perl
#--------------------------------------
# name: build_sources.sh
# version 0.1
# date 04-06-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

my($input, $project, @commands, %return);

chdir('..');
open($input,"config/build.conf") || die $!;

while(<$input>){
  @commands = split(/;/,$_);
  $project = $commands[0];
  shift @commands;
  
  print "[BUILD-SCRIPT] Find project: $project, build...\n\n";
  chdir('./sources/' . $project);

  for (@commands){
      $return{$project} = system($_);
  }
  
  print "\n";
  print "[BUILD-SCRIPT] ...build finished, " . $return{$project} . "\n\n";
  chdir('../../');
}

close $input;

for my $key ( keys %return) {
  my $value = $return{$key};
  if($value != "0"){
    print "WARNING! Project: " . $key . ", has failed!\n";
  }else {
    print "Project: " . $key . ", is OK.\n";
  }
}