package TrustAtHsH::Irondemo::Modules::IronDhcpEntry;

use 5.16.0;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';

my $DISCOVERER_DEVICE = 'discoverer';
my $IP                = 'ip';
my $MAC               = 'mac';
my $IFMAP_USER        = 'ifmap-user';
my $IFMAP_PASS        = 'ifmap-pass';

my @REQUIRED_ARGS = ( $DISCOVERER_DEVICE, $IP, $MAC );

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

    my $result = 1;
    
    my @argsListDiscBy = ( "ipv4", $data->{$IP}, $data->{$DISCOVERER_DEVICE} );
    my @argsListIpMac  = ( $data->{$IP}, $data->{$MAC} );

	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

    $result &= $self->call_ifmap_cli(
    	{
    		'cli_tool'        => "disc-by",
    		'mode'            => "update",
    		'args_list'       => \@argsListDiscBy,
    		'connection_args' => $connectionArgs
    	}
    );
    
    $result &= $self->call_ifmap_cli(
        {
            'cli_tool'        => "ip-mac",
            'mode'            => "update",
            'args_list'       => \@argsListIpMac,
            'connection_args' => $connectionArgs
        }
    );
    
    return $result;

}

### INSTANCE METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_required_arguments {
	my $self = shift;

	return @REQUIRED_ARGS;
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
#                 ip                  ->
#                 mac                 ->
#                 discoverer          ->
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ( $key, $val ) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;
