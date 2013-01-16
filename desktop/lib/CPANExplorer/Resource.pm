package CPANExplorer::Resource;

use 5.012;
use utf8;
use warnings FATAL => 'all';
use Moose;
use Data::Section '-setup';
use File::Temp;
use MIME::Base64;

my %tempfile;

sub xrc_file {
    my $self = shift;

    my $tempfile = File::Temp->new( UNLINK => 0, SUFFIX => '.dat' );

    my $xrc = $self->section_data('xrc');
    print $tempfile $$xrc;
    close $tempfile;

    return $tempfile;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__DATA__
__[ xrc ]__
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<resource xmlns="http://www.wxwindows.org/wxxrc" version="2.3.0.1">
	<object class="wxFrame" name="main_frame">
		<style>wxCAPTION|wxCLOSE_BOX|wxMAXIMIZE_BOX|wxMINIMIZE_BOX|wxRESIZE_BORDER|wxSYSTEM_MENU|wxTAB_TRAVERSAL</style>
		<size>700,550</size>
		<title>CPAN Explorer</title>
		<centered>1</centered>
		<object class="wxMenuBar" name="main_menubar">
			<label>MyMenuBar</label>
			<object class="wxMenu" name="main_menu_file">
				<label>_File</label>
				<object class="wxMenuItem" name="main_menu_file_preferences">
					<label>_Preferences</label>
					<help></help>
				</object>
				<object class="wxMenuItem" name="main_menu_file_quit">
					<label>_Quit</label>
					<help></help>
				</object>
			</object>
			<object class="wxMenu" name="main_menu_help">
				<label>_Help</label>
				<object class="wxMenuItem" name="main_menu_help_about">
					<label>_About</label>
					<help></help>
				</object>
			</object>
		</object>
	</object>
</resource>
