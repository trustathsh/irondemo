package TrustAtHsH::Irondemo::PolicyUtilities;

use 5.006;
use strict;
use warnings;


### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_id_rule {
	my $class     = shift;
	my $href_args = shift;
	
	my $string = "<pol:rule name=\"" . $href_args->{'name'} .
	  "\" administrative-domain=\"" . $href_args->{'administrative_domain'} . "\"" .
	  " xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";
	
	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_id_rule_instance {
	my $class     = shift;
	my $href_args = shift;
	
	my $string = "<pol:rule-instance name=\"" . $href_args->{'name'} .
	  "\" administrative-domain=\"" . $href_args->{'administrative_domain'} . "\"" .
	  " xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";
	
	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_id_action {
	my $class     = shift;
	my $href_args = shift;
	
	my $string = "<pol:action name=\"" . $href_args->{'name'} .
	  "\" value=\"" . $href_args->{'value'} .
	  "\" administrative-domain=\"" . $href_args->{'administrative_domain'} . "\"" .
	  " xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";
	
	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_id_condition {
	my $class     = shift;
	my $href_args = shift;
	
	my $string = "<pol:condition name=\"" . $href_args->{'name'} .
	  "\" administrative-domain=\"" . $href_args->{'administrative_domain'} . "\"" .
	  " xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";
	
	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_id_signature {
	my $class     = shift;
	my $href_args = shift;
	
	my $string = "<pol:signature name=\"" . $href_args->{'name'} .
	  "\" value=\"" . $href_args->{'value'} .
	  "\" administrative-domain=\"" . $href_args->{'administrative_domain'} . "\"" .
	  " xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";
	
	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_rule_condition {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:rule-condition ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_rule_action {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:rule-action ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_rule_device {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:rule-device ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_rule_instance_to_rule {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:rule-instance-to-rule ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_rule_instance_to_signature {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:rule-instance-to-signature ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_rule_instance_to_category {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:rule-instance-to-category ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_condition_signature {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:condition-signature ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_condition_element {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:condition-element ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_signature_and {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:signature-and ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_signature_or {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:signature-or ifmap-cardinality=\"singleValue\" xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

	return $string;
}

### CLASS METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub create_string_meta_feature {
	my $class     = shift;
	my $href_args = shift;
	
	my $string =
	  "<pol:feature ifmap-cardinality=\"singleValue\" value=\"" . $href_args->{'value'} .
	  "xmlns:pol=\"http://trust.f4.hs-hannover.de/projects/visitmeta/XMLSchema/1\" />";

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

1;