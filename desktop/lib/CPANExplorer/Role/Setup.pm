package CPANExplorer::Role::Setup;

use 5.012;
use utf8;
use warnings FATAL => 'all';
use Moose::Role;

has 'cfg'          => ( is  => 'rw',     isa => 'HashRef' );
has 'frames'       => ( is  => 'rw',     isa => 'HashRef' );
has 'xrc_resource' => ( is  => 'rw',     isa => 'Wx::XmlResource' );
has 'model'        => ( is  => 'rw',     isa => 'CPANExplorer::Model' );

sub BUILD { }

1;
