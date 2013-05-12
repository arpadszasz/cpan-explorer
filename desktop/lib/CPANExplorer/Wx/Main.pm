package CPANExplorer::Wx::Main;

use 5.012;
use utf8;
use warnings FATAL => 'all';
use Moose;
use MooseX::NonMoose;
use Wx ':everything';
use Wx::Event ':everything';
use Wx::XRC;
use CPANExplorer::Wx::Preferences;
use CPANExplorer::Wx::About;
use HTTP::Tiny;
use JSON;
use IPC::Open3;
use ExtUtils::Installed;

extends 'Wx::Frame';
with 'CPANExplorer::Role::Setup';

sub FOREIGNBUILDARGS {
    return;
}

after BUILD => sub {
    my $self = shift;
    $self->initialize;
    return $self;
};

sub initialize {
    my $self = shift;

    $self->xrc_resource->LoadFrame( $self, undef, 'main_frame' );
    $self->frames->{main_frame} = $self->FindWindow('main_frame');

    $self->FindWindow('main_textctrl_search')->SetFocus();

    $self->_show_preferences_dialog unless -r $self->cfg->{config_file};

    EVT_MENU(
        $self,
        Wx::XmlResource::GetXRCID('main_menu_file_preferences'),
        sub { $self->_show_preferences_dialog },
    );

    EVT_MENU(
        $self,
        Wx::XmlResource::GetXRCID('main_menu_file_quit'),
        sub { $self->_close_window },
    );

    EVT_MENU(
        $self,
        Wx::XmlResource::GetXRCID('main_menu_help_about'),
        sub { $self->_show_about_dialog },
    );

    EVT_BUTTON(
        $self,
        Wx::XmlResource::GetXRCID('main_button_search'),
        sub { $self->_search_module },
    );

    EVT_TEXT_ENTER(
        $self,
        Wx::XmlResource::GetXRCID('main_textctrl_search'),
        sub { $self->_search_module },
    );

    EVT_LIST_ITEM_RIGHT_CLICK(
        $self,
        Wx::XmlResource::GetXRCID('main_listctrl_search'),
        sub {
            my ( $this, $event ) = @_;

            return unless $event->GetIndex >= 0;

            my $distribution = $self->FindWindow('main_listctrl_search')
              ->GetItem( $event->GetData - 1, 1 )->GetText;
            $distribution =~ s/-/::/g;

            my $menu = Wx::Menu->new;
            $menu->Append( 1, 'Install' );
            $menu->Append( 2, 'Install without testing' );
            $menu->Append( 3, 'Force install' );
            $this->PopupMenu(
                $menu,
                $event->GetPoint->x,
                $event->GetPoint->y + 50
            );

            EVT_MENU( $this, 1,
                sub { $self->_install_module($distribution) } );
            EVT_MENU( $this, 2,
                sub { $self->_install_module( $distribution, 'notest' ) } );
            EVT_MENU( $this, 3,
                sub { $self->_install_module( $distribution, 'force' ) } );

            return;
        },
    );

    EVT_LIST_ITEM_RIGHT_CLICK(
        $self,
        Wx::XmlResource::GetXRCID('main_listctrl_installed'),
        sub {
            my ( $this, $event ) = @_;

            return unless $event->GetIndex >= 0;

            my $distribution = $self->FindWindow('main_listctrl_installed')
              ->GetItem( $event->GetData - 1, 1 )->GetText;
            $distribution =~ s/-/::/g;

            my $menu = Wx::Menu->new;
            $menu->Append( 1, 'Remove' );
            $this->PopupMenu(
                $menu,
                $event->GetPoint->x,
                $event->GetPoint->y + 50
            );

            EVT_MENU( $this, 1,
                sub { $self->_remove_module($distribution) } );

            return;
        },
    );

    EVT_NOTEBOOK_PAGE_CHANGED(
        $self,
        Wx::XmlResource::GetXRCID('main_notebook'),
        sub {
            my $self = shift;
            if ($self->FindWindow('main_notebook')->GetSelection == 1) {
                $self->_list_installed;
            }
            elsif ($self->FindWindow('main_notebook')->GetSelection == 2) {
                $self->_list_updates;
            }
            return;
        }
    );

    EVT_CLOSE( $self, sub { $self->_close_window } );

    return;
}

