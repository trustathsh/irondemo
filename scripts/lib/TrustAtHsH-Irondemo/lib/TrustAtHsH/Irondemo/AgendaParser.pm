package TrustAtHsH::Irondemo::AgendaParser;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);

use Data::Dumper;
use IO::File;

use Log::Log4perl;

my $log = Log::Log4perl->get_logger();


my $AGENDA_TYPE_SEQ = "seq_agenda";
my $AGENDA_TYPE_TIMED = "timed_agenda";


sub new {
	my $class = shift;
	my $args = shift;

	my $self = {};
	bless $self, $class;

    $self->{'agenda_path'} = $args->{'path'};

    return $self;
}


sub get_actions {
	my $self = shift;

    my @actions;
    my $filename = $self->{'agenda_path'};
    my $agenda_file = IO::File->new($filename, 'r');
    if (defined $agenda_file) {
        my $agenda_type = probe_agenda_type($agenda_file);
        $log->debug("detected agenda type '$agenda_type'");

        my $current_tick = 0;
        while( my $line = $agenda_file->getline() ) {
        	next if $line =~ /^\s*#/;
        	next if $line =~ /^\s*$/;
            if ($agenda_type eq $AGENDA_TYPE_TIMED) {
                my $action = parse_timed_line($line);
                push(@actions, $action) if $action;
            } else {
                my $action = parse_line($line, $current_tick);
                $current_tick += 1;
                push(@actions, $action) if $action;
            }
        }
        undef $agenda_file;
    } else {
        die("could not open $filename\n");
    }
    my @sorted_actions = sort { $a->{'time'} <=> $b->{'time'} } @actions;
	return @sorted_actions;
}


sub probe_agenda_type {
    my $agenda_file = shift;
    if (defined $agenda_file) {
        while ( my $line = $agenda_file->getline() ) {
            next if $line =~ /^\s*#/;
            next if $line =~ /^\s*$/;
            if ($line =~ /\s*At\s+\d+\s+do\s+/) {
                $agenda_file->seek(0, 0);
                return $AGENDA_TYPE_TIMED;
            } else {
                $agenda_file->seek(0, 0);
                return $AGENDA_TYPE_SEQ;
            }
        }
    }
}


sub parse_args {
    my $args_input = shift;
    my $args = {};
    my @args_strings = split(/,/, $args_input);
    trim_strings(\@args_strings);
    for my $arg (@args_strings) {
        my @key_value = split(/=>/, $arg);
        trim_strings(\@key_value);
        my $key = $key_value[0];
        my $value = $key_value[1];

        $args->{$key} = $value;
    }
    return $args;
}


sub parse_line {
    my $line = shift;
    my $current_tick = shift;
    my @matched_lines = ($line =~ m/^\s*(\w+)\((.*)\)/);
    if (@matched_lines) {
	    my ($name, $args_string) = @matched_lines;
	    my $action = {};
	    my $args = parse_args($args_string);
	    $action->{'action'} = $name;
	    $action->{'time'} = $current_tick;
	    $action->{'args'} = $args;
	    return $action;
	} else {
		$log->warn("Could not parse line $line");
		return 0;
	}
}


sub parse_timed_line {
    my $line = shift;
    my @matched_lines = ($line =~ m/^\s*At\s+(\d+)\s+do\s+(\w+)\((.*)\)/);
    if (@matched_lines) {
	    my ($time, $name, $args_string) = @matched_lines;
	    my $action = {};
	    my $args = parse_args($args_string);
	    $action->{'action'} = $name;
	    $action->{'time'} = $time;
	    $action->{'args'} = $args;
	    return $action;
	} else {
		$log->warn("Could not parse line $line");
		return 0;
	}
}


sub trim_strings {
    my $strings = shift;
    for my $s (@$strings) {
        $s =~ s/^\s+//;
        $s =~ s/\s+$//;
    }
}

1;
