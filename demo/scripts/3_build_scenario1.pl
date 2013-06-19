#!/usr/bin/perl
#--------------------------------------
# name: build_scenario1.sh
# version 0.1
# date 12-06-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;

my ($bundlePath);

my @projects = <"irond" "irondetect" "irongui" "visitmeta">;
my $scenario_prefix = "../scenarios/scenario1";
my $sources_prefix = "../sources";
my $resources_prefix = "../resources/scenario1/";

for (@projects) {

 $bundlePath = &getPath("Bundle", $_);
 
 system("unzip $bundlePath -d $scenario_prefix");
 
}

#ifmapcli

my $cliPath = &getPath("bin", "ifmapcli/ifmapcli-distribution");
&copy("-a", $cliPath, "/ifmapcli");

# copy config for irond
&copy("-a", "$resources_prefix/irond/basicauthusers.properties", "/irond/");

# copy policy for irondetect
&copy("-a", "$resources_prefix/irondetect/scenario1.pol", "/irondetect/policy/");

# copy config for irondetect
&copy("-a", "$resources_prefix/irondetect/configuration.properties", "/irondetect/");

# copy config for VisITMeta
&copy("-a", "$resources_prefix/visitmeta/config.properties", "/visitmeta/");

sub getPath {
  
  my @data;
  
  if($_[0] eq "Bundle") {
  
    @data = &grepBundleData($_[1]);
    
  } else {
  
    @data = grepBineData($_[1]);
    
  }

  if(@data == 1){
  
    return "$sources_prefix/$_[1]/target/$data[0]";
  
  }else {
  
    print "found to many  @data\n";
    
  }
}

sub grepBundleData {
  
  opendir(SOURCES, "$sources_prefix/$_[0]/target");
  my @data = grep /-bundle.zip$/, readdir(SOURCES);
  closedir(SOURCES);
  
  return @data;
}

sub grepBineData {
  
  opendir(SOURCES, "$sources_prefix/$_[0]/target");
  my @data = grep /-bin$/, readdir(SOURCES);
  closedir(SOURCES);
  
  return @data;
}

sub copy {
  system("cp $_[0] $_[1] $scenario_prefix$_[2]");
}