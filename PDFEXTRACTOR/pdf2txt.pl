#!/usr/bin/perl

use strict;

# forzo il flush dello STDOUT perche' a video mi serve la verbosity
# real-time... e non chunk-by-chunk...
$| = 1;

# Recupero l'elenco dei file da processare e ci ciclo...

# pdftotext è il binario che mi trasforma il PDF in TXT. Indispensabile!
my $pdftotext = '/usr/bin/pdftotext';

my $global_counter = 0; # contatore GLOBALE delle righe processate
my $local_counter = 0;  # contatore LOCALE al file, delle righe processate
my $all_data_ref;       # puntatore all'HASH che contiene tutti i dati
my @regioni   = (       # elenco delle Regioni riportate nel file
  'ABRUZZO',                      'MOLISE',
  'MARCHE',                       'PUGLIA',
  'LAZIO',                        'UMBRIA',
  'CAMPANIA',                     'VENETO',
  'LIGURIA',                      'LOMBARDIA',
  'TOSCANA',                      'CALABRIA',
  'SICILIA',                      'TRENTINO ALTO ADIGE (BOLZANO)',
  'TRENTINO ALTO ADIGE (TRENTO)', 'FRIULI VENEZIA GIULIA',
  'EMILIA ROMAGNA',               "VALLE D'AOSTA",
  'BASILICATA',                   'PIEMONTE',
  'SARDEGNA'
);

