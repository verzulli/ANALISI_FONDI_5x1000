# ANALISI FONDI 5x1000
Convertitore PDF => TXT (leggibile) dei dati relativi alla distribuzione del 5x1000

## Cos'é questo progetto?
I dati relativi alla distribuzione del 5x1000 vengono rilasciati ufficialmente in formato PDF [1].

Nel caso dell'anno fiscale 2019, si tratta dei 5 PDF che trovate nel progetto, ognuno dei quali riporta una tabella che ha 13.000 righe. Ogni PDF ha oltre 400 pagine. In dettaglio:

~~~
$ ls *pdf | xargs -I % sh -c 'echo -n %; echo -n " "; pdfinfo % | grep Pages'
00001_13000.pdf Pages:          420
13001_26000.pdf Pages:          420
26001_39000.pdf Pages:          420
39001_52000.pdf Pages:          420
52001_66494.pdf Pages:          468
~~~

È evidente che questi documenti sono inutilizzabili a fini statistici. Probabilmente possono solo supportare ricerche spot da parte di qualcuno, per cercare puntualmente i dati di qualcun altro.

Obiettivo di questo progetto è di realizzare una applicazione PERL in grado di agevolare l'estrazione di contenuti da tali PDF.

...e il risultato è presente nel file `out.txt`

~~~
$ wc -l out.txt 
66494 out.txt
~~~

## Come di usa?
1. Te lo cloni
2. rimuovi il file out.txt
3. lanci `./pdf2txt <pdf>`

## Perché l'ho fatto?
Perché mio fratello è Presidente dell'[Associazione Autismo Abruzzo ONLUS](https://www.autismoabruzzo.it/), ossia una di quelle righe!

E non essendo riuscito a processare questi dati, mi ha chiesto una mano...

Dopo una rapida occhiata ed aver visto che il buon `pdftotext -layout` fa già un ottimo lavoro... ho deciso di scatenare l'artiglieria pesante (ossia il buon vecchio caro [PERL](https://www.perl.org)

Chissè se i prossimi PDF saranno processabili allo stesso modo oppure... ora che è disponibile questo script, verranno artatamente hardenizzati!

OpenData, please!

## Cosa da sapere
+ lo script non verifica la presenza di doppioni; se lo lanci due volte sullo stesso file, lui esegue senza problemi;
+ lo script tende ad essere rigoroso: al minimo problema... si ferma e non fa niente
+ quando lanciato, in standard output riporta un tot di cose... che si possono ignorare
+ se si e' curiosi di capire come e' evoluto nel (poco) tempo di sviluppo (~5 ore), date un'occhiata ai commit

## Riferimenti
[1] Aggiungere fonti
