package TrustAtHsH::Irondemo::AbstractProcessStarterModule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Temp qw/tempfile/;
use File::Spec;
use Path::Tiny;
use lib '../../';
use TrustAtHsH::Irondemo::Config;
use parent 'TrustAtHsH::Irondemo::AbstractModule';

my @REQUIRED_ARGS;

### INSTANCE METHOD ###
# Purpose     :
# Returns     :
# Parameters  :
# Comments    :
sub start_process {
	my $self    = shift;
	my $command = shift;
	my @args    = @_;

	my $dir_pidfiles = TrustAtHsH::Irondemo::Config->instance->get_pid_dir();
	my ($fh_pidfile, $pidfile)  = tempfile( DIR => $dir_pidfiles, SUFFIX => '.pid' );
	my $pid          = fork();
	

	if ( !defined $pid ) {    # Unable to fork
		croak("ERROR: Could not fork: $!\n");
	}
	elsif ( $pid == 0 ) {     # Child	
		my $parentPath = path($command)->parent;	
		my $logFileName = ref($self);
 		$logFileName = substr($logFileName,rindex($logFileName, "::") +7 );
 		$logFileName = $logFileName . "-IrondemoLog.txt";
 		my $logFilePath = path($parentPath)->child($logFileName);
	
		open( STDOUT, '>', $logFilePath ) or croak( "Could not re-open STDOUT. Aborting." );
		open( STDERR, '>>', $logFilePath ) or croak( "Could not re-open STDERR. Aborting." );
		exec( $command, @args ) or croak( "Could not execute " . $command . ". Aborting." );
	}
	else {                    # Parent
		print $fh_pidfile $pid;
		return $pid;
	}
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
#
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ( $key, $val ) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
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

1;
