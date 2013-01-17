package CPANExplorer::Wx::Preferences;

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
        'preferences_frame'
    );
    $self->frames->{preferences_frame} = $self->FindWindow('preferences_frame');

    $self->frames->{main_frame}->Disable;

    EVT_BUTTON(
        $self,
        $self->FindWindow('preferences_button_perl_browse'),
        sub {
            my $dialog = Wx::DirDialog->new(
                $self->FindWindow('preferences_frame'),
                'Select Perl installation path',
            );
            $dialog->ShowModal;
            $self->FindWindow('preferences_textctrl_perl_path')
              ->SetValue( $dialog->GetPath );
            return;
        }
    );

    EVT_BUTTON(
        $self,
        $self->FindWindow('preferences_button_save'),
        sub { $self->_save_preferences }
    );

    EVT_BUTTON(
        $self,
        $self->FindWindow('preferences_button_cancel'),
        sub { $self->_close_window }
    );

    EVT_CLOSE( $self, sub { $self->_close_window } );

    return;
}

sub _save_preferences {
    my $self = shift;
    $self->_close_window;
    return;
}

sub _close_window {
    my $self = shift;
    $self->frames->{preferences_frame}->Destroy;
    $self->frames->{main_frame}->Enable;
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
