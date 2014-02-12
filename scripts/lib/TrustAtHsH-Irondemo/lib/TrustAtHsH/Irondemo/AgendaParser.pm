package TrustAtHsH::Irondemo::AgendaParser;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);

use Data::Dumper;
use IO::File;
use Parse::RecDescent;

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

    my $grammar = q {
        startrule   : token                           { $return = @item[1];                                     }
        token       : comment(s?) action              { $return = $item[2];                                     }
        comment     : /^\s*#.*\n/
        action      : timedAction | seqAction         { $return = @item[1];                                     }
        timedAction : 'At' timestamp 'do' actionDef   { $return = { 'time' => $item[2], 'action' => @item[4] }; }
        seqAction   : actionDef                       { $return = { 'action' => @item[1] };                     }
        actionDef   : moduleName '(' args ')'         { $return = { 'module' => $item[1], 'args' => @item[3] }; }
        args        : arg(s /,/)                      { $return = @item[1];                                     }
        arg         : key '=>' value                  { $return = { 'key' => $item[1], 'value' => $item[3] };   }
        key         : /[a-z][\w_-]*/
        value       : /\w+[\w:\.-\s]*/
        moduleName  : /[A-Z]\w*/
        timestamp   : /\d+/
    };
    $self->{'parser'} = Parse::RecDescent->new($grammar) or die "Bad grammar!\n";

    return $self;
}


sub get_actions {
	my $self = shift;

    my @actions;
    my $filename = $self->{'agenda_path'};

    # change new line delimiter
    $/ = ";";

    my $agenda_file = IO::File->new($filename, 'r');
    if (defined $agenda_file) {
        my $current_tick = 0;
        my $agenda_type = undef;
        while (my $token = $agenda_file->getline()) {
            # skip comments at file end?
            last if eof($agenda_file) && $token =~ /^\s*#.*$/;

            my $actionParsed = $self->{'parser'}->startrule($token);
            if ($actionParsed) {

                # check the agenda type:
                if (!$agenda_type) {
                    if (defined $actionParsed->{'time'}) {
                        $agenda_type = $AGENDA_TYPE_TIMED;
                    } else {
                        $agenda_type = $AGENDA_TYPE_SEQ;
                    }
                    $log->debug("detected agenda type '$agenda_type'");
                } else {
                    $log->warn("timed action in sequential agenda") if (
                                defined $actionParsed->{'time'} && $AGENDA_TYPE_SEQ eq $agenda_type);
                }
                my $action = {};
                my $args = {};

                for my $i (@{$actionParsed->{'action'}->{'args'}}) {
                    my $key = $i->{'key'};
                    my $value = $i->{'value'};
                    $args->{$key} = $value;
                }
                $action->{'args'} = $args;

                $action->{'action'} = $actionParsed->{'action'}->{'module'};
                my $time;
                if ($agenda_type eq $AGENDA_TYPE_TIMED) {
                    if (!defined $actionParsed->{'time'}) {
                        croak("missing timestamp for action '".$actionParsed->{'action'}->{'module'}."'");
                    }
                    $time = $actionParsed->{'time'};
                } else {
                    $time = $current_tick;
                    $current_tick += 1;
                }
                $action->{'time'} = $time;
                push(@actions, $action);

            } else {
                $log->warn("could not parse '$token'");
            }
        }
        undef $agenda_file;
    } else {
        die("could not open $filename\n");
    }
    my @sorted_actions = sort { $a->{'time'} <=> $b->{'time'} } @actions;
	return @sorted_actions;
}

1;
