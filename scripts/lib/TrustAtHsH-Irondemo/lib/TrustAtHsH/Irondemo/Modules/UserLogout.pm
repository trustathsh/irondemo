package TrustAtHsH::Irondemo::Modules::UserLogout;

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
	
	my $name = $data->{'name'};
	my $role = $data->{'role'};
	my $access_request = $data->{'access-request'};
	$self->{'ifmap-user'} = $data->{'ifmap-user'};
	$self->{'ifmap-pass'} = $data->{'ifmap-pass'};

	chdir($ifmapcli_path) or die "Could not open directory $ifmapcli_path: $! \n";
	
	system("java -jar auth-as.jar delete $access_request '$name' ".$self->ifmapcliOptions);
	system("java -jar role.jar delete $access_request '$name' $role ".$self->ifmapcliOptions);
	
}

sub init {
	my $self = shift;
	my $args = shift;
	
	$self->{'data'} = $args;
}

1;