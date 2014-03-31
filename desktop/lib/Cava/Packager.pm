#########################################################################################
# Package       Cava::Packager
# Description:  Cava Packager User Utilities
# Created       Tue Apr 27 22:17:28 2010
# SVN Id        $Id: Packager.pm 1282 2011-05-11 19:59:48Z Mark Dootson $
# Copyright:    Copyright (c) 2010 Mark Dootson
# Licence:      This program is free software; you can redistribute it 
#               and/or modify it under the same terms as Perl itself
#########################################################################################

package Cava::Packager;
use strict;
use warnings;

our $VERSION = '2.10';
# change this version - change it in CP.pm & Cava-Packager ppd too

# We might get packaged by a Cava Packager V.1 installation that does not know
# about us;

if( defined( &Cava::Pack::FreeMem ) && Cava::Pack::Packaged() ) {
    # we are a packaged Cava Pack version 1 app
    require Cava::Packager::Version1;
} else {
    # we are a perl run script - Cava Packager Version 2 with Version 1 compatibility
    require Cava::Packager::Version2;
}

1;

__END__

