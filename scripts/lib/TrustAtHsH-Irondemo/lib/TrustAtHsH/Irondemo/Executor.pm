package TrustAtHsH::Irondemo::Executor;

use 5.006;
use strict;
use warnings;
use threads;
use Thread::Queue;
use Carp qw(croak);
use Scalar::Util qw(blessed);

sub new {
	my $class = shift;
	
	my $args  = shift;
	
	my $self  = {};
	bless $self, $class;
	
	$self->{'threads'}  = $args->{'threadpool_size'} || 10;
	$self->{'Qwork'}    = new Thread::Queue;
	$self->{'Qresult'}  = new Thread::Queue;
	$self->{'pool'}     = [$self->create_thread_pool()];
	return $self;
	
}

sub run {
	my $self = shift;
	
	my $job  = shift;
	
	$job->execute();
}

sub run_concurrent {
	my $self = shift;
	
	my @jobs = @_;
	
	for my $job ( @jobs ) {
		$self->get_working_queue->enqueue($job);
	}
}

sub create_thread_pool {
	my $self = shift;
	
	my $threads = $self->{'threads'};
	my @pool;
	
	for (1..$threads) {
		my $thread = threads->create( \&worker, $self->get_working_queue(), $self->get_result_queue() );
		push @pool, $thread;
	}
	
	return @pool;
}

sub worker {
	my $tid = threads->tid;
	my( $Qwork, $Qresults ) = @_;

	while( my $job = $Qwork->dequeue ) {
		my $class = blessed $job;
		eval "require $class";
		my $result = $job->execute();
		$Qresults->enqueue( {$tid => 'binky'} );
	}
}

sub get_working_queue {
	my $self = shift;
	
	return $self->{'Qwork'};
}

sub get_result_queue {
	my $self = shift;
	
	return $self->{'Qresult'};
}

sub DESTROY {
	my $self = shift;

	for my $thread ( @{$self->{'pool'}} ) {
		$self->get_working_queue()->enqueue(undef);
	}
	for my $thread ( @{$self->{'pool'}} ) {
		$thread->join;
	}
}

1;