foreach my $infile (@ARGV) {
  print "\nProcesso il file: [" . $infile . "]\n";

  if ( !( $infile && -r $infile ) ) {
    print "Il file [" . $infile . "] non esiste o non e' leggibile!";
    next;
  }

  # Questo è il comando che lancero'
  my $cmd = $pdftotext . " -layout '$infile' -";

  # Eseguo l'ambaradan e mi preparo a leggere il risultato, riga per riga
  open(FH, "-|", $cmd ) || die("Errore nel lancio di pdftotext: $!");

  $local_counter = 0; # resetto il contatore locale

  my $prov_pos = 0;

  while ( my $line = <FH> ) {

    # tolgo l'accapo
    chomp($line);

    # Se ho trovato una intestazione che contiene la PR di provincia...
    if ( $line =~ /^Prog/ ) {

      # vedo a quale colonna è la PR di provincia
      $prov_pos = index( $line, "PR" );

      # print "=> Aggiorno POS a [".$prov_pos."]\n";
      next;
    }

    # se la riga non comincia con un numero, la salto
    next if ( $line !~ /^\s{0,1}\d+/ );

    # Spacco la riga in tre parti (centrando sulla provincia)
    my $part1 = substr( $line, 0,         $prov_pos );
    my $prov  = substr( $line, $prov_pos, 2 );
    my $part2 = substr( $line, $prov_pos + 2 );

    # ------ elaboro la parte1 (a sinistra della PRovincia) -----------
    # ...vediamo se trovo la regione, in fondo
    my $regione_found = 0;
    my $part1_a;
    my $part1_r;

    foreach my $r (@regioni) {
      if ( $part1 =~ /^(.*)(\Q$r\E)\s*$/ ) {
        $part1_a       = $1;
        $part1_r       = $2;
        $regione_found = 1;
        last;
      }
    }

    if ( !$regione_found ) {
      die("Errore: non sono riuscito a trovare una regione giusta ["
        . $part1
        . "]..." );
    }

    # ...spacco id, partita iva e ragione sociale
    my $id;
    my $piva;
    my $ragione_sociale;

    if ( $part1_a =~ /^\s{0,1}(\d+)\s+(\d+)\s+(.*?)\s+$/ ) {
      ( $id, $piva, $ragione_sociale ) = ( $1, $2, $3 );
    }
    else {
      die("Errore: non sono riuscito a spaccare la prima parte...");
    }

    # Sostituisco i doppi apici col singolo apice nella Regione Sociale
    $ragione_sociale =~ s/"/'/g;

    # tolgo gli spazi in fondo alla regione
    $part1_r =~ s/\s+$//;

    # ------ elaboro la parte2 (a destra della PRovincia) -----------
    # Tolgo gli spazi iniziali alla parte 2
    $part2 =~ s/^\s+//;
    my $part2_c  = '';
    my $part2_n  = 0;
    my $part2_v1 = 0;
    my $part2_v2 = 0;
    my $part2_v3 = 0;

    if ( $part2 =~
/^([\w\s\.\-']+?)[\sX]+([\d\.,]+)\s+([\d\.,]+)\s+([\d\.,]+)\s+([\d\.,]+)/
      )
    {
      $part2_c  = $1;
      $part2_n  = $2;
      $part2_v1 = $3;
      $part2_v2 = $4;
      $part2_v3 = $5;

      # tolgo i punti separatori delle migliaia
      $part2_n =~ s/\.//g;
      $part2_v1 =~ s/\.//g;
      $part2_v2 =~ s/\.//g;
      $part2_v3 =~ s/\.//g;

      # NON sostituisco le virgole con i punti per separare gli interi dai decimali
      # perche' con LibreOffice calc mi serve la virgola
      # $part2_n =~ s/,/./ig;
      # $part2_v1 =~ s/,/./ig;
      # $part2_v2 =~ s/,/./ig;
      # $part2_v3 =~ s/,/./ig;
    } else {
      die( "Caos con part2: [" . $part2 . "]" );
    }

    # Se arrivo qua, allora la riga è buona....
    $global_counter++;
    $local_counter++;

    # --------- stampo un feedback a video ---------------
    if (! ($local_counter % 1000)) {
      print "[" . $local_counter . "/" . $global_counter ."]";
    } elsif (! ($local_counter % 100)) {
      print ".";
    }

    # --------- Metto in memoria i dati estratti da questa riga -----
    my $data_ref = {
      'id'              => $id,
      'piva'            => $piva,
      'ragione_sociale' => $ragione_sociale,
      'regione'         => $part1_r,
      'provincia'       => $prov,
      'citta'           => $part2_c,
      'num_quote'       => $part2_n,
      'v1'              => $part2_v1,
      'v2'              => $part2_v2,
      'v3'              => $part2_v3
    };

    push( @{$all_data_ref}, $data_ref );
  }

  print "\nTerminato: [" . $local_counter . "/" . $global_counter ."]\n";


  # ho finito di frullare il file, e quindi "chiudo" e passo appresso
  close FH;

}

# Dumpo i risultati nel mega-JSON che mi serve
# ...e dato che mi ci trovo, creo pure un simil-CSV (per i fogli elettronici)

open (OH, ">out.csv");
open (JH, ">out.json");
my @temp_store;

foreach my $i (@{$all_data_ref}) {
  printf OH "%d|%s|%s|%s|%s|%s|%d|%s|%s|%s\n",
    $i->{'id'},
    $i->{'piva'},
    $i->{'ragione_sociale'},
    $i->{'regione'},
    $i->{'provincia'},
    $i->{'citta'},
    $i->{'num_quote'},
    $i->{'v1'},
    $i->{'v2'},
    $i->{'v3'};

  # sostituisco il separatore decimale (da "," a ".")
  # perche' nel JSON è cosi' che deve andare...
  $i->{'v1'} =~ s/,/./g;
  $i->{'v2'} =~ s/,/./g;
  $i->{'v3'} =~ s/,/./g;

  my $rec = '{';
  $rec .= '"id": ' . $i->{'id'} . ',';
  $rec .= '"piva": "' . $i->{'piva'} . '",';
  $rec .= '"ragione_sociale": "' . $i->{'ragione_sociale'} . '",';
  $rec .= '"regione": "' . $i->{'regione'} . '",';
  $rec .= '"provincia": "' . $i->{'provincia'} . '",';
  $rec .= '"citta": "' . $i->{'citta'} . '",';
  $rec .= '"num_quote": ' . $i->{'num_quote'} . ',';
  $rec .= '"v1": ' . $i->{'v1'} . ',';
  $rec .= '"v2": ' . $i->{'v2'} . ',';
  $rec .= '"v3": ' . $i->{'v3'};
  $rec .= "}\n";

  push(@temp_store,$rec);
}

print JH "[\n" . join(',',@temp_store)."\n]\n";
