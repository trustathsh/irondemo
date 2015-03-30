package TrustAtHsH::Irondemo::Modules::UnexpectedBehavior;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';

my $IDTYPE       = 'id-type';
my $IDENTIFIER   = 'identifier';
my $MODE	     = 'mode';
my $DISC_TIME    = 'disc-time';
my $DISC_ID      = 'disc-id';
my $MAGNITUDE    = 'magnitude';
my $CONFIDENCE   = 'confidence';
my $SIGNIFICANCE = 'significance';
my $TYPE         = 'type';
my $IFMAP_USER   = 'ifmap-user';
my $IFMAP_PASS   = 'ifmap-pass';

my @REQUIRED_ARGS = ( $IDTYPE, $IDENTIFIER, $MODE, $DISC_TIME, $DISC_ID);

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my @argsList = ( $data->{$IDTYPE}, $data->{$IDENTIFIER}, $data->{$DISC_TIME}, $data->{$DISC_ID},
		"--magnitude", $data->{$MAGNITUDE},
		"--confidence", $data->{$CONFIDENCE},
		"--significance", $data->{$SIGNIFICANCE},
		"--unexp-behavior-type", $data->{$TYPE} );

	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	return $self->call_ifmap_cli(
		{
			'cli_tool'        => "unexp-behavior",
			'mode'            => $data->{$MODE},
			'args_list'       => \@argsList,
			'connection_args' => $connectionArgs
		}
	);

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
#                 pdp            ->
#                 access-request ->
#                 mac            ->
#                 ip-address     ->
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ( $key, $val ) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
	$self->{'data'}->{$MAGNITUDE}    = "100"    	   unless defined $self->{'data'}->{$MAGNITUDE};
	$self->{'data'}->{$CONFIDENCE}   = "100"     	   unless defined $self->{'data'}->{$CONFIDENCE};
	$self->{'data'}->{$SIGNIFICANCE} = "critical"      unless defined $self->{'data'}->{$SIGNIFICANCE};
	$self->{'data'}->{$TYPE}         = "severe attack" unless defined $self->{'data'}->{$TYPE};
}

1;
