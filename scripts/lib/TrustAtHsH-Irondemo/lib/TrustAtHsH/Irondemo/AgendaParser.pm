package TrustAtHsH::Irondemo::AgendaParser;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);

use Data::Dumper;
use IO::File;

use Log::Log4perl;

my $log = Log::Log4perl->get_logger();

sub new {
	my $class = shift;
	my $args = shift;

	my $self = {};
	bless $self, $class;

    $self->{'agenda_path'} = $args->{'path'};

    return $self;
}


sub getActions {
	my $self = shift;

    my @actions;
    my $filename = $self->{'agenda_path'};
    my $agenda_file = IO::File->new($filename, 'r');
    if (defined $agenda_file) {
        while( my $line = $agenda_file->getline() ) {
        	next if $line =~ /^\s*#/;
        	next if $line =~ /^\s*$/;
            my $action = parseLine($line);
            push(@actions, $action) if $action;
        }
        undef $agenda_file;
    } else {
        die("could not open $filename\n");
    }
    my @sortedActions = sort { $a->{'time'} <=> $b->{'time'} } @actions;
	return @sortedActions;
}


sub parseLine {
    my $line = shift;
    my @matchedLines = ($line =~ m/^\s*At\s+(\d+)\s+do\s+(\w+)\((.*)\)/);
    if (@matchedLines) {
	    my ($time, $name, $argsString) = @matchedLines;
	    my $action = {};
	    my $args = {};
	    $action->{'action'} = $name;
	    $action->{'time'} = $time;
	    $action->{'args'} = $args;

	    my @argsStrings = split(/,/, $argsString);
	    trimStrings(\@argsStrings);
	    for my $arg (@argsStrings) {
	        my @keyValue = split(/=>/, $arg);
	        trimStrings(\@keyValue);
	        my $key = $keyValue[0];
	        my $value = $keyValue[1];

	        $args->{$key} = $value;
	    }
	    return $action;
	} else {
		$log->warn("Could not parse line $line");
		return 0;
	}
}


sub trimStrings {
    my $strings = shift;
    for my $s (@$strings) {
        $s =~ s/^\s+//;
        $s =~ s/\s+$//;
    }
}

1;
