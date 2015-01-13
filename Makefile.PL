use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Logging::Trivial',
    AUTHOR           => q{Alexander Brett <alex@alexander-brett.co.uk>},
    VERSION_FROM     => 'lib/Logging/Trivial.pm',
    ABSTRACT_FROM    => 'lib/Logging/Trivial.pm',
    LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.010,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
	'Test::Exception' => 0,
    },
    PREREQ_PM => {
      'Term::ANSIColor' => 0,
      'Scalar::Util' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Logging-Trivial-*' },
);
