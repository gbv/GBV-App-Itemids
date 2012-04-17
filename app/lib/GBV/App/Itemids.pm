use strict;
use warnings;
package GBV::App::Itemids;

use PICA::Record;
use PICA::Source;
use LWP::Simple qw(get);

use parent qw(Plack::App::SeeAlso);

our $ShortName   = 'GBV Exemplar-IDs';
our $Description = <<TXT;
Dieser SeeAlso-Server versucht verschiedene Exemplar-IDs im GBV aufeinander zu mappen.
Unterstützt werden PPN, EPN und Verbuchungsnummern/Barcodes (BAR).
TXT

our $Examples    = [
    { id => 'opac-de-7:ppn:309980437' },
    { id => 'opac-de-7:epn:775384704' },
    { id => 'opac-de-7:bar:7$219419868' },
];

our %opacs = (
    'opac-de-7'     => 'http://opac.sub.uni-goettingen.de/DB=1/',
    'opac-de-luen4' => 'http://opac.uni-lueneburg.de/DB=1/',
    'opac-de-hil2'  => 'http://opac.lbs-hildesheim.gbv.de/DB=1/',
);

sub add_barcode {
    my ($self, $resp, $item, $dbkey) = @_;

    if (my $f209G = $item->field('209G/..')) {
        my $bar = $f209G->sf('a');
        $self->push_seealso($resp, "$dbkey:bar:$bar", $bar);
    }
}

sub add_epn {
    my ($self, $resp, $item, $dbkey) = @_;
    my $label    = $dbkey . ':epn:' . $item->epn;
    my $signatur = 'Signatur: ' . ($item->sf('209A/..$a') || '???');
    $self->push_seealso($resp, $label, $signatur, "http://uri.gbv.de/document/$label");
}

sub query {
    my $self = shift;

    # Anfrage-ID parsen
    my $id = lc(shift);
    return unless $id =~ /^([a-z0-9-]+):(ppn|epn|bar):([0-9][0-9x\$]+)$/;
    my ($dbkey,$type,$localid) = ($1,$2,$3);

    return unless $opacs{$dbkey};
    my $resp = [$id,[],[],[]];

    # Mapping ermitteln
#    if ($type eq 'ppn') {
#        # via unAPI
#        my $url = "http://unapi.gbv.de/?id=$id&format=pp";
#        my $pica = eval { PICA::Record->new( get($url) ); } || return;
#        # TODO Fix bug in PICA::Record # print STDERR "ITEM: $pica\n";
#        foreach my $item ($pica->items) {
#            $self->add_epn($resp, $item, $dbkey);
#            $self->add_barcode($resp, $item, $dbkey);
#        }
#    } else {
        # via SRU
        my $sru = PICA::Source->new( SRU => "http://sru.gbv.de/$dbkey" ); 
        my ($pica) = $sru->cqlQuery( "pica.$type=$localid", Limit => 1 )->records();
        return unless $pica;

        if ($type eq 'ppn') {
            foreach my $item ($pica->items) {
                $self->add_epn($resp, $item, $dbkey);
                $self->add_barcode($resp, $item, $dbkey);
            }
        } else {
            my $label = "$dbkey:ppn:" . $pica->ppn;
            $self->push_seealso( $resp, $label, '', "http://uri.gbv.de/document/$label" );

            if ( $type eq 'bar' ) {
                my ($item) = grep { 
                    # BUGFIX?!
                    ($_->sf('209G/..$a') || '' ) eq $localid
                } $pica->items;
                $self->add_epn($resp, $item, $dbkey) if $item;
            } else {
                my ($item) = grep { $_->epn eq $localid } $pica->items;
                $self->add_barcode($resp, $item, $dbkey);
            }
        }
#    }

    return $resp;
}

1;
