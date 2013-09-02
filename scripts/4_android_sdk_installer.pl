#!/usr/bin/perl
#--------------------------------------
# name: 4_android_sdk_installer.pl
# version 0.1
# date 26-08-2013
# Trust@FHH
#--------------------------------------

use strict;
use warnings;
use LWP::Simple;

# Check if sudo rights
######################################
if($< != 0){
    print "Please type sudo $0 to use this.\n";
    exit 1;
}

#Download and install the Android SDK
######################################
if(! -d "/usr/local/android-sdk"){
  
  print "Android SDK not installed on /usr/local/android-sdk, start downloading....\n";
  
  # Download html site
  my $HTML_Zeile = get("http://developer.android.com/sdk/index.html");

  # Finde android SDK download link
  $HTML_Zeile =~ /"(http:\/\/dl.google.com.+linux.tgz)"/;
  my $lala = "$1";
  
  # Download and extract file
  system("wget $lala && tar --wildcards --no-anchored -xvzf android-sdk_*-linux.tgz");

  # Move dir
  system("mv android-sdk-linux /usr/local/android-sdk");
  system("chmod 777 -R /usr/local/android-sdk");
  
  # Delete android SDK file
  system("rm android-sdk_*-linux.tgz");
  
}else{

  print "Android SDK already installed to /usr/local/android-sdk.  Skipping.\n";

}

# Check if ADB is already installed
######################################
if(! -f "/usr/local/android-sdk/platform-tools/adb"){
  
  system("/usr/local/android-sdk/tools/android update sdk > /dev/null 2>&1 &");

}else{
  
  print "Android Debug Bridge already detected.\n";
  
}

# Check if the ddms symlink is set
######################################
if( -f "/bin/ddms"){
  system("rm /bin/ddms");
}

system("ln -s /usr/local/android-sdk/tools/ddms /bin/ddms");

#Check if the ADB environment is set
######################################
my $b = '0';
open(FILE, "/home/trustatfhh/.profile") or die $!;

while (<FILE>){
  if($_ =~ /(\/usr\/local\/android-sdk\/platform-tools)/){
    $b = '1';
  }
}
close(FILE);

if (!$b){
  open(FILE, ">>/home/trustatfhh/.profile") or die $!;
  print FILE "\nPATH=\$PATH:/usr/local/android-sdk/platform-tools";
  close(FILE);
  print "ADB environment is setup\n";
}else{
  print "ADB environment is set\n";
}
