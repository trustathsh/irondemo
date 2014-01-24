package TrustAtHsH::Irondemo::Modules::UserLogout;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractModule';

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
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
	#TODO check system's exit statuses and return something meaningful
	
}

### INTERNAL UTILITY ###
# Purpose     :
# Returns     :
# Parameters  : data ->
#                 ifmap-user          ->(optional)
#                 ifmap-pass          ->(optional)
#                 ifmap-url           ->(optional)
#                 ifmap-keystore-path ->(optional)
#                 ifmap-keystore-pass ->(optional)
#                 name                 >
#                 role                ->
#                 access-request      ->
#
sub _init {
	my $self = shift;
	my $args = shift;
	
	#TODO should check if needed parameters have been defined or set defaults 
	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

#to be removed
sub ifmapcliOptions {
	my $self = shift;
	return "$self->{'data'}->{'ifmap-url'} $self->{'data'}->{'ifmap-user'} $self->{'data'}->{'ifmap-pass'} $self->{'data'}->{'ifmap-keystore-path'} $self->{'data'}->{'ifmap-keystore-pass'}";
}

1;