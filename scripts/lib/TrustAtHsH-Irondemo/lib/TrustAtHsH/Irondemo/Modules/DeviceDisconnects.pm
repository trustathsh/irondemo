package TrustAtHsH::Irondemo::Modules::DeviceDisconnects;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;

use Data::Dumper;

use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractModule';

sub execute {
	my $self = shift;
	my $data = $self->{'data'};
	
	my $ifmapcli_path = File::Spec->catdir($ENV{'HOME'}, "ifmapcli");
	
	my $pdp = $data->{'pdp'};
	my $access_request = $data->{'access-request'};
	my $mac = $data->{'mac'};
	my $ip = $data->{'ip-address'};

	chdir($ifmapcli_path) or die "Could not open directory $ifmapcli_path: $! \n";
	
	# PDP
	$ENV{'IFMAP_USER'} = $data->{'ifmap-user-pdp'};
	$ENV{'IFMAP_PASS'} = $data->{'ifmap-pass-pdp'};
	system("java -jar auth-by.jar delete $access_request $pdp");
	system("java -jar ar-mac.jar delete $access_request $mac");
	
	# DHCP
	$ENV{'IFMAP_USER'} = $data->{'ifmap-user-dhcp'};
	$ENV{'IFMAP_PASS'} = $data->{'ifmap-pass-dhcp'};
	system("java -jar ip-mac.jar delete $ip $mac");
	
}

sub init {
	my $self = shift;
	my $args = shift;
	
	$self->{'data'} = $args;
}

1;