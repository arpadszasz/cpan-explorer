#########################################################################################
# Package       Cava::Packager::Version2
# Description:  Release Versioner
# Created       Wed Sep 22 14:00:00 2010
# SVN Id        $Id: Version2.pm 1556 2011-06-20 23:52:00Z Mark Dootson $
# Copyright:    Copyright (c) 2010 Mark Dootson
# Licence:      This program is free software; you can redistribute it 
#               and/or modify it under the same terms as Perl itself
#########################################################################################

package Cava::Packager::Version2;

#########################################################################################

package Cava::Packager;

use strict;
use warnings;
use Exporter;
use base qw( Exporter );
use File::Spec;
use File::Path qw( remove_tree );
use Carp;
use Cwd;

our $VERSION = '2.10';
our $PACKAGED = undef;

our @EXPORT_OK = qw( CRF CMF CPV );

sub CRF ($) { Cava::Packager::Resource( @_ );  }
sub CMF ($) { Cava::Packager::MapFile( @_ );  }
sub CPV ($) { Cava::Packager::Verbose( @_ ); }

# Don't use these vars directly - they are not available in packaged app
our( $_datadir, $_commondatadir, $_docdir, $_versinfo, @_cmdincpaths, $TMPPATH, $TMPPATHTID,
     $BINPATH, $RESPATH, $EXEPATH, $DLLPATH, $EXE, $PRJPATH, $STDPATH, $APPROOT, $USRPATH,
     $_collector, $VERBOSE, $APPCLASSID, $PRODUCTCLASSID, $BINALTP, $BINSTDP );

our $_pathdelim = '/';
$TMPPATHTID = -100;

$VERBOSE = 0;
# Replace with unique values for exec and product
$APPCLASSID     = '2ADB5FCE-E293-4B3B-9066-85F967D927A8';
$PRODUCTCLASSID = '4504BBC0-2EB8-4C17-B787-661A5A772383';

sub Packaged { 0 }
sub IsPackaged { 0 }

sub IsGUI { 0 }

sub IsWindows { $^O =~ /^mswin/i }
sub IsLinux { $^O =~ /^linux/i }
sub IsMac { $^O =~ /^darwin/i }

our $PATHSEP = ( IsWindows() ) ? ';' : ':';

sub CAVA_FOLDER_PERSONAL       ()       { 0x0005 }    
sub CAVA_FOLDER_LOCAL_APPDATA  ()       { 0x001C }    
sub CAVA_FOLDER_APPDATA        ()       { 0x001A }     
sub CAVA_FOLDER_COMMON_APPDATA ()       { 0x0023 }

sub GetBinPath { $BINPATH }
sub GetExePath { $EXEPATH }
sub GetExecutable  { $EXE }
sub GetResourcePath { $RESPATH }
sub GetUserPath { $USRPATH }
sub GetResource { Cava::Packager::Resource(@_); }

sub GetSharedLibraryPath { $DLLPATH }
sub SetSharedLibraryPath { $DLLPATH = $_[0]; }
sub GetStandardIncPath { $STDPATH }
sub SetStandardIncPath { $STDPATH = $_[0]; }

sub GetStandardBinPath { $BINSTDP }
sub SetStandardBinPath { $BINSTDP = $_[0]; }

sub GetAlternateBinPath { $BINALTP }
sub SetAlternateBinPath { $BINALTP = $_[0]; }

sub GetAppRoot { $APPROOT }
sub SetAppRoot { $APPROOT = $_[0]; }
sub GetClassId { $APPCLASSID }
sub SetClassId { $APPCLASSID = $_[0]; }
sub GetProductClassId { $PRODUCTCLASSID }
sub SetProductClassId { $PRODUCTCLASSID = $_[0]; }

sub InitCommonControls { 1 }
sub MacSetFrontProcess { 1 }

sub SetVerboseMode { $VERBOSE = $_[0]; }

