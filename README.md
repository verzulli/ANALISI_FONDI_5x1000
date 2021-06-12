# ANALISI FONDI 5x1000
Convertitore PDF => TXT (leggibile) dei dati relativi alla distribuzione del 5x1000

[Link alla WebApp](https://verzulli.github.io/ANALISI_FONDI_5x1000/)

## Cos'é questo progetto?
I dati relativi alla distribuzione del 5x1000 vengono rilasciati ufficialmente in formato PDF direttamente [sul sito dell'Agenzia delle Entrate](https://www.agenziaentrate.gov.it/portale/area-tematica-5x1000)

Nel caso dell'anno fiscale [2019](https://www.agenziaentrate.gov.it/portale/elenco-complessivo-dei-beneficiari-2019), si tratta dei 5 PDF che trovate nel progetto, ognuno dei quali riporta una tabella che ha 13.000 righe. Ogni PDF ha oltre 400 pagine. In dettaglio:

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

Lo sviluppo dell'applicativo è ancora in itinere. Si è iniziato con l'anno 2019, realizzando un parser per i relativi PDF. 

Il parser pare funzionare (sul 2019)... e il risultato è presente nel file `out.txt`

~~~
$ wc -l out.txt 
66494 out.txt
~~~

Per gli altri anni ([2020](https://www.agenziaentrate.gov.it/portale/web/guest/elenco-5x1000-2020-enti-ammessi-categorie-di-beneficiari), [2018](https://www.agenziaentrate.gov.it/portale/elenco-complessivo-beneficiari-2018), [2017](https://www.agenziaentrate.gov.it/portale/archivio/archivioschedeadempimento/schede-adempimento-2017/agevolazioni-2017/iscrizione-elenchi-5-per-mille-2017/elenchi-5xmille2017/elenco-completo-beneficiari-5xmille2017)) sono disponibili altri file PDF, che pur essendo simili.. in realtà sono stati generati diversamente e quindi non possono essere processati dal parser in modo identico al 2019. Servirà aggiornarlo... ed i relativi lavori sono ancora "in corso" :-)

## Come di usa?
1. Te lo cloni
2. rimuovi il file out.txt
3. lanci `./pdf2txt *.pdf`

## Perché l'ho fatto?
Perché mio fratello è Presidente dell'[Associazione Autismo Abruzzo ONLUS](https://www.autismoabruzzo.it/), ossia una di quelle righe!

E non essendo riuscito a processare questi dati, mi ha chiesto una mano...

Dopo una rapida occhiata ed aver visto che il buon `pdftotext -layout` fa già un ottimo lavoro... ho deciso di scatenare l'artiglieria pesante (ossia il buon vecchio caro [PERL](https://www.perl.org)

Chissè se i prossimi PDF saranno processabili allo stesso modo oppure... ora che è disponibile questo script, verranno artatamente hardenizzati!

OpenData, please!

## Cosa ho fatto

1. l'applicazione PERL che prende i PDF e produce un CSV (importabile in LibreOffice Calc, o altri fogli elettronici capaci di leggere un file di testo e spaccarlo in base al carattere "|" (pipe))

2. una [web-app](https://verzulli.github.io/ANALISI_FONDI_5x1000/) sulla quale, man mano, verranno aggiunti un po' di grafici. La webApp è 100% client-side, ed è basata sul framework [VueJS](https://vuejs.org/)
## Cosa da sapere
+ lo script sovrascrive ogni volta il file risultato;
+ lo script tende ad essere rigoroso: al minimo problema... si ferma e non fa niente
+ quando lanciato, in standard output riporta un trace delle attivita' in corso. Trace che... si possono ignorare
+ se si e' curiosi di capire come e' evoluto nel (poco) tempo di sviluppo (~5 ore), date un'occhiata ai commit

## Riferimenti
[1] Aggiungere fonti