sub _close_window {
    my $self = shift;

    my $dialog = Wx::MessageDialog->new(
        $self->frames->{main_frame}, ("Close application?"),
        '',
        wxNO_DEFAULT | wxYES_NO | wxICON_QUESTION
    );
    my $selection = $dialog->ShowModal;

    return if $selection == wxID_NO;

    $self->frames->{main_frame}->Destroy;

    return;
}

sub _show_about_dialog {
    my $self = shift;

    CPANExplorer::Wx::About->new(
        {
            cfg          => $self->cfg,
            frames       => $self->frames,
            model        => $self->model,
            xrc_resource => $self->xrc_resource,
        }
    )->Show(1);

    return;
}

sub _show_preferences_dialog {
    my $self = shift;

    CPANExplorer::Wx::Preferences->new(
        {
            cfg          => $self->cfg,
            frames       => $self->frames,
            model        => $self->model,
            xrc_resource => $self->xrc_resource,
        }
    )->Show(1);

    return;
}

sub _search_module {
    my $self = shift;

    my $listctrl = $self->FindWindow('main_listctrl_search');
    $listctrl->ClearAll;

    my $module = $self->FindWindow('main_textctrl_search')->GetValue;

    # Adapted by code from Toby Inkster
    # http://blogs.perl.org/users/toby_inkster/2013/03/not-using-that-any-more.html
    my $query = {
        size   => 5000,
        fields => [qw(distribution version)],
        query  => { match_all => {} },
        filter => {
            and => [
                { term => { "release.dependency.module" => $module } },
                { term => { "release.status"            => "latest" } },
            ]
        }
    };

    Wx::BusyCursor->new;

    eval {
        my $response = "HTTP::Tiny"->new->post(
            "http://api.metacpan.org/v0/release/_search" => {
                content => to_json($query),
                headers => {
                    "Content-Type" => "application/json",
                },
            },
        );

        my $result = from_json( $response->{content} );

        $listctrl->Show(0);

        $listctrl->InsertColumn( 0, '#' );
        $listctrl->InsertColumn( 1, 'Distribution' );
        $listctrl->InsertColumn( 2, 'Version' );

        $listctrl->SetColumnWidth( 0, 30 );
        $listctrl->SetColumnWidth( 1, 250 );
        $listctrl->SetColumnWidth( 2, 50 );

        foreach ( 1 .. ( scalar @{ $result->{hits}->{hits} } ) ) {
            my $dist = $result->{hits}->{hits}->[ $_ - 1 ];

            my $row = $listctrl->InsertStringImageItem(
                $_,
                $_,
                0
            );
            $listctrl->SetItemData( $row, $_ );
            $listctrl->SetItem( $row, 1, $dist->{fields}->{distribution} );
            $listctrl->SetItem( $row, 2, $dist->{fields}->{version} );
        }

        $listctrl->Show(1);
    };

    if ($@) {
        my $dialog = Wx::MessageDialog->new(
            $self->frames->{top_level_frame},
            "MetaCPAN API search error!\n$@",
            'Search error',
            wxOK | wxICON_ERROR
        );
        $dialog->ShowModal;
    }

    return;
}

sub _install_module {
    my $self         = shift;
    my $distribution = shift;
    my $option       = shift;

    $self->FindWindow('main_textctrl_terminal')->Clear;

    my $flags;
    given ($option) {
        when ('notest') { $flags = '-n' }
        when ('force')  { $flags = '-f' }
        default         { $flags = '' }
    }

    my $cpanm = $self->cfg->{defaults}->{perl}->{path} . '/cpanm';

    Wx::BusyCursor->new;

    my ( $stdout_fh, $stdin_fh );
    my $pid = open3( $stdin_fh, $stdout_fh, $stdout_fh,
        "$cpanm $flags $distribution" );

    my $status;
    while (<$stdout_fh>) {
        $self->FindWindow('main_textctrl_terminal')->AppendText($_);
        $status = $_;
    }

    my $dialog = Wx::MessageDialog->new(
        $self->frames->{main_frame},
        $status,
        '',
        wxOK | wxICON_INFORMATION
    );
    $dialog->ShowModal;

    waitpid($pid, 0);

    return;
}

