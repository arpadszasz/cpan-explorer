#!/usr/bin/env perl

use 5.012;
use utf8;
use warnings FATAL => 'all';

our $RealBin;

BEGIN {
    use File::Basename 'dirname';
    use File::Spec::Functions 'rel2abs';
    $RealBin = rel2abs( dirname(__FILE__) );
}

use lib "$RealBin/lib";
use CPANExplorer::Resource;
use CPANExplorer::Wx;

my $resource    = CPANExplorer::Resource->new;

my $app = CPANExplorer::Wx->new(
    {
        cfg => {
            program_version => '0.1',
            copyright_start => 2013,
            xrc_file        => $resource->xrc_file,
            program_path    => $RealBin,
            app_name        => 'CPAN Explorer',
            defaults        => {},
        }
    }
);
$app->MainLoop;
