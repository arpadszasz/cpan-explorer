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

            my $menu = Wx::Menu->new;
            $menu->Append( 1, 'Install' );
            $menu->Append( 2, 'Install without testing' );
            $menu->Append( 3, 'Force install' );
            $this->PopupMenu(
                $menu,
                $event->GetPoint->x,
                $event->GetPoint->y + 100
            );

            EVT_MENU( $this, 1, sub { $self->_install_module() } );
            EVT_MENU( $this, 2, sub { $self->_install_module('notest') } );
            EVT_MENU( $this, 3, sub { $self->_install_module('force') } );

            return;
        },
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

    return;
}

sub _install_module {
    my $self = shift;

    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
