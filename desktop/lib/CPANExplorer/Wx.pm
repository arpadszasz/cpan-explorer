package CPANExplorer::Wx;

use 5.012;
use utf8;
use warnings FATAL => 'all';
use Moose;
use MooseX::NonMoose;
use Wx ':everything';
use Try::Tiny;
use CPANExplorer::Model;
use CPANExplorer::Wx::Main;

extends 'Wx::App';
with 'CPANExplorer::Role::Setup';

our $cfg;

sub FOREIGNBUILDARGS {
    my $class = shift;
    my $args  = shift;
    $cfg = $args->{cfg};
    return;
}

sub OnInit {
    my $self = shift;

    $self->cfg($cfg);

    $self->SetAppName( $self->cfg->{app_name} );

    try {
        $self->model( CPANExplorer::Model->new( { cfg => $self->cfg } ) );
    }
    catch {
        Wx::LogError('Program initialization error!');
        return 1;
    };

    $self->xrc_resource( Wx::XmlResource->new );
    $self->xrc_resource->InitAllHandlers;
    $self->xrc_resource->Load( $self->cfg->{xrc_file} )
      or die "Can't load XRC file\n";

    $self->frames( { main_frame => '' } );

    my $main_frame = CPANExplorer::Wx::Main->new(
        {
            cfg          => $self->cfg,
            frames       => $self->frames,
            model        => $self->model,
            xrc_resource => $self->xrc_resource,
        }
    );
    $self->SetTopWindow($main_frame);
    $main_frame->Show(1);

    return 1;
}

sub OnExit {
    my $self = shift;
    unlink $self->cfg->{xrc_file};
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
