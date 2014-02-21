package TrustAtHsH::Irondemo::Config;

use strict;
use warnings;

my $instance;

### CONSTRUCTOR ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub _new {
	my $class = shift;
	
	my $self = {};
	bless $self, $class;
}

### CLASS_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub instance {
	my $class = shift;
	
	unless ( defined $instance ) {
		$instance = $class->_new;
	}
	
	return $instance;
}

### INSTANCE_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub set_modules_config {
	my $self = shift;
	
	$self->{modules_conf} = shift;
	return $self;
}

### INSTANCE_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_modules_config {
	my $self = shift;
	
	return $self->{modules_conf};
}

### INSTANCE_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_module_config {
	my $self   = shift;
	my $module = shift;
	
	return $self->get_modules_config->{$module};
}

### INSTANCE_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub set_projects_config {
	my $self = shift;
	
	$self->{projects_conf} = shift;
	return $self;	
}

### INSTANCE_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_projects_config {
	my $self = shift;
	
	return $self->{projects_conf};
}

### INSTANCE_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_project_config {
	my $self    = shift;
	my $project = shift;
	
	return $self->get_projects_config->{$project};
}

### INSTANCE_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub set_current_scenario_dir {
	my $self         = shift;
	my $scenario_dir = shift;
	
	$self->{current_scenario_dir} = $scenario_dir;
	return $self;
}

### INSTANCE_METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_current_scenario_dir {
	my $self = shift;
	
	return $self->{current_scenario_dir};
}

1;