package CPANExplorer::Model;

use 5.012;
use utf8;
use warnings FATAL => 'all';
use Moose;

has cfg => ( is => 'rw' );

sub BUILD {}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
