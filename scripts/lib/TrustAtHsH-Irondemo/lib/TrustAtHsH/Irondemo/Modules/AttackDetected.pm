package TrustAtHsH::Irondemo::Modules::AttackDetected;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use lib '../../../';
use TrustAtHsH::Irondemo::SimuUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';

my $SERVICE   = 'service';
my $HOST      = 'host';
my $PORT      = 'port';
my $SOURCE_IP = 'source-ip';
my $RULE      = 'rule';
my $REF_TYPE  = 'ref-type';
my $REF_ID    = 'ref-id';
my $COMMENT   = 'comment';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ( $SERVICE, $HOST, $PORT, $RULE, $SOURCE_IP );

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};
	my $result = 1;
	
	my ( %service, %ip, %meta_attack_detected );
	
	%service = ( extended =>
	  TrustAtHsH::Irondemo::SimuUtilities->create_string_id_service({
	    type     => $data->{$SERVICE},
	    name     => $data->{$HOST},
	    port     => $data->{$PORT},
	  })
	);
	
	$ip{'standard'}-> {'type'}  = 'ipv4';
	$ip{'standard'}-> {'value'} = $data->{$SOURCE_IP};
	
	%meta_attack_detected = ( extended =>
	  TrustAtHsH::Irondemo::SimuUtilities->create_string_meta_attack_detected({
	    rule     => $data->{$RULE},
	    ref_type => $data->{$REF_TYPE},
	    ref_id   => $data->{$REF_ID},
	    comments => $data->{$COMMENT},
	  })
	);
	
	$result &= $self->publish($data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%ip, \%meta_attack_detected, \%service );
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
# Returns     :LoginFailed
# Parameters  : data ->
#                 ifmap-user          ->(optional)
#                 ifmap-pass          ->(optional)
#                 ifmap-url           ->(optional)
#                 ifmap-keystore-path ->(optional)
#                 ifmap-keystore-pass ->(optional)
#
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;