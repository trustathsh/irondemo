use inc::Module::Install;

name     'TrustAtHsH-Irondemo';
all_from 'lib/TrustAtHsH/Irondemo.pm';
author   q{Trust@HsH <trust@f4-i.fh-hannover.de>};
license  'apache';

build_requires 'Test::More';
build_requires 'Test::Kwalitee';

requires 'Log::Log4perl';
requires 'Parse::RecDescent';
requires 'Try::Tiny';
requires 'IPC::Run';
requires 'LWP::UserAgent';
requires 'LWP::Protocol::https';
requires 'HTTP::Request';
requires 'MIME::Base64';
requires 'XML::XPath';
requires 'XML::XPath::XMLParser';
requires 'File::Copy';
requires 'File::Copy::Recursive';
requires 'File::Spec';
requires 'File::Basename';
requires 'File::Path';
requires 'Carp';
requires 'Data::Dumper';
requires 'IO::File';
requires 'Parse::RecDescent';
requires 'Thread::Queue';
requires 'Scalar::Util';
requires 'Archive::Extract';
requires 'Storable';
requires 'YAML';

auto_install;

WriteAll;
