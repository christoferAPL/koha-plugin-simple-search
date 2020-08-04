package Koha::Plugin::Com::ByWaterSolutions::SimpleSearch;

## It's good practice to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

## We will also need to include any Koha libraries we want to access
use C4::Context;
use C4::Auth;
use C4::Search;
#use Koha::Patron;
use Koha::DateUtils;
use Koha::Libraries;
use Koha::Patron::Categories;
#use Koha::Account;
#use Koha::Account::Lines;
##use MARC::Record;
use MARC::Record::MiJ;
use Cwd qw(abs_path);
use Mojo::JSON qw(decode_json);;
use URI::Escape qw(uri_unescape);
use LWP::UserAgent;

## Here is our metadata, some keys are required, some are optional
our $metadata = {
    name            => 'App Search Plugin',
    author          => 'Christofer Zorn',
    date_authored   => '2020-06-05',
    date_updated    => "2020-07-21",
    minimum_version => '19.11',
    maximum_version => undef,
    version         => 1.0,
    description     => 'This plugin implements a simple search api for the mobile app. Forked from N.Clemens code.'
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

## If your plugin needs to add some CSS to the OPAC, you'll want
## to return that CSS here. Don't forget to wrap your CSS in <style>
## tags. By not adding them automatically for you, you'll have a chance
## to include external CSS files as well!
sub opac_head {
    my ( $self ) = @_;

    return q||;
}

## If your plugin needs to add some javascript in the OPAC, you'll want
## to return that javascript here. Don't forget to wrap your javascript in
## <script> tags. By not adding them automatically for you, you'll have a
## chance to include other javascript files if necessary.
sub opac_js {
    my ( $self ) = @_;

    return q||;
}


## If your plugin needs to add some CSS to the staff intranet, you'll want
## to return that CSS here. Don't forget to wrap your CSS in <style>
## tags. By not adding them automatically for you, you'll have a chance
## to include external CSS files as well!
sub intranet_head {
    my ( $self ) = @_;

    return q||;
}

## If your plugin needs to add some javascript in the staff intranet, you'll want
## to return that javascript here. Don't forget to wrap your javascript in
## <script> tags. By not adding them automatically for you, you'll have a
## chance to include other javascript files if necessary.
sub intranet_js {
    my ( $self ) = @_;

    return q||;
}

## This is the 'upgrade' method. It will be triggered when a newer version of a
## plugin is installed over an existing older version of a plugin
sub upgrade {
    my ( $self, $args ) = @_;

    my $dt = dt_from_string();
    $self->store_data( { last_upgraded => $dt->ymd('-') . ' ' . $dt->hms(':') } );

    return 1;
}

## This method will be run just before the plugin files are deleted
## when a plugin is uninstalled. It is good practice to clean up
## after ourselves!
sub uninstall() {
    my ( $self, $args ) = @_;
    return 1;
}

sub simple_search {
    my ($self, $query, $offset, $max_results) = @_;
    $offset = 0 if not defined $offset or $offset < 0;
    $max_results //= 100;
    my $searcher = Koha::SearchEngine::Search->new({ index => 'biblios'});
    my (undef, $results, $hits) = $searcher->simple_search_compat($query,$offset,$max_results);

    return $results;

    #my @return;
    #foreach my $result ( @$results ){
    #    my $marc_record = C4::Search::new_record_from_zebra( 'biblioserver', $result);
    #    push @return, $marc_record->to_mij;
    #}

    #return \@return;
}

## API methods
# If your plugin implements API routes, then the 'api_routes' method needs
# to be implemented, returning valid OpenAPI 2.0 paths serialized as a hashref.
# It is a good practice to actually write OpenAPI 2.0 path specs in JSON on the
# plugin and read it here. This allows to use the spec for mainline Koha later,
# thus making this a good prototyping tool.

sub api_routes {
    my ( $self, $args ) = @_;

    my $spec_str = $self->mbf_read('openapi.json');
    my $spec     = decode_json($spec_str);

    return $spec;
}

sub api_namespace {
    my ( $self ) = @_;
    
    return 'simplesearch';
}

sub static_routes {
    my ( $self, $args ) = @_;

    my $spec_str = $self->mbf_read('staticapi.json');
    my $spec     = decode_json($spec_str);

    return $spec;
}

1;