sub Verbose {
    return if !$VERBOSE;
    my( $sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $hour = sprintf("%02d", $hour);
    $min = sprintf("%02d", $min);
    $sec = sprintf("%02d", $sec);
    my $stamp = qq($hour:$min:$sec);
    my $pid = $$;
    print STDOUT qq(VERBOSE PID $pid - $stamp : $_[1]\n);
}

sub MapFile {
    croak "The Project Path has not been set - required for Cava::Packager::MapFile" if !$PRJPATH;
    $_collector->register_mapped_file($_[0]); # returns filename
}

sub RecordRequire {
    croak "The Project Path has not been set - required for Cava::Packager::RecordRequire" if !$PRJPATH;
    $_collector->set_record_require(1);
}

sub SetProjectPath {
    my $projectpath = shift;
    if($PRJPATH) {
        warn qq(Project path already set to $PRJPATH : new setting will be ignored.);
        return;
    }
    my $usepath = $projectpath;
    $usepath .= '/cava20.cpkgproj'; # if $usepath !~ /[\\\/]cava20\.cpkgproj$/;
    die "Invalid Project Path" if !-f $usepath;
    $PRJPATH = $projectpath;
    my $datafile = qq($projectpath/project/rundata.dat);
    $_collector = Cava::Packager::RuntimeRecorder->new( $datafile );
}

sub GetScriptCommand {
    my ($scriptname, $perloptions, @args) = @_;
    # None Packaged Version Here
    # Packaged version simply dumps $perloptions
    # and returns the packaged executable for
    # the script + args
    my $exec = $^X;
    $exec = '"' . $exec . '"' if ($exec =~ /\s/ && !wantarray);
    my @rvals = ( $exec );
    if(defined($perloptions)) {
        if( ref($perloptions) ) {
            push (@rvals, ( @$perloptions ));
        } else {
            push (@rvals, $perloptions);
        }
    }
    my $script = GetBinPath() . '/' . $scriptname;
    push(@rvals, $script);
    if(@args) {
        push (@rvals, (@args));
    }
    return ( wantarray ) ? @rvals : join(' ', @rvals);
}

sub __real_path {
    my $path = File::Spec->rel2abs(shift);
    $path = Cwd::realpath($path) if -e $path;
    return $path;
}


sub _app_init {

    #----------------------
    # Get MainPaths
    #----------------------
    {
        $EXEPATH = __real_path($0);
        $EXEPATH =~ s/\\/\//g;
        my @paths = split(/[\\\/]/, $EXEPATH);
        $EXE = pop(@paths);
        $BINPATH = join('/', @paths);
        $BINSTDP = $BINALTP = $BINPATH;
        pop(@paths);
        $APPROOT = join('/', @paths);
    }

    #----------------------
    # OS Specific Init
    #----------------------
    my $os = $^O;
    if ( $os =~ /^mswin/i ) {
        _init_mswin();
    } elsif( $os =~ /^darwin/i ) {
        _init_osx();
    } elsif($os =~ /^linux/i ) {
        _init_linux();
    } else {
        croak("Operating system $os is not supported by Cava Packager");
    }
    #----------------------
    # Common init
    #----------------------
    _init_common();
}

sub _init_common {
    #----------------------
    # Fixed Paths
    #----------------------
    {
        my @parts = split(/[\/\\]/, $BINPATH);
        pop(@parts);
        $RESPATH = join('/', @parts) . '/res';
        $DLLPATH = join('/', @parts) . '/dll';
        $STDPATH = join('/', @parts) . '/lib';
        $USRPATH = join('/', @parts) . '/user';
        if(!IsWindows) {
            $BINPATH = '/' . $BINPATH;
            $APPROOT = '/' . $APPROOT;
            $RESPATH = '/' . $RESPATH;
            $DLLPATH = '/' . $DLLPATH;
            $STDPATH = '/' . $STDPATH;
            $USRPATH = '/' . $USRPATH;
        }
    }
}

sub _make_user_temproot {
    my $temproot = undef;
    for my $envtemp( qw( TMPDIR TEMP TMP ) ) {
        $temproot = (defined($ENV{$envtemp}) && (-d $ENV{$envtemp})) ? $ENV{$envtemp} : undef;
        last if defined($temproot);
    }
    $temproot ||= (-d '/tmp') ? '/tmp' : undef;
    die q(No Temporary directory available) if !$temproot;
    mkdir($temproot, 0755) if(!-d $temproot);
    my $userstub = ( IsPackaged ) ? 'cvpk2temp-' : 'cvpk2temp-dev-';
    $userstub .= (IsWindows()) ? getlogin : (getpwuid($<))[0];
    $userstub =~ s/[^A-Za-z0-9\-\_]/_/g;
    $temproot .= '/' . $userstub;
    mkdir($temproot, 0755) if(!-d $temproot);
    die q(No Temporary directory available) if !-d $temproot;
    return $temproot;
}

sub _make_temp_path {
    my $temproot = _make_user_temproot();
    my $tmpstr = _get_random_chars(8);
    my $checkpath = $temproot . $_pathdelim . 'pid-' . $$;
    mkdir($checkpath, 0700) if !-d $checkpath;
    $TMPPATH = CodePath($checkpath);
    $TMPPATHTID = threads->tid if $threads::threads;
    return $TMPPATH;
}

sub _init_mswin {
    $_pathdelim = "\\";
    require Win32;
    
    #----------------------
    # Data Root
    #----------------------
    {
        $_datadir = Win32::GetFolderPath(CAVA_FOLDER_LOCAL_APPDATA, 1);
        $_datadir = Cava::Packager::CodePath($_datadir);
        
        $_commondatadir = Win32::GetFolderPath(CAVA_FOLDER_COMMON_APPDATA, 1);
        $_commondatadir = Cava::Packager::CodePath($_commondatadir);
    }
    #----------------------
    # Documents
    #----------------------
    {
        $_docdir = Win32::GetFolderPath(CAVA_FOLDER_PERSONAL, 1);
        $_docdir = Cava::Packager::CodePath($_docdir);
    }
}

sub _init_osx {
    
    #----------------------
    # Data Root
    #----------------------
    {
        $_datadir = $ENV{HOME} . '/Library/Application Support';
        $_commondatadir = '/Library/Application Support';
    }
    #----------------------
    # Documents
    #----------------------
    {
        $_docdir = $ENV{HOME} . '/Documents';
    }
}

sub _init_linux {
    
    #----------------------
    # Data Root
    #----------------------
    {
        $_datadir = $ENV{HOME};
        $_commondatadir = '/etc';
    }
    #----------------------
    # Documents
    #----------------------
    {
        $_docdir = ( -d qq($ENV{HOME}/Documents) ) ? qq($ENV{HOME}/Documents) : ( -d qq($ENV{HOME}/.Documents) ) ? qq($ENV{HOME}/.Documents) : $ENV{HOME};
    }
}

&_app_init;

sub Resource {
    my $filename = shift;
    return qq($RESPATH/$filename);
}

sub GetUserFile {
    my $filename = shift;
    return qq($USRPATH/$filename);
}

sub UserName {
    my $username = (Cava::Packager::IsWindows()) ? getlogin : (getpwuid($<))[0];
    return $username;
}

sub CodePath {
    my $path = shift;
    # return a perl happy path.
    # forward slash delimiters
    # individual directory/ file names converted 
    # to short form if they contain spaces on win
    return $path if(!Cava::Packager::IsWindows());
    $path =~ s/\\/\//g;
    $path =~ s/^\/\//\\\\/; # unc paths
    return $path if !-e $path;

    my $shortpathstr = Win32::GetShortPathName($path);
    my $longpathstr  = Win32::GetLongPathName($path);
    
    my @shortnames = split(/\//, $shortpathstr);
    my @longnames = split(/\//, $longpathstr);
    
    my $limit = (scalar @shortnames);
    my $index = 0;
    my @outpath = ();
    
    while($index < $limit) {
        if($longnames[$index] =~ /\s/) {
            push(@outpath, $shortnames[$index]);
        } else {
            push(@outpath, $longnames[$index]);
        }
        $index ++;
    }
    my $newpath = join('/', @outpath);
    if($newpath =~ /\w/) {
        return $newpath;
    } else {
        return undef;
    }  
}

sub ShortPath {
    my $path = shift;
    # return a perl happy path.
    # forward slash delimiters
    # individual directory/ file names all shortened
    return $path if(!Cava::Packager::IsWindows());
    $path =~ s/\\/\//g;
    $path =~ s/^\/\//\\\\/; # unc paths
    return $path if !-e $path;
    Win32::GetShortPathName($path);
}

sub DisplayPath {
    my $path = shift;
    return $path if(!Cava::Packager::IsWindows());
    $path =~ s/\//\\/g;
    return $path if !-e $path;
    $path = Win32::GetLongPathName($path);
    return $path;
}

sub GetUserAppDataDir { $_datadir }

sub GetUserDocumentDir { $_docdir }

sub GetCommonAppDataDir { $_commondatadir }

sub GetTempDir {
    if($threads::threads) {
        if($TMPPATHTID == threads->tid) {
            return $TMPPATH;
        } else {
            return _make_temp_path();
        }
    } else {
        return ( defined($TMPPATH) ) ? $TMPPATH : _make_temp_path();
    }
}

sub GetTempFile {
    my $extension = shift || 'tmp';
    $extension =~ s/^\.//;
    my $tempfile = '';
    while($tempfile eq '') {
        my $tmp = Cava::Packager::GetTempDir() . '/' . Cava::Packager::_get_random_chars(8) . '.' . $extension;
        if(!-e $tmp) {
            open my $tfh, ">", $tmp;
            close($tfh);
            $tempfile = $tmp;
        }
    }
    return $tempfile;
}

sub GetFileInINC {
    my $filekey = shift;
    my $rval = undef;
    for ( @INC ) {
        my $checkfile = qq($_/$filekey);
        if(-f $checkfile) {
            $rval = $checkfile;
            last;
        }
    }
    return $rval;
}

# all 'Set' subs are noops when packaged with Cava Packager

sub SetResourcePath {
    my $path = shift;
    $path = __real_path($path);
    $RESPATH = Cava::Packager::CodePath($path);
}

sub SetUserPath {
    my $path = shift;
    $path = __real_path($path);
    $USRPATH = Cava::Packager::CodePath($path);
}

sub SetInfoProductName {
    $_versinfo->{ProductName} = shift;
}

sub SetInfoProductVersion {
    $_versinfo->{ProductVersion} = shift;
}

sub SetInfoVendor {
    $_versinfo->{Vendor} = shift;
}

sub SetInfoCopyright {
    $_versinfo->{Copyright} = shift;
}

sub SetInfoTrademarks {
    $_versinfo->{Trademarks} = shift;
}

sub SetInfoComments {
    $_versinfo->{Comments} = shift;
}

sub SetInfoFileDescription {
    $_versinfo->{FileDescription} = shift;
}

sub SetInfoFileInternalName {
    $_versinfo->{FileInternalName} = shift;
}

sub SetInfoFileVersion {
    $_versinfo->{FileVersion} = shift;
}

sub SetInfoFileOriginalName {
    $_versinfo->{FileOriginalName} = shift;
}

sub GetInfoProductName {
    return $_versinfo->{ProductName};
}

sub GetInfoProductVersion {
    return $_versinfo->{ProductVersion};
}

sub GetInfoVendor {
    return $_versinfo->{Vendor};
}

sub GetInfoCopyright {
    return $_versinfo->{Copyright};
}

sub GetInfoTrademarks {
    return $_versinfo->{Trademarks};
}

sub GetInfoComments {
    return $_versinfo->{Comments};
}

sub GetInfoFileDescription {
    return $_versinfo->{FileDescription};
}

sub GetInfoFileInternalName {
    return $_versinfo->{FileInternalName};
}

sub GetInfoFileVersion {
    return $_versinfo->{FileVersion};
}

sub GetInfoFileOriginalName {
    return $_versinfo->{FileOriginalName};
}

sub _get_random_chars {
    my ($numchars) = @_;
    my @vals = qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9);
    my $buffer = '';
    for (my $i = 1; $i <= $numchars; $i++) {
        my $index = int(rand(scalar @vals));
        $buffer .= $vals[$index];
    }
    return $buffer;
}

#----------------------------------------------------
# Clear out temp dir at app end
#----------------------------------------------------

END {
    # check if the dir we are going to remove is still in the temp path
    # Ya never know!
    my $temproot = File::Spec->tmpdir;
    $temproot = Cava::Packager::CodePath($temproot);
    my $cleanrequired = ( $threads::threads && ($TMPPATHTID != threads->tid)) ? 0 : 1;
    if($cleanrequired && defined($TMPPATH) && $TMPPATH =~ /^\Q$temproot\E/) {
        my $errors;
        my $result;
        remove_tree($TMPPATH, { verbose => 0, error => \$errors, keep_root => 0, result => \$result } );
    }
    $_collector->write if $_collector;
}

#########################################################################################

package Cava::Packager::RuntimeRecorder;

#########################################################################################
use strict;
use warnings;
use Storable;
#use Data::Dumper;

sub new {
    my ($class, $datafile) = @_;
    my $self = bless {}, $class;
    if(!-f $datafile) {
        my $tempdata = { mappedfiles => {}, runrequires => {} };
        Storable::lock_nstore( $tempdata, $datafile );
    }
    $self->{datafile} = $datafile;
    $self->{mapdata} = {};
    $self->{recordrequire} = 0;
    return $self;
}

sub set_record_require { $_[0]->{recordrequire}=$_[1]; }

sub register_mapped_file {
    my($self, $filename) = @_;
    $self->{mapdata}->{$filename} = time;
    return $filename;
}

sub write {
    my $self = shift;
    if(!-f $self->{datafile}) {
        my $tempdata = { mappedfiles => {}, runrequires => {} };
        Storable::lock_nstore( $tempdata, $self->{datafile} );
    }
    my $sdata = Storable::lock_retrieve($self->{datafile});
    if($self->{recordrequire}) {
        my $lastrequired = time;
        foreach my $filekey (sort keys(%INC)) {
            next if $filekey =~ /^(\/|[a-z]:)/i;
            $sdata->{runrequires}->{$filekey} = { lastrequired => $lastrequired, lastlocation => $INC{$filekey} };
        }
    }
    foreach my $filekey (sort keys(%{$self->{mapdata}})) {
        $sdata->{mappedfiles}->{$filekey} = $self->{mapdata}->{$filekey};
    }

    Storable::lock_nstore($sdata, $self->{datafile} );
}

#---------------------------------------------------------------------------------------
# Compatibility Package For Version 1.3 users
#---------------------------------------------------------------------------------------

package Cava::Pack;

my $incpath = $INC{'Cava/Packager.pm'};
$INC{'Cava/Pack.pm'} = $incpath;

our $BINPATH = Cava::Packager::GetBinPath;
our $RESPATH = Cava::Packager::GetResourcePath;
our $EXEPATH = Cava::Packager::GetExePath;
our $EXE     = Cava::Packager::GetExecutable;

sub FreeMem { 1 } 

sub Packaged { Cava::Packager::Packaged() }
sub Resource { Cava::Packager::Resource(@_) }
sub CodePath { Cava::Packager::CodePath(@_) }
sub ShortPath { Cava::Packager::ShortPath(@_) }
sub DisplayPath { Cava::Packager::DisplayPath(@_) }
sub GetUserAppDataDir { Cava::Packager::GetUserAppDataDir(@_) }
sub GetUserDocumentDir { Cava::Packager::GetUserDocumentDir(@_) }
sub GetCommonAppDataDir { Cava::Packager::GetCommonAppDataDir(@_) }
sub GetTempDir { Cava::Packager::GetTempDir(@_) }
sub GetTempFile { Cava::Packager::GetTempFile(@_) }
sub SetResourcePath { Cava::Packager::SetResourcePath(@_) }
sub SetInfoProductName { Cava::Packager::SetInfoProductName(@_) }
sub SetInfoProductVersion { Cava::Packager::SetInfoProductVersion(@_) }
sub SetInfoVendor { Cava::Packager::SetInfoVendor(@_) }
sub SetInfoCopyright { Cava::Packager::SetInfoCopyright(@_) }
sub SetInfoTrademarks { Cava::Packager::SetInfoTrademarks(@_) }
sub SetInfoComments { Cava::Packager::SetInfoComments(@_) }
sub SetInfoFileDescription { Cava::Packager::SetInfoFileDescription(@_) }
sub SetInfoFileInternalName { Cava::Packager::SetInfoFileInternalName(@_) }
sub SetInfoFileVersion { Cava::Packager::SetInfoFileVersion(@_) }
sub SetInfoFileOriginalName { Cava::Packager::SetInfoFileOriginalName(@_) }
sub GetInfoProductName { Cava::Packager::GetInfoProductName(@_) }
sub GetInfoProductVersion { Cava::Packager::GetInfoProductVersion(@_) }
sub GetInfoVendor { Cava::Packager::GetInfoVendor(@_) }
sub GetInfoCopyright { Cava::Packager::GetInfoCopyright(@_) }
sub GetInfoTrademarks { Cava::Packager::GetInfoTrademarks(@_) }
sub GetInfoComments { Cava::Packager::GetInfoComments(@_) }
sub GetInfoFileDescription { Cava::Packager::GetInfoFileDescription(@_) }
sub GetInfoFileInternalName { Cava::Packager::GetInfoFileInternalName(@_) }
sub GetInfoFileVersion { Cava::Packager::GetInfoFileVersion(@_) }
sub GetInfoFileOriginalName { Cava::Packager::GetInfoFileOriginalName(@_) }

1;

__END__

