package TrustAtHsH::Irondemo::Modules::PolicyRule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use lib '../../../';
use TrustAtHsH::Irondemo::PolicyUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';

my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';
my $RULE       = 'rule';
my $DEVICE     = 'device';
my $ACTION     = 'action';
my $ACTION_VALUE = 'action-value';
my $CONDITION  = 'condition';
my $IP         = 'ip';

my @REQUIRED_ARGS = ( $DEVICE, $RULE, $ACTION, $ACTION_VALUE, $CONDITION );

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};
	my $result = 1;
	
	my ( %rule, %device, %meta_rule_device, %action, %meta_rule_action, %condition, %meta_rule_condition );
	
	%rule = ( extended =>
	  TrustAtHsH::Irondemo::PolicyUtilities->create_string_id_rule({
	    name     => $data->{$RULE},
	  })
	);
	
	%action = ( extended =>
	  TrustAtHsH::Irondemo::PolicyUtilities->create_string_id_action({
	    name     => $data->{$ACTION},
	    value    => $data->{$ACTION_VALUE}
	  })
	);
	
	%condition = ( extended =>
	  TrustAtHsH::Irondemo::PolicyUtilities->create_string_id_condition({
	    name     => $data->{$CONDITION},
	  })
	);

	$device{'standard'}-> {'type'}  = 'dev';
	$device{'standard'}-> {'value'} = $data->{$DEVICE};
	
	%meta_rule_device = ( extended => TrustAtHsH::Irondemo::PolicyUtilities->create_string_meta_rule_device());
	%meta_rule_action = ( extended => TrustAtHsH::Irondemo::PolicyUtilities->create_string_meta_rule_action());
	%meta_rule_condition = ( extended => TrustAtHsH::Irondemo::PolicyUtilities->create_string_meta_rule_condition());
	
	$result &= $self->publish(
	  $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%rule, \%meta_rule_device, \%device
	);
	
	$result &= $self->publish(
	  $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%rule, \%meta_rule_action, \%action
	);
	
	$result &= $self->publish(
	  $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%rule, \%meta_rule_condition, \%condition
	);
	
	if ( $data->{$IP} ) {
		$result &= $self->call_ifmap_cli({
		  'cli_tool' => "dev-ip",
		  'mode' => "update",
		  'args_list' => [$data->{$DEVICE}, $data->{$IP}],
		  'connection_args' => { 'ifmap-user' => $data->{$IFMAP_USER},
		    'ifmap-pass' => $data->{$IFMAP_PASS}
		  },
		});
	}
	
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
#                 service             ->
#                 service-ip          ->
#                 host                ->
#                 device              ->(optional)
#                 port                ->
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;