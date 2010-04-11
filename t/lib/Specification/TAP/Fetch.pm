package Specification::TAP::Fetch;

use strict;
use warnings;

use Archive::Tar;
use Carp qw( croak );
use File::Basename qw( dirname basename );
use File::Path qw( mkpath );
use File::Spec;
use File::chdir;
use LWP::UserAgent;
use Perl::Version;

=head1 NAME

Specification::TAP::Fetch - Fetch a version of Test::Harness

=cut

sub new {
  my ( $class, $base, $manifest, $workdir ) = @_;
  $base =~ s{/$}{};
  my $self = bless {
    base    => "$base",
    workdir => File::Spec->rel2abs( "$workdir" ),
  }, $class;
  $self->_parse_manifest( $manifest );
  return $self;
}

sub _parse_manifest {
  my ( $self, $manifest ) = @_;
  open my $mf, '<', $manifest
   or croak "Can't read $manifest: $!";
  my @vers = ();
  my %idx  = ();
  while ( defined( my $line = <$mf> ) ) {
    chomp $line;
    $line =~ s/\s*#.*//;
    next if $line =~ /^\s*$/;
    croak "Can't extract version from $line"
     unless $line =~ Perl::Version::REGEX;
    push @vers, Perl::Version->new( $2 );
    $idx{$2} = $line;
  }
  $self->{idx}  = \%idx;
  $self->{vers} = [ sort @vers ];
}

sub base    { shift->{base} }
sub workdir { shift->{workdir} }

sub distname {
  my ( $self, $version ) = @_;
  $version = "$version";    # stringify Perl::Version object
  croak "No version $version found"
   unless exists $self->{idx}{$version};
  return $self->{idx}{$version};
}

sub disturi {
  my ( $self, $version ) = @_;
  return $self->base . '/' . $self->distname( $version );
}

sub localname {
  my ( $self, $version ) = @_;
  return File::Spec->catfile( $self->workdir,
    $self->distname( $version ) );
}

sub _ua {
  my $self = shift;
  return $self->{_ua} ||= LWP::UserAgent->new;
}

sub fetch {
  my ( $self, $version ) = @_;
  my $localname = $self->localname( $version );
  my $localdir  = dirname( $localname );
  mkpath( $localdir );
  $self->_ua->mirror( $self->disturi( $version ), $localname );
  return $localname;
}

sub unpack {
  my ( $self, $version ) = @_;
  my $tarball = $self->fetch( $version );
  local $CWD = dirname( $tarball );
  my $workdir
   = File::Spec->catfile( $CWD, basename( $tarball, '.tar.gz' ) );
  return $workdir if -d $workdir;
  my $arc = Archive::Tar->new( $tarball );
  $arc->extract;
  return $workdir;
}

sub build {
  my ( $self, $version, @args ) = @_;
  local $CWD = $self->unpack( $version );
  my ( $build, $cmd, $builder )
   = -f 'Build.PL'
   ? ( 'Build.PL', './Build', 'Build' )
   : ( 'Makefile.PL', 'make', 'Makefile' );
  unless ( -f $builder ) {
    system 'perl', $build and croak "perl $build failed: $?";
  }
  system $cmd, @args and croak join( ' ', $cmd, @args ), " failed: $?";
  return $CWD;
}

sub libpath {
  my ( $self, $version, @verb ) = @_;
  my $workdir = $self->unpack( $version );
  return File::Spec->catdir( $workdir, 'lib' ) unless @verb;
  croak "Form is libpath($version, 'make')"
   unless shift @verb eq 'make';
  $self->build( $version, @verb );
  return File::Spec->catdir( $workdir, 'blib', 'lib' );
}

sub versions {
  my $self = shift;
  return @{ $self->{vers} };
}

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
