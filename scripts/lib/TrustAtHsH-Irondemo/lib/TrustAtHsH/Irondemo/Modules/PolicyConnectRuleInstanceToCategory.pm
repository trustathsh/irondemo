package TrustAtHsH::Irondemo::Modules::PolicyConnectRuleInstanceToCategory;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapPublishModule';


my $RULE_INSTANCE = 'rule-instance';
my $CATEGORY = 'category';
my $IFMAP_USER = 'ifmap-user';
my $IFMAP_PASS = 'ifmap-pass';

my @REQUIRED_ARGS = ($RULE_INSTANCE, $CATEGORY);


### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $rule_instance = TrustAtHsH::Irondemo::PolicyUtilities->create_string_id_rule_instance({
	    name     => $data->{$RULE_INSTANCE},
	});
	my $category = $data->{$CATEGORY};

	my $updates = <<"END_MESSAGE";
<update lifetime="forever">
	<identity name="&amp;lt;rule-instance xmlns=&amp;quot;http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1&amp;quot; administrative-domain=&amp;quot;&amp;quot; name=&amp;quot;1&amp;quot;&amp;gt;&amp;lt;/rule-instance&amp;gt;" other-type-definition="extended" type="other"/>
	<identity administrative-domain="smartphone" name="$category" other-type-definition="32939:category" type="other"/>
	<metadata>
		<pol:rule-instance-to-category ifmap-cardinality="singleValue" xmlns:pol="http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1"/>
	</metadata>
</update>
END_MESSAGE

	my $connectionArgs = {
		"ifmap-user" => $data->{$IFMAP_USER},
		"ifmap-pass" => $data->{$IFMAP_PASS}
	};

	my $result = $self->send_soap_publish_request({
		'update_elements' => $updates,
		'connection_args' => $connectionArgs});

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
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ($key, $val) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;