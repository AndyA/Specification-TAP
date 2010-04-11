#!perl

use strict;
use warnings;

use lib qw( t/lib );

use Config::Tiny;
use Data::Dumper;
use File::Spec;
use File::Temp;

use Specification::TAP::Fetch;

use Test::More tests => 8;

my $config = Config::Tiny->read( 'CONFIG' )
 or die "Can't read CONFIG: ", Config::Tiny->errstr;

my $tmpdir = File::Temp->newdir;

ok my $f = Specification::TAP::Fetch->new( $config->{_}{mirror},
  'VERSIONS', $tmpdir ),
 'created ok';

is $f->distname( '3.14' ),
 'authors/id/A/AN/ANDYA/Test-Harness-3.14.tar.gz', 'dist name';

is $f->disturi( Perl::Version->new( '3.14' ) ),
 'http://backpan.hexten.net/authors/id/A/AN/ANDYA/Test-Harness-3.14.tar.gz',
 'dist name';

my $localname = $f->fetch( '3.14' );
like $localname, qr{Test-Harness-3\.14\.tar\.gz}, 'fetch';
ok -r $localname, 'fetched archive is readable';

my $localdir = $f->unpack( '3.14' );
ok -r File::Spec->catfile( $localdir, 'Makefile.PL' ),
 'got Makefile.PL';

my $libpath = $f->libpath( '3.14' );
ok -d $libpath, 'libpath';
ok -f File::Spec->catfile( $libpath, 'Test', 'Harness.pm' ), 'th.pm';

# vim:ts=2:sw=2:et:ft=perl

