#! /usr/bin/perl
#--------------------------------------
# name: update_sources.sh
# version 0.1
# date 04-06-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

my($input, $project, @commands, %return);

if (!-d "../sources") {
	mkdir("../sources");
}

chdir('../sources/');

if(chdir('.git') != 1){
  system("git init");
}else {
  chdir('../');
}

open($input,"../config/sources.conf") || die $!;

while(<$input>){
  @commands = split(/;/,$_);
  $project = $commands[0];
  shift @commands;
  
  print "||||| Find project: $project |||||\n\n";
  my $exist = chdir('./' . $project);
  
  if($exist != 1){
    system("git clone http://github.com/trustatfhh/" . $project . ".git");
    chdir('./' . $project);
  }

  for (@commands){
      $return{$project} = system($_);
  }
  
  print "\n";
  print "||||| Project: $project finished, $return{$project}\n\n";
  chdir('../');
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