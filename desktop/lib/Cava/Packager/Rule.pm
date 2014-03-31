#########################################################################################
# Package       Cava::Packager::Rule
# Description:  Runtime Rule Modification
# Created       Tue Oct 26 10:08:44 2010
# SVN Id        $Id: Rule.pm 957 2011-03-07 20:00:03Z Mark Dootson $
# Copyright:    Copyright (c) 2010 Mark Dootson
# Licence:      This program is free software; you can redistribute it 
#               and/or modify it under the same terms as Perl itself
#########################################################################################

package Cava::Packager::Rule;

#########################################################################################

use strict;
use warnings;

our $VERSION;

=head1 NAME

Cava::Packager::Rule - Script Utilities For Cava Packager Module Rules

=head1 SYNOPSIS

    use Cava::Packager::Rule;
    my $handler = Cava::Packager::Rule->new;
    ....
    $handler->add_shared_library( $libname, $libfullpath );
        
    cavalog(qq(I Added A Library $libname));
    cavalogwarning(qq(But you should know this));
    cavalogerror(qq(I encountered this error));

=head1 DESCRIPTION

   See Cava Packager help for a full description of available methods

=cut


1;
