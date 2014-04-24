package PerlMetrics::Web;

=head1 NAME

PerlMetrics::Web

=cut

use strict;
use warnings;

use Dancer ':syntax';

our $VERSION = '0.1';

=head1 ROUTES

=head2 GET /about

=cut

get '/about' => sub
{
    template 'markdown', { file => config->{public} . '/md/about.md' };
};

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
