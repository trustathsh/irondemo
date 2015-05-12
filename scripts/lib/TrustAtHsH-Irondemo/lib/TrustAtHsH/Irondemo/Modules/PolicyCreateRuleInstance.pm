package TrustAtHsH::Irondemo::Modules::PolicyCreateRuleInstance;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use lib '../../../';
use TrustAtHsH::Irondemo::PolicyUtilities;
use parent 'TrustAtHsH::Irondemo::ExtMeta';

my $IFMAP_USER    = 'ifmap-user';
my $IFMAP_PASS    = 'ifmap-pass';
my $RULE          = 'rule';
my $RULE_INSTANCE = 'rule-instance';
my $SIGNATURE     = 'signature';
my $SIGNATURE_VALUE = 'signature-value';

my @REQUIRED_ARGS = ( $RULE, $SIGNATURE, $RULE_INSTANCE );

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};
	my $result = 1;
	
	my ( %rule, %signature, %rule_instance, %meta_rule_instance_to_signature, %meta_rule_instance_to_rule );
	
	%rule = ( extended =>
	  TrustAtHsH::Irondemo::PolicyUtilities->create_string_id_rule({
	    name     => $data->{$RULE},
	  })
	);
	
	%signature = ( extended =>
	  TrustAtHsH::Irondemo::PolicyUtilities->create_string_id_signature({
	    name     => $data->{$SIGNATURE},
	    value    => $data->{$SIGNATURE_VALUE}
	  })
	);
	
	%rule_instance = ( extended =>
	  TrustAtHsH::Irondemo::PolicyUtilities->create_string_id_rule_instance({
	    name     => $data->{$RULE_INSTANCE},
	  })
	);
	
	%meta_rule_instance_to_rule = ( extended => TrustAtHsH::Irondemo::PolicyUtilities->create_string_meta_rule_instance_to_rule());
	%meta_rule_instance_to_signature = ( extended => TrustAtHsH::Irondemo::PolicyUtilities->create_string_meta_rule_instance_to_signature());

	$result &= $self->publish(
	  $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%rule_instance, \%meta_rule_instance_to_rule, \%rule
	);

	$result &= $self->publish(
	  $data->{$IFMAP_USER}, $data->{$IFMAP_PASS}, \%rule_instance, \%meta_rule_instance_to_signature, \%signature
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