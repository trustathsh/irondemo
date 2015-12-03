package TrustAtHsH::Irondemo::Modules::IcsGraph;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use File::Spec;
use File::Basename;
use lib '../../../';
use parent 'TrustAtHsH::Irondemo::AbstractIfmapCliModule';


my @REQUIRED_ARGS = ();

### INSTANCE METHOD ###
# Purpose     :
# Returns     : True value on success, false value on failure
# Parameters  : None
# Comments    :
sub execute {
	my $self = shift;
	my $data = $self->{'data'};

	my $connectionArgs = {
		"ifmap-user" => "nmap",
		"ifmap-pass" => "nmap"
	};

	my @argsList1 = ("bhi1", "10.10.10.7");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "bhi-addr",
			'mode'            => "update",
			'args_list'       => \@argsList1,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList2 = ("link", "bhi1", "ipv4", "10.10.10.7", "Overlay1", "allow");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "overlay-pol",
			'mode'            => "update",
			'args_list'       => \@argsList2,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList3 = ("bhi1", "ipv4", "10.10.10.7");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "prot-by",
			'mode'            => "update",
			'args_list'       => \@argsList3,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList4 = ("bhi1", "ipv4", "10.10.10.7");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "obs-by",
			'mode'            => "update",
			'args_list'       => \@argsList4,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList5 = ("link", "bhi2", "mac", "ab:12:cd:34:ef:56", "Overlay1", "allow");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "overlay-pol",
			'mode'            => "update",
			'args_list'       => \@argsList5,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList6 = ("bhi2", "mac", "ab:12:cd:34:ef:56");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "prot-by",
			'mode'            => "update",
			'args_list'       => \@argsList6,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList7 = ("bhi2", "mac", "ab:12:cd:34:ef:56");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "obs-by",
			'mode'            => "update",
			'args_list'       => \@argsList7,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList8 = ("identifier", "bhi2", "Overlay1", "allow");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "overlay-pol",
			'mode'            => "update",
			'args_list'       => \@argsList8,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList9 = ("link", "bhi1", "bhi2", "Overlay1", "allow");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "backhl-pol",
			'mode'            => "update",
			'args_list'       => \@argsList9,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList10 = ("ics_ovNetwGr", "OverlNetwGroup", "ics_bhi", "bhi2");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "member-of",
			'mode'            => "update",
			'args_list'       => \@argsList10,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList11 = ("identifier", "OverlNetwGroup", "Overlay1", "allow");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "backhl-pol",
			'mode'            => "update",
			'args_list'       => \@argsList11,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList12 = ("OverlManagerGroup", "ics_bhi", "bhi2");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "manager-of",
			'mode'            => "update",
			'args_list'       => \@argsList12,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList13 = ("OverlManagerGroup", "ics_ovNetwGr", "OverlNetwGroup");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "manager-of",
			'mode'            => "update",
			'args_list'       => \@argsList13,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList14 = ("OverlManagerGroup", "LdapUri");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "group-xref",
			'mode'            => "update",
			'args_list'       => \@argsList14,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList15 = ("ics_ovManagerGr", "OverlManagerGroup", "id_dist", "CN=Christian Huitema, O=INRIA, C=FR");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "member-of",
			'mode'            => "update",
			'args_list'       => \@argsList15,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList16 = ("CN=Christian Huitema, O=INRIA, C=FR", "OverlManagerGroup", "member-of");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "ifmap-client-has-task",
			'mode'            => "update",
			'args_list'       => \@argsList16,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList17 = ("bhi1", "CN=Christian Huitema, O=INRIA, C=FR");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "bhi-id",
			'mode'            => "update",
			'args_list'       => \@argsList17,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList18 = ("CN=Christian Huitema, O=INRIA, C=FR", "2001:10:7654:3210:fedc:ba98:7654:3210");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "dn-hit",
			'mode'            => "update",
			'args_list'       => \@argsList18,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList19 = ("CN=Christian Huitema, O=INRIA, C=FR", "BHI1_DN1_CERT1");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "bhi-cert",
			'mode'            => "update",
			'args_list'       => \@argsList19,
			'connection_args' => $connectionArgs
		}
	);

	my @argsList20 = ("CN=Christian Huitema, O=INRIA, C=FR", "DISCOVERED-TIME", "DISCOVERER-ID", "DISCOVERY-METHOD");

	$self->call_ifmap_cli(
		{
			'cli_tool'        => "dev-char-ics",
			'mode'            => "update",
			'args_list'       => \@argsList20,
			'connection_args' => $connectionArgs
		}
	);
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

### INTERNAL UTILITY ###
# Purpose     :
# Returns     :
# Parameters  : data ->
#                 ifmap-user          ->(optional)
#                 ifmap-pass          ->(optional)
#                 ifmap-url           ->(optional)
#                 ifmap-keystore-path ->(optional)
#                 ifmap-keystore-pass ->(optional)
#                 pdp            ->
#                 access-request ->
#                 mac            ->
#                 ip-address     ->
# Comments    : Override, called from parent's constructor
sub _init {
	my $self = shift;
	my $args = shift;

	while ( my ( $key, $val ) = each %{$args} ) {
		$self->{'data'}->{$key} = $val;
	}
}

1;
