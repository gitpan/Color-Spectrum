use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Color::Spectrum',
    'VERSION_FROM'	=> 'Spectrum.pm',
    'PREREQ_PM'		=> {Test::More => '0.47'},
);
