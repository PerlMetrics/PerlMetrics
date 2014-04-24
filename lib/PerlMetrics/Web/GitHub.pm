package PerlMetrics::Web::GitHub;

=head1 NAME

PerlMetrics::Web::GitHub

=cut

use strict;
use warnings;

use Dancer ':syntax';
use JSON;
use LWP::UserAgent;

my $GH_CLIENT_ID = $ENV{GITHUB_CLIENT_ID};
my $GH_CLIENT_SECRET = $ENV{GITHUB_CLIENT_SECRET};
my $GH_URL_OAUTH = 'https://github.com/login/oauth';

=head1 ROUTES

=head2 GET /github/auth/callback

=cut

get '/github/auth/callback' => sub
{
    #github sends us a code to authenticate. Here we need to retrieve it
    my $code = params->{'code'};
    my $ua = LWP::UserAgent->new;
    my $resp  = $ua->post("$GH_URL_OAUTH/access_token",
        [
         client_id     => $GH_CLIENT_ID,
         client_secret => $GH_CLIENT_SECRET, 
         code          => $code,
         state         => 'x12'
        ]);
    die "error while fetching: ", $resp->status_line
        unless $resp->is_success;
    #parse the query string, we get a access token from github...    
    my %querystr = parse_query_str($resp->decoded_content);
    #grab the access token
    my $acc = $querystr{access_token};
    #make another GET request to github with our access token to get the logged user info
    my $jresp  = $ua->get("https://api.github.com/user?access_token=$acc");
    #decode the JSON gives us
    my $json = from_json($jresp->decoded_content);
    
    #set our session variables to the stuff we got from github
    session 'username' => $json->{login};
    session 'avatar' => $json->{avatar_url};
    session 'logged_in' => true;
    
    redirect "/";
};

sub parse_query_str 
{
  my $str = shift;
    my %in = ();
    if (length ($str) > 0){
          my $buffer = $str;
          my @pairs = split(/&/, $buffer);
          foreach my $pair (@pairs){
               my ($name, $value) = split(/=/, $pair);
               $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
               $in{$name} = $value; 
          }
     }
    return %in;
}

=head2 GET /github/auth/login

=cut

get '/github/auth/login' => sub
{
    redirect "$GH_URL_OAUTH/authorize?&client_id=$GH_CLIENT_ID&state=x12";
};

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut