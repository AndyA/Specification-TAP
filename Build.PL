use strict;
use warnings;

use lib 'inc';

use Module::Build;
use MyBuilder;

my $builder = MyBuilder->new(
  module_name       => 'Specification::TAP',
  license           => 'perl',
  dist_author       => 'Andy Armstrong <andy@hexten.net>',
  dist_version_from => 'lib/Specification/TAP.pm',
  requires          => {
    'Archive::Tar'   => 0,
    'Config::Tiny'   => 0,
    'IO::Zlib'       => 0,
    'LWP::UserAgent' => 0,
    'Perl::Version'  => 0,
    'Test::More'     => 0,
  },
  add_to_cleanup => ['Specification-TAP-*'],
);

$builder->create_build_script();
