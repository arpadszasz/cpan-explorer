#!/usr/bin/env perl

use 5.012;
use utf8;
use warnings FATAL => 'all';

our $RealBin;

BEGIN {
    use File::Basename 'dirname';
    use File::Spec::Functions 'rel2abs';
    $RealBin = rel2abs( dirname(__FILE__) );

    eval { require Cava::Packager };
    if ( !$@ ) {
        Cava::Packager->import;
        if ( Cava::Packager::IsPackaged() ) {
            $RealBin = Cava::Packager::GetBinPath();
        }
    }
}

use lib "$RealBin/lib";
use Config::INI::Reader;
use CPANExplorer::Resource;
use CPANExplorer::Wx;

my $config_filename = "$RealBin/cpan-explorer.ini";
my $defaults        = {};
if ( -r $config_filename ) {
    $defaults = Config::INI::Reader->read_file($config_filename);
}

my $resource    = CPANExplorer::Resource->new;

my $app = CPANExplorer::Wx->new(
    {
        cfg => {
            program_version => '0.2',
            copyright_start => 2013,
            xrc_file        => $resource->xrc_file,
            program_path    => $RealBin,
            config_file     => $config_filename,
            app_name        => 'CPAN Explorer',
            defaults        => $defaults,
        }
    }
);
$app->MainLoop;
