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
		<size>600,400</size>
		<bg>#f9f9f8</bg>
		<title>CPAN Explorer</title>
		<centered>1</centered>
		<aui_managed>0</aui_managed>
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
		<object class="wxBoxSizer">
			<orient>wxVERTICAL</orient>
			<object class="sizeritem">
				<option>1</option>
				<flag>wxEXPAND | wxALL</flag>
				<border>5</border>
				<object class="wxNotebook" name="main_notebook">
					<bg>#f9f9f8</bg>
					<object class="notebookpage">
						<label>Search</label>
						<selected>1</selected>
						<object class="wxPanel" name="m_panel3">
							<style>wxTAB_TRAVERSAL</style>
							<bg>#f9f9f8</bg>
							<object class="wxBoxSizer">
								<orient>wxVERTICAL</orient>
								<object class="sizeritem">
									<option>0</option>
									<flag>wxEXPAND</flag>
									<border>5</border>
									<object class="wxBoxSizer">
										<orient>wxHORIZONTAL</orient>
										<object class="spacer">
											<option>1</option>
											<flag>wxEXPAND</flag>
											<border>5</border>
											<size>0,0</size>
										</object>
										<object class="sizeritem">
											<option>0</option>
											<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
											<border>5</border>
											<object class="wxTextCtrl" name="main_textctrl_search">
												<style>wxTE_PROCESS_ENTER</style>
												<size>250,-1</size>
												<value></value>
											</object>
										</object>
										<object class="sizeritem">
											<option>0</option>
											<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
											<border>5</border>
											<object class="wxButton" name="main_button_search">
												<label>_Search</label>
												<default>0</default>
											</object>
										</object>
										<object class="spacer">
											<option>1</option>
											<flag>wxEXPAND</flag>
											<border>5</border>
											<size>0,0</size>
										</object>
									</object>
								</object>
								<object class="sizeritem">
									<option>1</option>
									<flag>wxEXPAND</flag>
									<border>5</border>
									<object class="wxBoxSizer">
										<orient>wxVERTICAL</orient>
										<object class="sizeritem">
											<option>1</option>
											<flag>wxALL|wxEXPAND</flag>
											<border>5</border>
											<object class="wxListCtrl" name="main_listctrl_search">
												<style>wxLC_HRULES|wxLC_REPORT|wxLC_SINGLE_SEL|wxLC_VRULES</style>
											</object>
										</object>
									</object>
								</object>
							</object>
						</object>
					</object>
					<object class="notebookpage">
						<label>Installed</label>
						<selected>0</selected>
						<object class="wxPanel" name="m_panel4">
							<style>wxTAB_TRAVERSAL</style>
							<object class="wxBoxSizer">
								<orient>wxVERTICAL</orient>
								<object class="sizeritem">
									<option>1</option>
									<flag>wxALL|wxEXPAND</flag>
									<border>5</border>
									<object class="wxListCtrl" name="main_listctrl_installed">
										<style>wxLC_HRULES|wxLC_REPORT|wxLC_SINGLE_SEL|wxLC_VRULES</style>
										<size>-1,200</size>
									</object>
								</object>
							</object>
						</object>
					</object>
					<object class="notebookpage">
						<label>Updates</label>
						<selected>0</selected>
						<object class="wxPanel" name="m_panel5">
							<style>wxTAB_TRAVERSAL</style>
							<object class="wxBoxSizer">
								<orient>wxVERTICAL</orient>
								<object class="sizeritem">
									<option>0</option>
									<flag>wxEXPAND</flag>
									<border>5</border>
									<object class="wxBoxSizer">
										<orient>wxHORIZONTAL</orient>
										<object class="spacer">
											<option>1</option>
											<flag>wxEXPAND</flag>
											<border>5</border>
											<size>0,0</size>
										</object>
										<object class="sizeritem">
											<option>0</option>
											<flag>wxALL</flag>
											<border>5</border>
											<object class="wxButton" name="main_button_update">
												<label>_Update all</label>
												<default>0</default>
											</object>
										</object>
										<object class="spacer">
											<option>1</option>
											<flag>wxEXPAND</flag>
											<border>5</border>
											<size>0,0</size>
										</object>
									</object>
								</object>
								<object class="sizeritem">
									<option>1</option>
									<flag>wxALL|wxEXPAND</flag>
									<border>5</border>
									<object class="wxListCtrl" name="main_listctrl_updates">
										<style>wxLC_HRULES|wxLC_REPORT|wxLC_SINGLE_SEL|wxLC_VRULES</style>
										<size>-1,200</size>
									</object>
								</object>
							</object>
						</object>
					</object>
				</object>
			</object>
			<object class="sizeritem">
				<option>0</option>
				<flag>wxEXPAND</flag>
				<border>5</border>
				<object class="wxBoxSizer">
					<orient>wxVERTICAL</orient>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxALL</flag>
						<border>5</border>
						<object class="wxStaticText" name="m_staticText4">
							<label>Output</label>
							<wrap>-1</wrap>
						</object>
					</object>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxALL|wxEXPAND</flag>
						<border>5</border>
						<object class="wxTextCtrl" name="main_textctrl_terminal">
							<style>wxTE_MULTILINE</style>
							<size>-1,80</size>
							<bg>#4c4c4c</bg>
							<fg>#ffffff</fg>
							<value></value>
						</object>
					</object>
				</object>
			</object>
		</object>
	</object>
	<object class="wxFrame" name="about_frame">
		<style>wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL</style>
		<size>300,120</size>
		<title></title>
		<centered>1</centered>
		<aui_managed>0</aui_managed>
		<object class="wxPanel" name="m_panel1">
			<style>wxTAB_TRAVERSAL</style>
			<object class="wxBoxSizer">
				<orient>wxVERTICAL</orient>
				<object class="sizeritem">
					<option>1</option>
					<flag>wxEXPAND</flag>
					<border>5</border>
					<object class="wxBoxSizer">
						<orient>wxHORIZONTAL</orient>
						<object class="spacer">
							<option>1</option>
							<flag>wxEXPAND</flag>
							<border>5</border>
							<size>0,0</size>
						</object>
						<object class="sizeritem">
							<option>0</option>
							<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
							<border>5</border>
							<object class="wxStaticText" name="about_statictext_version">
								<label>CPAN Explorer - version</label>
								<wrap>-1</wrap>
							</object>
						</object>
						<object class="spacer">
							<option>1</option>
							<flag>wxEXPAND</flag>
							<border>5</border>
							<size>0,0</size>
						</object>
					</object>
				</object>
				<object class="sizeritem">
					<option>1</option>
					<flag>wxEXPAND</flag>
					<border>5</border>
					<object class="wxBoxSizer">
						<orient>wxHORIZONTAL</orient>
						<object class="spacer">
							<option>1</option>
							<flag>wxEXPAND</flag>
							<border>5</border>
							<size>0,0</size>
						</object>
						<object class="sizeritem">
							<option>0</option>
							<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
							<border>5</border>
							<object class="wxStaticText" name="about_statictext_copyright">
								<label>(C)</label>
								<wrap>-1</wrap>
							</object>
						</object>
						<object class="spacer">
							<option>1</option>
							<flag>wxEXPAND</flag>
							<border>5</border>
							<size>0,0</size>
						</object>
					</object>
				</object>
				<object class="sizeritem">
					<option>1</option>
					<flag>wxEXPAND</flag>
					<border>5</border>
					<object class="wxBoxSizer">
						<orient>wxHORIZONTAL</orient>
						<object class="spacer">
							<option>1</option>
							<flag>wxEXPAND</flag>
							<border>5</border>
							<size>0,0</size>
						</object>
						<object class="sizeritem">
							<option>0</option>
							<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
							<border>5</border>
							<object class="wxButton" name="about_button_close">
								<label>_Close</label>
								<default>0</default>
							</object>
						</object>
						<object class="spacer">
							<option>1</option>
							<flag>wxEXPAND</flag>
							<border>5</border>
							<size>0,0</size>
						</object>
					</object>
				</object>
			</object>
		</object>
	</object>
	<object class="wxFrame" name="preferences_frame">
		<style>wxCAPTION|wxCLOSE_BOX|wxFRAME_FLOAT_ON_PARENT|wxSYSTEM_MENU|wxTAB_TRAVERSAL</style>
		<size>450,100</size>
		<bg>#f9f9f8</bg>
		<title></title>
		<centered>1</centered>
		<aui_managed>0</aui_managed>
		<object class="wxBoxSizer">
			<orient>wxVERTICAL</orient>
			<object class="sizeritem">
				<option>1</option>
				<flag>wxEXPAND | wxALL</flag>
				<border>5</border>
				<object class="wxPanel" name="m_panel2">
					<style>wxTAB_TRAVERSAL</style>
					<bg>#f9f9f8</bg>
					<object class="wxBoxSizer">
						<orient>wxHORIZONTAL</orient>
						<object class="spacer">
							<option>1</option>
							<flag>wxEXPAND</flag>
							<border>5</border>
							<size>0,0</size>
						</object>
						<object class="sizeritem">
							<option>0</option>
							<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
							<border>5</border>
							<object class="wxStaticText" name="m_staticText3">
								<bg>#f9f9f8</bg>
								<label>Perl installation</label>
								<wrap>-1</wrap>
							</object>
						</object>
						<object class="sizeritem">
							<option>0</option>
							<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
							<border>5</border>
							<object class="wxTextCtrl" name="preferences_textctrl_perl_path">
								<size>220,-1</size>
								<value></value>
								<maxlength>0</maxlength>
							</object>
						</object>
						<object class="sizeritem">
							<option>0</option>
							<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
							<border>5</border>
							<object class="wxButton" name="preferences_button_perl_browse">
								<label>_Browse</label>
								<default>0</default>
							</object>
						</object>
						<object class="spacer">
							<option>1</option>
							<flag>wxEXPAND</flag>
							<border>5</border>
							<size>0,0</size>
						</object>
					</object>
				</object>
			</object>
			<object class="sizeritem">
				<option>1</option>
				<flag>wxEXPAND</flag>
				<border>5</border>
				<object class="wxBoxSizer">
					<orient>wxHORIZONTAL</orient>
					<object class="spacer">
						<option>1</option>
						<flag>wxEXPAND</flag>
						<border>5</border>
						<size>0,0</size>
					</object>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
						<border>5</border>
						<object class="wxButton" name="preferences_button_save">
							<label>_Save</label>
							<default>0</default>
						</object>
					</object>
					<object class="sizeritem">
						<option>0</option>
						<flag>wxALIGN_CENTER_VERTICAL|wxALL</flag>
						<border>5</border>
						<object class="wxButton" name="preferences_button_cancel">
							<label>_Cancel</label>
							<default>0</default>
						</object>
					</object>
					<object class="spacer">
						<option>1</option>
						<flag>wxEXPAND</flag>
						<border>5</border>
						<size>0,0</size>
					</object>
				</object>
			</object>
		</object>
	</object>
</resource>
