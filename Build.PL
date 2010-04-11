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
        'Test::More' => 0,
    },
    add_to_cleanup => ['Specification-TAP-*'],
);

$builder->create_build_script();
