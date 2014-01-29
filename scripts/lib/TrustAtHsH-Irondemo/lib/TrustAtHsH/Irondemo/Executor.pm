package TrustAtHsH::Irondemo::Executor;

use 5.006;
use strict;
use warnings;
use threads;
use Thread::Queue;
use Carp qw(croak);
use Log::Log4perl;
use Scalar::Util qw(blessed);
use Try::Tiny;

my $log = Log::Log4perl->get_logger();

### CONSTRUCTOR ###
# Purpose    : Constructor
# Returns    : Instance
# Parameters : threadpool_size -> number of threads to spawn (optional)
# Comments   :
sub new {
	my $class = shift;
	
	my $args  = shift;
	
	my $self  = {};
	bless $self, $class;
	
	$self->{'threads'}  = $args->{'threadpool_size'} || 10;
	$self->{'Qwork'}    = new Thread::Queue;
	$self->{'Qresult'}  = new Thread::Queue;
	$self->{'pool'}     = [$self->_create_thread_pool()];
	
	return $self;	
}


### INSTANCE METHOD ###
# Purpose     : Execute a module
# Returns     : Exit status of module
# Parameters  : TrustAtHsH::Irondemo::AbstractModule
# Comments    :
sub run {
	my $self = shift;
	
	my $job  = shift;
	my $return;
	
	$log->debug('Executing 1 module ...');
	my $result = $job->execute();
	
	if ($result) {
			$log->debug("... execution returned SUCCESS");
	} else {
			$log->debug(" ... execution returned FAILURE");
	}
	return $result;
}


### INSTANCE METHOD ###
# Purpose     : Execute a number of modules concurrently
# Returns     : Nothing
# Parameters  : Array of TrustAtHsH::Irondemo::AbstractModule
# Comments    :
sub run_concurrent {
	my $self = shift;
	my @jobs = @_;
	
	
	$log->debug('Executing ' . @jobs . ' module(s) concurrently');
	for my $job ( @jobs ) {
		$self->_get_working_queue->enqueue($job);
	}
}


### INSTANCE METHOD ###
# Purpose     : Getter for result queue
# Returns     : Thread::Queue
# Parameters  : None
# Comments    :
sub get_result_queue {
	my $self = shift;
	
	return $self->{'Qresult'};
}


### INTERNAL UTILITY ###
# Purpose     : Build initial thread pool
# Returns     : Array of thread objects
# Parameters  : None
# Comments    :
sub _create_thread_pool {
	my $self = shift;
	
	my $threads = $self->{'threads'};
	my @pool;
	
	$log->debug("Creating threadpool with $threads threads");
	for (1..$threads) {
		my $thread = threads->create(
			\&_worker, $self->_get_working_queue(),
			 $self->get_result_queue()
		);
		push @pool, $thread;
	}	
	return @pool;
}


### INTERNAL UTILITY ###
# Purpose     : Main routine for worker threads
# Returns     : Thread ID
# Parameters  : Working Queue(Thread::Queue),
#               Result Queue (Thread::Queue)
# Comments    :
sub _worker {
	my $tid = threads->tid;
	my( $Qwork, $Qresults ) = @_;

	while( my $job = $Qwork->dequeue ) {
		my $class = blessed $job;
		
		try {
			eval "require $class";
		} catch {
			my$error = $_;
			$log->error("Thread $tid: Cannot load $class: $error");
			croak($error);
		};
		
		$log->debug("Thread $tid: Executing $class ...");
		my $result = $job->execute();
		
		if ($result) {
			$log->debug("Thread $tid: ... execution returned SUCCESS");
		} else {
			$log->debug("Thread $tid: ... execution returned FAILURE");
		}
		$Qresults->enqueue( {$tid => $result} );
	}
	$log->debug("Thread $tid has finished, ready to join");
	return $tid;
}


### INTERNAL UTILITY ###
# Purpose     : (Internal) getter for working queue
# Returns     : Thread::Queue
# Parameters  : None
# Comments    :
sub _get_working_queue {
	my $self = shift;
	
	return $self->{'Qwork'};
}


### INTERNAL UTILITY ###
# Purpose     : Terminate threads on object destruction
# Returns     : Nothing
# Parameters  : None
# Comments    : 
sub DESTROY {
	my $self = shift;
	my $joined;

	#make sure all threads end
	for my $thread ( @{$self->{'pool'}} ) {
		$self->_get_working_queue()->enqueue(undef);
	}
	
	$log->debug('Waiting for all threads to finish');
	#wait for all threads to finish
	for my $thread ( @{$self->{'pool'}} ) {
		my $tid = $thread->tid();
		$thread->join;
		$joined++;
		$log->debug("Joined thread $tid ($joined of $self->{'threads'} threads joined)")
	}
	$log->debug('All threads joined successfully');
}


1;