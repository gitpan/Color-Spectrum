package Color::Spectrum;

use strict;
use POSIX;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
@ISA = qw(Exporter AutoLoader);
@EXPORT = qw(generate rgb2hsi hsi2rgb);
$VERSION = '1.02';


sub new {
	my $class = shift;
	my $self  = {};
	bless $self, $class;
	return $self;
}

sub generate {
	my $self = shift if ref($_[0]) eq __PACKAGE__;
	croak "ColorCount and at least 1 color like #AF32D3 needed\n" if @_ < 2;
	my $cnt  = shift;
	my $col1 = shift;
	my $col2 = shift || $col1;
	my @murtceps;
	push @murtceps, uc $col1;

	my $pound = $col1 =~ /^#/ ? "#" : "";
	$col1 =~s/^#//;
	$col2 =~s/^#//;

	my $clockwise = 0;
	$clockwise++ if ( $cnt < 0 );
	$cnt = int( abs( $cnt ) );

	return ( wantarray() ? @murtceps : \@murtceps ) if $cnt == 1;
	return ( wantarray() ? ($col1, $col2) : [$col1, $col2] ) if $cnt == 2;

	# The RGB values need to be on the decimal scale,
	# so we divide em by 255 enpassant.
	my ( $h1, $s1, $i1 ) = rgb2hsi( map { hex() / 255 } unpack( 'a2a2a2', $col1 ) );
	my ( $h2, $s2, $i2 ) = rgb2hsi( map { hex() / 255 } unpack( 'a2a2a2', $col2 ) );
	$cnt--;
	my $sd = ( $s2 - $s1 ) / $cnt;
	my $id = ( $i2 - $i1 ) / $cnt;
	my $hd = $h2 - $h1;
	if ( uc( $col1 ) eq uc( $col2 ) ) {
		$hd = ( $clockwise ? -1 : 1 ) / $cnt;
	} else {
		$hd = ( ( $hd < 0 ? 1 : 0 ) + $hd - $clockwise) / $cnt;
	}

	while (--$cnt) {
		$s1 += $sd;
		$i1 += $id;
		$h1 += $hd;
		$h1 -= 1 if $h1>1;
		$h1 += 1 if $h1<0;
		push @murtceps, sprintf "$pound%02X%02X%02X",
			map { int( $_ * 255 +.5) } hsi2rgb( $h1, $s1, $i1 );
	}
	push @murtceps, uc "$pound$col2";
	return wantarray() ? @murtceps : \@murtceps;
}

sub rgb2hsi {
	my ( $r, $g, $b ) = @_;
	my ( $h, $s, $i ) = ( 0, 0, 0 );

	$i = ( $r + $g + $b ) / 3;
	return ( $h, $s, $i ) if $i == 0;

	my $x = $r - 0.5 * ( $g + $b );
	my $y = 0.866025403 * ( $g - $b );
	$s = ( $x ** 2 + $y ** 2 ) ** 0.5;
	return ( $h, $s, $i ) if $s == 0;

	$h = POSIX::atan2( $y , $x ) / ( 2 * 3.1415926535 );
	return ( $h, $s, $i );
}

sub hsi2rgb {
	my ( $h, $s, $i ) =  @_;
	my ( $r, $g, $b ) = ( 0, 0, 0 );

	# degenerate cases. If !intensity it's black, if !saturation it's grey
	return ( $r, $g, $b ) if ( $i == 0 );
	return ( $i, $i, $i ) if ( $s == 0 );

	$h = $h * 2 * 3.1415926535;
	my $x = $s * cos( $h );
	my $y = $s * sin( $h );

	$r = $i + ( 2 / 3 * $x );
	$g = $i - ( $x / 3 ) + ( $y / 2 / 0.866025403 );
	$b = $i - ( $x / 3 ) - ( $y / 2 / 0.866025403 );

	# limit 0<=x<=1  ## YUCK but we go outta range without it.
	( $r, $b, $g ) = map { $_ < 0 ? 0 : $_ > 1 ? 1 : $_ } ( $r, $b, $g );

	return ( $r, $g, $b );
}

1;

__END__
=head1 NAME

Color::Spectrum - Generate spectrums of web colors

=head1 SYNOPSIS

  # Procedural interface:
  use Color::Spectrum qw(generate);
  my @color = generate(10,'#000000','#FFFFFF');

  # OO interface:
  use Color::Spectrum;
  my $spectrum = Color::Spectrum->new();
  my @color = $spectrum->generate(10,'#000000','#FFFFFF');

=head1 DESCRIPTION

This is a rewrite of a script I wrote 4 years ago to make spectrums of colors for web page table tags.  It uses a real simple geometric conversion that gets the job done.

It can shade from dark to light, from saturated to dull, and around the spectrum all at the same time. It can go thru the spectrum in either direction.

=head1 METHODS

=over 4

=item B<generate>

  # Procedural interface:
  @list = generate($elements,$start_color,$end_color);

  # OO interface:
  @list = $spectrum->generate($elements,$start_color,$end_color);

This method returns a list of size $elements which contains web colors starting from $start_color and ranging to $end_color.

=head1 AUTHOR

Mark Mills <extremely@hostile.org>

=head1 MAINTAINANCE

This package is maintained by Jeffrey Hayes Anderson <captvanhalen@yahoo.com>

=head1 COPYRIGHT

Copyright (c) 2003 Mark Mills.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
