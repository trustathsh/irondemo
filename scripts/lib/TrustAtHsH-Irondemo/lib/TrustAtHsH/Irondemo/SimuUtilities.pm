package TrustAtHsH::Irondemo::SimuUtilities;

use 5.006;
use strict;
use warnings;

use constant {
	META_SERVICE_IP    => "<simu:service-ip xmlns:simu=\"http://simu-project.de/XMLSchema/1\" ifmap-cardinality=\"singleValue\" />",
	META_IDENTIFIES_AS => "<simu:identifies-as xmlns:simu=\"http://simu-project.de/XMLSchema/1\" ifmap-cardinality=\"singleValue\" />",
};

sub create_string_id_service {
	my $class     = shift;
	my $href_args = shift;
	
	my $string = 
	  "<simu:service type=\"" . $href_args->{'type'} .
	  "\" name=\"" . $href_args->{'name'} . "\"" . " port=\"" . $href_args->{'port'} .
	  "\" administrative-domain=\"" . $href_args->{'administrative_domain'} . 
	  "\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\" />";
	
	return $string;
}

sub create_string_meta_login_failed {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<simu:login-failure ifmap-cardinality=\"singleValue\"" .
	  " xmlns:simu=\"http://simu-project.de/XMLSchema/1\">" . 
	  "<simu:credential-type>" . $href_args->{'credential_type'} . "</simu:credential-type>" . 
	  "<simu:reason>" . $href_args->{'reason'} . "</simu:reason>" .
	  "</simu:login-failure>";
	
	return $string;
}

1;