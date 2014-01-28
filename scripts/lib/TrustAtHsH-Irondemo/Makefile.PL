use inc::Module::Install;

name     'TrustAtHsH-Irondemo';
all_from 'lib/TrustAtHsH/Irondemo.pm';
author   q{Trust@HsH <trust@f4-i.fh-hannover.de>};
license  'apache';

build_requires 'Test::More';
build_requires 'Test::Kwalitee';

requires 'Log::Log4perl';

auto_install;

WriteAll;

