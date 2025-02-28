use 5.006001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'GRIB::API',
   # Module version
   'VERSION'   => '1.9.16',

   # Preprocessor defines
   'DEFINE' => '-DHAVE_CONFIG_H',     # e.g., '-DHAVE_SOMETHING'

    VERSION_FROM      => 'lib/GRIB/API.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/GRIB/API.pm', # retrieve abstract from module
       AUTHOR         => 'Baudouin Raoult <mab@suse.de>') : ()),
    LIBS              => ['-L../../src -lgrib_api -lm @LIB_JP2@ '], # e.g., '-lm'
    INC               => '-I/gpfs/dell1/nco/ops/nwpara/wsr.v3.1.0.1/libs/grib_api-1.9.16-working/src', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
	depend           => { "API.o" => "../../src/libgrib_api.a" }
);
