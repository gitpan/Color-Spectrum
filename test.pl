use Test::More qw(no_plan);

BEGIN { use_ok('Color::Spectrum',qw(generate)) }

my $color = Color::Spectrum->new();
isa_ok($color, 'Color::Spectrum');
can_ok($color,qw( generate ));

my @pcolor = generate(4,"#ffffff","#000000");
is (@pcolor, 4, 'elements generated (exported)');

my @ocolor = $color->generate(4,"#ffffff","#000000");
is (@ocolor, 4, 'elements generated (instantiated)');

is (eq_array(\@pcolor,\@ocolor),1,'export vs instantiation');
