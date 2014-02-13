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
requires 'File::Copy::Recursive';

auto_install;

WriteAll;

