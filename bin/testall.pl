#!/usr/bin/env perl

use strict;
use warnings;

use lib qw( t/lib );

use Config::Tiny;
use Specification::TAP::Fetch;

my $config = Config::Tiny->read( 'CONFIG' )
 or die "Can't read CONFIG: ", Config::Tiny->errstr;

my $workdir = 'thwork';

my $f = Specification::TAP::Fetch->new( $config->{_}{mirror},
  'VERSIONS', $workdir );

for my $v ( $f->versions ) {
  print "Building Test::Harness $v\n";
  my $lib = eval { $f->libpath( $v, 'make', 'test' ) };
  if ( $@ ) {
    print "Test::Harness $v failed: $@\n";
  }
  else {
    print "Tested Test::Harness $v is at $lib\n";
  }
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