sub _list_installed {
    my $self = shift;

    my $listctrl = $self->FindWindow('main_listctrl_installed');
    $listctrl->ClearAll;
    $listctrl->Show(0);
    $listctrl->InsertColumn( 0, '#' );
    $listctrl->InsertColumn( 1, 'Distribution' );
    $listctrl->InsertColumn( 2, 'Version' );
    $listctrl->SetColumnWidth( 0, 30 );
    $listctrl->SetColumnWidth( 1, 250 );
    $listctrl->SetColumnWidth( 2, 50 );

    Wx::BusyCursor->new;

    my $installed = ExtUtils::Installed->new;
    my $count = 1;
    foreach ($installed->modules) {
        my $row = $listctrl->InsertStringImageItem(
            $count,
            $count,
            0
        );
        $listctrl->SetItemData( $row, $count );
        $listctrl->SetItem( $row, 1, $_ );
        $listctrl->SetItem( $row, 2, $installed->version($_) );

        $count++;
    }

    $listctrl->Show(1);

    return;
}

sub _remove_module {
    my $self         = shift;
    my $distribution = shift;

    $self->FindWindow('main_textctrl_terminal')->Clear;

    my $pm_uninstall
      = $self->cfg->{defaults}->{perl}->{path} . '/pm-uninstall';
    if ( !-r $pm_uninstall ) {
        $pm_uninstall
          = $self->cfg->{defaults}->{perl}->{path}
          . '../site/bin/pm-uninstall';
    }

    Wx::BusyCursor->new;

    my ( $stdout_fh, $stdin_fh );
    my $pid = open3( $stdin_fh, $stdout_fh, $stdout_fh,
        "$pm_uninstall -f $distribution" );

    my $status;
    while (<$stdout_fh>) {
        $self->FindWindow('main_textctrl_terminal')->AppendText($_);
        $status = $_;
    }

    my $dialog = Wx::MessageDialog->new(
        $self->frames->{main_frame},
        $status,
        '',
        wxOK | wxICON_INFORMATION
    );
    $dialog->ShowModal;

    waitpid($pid, 0);

    return;
}

sub _list_updates {
    my $self = shift;

    my $listctrl = $self->FindWindow('main_listctrl_updates');
    $listctrl->ClearAll;
    $listctrl->Show(0);
    $listctrl->InsertColumn( 0, '#' );
    $listctrl->InsertColumn( 1, 'Distribution' );
    $listctrl->InsertColumn( 2, 'Old version' );
    $listctrl->InsertColumn( 3, 'New version' );
    $listctrl->SetColumnWidth( 0, 30 );
    $listctrl->SetColumnWidth( 1, 210 );
    $listctrl->SetColumnWidth( 2, 70 );
    $listctrl->SetColumnWidth( 3, 70 );

    my $cpanoutdated
      = $self->cfg->{defaults}->{perl}->{path} . '/cpan-outdated';

    Wx::BusyCursor->new;

    my ( $stdout_fh, $stdin_fh );
    my $pid = open3( $stdin_fh, $stdout_fh, $stdout_fh,
        "$cpanoutdated --verbose" );

    my $count = 1;
    while (<$stdout_fh>) {
        if (/^(.+?)\s+(.+?)\s+(.+?)\s/) {
            my $row = $listctrl->InsertStringImageItem(
                $count,
                $count,
                0
            );
            $listctrl->SetItemData( $row, $count );
            $listctrl->SetItem( $row, 1, $1 );
            $listctrl->SetItem( $row, 2, $2 );
            $listctrl->SetItem( $row, 3, $3 );

            $count++;
        }
    }

    $listctrl->Show(1);
    
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
