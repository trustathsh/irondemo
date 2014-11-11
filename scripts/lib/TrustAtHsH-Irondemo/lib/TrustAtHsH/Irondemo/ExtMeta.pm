package TrustAtHsH::Irondemo::ExtMeta;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Temp qw(tempfile);
use lib '../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';

my $IFMAP_USER = '';
my $IFMAP_PASS = 'ifmap-pass';

### INTERNAL UTILITY ###
# Purpose     : Process constuctor parameters
# Returns     : Nothing
# Parameters  : Hashref, content to be defined by sub class
# Comments    :
sub _init {
	croak( caller() . ' is an abstract base class and must not be instantiated.' );
}

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub publish {
	my $self = shift;
	
	my $user = shift;
	my $pass = shift;
	my ( $href_first_id, $href_meta, $href_second_id ) = @_;
	
	my $connectionArgs = {
		"ifmap-user" => $user,
		"ifmap-pass" => $pass
	};
	
	my $result =1;

	my @identifier_first  = _construct_first_identifier_args( $href_first_id );
	my @identifier_second = _construct_second_identifier_args( $href_second_id );
	my @metadatum         = _construct_metadatum_args( $href_meta );
	my @argsList = (@identifier_second, @metadatum, @identifier_first);
	$result &= $self->call_ifmap_cli({
			'cli_tool'        => "ex-meta",
			'mode'            => "update",
			'args_list'       => \@argsList,
			'connection_args' => $connectionArgs
		});
		
	return $result;
}


### INTERNAL UTILITY ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub _construct_first_identifier_args {
	my $href_identifier   = shift;
	my @identifier_args;
	
	if ( defined( $href_identifier->{'extended'} ) ) {
		push @identifier_args, 'exid';
		push @identifier_args, _tempfile_for_extended( $href_identifier->{'extended'} );
	} else { 
		push @identifier_args, $href_identifier->{'standard'}->{'type'};
		push @identifier_args, $href_identifier->{'standard'}->{'value'};
	}
	return @identifier_args;
}
	

### INTERNAL UTILITY ###
# Purpose     :
# Returns     :
# Parameters  :/tmp/NvAWRHAYh4
# Comments    :
sub _construct_second_identifier_args {
	my $href_identifier   = shift;
	return '' unless $href_identifier;
	
	my @identifier_args;
	push @identifier_args, '--sec-identifier-type';
	
		if ( $href_identifier->{'extended'} ) {
			push @identifier_args, 'exid';
			push @identifier_args, '--sec-identifier';
			push @identifier_args, _tempfile_for_extended( $href_identifier->{'extended'} );
		} else {
			push @identifier_args, $href_identifier->{'standard'}->{'type'};
			push @identifier_args, '--sec-identifier';
			push @identifier_args, $href_identifier->{'standard'}->{'value'};
		}
		return @identifier_args;
}

### INTERNAL UTILITY ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub _construct_metadatum_args {
	my $href_metadatum   = shift;
	my @metadatum_args;
	push @metadatum_args, '--meta-in';
	push @metadatum_args, _tempfile_for_extended($href_metadatum->{'extended'});
	
	return @metadatum_args;
}

### INTERNAL UTILITY ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub _tempfile_for_extended {
	my $file_output = shift;
	
	my ( $fh, $filename ) = tempfile();
	print( $fh $file_output );
	
	return $filename;
}



### INSTANCE METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub get_required_arguments {
	my $self = shift;
}

1;