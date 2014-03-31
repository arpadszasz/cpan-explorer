#########################################################################################
# Package       Cava::Packager::Version1
# Description:  Release Versioner
# Created       Wed Sep 22 14:00:00 2010
# SVN Id        $Id: Version1.pm 1282 2011-05-11 19:59:48Z Mark Dootson $
# Copyright:    Copyright (c) 2010 Mark Dootson
# Licence:      This program is free software; you can redistribute it 
#               and/or modify it under the same terms as Perl itself
#########################################################################################

package Cava::Packager::Version1;

#########################################################################################

# compatibility loader if we pack Cava/Packager.pm using Version 1 executable.

package Cava::Packager;

use strict;
use warnings;
use Carp;

our $VERSION = '2.10';

sub IsWindows { $^O =~ /^mswin/i }
sub IsLinux { $^O =~ /^linux/i }
sub IsMac { $^O =~ /^darwin/i }

sub GetBinPath { $Cava::Pack::BINPATH }
sub GetExePath { $Cava::Pack::EXEPATH }
sub GetExecutable  { $Cava::Pack::EXE }
sub GetResourcePath { $Cava::Pack::RESPATH }
sub GetResource { Cava::Pack::Resource(@_); }

our $v1scripts = {};

sub set_version1_script {
    my($scriptname, $executable) = @_;
    $executable .= '.exe' if((IsWindows()) && ($executable !~ /\.pm$/i) );
    $v1scripts->{$scriptname} = $executable;
}

sub GetScriptCommand {
    my ($scriptname, $perloptions, @args) = @_;
    if(!exists($v1scripts->{$scriptname})) {
        croak('Unable to find command to execute in this version');
    }
    my @rvals = ();
    my $exec = GetBinPath() . '/' . $v1scripts->{$scriptname};
    if(@args) {
        push (@rvals, (@args));
    }
    return ( wantarray ) ? @rvals : join(' ', @rvals);
}

sub Packaged {Cava::Pack::Packaged() }
sub IsPackaged {Cava::Pack::Packaged() }
sub Resource {Cava::Pack::Resource(@_) }
sub CodePath {Cava::Pack::CodePath(@_) }
sub ShortPath {Cava::Pack::ShortPath(@_) }
sub DisplayPath {Cava::Pack::DisplayPath(@_) }
sub GetUserAppDataDir {Cava::Pack::GetUserAppDataDir(@_) }
sub GetUserDocumentDir {Cava::Pack::GetUserDocumentDir(@_) }
sub GetCommonAppDataDir {Cava::Pack::GetCommonAppDataDir(@_) }
sub GetTempDir {Cava::Pack::GetTempDir(@_) }
sub GetTempFile {Cava::Pack::GetTempFile(@_) }
sub SetResourcePath {Cava::Pack::SetResourcePath(@_) }
sub SetInfoProductName {Cava::Pack::SetInfoProductName(@_) }
sub SetInfoProductVersion {Cava::Pack::SetInfoProductVersion(@_) }
sub SetInfoVendor {Cava::Pack::SetInfoVendor(@_) }
sub SetInfoCopyright {Cava::Pack::SetInfoCopyright(@_) }
sub SetInfoTrademarks {Cava::Pack::SetInfoTrademarks(@_) }
sub SetInfoComments {Cava::Pack::SetInfoComments(@_) }
sub SetInfoFileDescription {Cava::Pack::SetInfoFileDescription(@_) }
sub SetInfoFileInternalName {Cava::Pack::SetInfoFileInternalName(@_) }
sub SetInfoFileVersion {Cava::Pack::SetInfoFileVersion(@_) }
sub SetInfoFileOriginalName {Cava::Pack::SetInfoFileOriginalName(@_) }
sub GetInfoProductName {Cava::Pack::GetInfoProductName(@_) }
sub GetInfoProductVersion {Cava::Pack::GetInfoProductVersion(@_) }
sub GetInfoVendor {Cava::Pack::GetInfoVendor(@_) }
sub GetInfoCopyright {Cava::Pack::GetInfoCopyright(@_) }
sub GetInfoTrademarks {Cava::Pack::GetInfoTrademarks(@_) }
sub GetInfoComments {Cava::Pack::GetInfoComments(@_) }
sub GetInfoFileDescription {Cava::Pack::GetInfoFileDescription(@_) }
sub GetInfoFileInternalName {Cava::Pack::GetInfoFileInternalName(@_) }
sub GetInfoFileVersion {Cava::Pack::GetInfoFileVersion(@_) }
sub GetInfoFileOriginalName {Cava::Pack::GetInfoFileOriginalName(@_) }

sub GetSharedLibraryPath { __cava1_unsupported(); }
sub SetSharedLibraryPath { __cava1_unsupported(); }
sub GetStandardIncPath { __cava1_unsupported(); }
sub SetStandardIncPath {  __cava1_unsupported(); }
sub MapFile { __cava1_unsupported(); }
sub SetProjectPath { __cava1_unsupported(); }
sub RecordRequire { __cava1_unsupported(); }
sub GetFileInINC { __cava1_unsupported(); }
sub RunTests { __cava1_unsupported(); }
sub GetUserPath { __cava1_unsupported(); }
sub SetUserPath { __cava1_unsupported(); }

sub __cava1_unsupported {
    my @info = caller(1);
    croak qq(\"$info[3]\" not supported in Cava Packager Version 1);
}

1;

__END__

