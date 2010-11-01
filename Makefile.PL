use strict;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME      => 'App-eijiro',
    EXE_FILES => ['eijiro.pl'],
    PREREQ_PM => {
        'Furl'                 => 0.06,
        'HTML::Tree'           => 4.0,
        'HTML::Formatter'      => 2.00,
        'Term::ReadLine'       => 1.00,
        'Term::ReadLine::Perl' => 1.00,
    },

    test => { TESTS => 't/*.t' },
);

