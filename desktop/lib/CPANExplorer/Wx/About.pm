package CPANExplorer::Wx::About;

use 5.012;
use utf8;
use warnings FATAL => 'all';
use Moose;
use MooseX::NonMoose;
use Wx ':everything';
use Wx::Event ':everything';
use Wx::XRC;
use POSIX 'strftime';

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

    $self->xrc_resource->LoadFrame(
        $self, $self->frames->{main_frame},
        'about_frame'
    );
    $self->frames->{about_frame} = $self->FindWindow('about_frame');

    $self->frames->{main_frame}->Disable;

    my $program_version = $self->FindWindow('about_statictext_version');
    $program_version->SetLabel(
        $program_version->GetLabel . ' ' . $self->cfg->{program_version} );

    my $current_year = strftime( '%Y', localtime );
    my $copyright
      = $current_year > $self->cfg->{copyright_start}
      ? ( $self->cfg->{copyright_start} . '-' . $current_year )
      : $self->cfg->{copyright_start};
    my $program_copyright = $self->FindWindow('about_statictext_copyright');
    $program_copyright->SetLabel(
        $program_copyright->GetLabel . ' ' . $copyright );

    EVT_BUTTON(
        $self,
        $self->FindWindow('about_button_close'),
        sub { $self->_close_window }
    );

    EVT_CLOSE( $self, sub { $self->_close_window } );

    return;
}

sub _close_window {
    my $self = shift;
    $self->frames->{about_frame}->Destroy;
    $self->frames->{main_frame}->Enable;
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
