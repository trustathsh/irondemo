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
	$ENV{'IFMAP_USER'} = $data->{'ifmap-user'};
	$ENV{'IFMAP_PASS'} = $data->{'ifmap-pass'};

	chdir($ifmapcli_path) or die "Could not open directory $ifmapcli_path: $! \n";
	
	system("java -jar auth-by.jar delete $access_request $pdp");
	system("java -jar ar-mac.jar delete $access_request $mac");

	
}

sub init {
	my $self = shift;
	my $args = shift;
	
	$self->{'data'} = $args;
}

1;