use strict;
use warnings;
use inc::Module::Install;

name 'IO-AIO-Temp';

perl_version '5.008';
all_from     'lib/IO/AIO/Temp.pm';
license      'perl';

requires 'Guard';
requires 'IO::AIO';
requires 'File::Spec';

test_requires 'Test::More';

tests_recursive();
WriteAll();
