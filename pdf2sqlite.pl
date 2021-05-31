#!/usr/bin/perl

use strict;

my $infile = $ARGV[0];

if (! ( $infile && -r $infile )) {
    die("Il file [".$infile."] non esiste o non e' leggibile!")
}

# Questo è il path a pdftotext
my $pdftotext = '/usr/bin/pdftotext';
my @regioni = ('ABRUZZO', 'MOLISE', 'MARCHE', 'PUGLIA','LAZIO','UMBRIA','CAMPANIA','VENETO',
'LIGURIA', 'LOMBARDIA', 'TOSCANA', 'CALABRIA', 'SICILIA', 'TRENTINO ALTO ADIGE (BOLZANO)',
'TRENTINO ALTO ADIGE (TRENTO)','FRIULI VENEZIA GIULIA', 'EMILIA ROMAGNA', "VALLE D'AOSTA",
'BASILICATA','PIEMONTE','SARDEGNA' );

# Questo è il comando che lancero'
my $cmd = $pdftotext . " -layout '$infile' -";

# Eseguo l'ambaradan e mi preparo a leggere il risultato, riga per riga
open (FH, "-|", $cmd) || die ("Errore nel lancio di pdftotext: $!");

my $all_data_ref;

my $prov_pos = 0;

while(my $line = <FH>) {

    # tolgo l'accapo
    chomp($line);

    # Se ho trovato una intestazione che contiene la PR di provincia...
    if ($line =~ /^Prog/) {
        # vedo a quale colonna è la PR di provincia
        $prov_pos = index($line,"PR");

        # print "=> Aggiorno POS a [".$prov_pos."]\n";
        next;
    };

    # se la riga non comincia con un numero, la salto
    next if ($line !~ /^\d+/);

    # Spacco la riga in tre parti (centrando sulla provincia)
    my $part1 = substr($line,0,$prov_pos);
    my $prov = substr($line,$prov_pos,2);
    my $part2 = substr($line,$prov_pos+2);

    # elaboro la parte1
    # ...vediamo se trovo la regione, in fondo
    my $regione_found = 0;
    my $part1_a;
    my $part1_r;
    
    foreach my $r (@regioni) {
        if ($part1 =~ /^(.*)(\Q$r\E)\s*$/) {
            $part1_a = $1;
            $part1_r = $2;
            $regione_found = 1;
            last;
        }
    };

    if (! $regione_found) {
        die("Errore: non sono riuscito a trovare una regione giusta...")
    };

    my $id;
    my $piva;
    my $ragione_sociale;

    if ($part1_a =~ /^(\d+)\s+(\d+)\s+(.*?)\s+$/) {
        ($id, $piva, $ragione_sociale) = ($1, $2, $3);
    } else {
        die("Errore: non sono riuscito a spaccare la prima parte...")
    }

    # prendo la regione e tolgo gli spazi in fondo
    $part1_r =~ s/\s+$//;

    # Tolgo gli spazi iniziali alla parte 2
    $part2 =~ s/^\s+//;
    my $part2_c = '';
    my $part2_n = 0;
    my $part2_v1 = 0;
    my $part2_v2 = 0;
    my $part2_v3 = 0;

    if ($part2 =~ /^([\w\s\.\-']+?)[\sX]+([\d\.,]+)\s+([\d\.,]+)\s+([\d\.,]+)\s+([\d\.,]+)/) {
        $part2_c = $1;
        $part2_n = $2;
        $part2_v1 = $3;
        $part2_v2 = $4;
        $part2_v3 = $5;
        # tolgo i punti separatori delle migliaia
        $part2_n =~ s/\.//g;
        $part2_v1 =~ s/\.//g;
        $part2_v2 =~ s/\.//g;
        $part2_v3 =~ s/\.//g;
    } else {
        die ("Caos con part2: [" . $part2 . "]");
    }

    # stampo la riga
    # print "[A ] [" . $part1 . "]\n";
    # print "[1a] [" . $part1_a . "]\n";
    print "[id] [" . $id . "]\n";
    print "[iv] [" . $piva . "]\n";
    print "[rs] [" . $ragione_sociale . "]\n";
    print "[1r] [" . $part1_r . "]\n";
    print "[PR] [" . $prov . "]\n";
    print "[2c] [" . $part2_c . "]\n";
    print "[2n] [" . $part2_n . "]\n";
    print "[v1] [" . $part2_v1 . "]\n";
    print "[v2] [" . $part2_v2 . "]\n";
    print "[v3] [" . $part2_v3 . "]\n";
    print "\n";

    my $data_ref = {
        'id' => $id,
        'piva' => $piva,
        'ragione_sociale' => $ragione_sociale,
        'regione' => $part1_r,
        'provincia' => $prov,
        'citta' => $part2_c,
        'num_quote' => $part2_n,
        'v1' => $part2_v1,
        'v2' => $part2_v2,
        'v3' => $part2_v3
    };

    push (@{$all_data_ref}, $data_ref);
}
