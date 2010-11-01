#!/usr/bin/perl
# eijiro.pl - http://www.alc.co.jp/eijiro/
use strict;
use Carp qw(verbose);
use Furl;
use URI::Escape;
use HTML::FormatText;
use HTML::TreeBuilder;
use Encode;
#use Term::ReadLine;
#use Term::ReadLine::Perl;

our $VERSION = '1.0';

my $api_host = 'eow.alc.co.jp';

my $api_input_encoding  = 'UTF-8';
my $api_output_encoding = 'UTF-8';

my $term_encoding = 'UTF-8';

my $historyfile = $ENV{HOME} . '/.eijirohistory';
my $pager       = $ENV{PAGER} || 'less';

my $ua = Furl->new(
    agent   => "EijiroClient/$VERSION",
    headers => ['Accept-Encoding' => 'gzip'],
);


# Terminal mode / Argv mode
if (@ARGV) {
    my $line = join ' ', @ARGV;
    translate($line);
} elsif(-t STDOUT) {
    require Term::ReadLine;
    require Term::ReadLine::Perl;

    my $term = Term::ReadLine->new('Eijiro');
    # read history
    {
        open my $fh, "<", $historyfile or last;
        my @h = <$fh>;
        chomp @h;
        my %seen;
        $term->addhistory($_) foreach (grep { /\S/ && !$seen{$_}++ } @h);
    }
    # readline & translate
    while ( defined ($_ = $term->readline('eijiro> ')) ) {
        next if !/\S/;
        last if /^!exit/;
        translate($_);
        # Add history
        {
            open my $fh, '>>', $historyfile or die $!;
            print $fh "$_\n";
        }
        $term->addhistory($_);
    }
    print "\n";
}

sub translate {
    my $line = shift or return;

    my $str = decode($term_encoding, $line);
    my $path_query = sprintf '/%s/%s',
        uri_escape(encode($api_input_encoding, $str)), $api_input_encoding;


    print "request: $line\n";
    my $res = $ua->request(
        host       => $api_host,
        path_query => $path_query,
    );

    my $content = decode($api_output_encoding, $res->content);

    my $parser    = HTML::TreeBuilder->new();
    my $formatter = HTML::FormatText->new( leftmargin => 0 );

    my $html   = $parser->parse($content);
    my $result = $html->find_by_attribute(id => "resultsArea") || $html;

    my $text = $formatter->format($result);
    
    my $output;
    if( -t STDOUT ) {
        open my $p, "| $pager";
        $output = $p;
    }
    else {
        $output = \*STDOUT;
    }

    print $output encode($term_encoding, $text);
    return;
}
