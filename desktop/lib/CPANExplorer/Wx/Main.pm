package CPANExplorer::Wx::Main;

use 5.012;
use utf8;
use warnings FATAL => 'all';
use Moose;
use MooseX::NonMoose;
use Wx ':everything';
use Wx::Event ':everything';
use Wx::XRC;

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

    EVT_MENU(
        $self,
        Wx::XmlResource::GetXRCID('main_menu_file_quit'),
        sub { $self->_close_window },
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

no Moose;
__PACKAGE__->meta->make_immutable;

1;
