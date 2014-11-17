package TrustAtHsH::Irondemo::SimuUtilities;

use 5.006;
use strict;
use warnings;


### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_id_service {
	my $class     = shift;
	my $href_args = shift;
	
	my $string = 
	  "<simu:service type=\"" . $href_args->{'type'} .
	  "\" name=\"" . $href_args->{'name'} . "\"" . " port=\"" . $href_args->{'port'} .
	  "\" administrative-domain=\"" . $href_args->{'administrative_domain'} . "\"" . 
	  " xmlns:simu=\"http://simu-project.de/XMLSchema/1\" />";
	
	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_id_implementation {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<simu:implementation name=\"" . $href_args->{'name'} . "\"" .
	  " version=\"" . $href_args->{'version'} . "\"";
	
	if ( $href_args->{'local_version'} ) {
		$string .= " local-version=\"" . $href_args->{'local-version'} . "\"";
	}
	
	if ( $href_args->{'platform'} ) {
		$string .= " platform=\"" . $href_args->{'platform'} . "\"";
	}
	
	$string .= " xmlns:simu=\"http://simu-project.de/XMLSchema/1\" " . "administrative-domain=\"\"" . "/>";
	
	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_id_vulnerability {
	my $class = shift;
	my $href_args = shift;
	
	my $string = 
	  "<simu:vulnerability type=\"" . $href_args->{'type'} . "\"" .
	  " id=\"" . $href_args->{'id'} . "\"";
	
	if ( $href_args-> {'severity'} ) {
		$string .= " severity=\"" . $href_args-> {'severity'} . "\"";
	}
	
	$string .= " xmlns:simu=\"http://simu-project.de/XMLSchema/1\" " . "administrative-domain=\"\"" . "/>";
	
	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
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

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_attack_detected {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<simu:attack-detected ifmap-cardinality=\"multiValue\"" .
	  " xmlns:simu=\"http://simu-project.de/XMLSchema/1\">" .
	  " <simu:rule>" . $href_args->{'rule'} . " </simu:rule>";
	
	if ( $href_args->{'ref_type'} && $href_args->{'ref_id'} ) {
		$string .=
		  " <simu:ref-type>" . $href_args->{'ref_type'} . "</simu:ref-type>" .
		  " <simu:ref-id>" . $href_args->{'ref_id'} . "</simu:ref-id>";
	}
	
	if ( $href_args->{'comment'} ) {
		$string .= " <simu:comment>" . $href_args->{'comment'} . "</simu:comment>";
	}
	
	$string .= "</simu:attack-detected>";
	return $string;
}
	
### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_service_ip {
	my $class = shift;
	
	return "<simu:service-ip xmlns:simu=\"http://simu-project.de/XMLSchema/1\" ifmap-cardinality=\"singleValue\" />";
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_identifies_as {
	my $class = shift;
	
	return "<simu:identifies-as xmlns:simu=\"http://simu-project.de/XMLSchema/1\" ifmap-cardinality=\"singleValue\" />";
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_service_implementation {
	my $class = shift;
	
	return "<simu:service-implementation xmlns:simu=\"http://simu-project.de/XMLSchema/1\" ifmap-cardinality=\"singleValue\" />";
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_implementation_vulnerability {
	my $class = shift;
	
	return "<simu:implementation-vulnerability xmlns:simu=\"http://simu-project.de/XMLSchema/1\" ifmap-cardinality=\"singleValue\" />";
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_login_success {
	my $class = shift;
	
	return "<simu:login-success ifmap-cardinality=\"singleValue\" xmlns:simu=\"http://simu-project.de/XMLSchema/1\"><simu:credential-type>Password</simu:credential-type></simu:login-success>";
}

1;