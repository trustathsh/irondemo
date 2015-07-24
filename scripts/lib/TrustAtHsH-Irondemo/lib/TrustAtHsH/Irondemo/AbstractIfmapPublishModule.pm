package TrustAtHsH::Irondemo::AbstractIfmapPublishModule;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use Data::Dumper;
use LWP::UserAgent;
use File::Spec;
use File::Basename;
use HTTP::Request;
use MIME::Base64;
use Log::Log4perl;
use IPC::Run qw(run);
use Try::Tiny;
use XML::XPath;
use XML::XPath::XMLParser;
use lib '../../';
use parent 'TrustAtHsH::Irondemo::AbstractModule';


my $log = Log::Log4perl->get_logger();


my $NEW_SESSION_SOAP = <<'END_MESSAGE';
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"
	xmlns:ifmap="http://www.trustedcomputinggroup.org/2010/IFMAP/2">
		<s:Body>
			<ifmap:newSession />
		</s:Body>
</s:Envelope>
END_MESSAGE


### INSTANCE METHOD ###
# Purpose     : Opens a new SSRC session sends the given publish update
#               elements ends the session a returns the response of the request.
# Returns     : True value on success, false value on failure
# Parameters  : update_elements -> the IF-MAP update elements to send (required)
#               connection_args ->(optional)
# Comments    :
sub send_soap_publish_request {
	my $self = shift;
	my $args = shift;
	my $data = $self->{'data'};

	my $connection_args = $args->{connection_args};
	my $update_elements = $args->{update_elements};

	my $url = $connection_args->{'ifmap-url'}   || 'https://localhost:8443';
	my $user = $connection_args->{'ifmap-user'} || 'test';
	my $pass = $connection_args->{'ifmap-pass'} || 'test';

	# create the HTTP request object
	my $request = HTTP::Request->new(POST => $url);
	my $encodedAuth = encode_base64("$user:$pass");
	$request->header( 'Authorization' => "Basic $encodedAuth" );
	$request->content($NEW_SESSION_SOAP);

	# configure the user agent
	my $ua = LWP::UserAgent->new;
	$ua->ssl_opts( verify_hostnames => 0 ); # TODO enable server cert verification

	my $result = 1;
	try {
		# send the newSession request
		my $newSessionResponse = $ua->request($request);

		# parse the response and extract the session-id
		my $xp = XML::XPath->new( xml => $newSessionResponse->content);
		$xp->set_namespace("ifmap", 'http://www.trustedcomputinggroup.org/2010/IFMAP/2' );
		$xp->set_namespace("soap", 'http://www.w3.org/2003/05/soap-envelope' );
		my $session_id = $xp->findvalue('/soap:Envelope/soap:Body/ifmap:response/newSessionResult/@session-id');

		my $publish_template = <<"END_MESSAGE";
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
	<soap:Body>
		<ifmap:publish session-id="$session_id" xmlns:ifmap="http://www.trustedcomputinggroup.org/2010/IFMAP/2">
			$update_elements
		</ifmap:publish>
	</soap:Body>
</soap:Envelope>
END_MESSAGE

		# send the publish request
		$request->content($publish_template);
		my $publishResponse = $ua->request($request);

		my $endSessionRequest = <<"END_MESSAGE";
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
	<soap:Body>
		<ifmap:endSession session-id="$session_id" xmlns:ifmap="http://www.trustedcomputinggroup.org/2010/IFMAP/2"/>
	</soap:Body>
</soap:Envelope>
END_MESSAGE

		# send the endSession request
		$request->content($endSessionRequest);
		my $endSessionResponse = $ua->request($request);

	} catch {
		my $error = $_;
		$log->error("Execution of publish failed: $error");
		croak($error);
	};
	return $result;
}

1;
