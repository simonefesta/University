# Sistemi Operativi Avanzati

- Versione originale: Matteo Fanfarillo  

- Umile formattazione: Simone Festa

# Hardware Insights

## Introduzione

In generale, non è possibile dire che lo stato di un’applicazione sia semplicemente dato dal “puzzle” degli stati dei componenti software sviluppati. Di fatto, quando mandiamo in esercizio tali componenti software, stiamo generando dei cambi di stato al livello hardware che concorrono a determinare qual è lo stato effettivo del nostro sistema. Tra l’altro, alcuni dei cambi di stato al livello hardware possono non essere voluti o specificati dal programmatore. Il fatto che l’esecuzione di moduli software sviluppati a qualsiasi livello impatti sui moduli sottostanti (e quindi sull’hardware), come vedremo, può rappresentare un problema importante per quanto riguarda la sicurezza: talvolta, per ottenere un sistema più sicuro e performante a livello hardware, sarà necessario ristrutturare l’applicazione software.

Ma quali sono le entità che si frappongono tra ciò che viene specificato dal programmatore e ciò che realmente avviene nel sistema? 

- Il **compilatore**: il programma compilato è un oggetto molto complesso che può interfacciarsi direttamente con l’hardware; il compilatore può decidere ad esempio di inserire particolari istruzioni macchina secondo uno specifico ordine in modo completamente trasparente al programmatore. 

- Le **hardware run-time decisions**: una volta che è stato generato il flusso esatto delle istruzioni macchina da eseguire per mandare in esercizio l’applicazione, l’hardware in realtà può prendere delle decisioni a run-time su come gestire tale flusso. A parità di istruzioni macchina, processori di vendor diversi possono prendere delle decisioni a run-time differenti. 

- La **disponibilità** (o l’assenza) **di specifiche features dell’hardware**.

In pratica, si ha una sorta di non-determinismo dell’hardware e, quindi, del software. 

**Esempio**: Se implementiamo l’algoritmo del Panificio di Lamport senza l’ausilio di librerie di sistema (e quindi senza l’ausilio di spinlock o semafori), l’algoritmo a un certo punto della sua esecuzione si romperà. Infatti, le macchine moderne (a meno che non siano single core, dove non è assicurata consistenza globale) non garantiscono una visione consistente per tutti i thread di ciò che sta succedendo in memoria. Prima, ad ogni cpu veniva associato un flusso di esecuzione, cosa non vera per i sistemi moderni.

## Scheduling e parallelismo nell’architettura di Von Newman

L’architettura di calcolatore più semplice a cui siamo stati abituati a pensare è quella di **Von Newman**, ed è caratterizzata da:

- Un’unica CPU. 

- Un’unica memoria. 

- Un unico flusso di controllo (*fetch – execute – store*).

- Transizioni nell'hardware time-separated: le istruzioni devono essere eseguite tutte una alla volta.

- Stato della memoria ben definito all’inizio di ciascuna istruzione, la quale quindi deve poter vedere la memoria in uno stato coerente con l’esecuzione delle istruzioni precedenti.

La maniera moderna di pensare le architetture non è basata sull’idea di seguire il flusso di *esecuzione* *esattamente così com’è* stato codificato nel programma, bensì è basata sul concetto di **scheduling** (e.g. dell’utilizzo dei componenti hardware) che, alla fine della fiera, porterà a eseguire un flusso di esecuzione equivalente al flusso codificato nel programma (gli stati intermedi possono essere diversi, possono cambiare di run in run, non sono deterministici, ma influenzabili da fattori esterni come la temperatura). In particolare, lo scheduling dovrebbe consentire di eseguire più cose in **parallelo**, anche in contesti con un’unica CPU, un’unica memoria e un unico flusso di controllo.
Per quanto riguarda lo scheduling, ne esistono diverse tipologie. 
A livello **hardware** abbiamo: 

- Scheduling delle istruzioni all’interno di un singolo program flow.

- Scheduling delle istruzioni in program flow paralleli (**speculativi** **=** non so se l’esecuzione sia corretta o meno, ad esempio la branch condition non sempre lo è. Il processore sceglie come propagare l’update, non è imposto. Ho garantita l’equivalenza software, non ciò che avviene dentro). 

- Propagazione dei valori tra i componenti hardware del sistema.

A livello software invece abbiamo: 

- Scheduling dei thread da assegnare alle CPU / ai CPU-core. 

- Scheduling delle attività da eseguire sull’hardware (e.g. gli interrupt). 

- Supporti di sincronizzazione tra thread software-based.

Anche per quanto riguarda il **parallelismo**, ne esistono diverse tipologie: 

- A livello hardware si parla di **ILP** (**Instruction** **Level** **Parallelism**), che consiste nell’impiegare le risorse hardware in modo tale da eseguire contemporaneamente istruzioni macchina diverse. (ad esempio posso eseguire al tempo ‘t’ sia A sia B, anche in un unico flusso). 

- A livello software, invece, abbiamo il **TLP (Thread Level** **Parallelism)**, secondo cui un programma può essere pensato come la combinazione di molteplici flussi di esecuzione concorrenti. (Ad esempio ho 3 flussi su 3 processori,singolarmente sarebbero ILP, che cambiano).

## Velocità di computazione

È generalmente correlata alla velocità di un processore (espressa in GHz), anche se in realtà esistono istruzioni che possono richiedere un numero arbitrario di cicli di clock a causa di più possibili fattori: 

- Possono essere istruzioni più onerose per loro natura. 

- Possono dover richiedere a un certo punto una risorsa hardware tuttora occupata da un’altra istruzione, per cui devono rimanere in attesa. 

- Possono esservi delle asimmetrie a livello hardware (e.g. un CPU-core può essere più veloce di un altro). 

- I pattern per l’accesso ai dati influiscono a loro volta sulle prestazioni: ad esempio, se un dato viene memorizzato in cache, l’accesso a esso sarà più efficiente e viceversa.

Nel corso base di Sistemi Operativi abbiamo parlato di thread CPU-bound e di thread I/O-bound; introduciamo ora una terza categoria di thread (che, di fatto, è una sottocategoria dei CPU-bound): i **memory-bound**. Essi sono dei thread che utilizzano in maniera intensiva la CPU ma, mentre sono in esecuzione, utilizzano in maniera intensiva anche la memoria. I thread (o comunque i programmi) che presentano questa caratteristica possono rappresentare un problema dal punto di vista prestazionale: come riportato dal seguente grafico, il divario prestazionale tra processore e memoria aumenta sempre di più col tempo; questo fenomeno è detto **memory** **wall**.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-41-49-image.png)

Per evitare che i thread memory-bound sperimentino e causino ad altri thread un crollo delle prestazioni, sono necessari dei meccanismi avanzati ad-hoc al livello dell’hardware.

## Pipeline

È una **tecnica di scheduling e parallelismo** **hardware-based**. Infatti: 

- Non prevede una separazione temporale tra le finestre di esecuzione delle diverse istruzioni: più istruzioni possono essere in esecuzione contemporaneamente (questo è *parallelismo*). 

- Le istruzioni che vengono sequenzializzate dal programmatore non sono necessariamente eseguite secondo la stessa sequenza nell’hardware, anche per conseguire la proprietà di parallelismo (questo è *scheduling*).

In ogni caso, ci sono spesso e volentieri coppie di istruzioni (*i1, i2*) in cui *i2*, per essere eseguita, necessita del risultato ottenuto da *i1*. In tal caso, *la causalità deve essere preservata*, per cui *i1* e *i2* non possono essere schedulate in modo del tutto arbitrario. Questo non è altro che un modello **data flow** per l’esecuzione dei programmi.

Ricordiamo che le fasi (stage) delle istruzioni sono: 

- **IF** (**Instruction** **Fetch**): caricamento dell’istruzione nel processore (richiede certamente un accesso in memoria). 

- **ID** (**Instruction** **Decode**): decodifica dell’istruzione, in cui viene stabilito ciò che deve effettivamente essere fatto per eseguire l’istruzione stessa. 

- **LO** (**Load** **Operands**): caricamento degli operandi richiesti per l’esecuzione dell’istruzione (potrebbe richiedere un accesso in memoria). 

- **EX** (**Execute**): esecuzione vera e propria dell’istruzione. 

- **WB** (**Write Back**): scrittura dell’output dell’istruzione su un registro o in memoria (potrebbe quindi richiedere un accesso in memoria).

Il fatto che un thread o un’applicazione sia memory-bound o meno dipende proprio dagli stage *LO* e *WB*. Inoltre, per permettere l’esecuzione di più istruzioni in parallelo, è necessario che ciascuno *stage coinvolga una componente hardware differente del processore*, in modo tale da non avere collisioni tra più istruzioni che vengono eseguite contemporaneamente. In particolare, un’astrazione di base della pipeline è quella riportata nella seguente figura.
![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-13-17-01-36-2.png)

In questo scenario, idealmente, sarebbe possibile completare un’istruzione per ogni ciclo di clock (anche se poi nella realtà non è esattamente così per i motivi esposti nel paragrafo “Velocità di computazione”). Supponiamo comunque di trovarci nello scenario ideale in cui ciascuno stage viene eseguito in un unico ciclo di clock, e supponiamo di voler fornire $N$ risultati (1 per ogni istruzione), di avere $L$ diversi stage per le istruzioni (gli stage sarebbero *IF, ID, LO, EX* e *WB* che devo attraversare) e di avere un ciclo di clock di durata pari a $T$. 

- Senza pipeline si ha un ritardo pari a $N \cdot L \cdot T$

- Con la pipeline si ha un ritardo pari a $(N+L) \cdot T$

Lo speedup è dunque pari a $(N \cdot L)/(N+L)$, che tende a L per N tendente a infinito. Dal punto di vista delle prestazioni, sarebbe magnifico avere un $L$ molto grande (ovvero molti stage diversi per le istruzioni, ovvero riesco a parallelizzare molto di più se aumento il numero di componenti parallelizzabili) ma ciò nella realtà non accade. Il caso estremo richiederebbe avere hardware infinito, visto che ogni stage è un pezzo hw! Nella realtà:

- I processori Pentium prevedevano 5 stage. 

- I processori i3 / i5 / i7 prevedono 14 stage. 

- I processori ARM-11 prevedono 8 stage. 

Questa scelta è dovuta alla necessità di preservare la causalità tra le istruzioni. Più istruzioni si prendono in considerazione insieme, più è probabile che tra tali istruzioni ce ne siano alcune (e.g. *i1, i2*) legate da una relazione di causalità, e sappiamo che *i2*, per essere eseguita, deve attendere che il risultato di *i1* sia pronto; in tal caso, più $L$ è grande, più la pipeline è lunga, più l’attesa di *i2* sarà lunga.
Lo scenario di cui abbiamo appena parlato è una **data** **dependency**. Oltre a questa esiste anche la **control** **dependency**, che si può avere nel momento in cui c’è un salto condizionale il cui esito dipende dagli outcome delle istruzioni precedenti al salto. Per quanto concerne la data dependency tra le istruzioni *i1* e *i2*, abbiamo che lo stage **LO** di *i2* tipicamente non può precedere lo stage **WB** di *i1*. Analogamente, per quanto riguarda la control dependency tra le istruzioni *i1*e *i2* (dove *i1* è l’istruzione di salto condizionato), non si conosce l’esito del salto prima della fase **EX*** di *i1*, per cui la fetch di *i2* non dovrebbe precedere lo stage **EX*** di *i1*. Tutte queste condizioni possono comportare dei rallentamenti nell’esecuzione dell’applicazione rispetto al caso ideale di pipeline. Per gestire tali condizioni è possibile ricorrere a svariati meccanismi: 

- **Stalli software** (compiler driven): possono essere aggiunti all’interno della pipeline con lo scopo di distanziare due istruzioni *i1*, *i2* in modo tale che uno stage $x$ (e.g. LO) di *i2* venga eseguito dopo uno stage $y$ (e.g. WB) di *i1*.

-  **Rischedulazione** **software** (compiler driven): se devono essere eseguite tre istruzioni *i1, i2, i3* tali per cui *i2* dipende da *i1* ma *i3* non dipende né da *i1* né da *i2*, il compilatore può frapporre *i3* tra *i1* e *i2* in modo tale da svolgere lavoro utile mentre *i2* è in attesa che si completi uno specifico stage di i1. 

- **Propagazione hardware**: se l’istruzione *i2* dipende dall’istruzione *i1* e, ad esempio, lo stage LO di *i2* consiste nell’acquisire un valore prodotto dallo stage EX di *i1*, allora è possibile per *i1* propagare il valore a *i2* subito dopo la fase EX senza dover attendere il completamento della write-back.

- **Azzardi hardware** **supported**: contestualmente a un’istruzione di salto condizionale, il processore può provare a *indovinare* se il salto viene preso o meno per poi anticipare la fetch delle istruzioni successive di conseguenza. Dal punto di vista delle performance, una predizione errata equivale a un inserimento di stalli per attendere passivamente l’esito dell’istruzione di salto; di conseguenza, la tecnica degli azzardi è statisticamente conveniente da adottare. 

- **Rischedulazione** **hardware**: è un meccanismo noto anche come **out-of-order pipeline** (**OOO**), e prevede che le istruzioni vengano completate non necessariamente nel medesimo ordine con cui sono entrate all’interno della pipeline. In particolare, un’istruzione $i_k$, per accedere allo stage $x$, non deve necessariamente attendere che tutte le istruzioni a lei precedenti abbiano completato lo stage $x$. Si può dunque avere un meccanismo di **superamento** delle istruzioni all’interno della pipeline. Tale tecnica è vantaggiosa poiché permette all’istruzione $i_k$ di essere completata prima e, quindi, di liberare un posto all’interno della pipeline. Tuttavia, è una tecnica che *richiede la possibilità da parte dell’hardware* *di ospitare più istruzioni contemporaneamente* *all’interno dello stesso stage* (altrimenti non sarebbe possibile effettuare il sorpasso): i processori con questa caratteristica sono detti **superscalari**. Inoltre, ovviamente, affinché si possa avere una out-of-order pipeline, *l’istruzione che effettua il sorpasso non deve dipendere dalle istruzioni che vengono sorpassate.* Non si hanno effetti reali sull’**Instruction Set Architecture** finchè non si deve “mostrare” l'output. 

**Esempio**:

Se in pipeline su un thread ho $A\rightarrow B$, e nella pipeline B supera A, ma A è oggetto di *trap* (quindi non può fare quello che stava facendo, come dividere per 0, di conseguenza non potrò averla in ISA), cosa accade a B? Vedremo che in OOO si producono valori registrati in maniera “speculativa” che poi butterò, ma non posso eseguire una UNDO. 

*Nota*: le istruzioni tra due thread sono indipendenti, dipendono solo se usano info condivise, ma ciò è di interesse al programmatore, non al processore. L’ordine della sorgente (programma) non è detto coincida con l’ordine del compilatore, tuttavia abbiamo la sicurezza che il data flow sia compatibile. 
A livello hardware, se ho operazione $x,y,z$ può capitare quindi di avere $z,x,y$; ma ciò è realizzato dinamicamente dall’hardware. Ho sorpasso se non ho dipendenza.

### Pipeline vs Sviluppo

Come abbiamo visto, i programmatori non hanno il diretto controllo del comportamento di un processore (trattasi di microcodice) ma, comunque sia, il modo con cui viene scritto il software può impattare sulle prestazioni effettive della pipeline. A livello ISA vedo il set di istruzioni e risorse usabili, ma non vedo la pipeline. 
**Esempio:** 
Esempi di ISA sono *ADD, COMPARE, JUMP*.onsideriamo le seguenti istruzioni C: 

1) `a = *++p`

2) `a = *p++`

L’istruzione $1$ prevede che prima debba essere incrementato il puntatore p affinché referenzi la entry successiva e solo dopo si possa accedere alla entry appena referenziata; di conseguenza, l’accesso dipende dall’incremento del puntatore. 
Al contrario, l’istruzione $2$ prevede che prima si debba accedere alla entry attualmente referenziata dal puntatore p e solo poi si debba incrementare p; stavolta, l’accesso non dipende dall’incremento del puntatore. 
Questo vuol dire che c’è dipendenza. 
Consideriamo due programmi, di cui il primo prevede l’istruzione $1$ all’interno di un loop e il secondo prevede l’istruzione $2$ all’interno di un loop. Nel secondo c’è indipendenza. La differenza prestazionale tra i due programmi è abbastanza significativa (può raggiungere tranquillamente il $20/25$%).

Per giunta, esistono delle istruzioni macchina che, da sole, hanno degli effetti devastanti sulle prestazioni del programma. Un esempio è `cpuid`, che ha lo scopo di restituire l’id del processore (o del CPU-core o dell’hyperthread) che ha processato l’istruzione stessa. Ma, oltre a questo, effettua anche lo **squash** della pipeline: in particolare, nel momento in cui `cpuid` viene realmente eseguita, la pipeline viene svuotata e le altre istruzioni al suo interno vengono buttate. Questo non deve necessariamente rappresentare uno svantaggio: avere istruzioni pendenti all’interno della pipeline significa dire che tali istruzioni possono essere schedulate dinamicamente dall’hardware secondo regole non meglio identificate, e ciò può impattare non solo sulla correttezza, ma anche sulla sicurezza del sistema. Più precisamente, quello di flushare la pipeline è un concetto legato al termine “**serializzazione**”. Di fatto, `cpuid` è detta **istruzione serializzante**, poiché riporta la pipeline a lavorare secondo uno schema sequenziale. Non solo: `cpuid`, come tutte le istruzioni serializzanti, garantisce che qualunque modifica apportata a flag, registri e memoria da parte delle istruzioni precedenti sia completata (finalizzata) **prima** che una qualsiasi istruzione a lei successiva venga fetchata ed eseguita. *Ciò implica anche che* *cpuid* *non* *può superare alcuna istruzione davanti a lei nella pipeline.* (*e.g:* Perchè le istruzioni successive devono ancora essere fetchate ed eseguite, quindi come potrei superarle? Ciò che viene dopo  questa istruzione serializzante è come se andasse in stallo finchè non completo questa istruzione serializzante, e garantisce anche che le istruzioni precedenti vengano viste da quelle successive.)  
Se avessi SOLO istruzioni serializzanti, il sistema sarebbe molto più lento.

### Pipeline superscalare

È un insieme di molteplici pipeline che operano simultaneamente all’interno del processore. La si può ottenere aggiungendo *ridondanza alle risorse* *hardware* in modo tale che più componenti distinti siano adibite a uno stesso stage della pipeline. Come detto in precedenza, questa possibilità permette anche di adottare il modello OOO, la cui idea di base consiste in: 

- Effettuare il **commit** (o **retire** o **finalizzazione**) delle istruzioni esattamente nel medesimo ordine in cui sono *entrate nella pipeline*, indipendentemente dagli eventuali sorpassi avvenuti all’interno della pipeline. Ciò significa che le scritture dei risultati delle istruzioni in memoria, su un registro qualunque o su un registro di stato *devono avvenire esattamente nell’ordine prestabilito*. 

- **Processare le istruzioni independenti** (sia sui dati che sulle risorse hardware) **il prima possibile**, dove un’istruzione indipendente sulle risorse hardware è un’istruzione che non ha bisogno di attendere che un qualche componente si liberi per processare un certo stage $x$.

L’immagine riportata di seguito mostra molto bene come lo stage EX delle istruzioni possa avere una durata variabile in termini di numero di cicli di clock, ed è a partire da tale presupposto che risulta utile avere un out-of-order pipeline.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-13-18-04-27-3.png)

La seguente altra figura mostra invece la differenza prestazionale che si può avere tra il modello non OOO e il modello OOO:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-42-17-image.png)

----

: Con una pipeline che ha ridondanza hardware (come i pc moderni), possiamo ad esempio parlare di “*Pipeline parallele a X canali*”, che è come avere una autostrada a X corsie. Con Out-Of-Order Pipeline si evitano “grosse latenze”, poichè se “libero una corsia perchè sono veloce” anche gli altri andranno più veloci (liberarando risorse utili ad altri). Lo stallo impatta su tutti invece. Nella O.O.O, se posso andare avanti, lo faccio, non mi importa che devo aspettare il commit, se posso eseguire qualcosa lo eseguo. Per questo parliamo di WAIT e non più di STALL. Nella WAIT, appena ho un risultato (outcome di una “corsia”) lo fornisco a chi lo necessita, non mi serve aspettare che si liberi tutta la corsia.

---

Ora, poiché tra l’**emission** (= iniezione all’interno della pipeline, normalmente di più di una istruzione) e il retire (= **commit**) delle istruzioni si ha una fase di esecuzione in cui le istruzioni stesse possono sorpassarsi a vicenda, si va incontro al cosiddetto problema delle **eccezioni imprecise (OFFENDING)**: supponiamo di avere un’istruzione *i2* che ha superato un’istruzione *i1*, e assumiamo che *i1*, durante lo stage EX, generi un’eccezione (*e.g*: perché magari si tratta di una divisione per 0); a questo punto, anche se il risultato di *i2* non è stato ancora committato e, quindi, esposto a livello di ISA, *i2* può aver comunque toccato delle risorse non esposte a livello di ISA ed effettuato dunque dei cambi di stato (in particolare cambi di **stato micro-architetturale**). Quindi con offending instructions non esponiamo su ISA, ma potrei cambiare lo stato hardware, il che è usabile da malintenzionati. Questo perchè, lavorare in un contesto Out-Of-Order permette il superamento di istruzioni (**SPECULAZIONE**) che lascia delle tracce.  Di conseguenza, l’eccezione sollevata da *i1* vede uno stato interno dell’hardware che ingloba anche delle attività relative a *i2*. Un problema analogo lo si ha anche a parti invertite: se l’istruzione che genera l’eccezione è *i2*, l’eccezione vedrà uno stato interno dell’hardware che non comprende il risultato prodotto da *i1*. Questo è un problema dello stato e delle informazioni all’interno del processore (*ma non esposte nell’ISA*). Peggio ancora: *i2* potrebbe sollevare un’eccezione che in realtà, secondo il program flow, non sarebbe dovuta mai esistere, magari perché *i1* è a sua volta un’istruzione che solleva un’eccezione o un’istruzione di salto. In realtà, si possono avere eccezioni imprecise anche in assenza di sorpassi: se l’istruzione *i2* viene dopo l’istruzione *i1* che genera un’eccezione, *i2* può aver comunque attraversato degli stage e, quindi, può aver modificato lo stato interno dell’hardware. Come vedremo, tutto questo rappresenta un grave problema per la sicurezza dei sistemi: **Meltdown** è solo il primo di una valanga di attacchi che hanno sfruttato tale vulnerabilità.

## Algoritmo di Robert Tomasulo

Secondo Robert Tomasulo, in uno scenario di utilizzo di una pipeline speculativa out-of-order (dove speculativa = caratterizzata dall’esecuzione di istruzioni che potrebbero servire solo in un secondo momento), se consideriamo due istruzioni A, B tali che $A \rightarrow B$ nell’ordine di programma, dobbiamo stare attenti nell’evitare i seguenti tre tipi di azzardo: 

- **RAW** (**Read After Write**): B deve leggere un dato R necessariamente dopo che A lo ha aggiornato. 

- **WAW** (**Write After Write**): B deve scrivere su un dato R necessariamente dopo che A lo ha aggiornato. 

- **WAR** (**Write After Read**): B deve scrivere su un dato R necessariamente dopo che A ne ha letto il valore precedente (altrimenti vorrebbe dire che A è in grado di leggere dal futuro).

### Dipendenza RAW

Qui è necessario bloccare l’istruzione B e tenere traccia di quando il dato che deve essere letto da B sarà disponibile (disponibile non vuole dire necessariamente committato).

### Dipendenza WAW e WAR

Qui è necessario adottare una tecnica nota come **register renaming**, secondo cui al programmatore vengono esposti dei registri logici, e ciascuno di questi registri logici (che sono di fatto dei multi-registri) ingloba un insieme di registri fisici non visibili al livello dell’ISA. Quindi noi non scriviamo MAI sul registro esposto in ISA, ma su delle ‘*copie numerate*’ o alias, cioè registri multivalore. Ci ritroviamo dunque nella seguente situazione:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-42-36-image.png)

Qui i vari registri fisici rappresentano diverse versioni del medesimo registro logico *R*. Nel momento in cui all’interno della pipeline entra un’istruzione che vuole scrivere sul registro logico *R*, si considera il primo registro fisico $R_k$ all’interno del quale viene effettivamente memorizzato il valore 
(quindi scrivo sempre sul primo tag libero, e leggo dall’ultimo tag in pipeline. Se A scrive in TAG 0, e B scrive in TAG 1, leggo da TAG1). Tipicamente, per la selezione del registro fisico, si segue un approccio round-robin; se però a un certo punto tutti i registri fisici di *R* sono stati sovrascritti e nessuna delle istruzioni che ha eseguito la scrittura è andata in commit, per un’eventuale altra scrittura su *R* bisognerà attendere.

Posso superare solo dopo essere entrato nella pipeline (nelle condizioni discusse nelle pagine precedenti), ma non posso superare prima di entrare in pipeline.

In pratica, un *renamed register* materializza il concetto di speculatività di una pipeline: quando vengono effettuate delle write, vengono scritti dei valori che non necessariamente verranno considerati come validi, ma che comunque potranno essere letti dalle istruzioni successive (che sono state introdotte nella pipeline speculativamente).

Relativamente al registro *R*, vengono memorizzati anche dei metadati di gestione di *R* che indicano qual è il tag contenente la versione committata; la versione committata è la versione del valore di *R* scritto dall’ultima istruzione andata in commit che ha toccato proprio *R*. In questi registri abbiamo il “futuro” che avverrà, perchè non li ho ancora committati.

### Architettura di riferimento di Tomasulo

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-42-50-image.png)

- **A)**: I metadati associati alle istruzioni fetchate vengono memorizzati all’interno del **ROB** (**Re-Order Buffer**), che ci aiuta a  scrivere le istruzioni nello store buffer, in quanto posso andare in memoria solo se sono committed, ma io non posso aspettare sempre questa fase prima di utilizzare i dati. Tali metadati possono essere:  
  
  - *L’ordine* *con cui le istruzioni dovranno andare in* *commit.* 
  
  - Che cosa dovrebbero fare le istruzioni nella loro esecuzione speculativa. 
  
  - Qual è l’alias (l’istanza fisica) dei registri che dovranno essere usati da ciascuna istruzione; ad esempio, se un’istruzione A deve scrivere su un certo registro R e un’istruzione B successiva deve leggere dallo stesso registro R con una dipendenza RAW, è chiaro che A e B dovranno utilizzare il medesimo alias.

- **B)**: Le operazioni vere e proprie da eseguire (quindi gli OP code delle istruzioni) vengono memorizzate all’interno dell’**OP** **queue** e, in base alla loro tipologia, verranno date in input a un particolare componente di processamento (add, mult e così via). Nel momento in cui un’istruzione è pronta per essere processata, devono essere recuperati i metadati associati a essa e, in particolare, gli alias dei registri da usare. A tale scopo, c’è un bus comune (detto **Common Data Bus** – **CDB**) che mette in comunicazione i componenti di processamento col ROB. Se un alias non è pronto per essere utilizzato (perché magari bisogna attendere che venga sovrascritto da un’istruzione precedente), l’istruzione viene posta in attesa all’interno del relativo componente di processamento. I componenti di processamento sono detti anche **reservation** **station**. *Cosa è Reservation Station?* Per ogni componente in grado di eseguire uno specifico calcolo, si ha una coda/buffer/corsia dove posso mettere varie istruzioni, e le operazioni identificate dai registri usati (sorgenti). Non si ha sorpasso per utilizzare tali componenti in queste code, al massimo se ho due istruzioni dipendenti cerco di metterle nella stessa reservation station.

- Si fa uso di una **cache** per leggere in modo più efficiente i dati provenienti dalla memoria.

- Nel momento in cui viene **committata** un’istruzione, l’eventuale alias aggiornato da tale istruzione viene installato all’interno del **register** **file** come valore valido, ovvero come **valore esposto all’interno dell’ISA.**

- **E)**: Se l’istruzione committata prevede una scrittura in memoria, il valore di output, prima di essere riportato in memoria, viene inserito nello **store buffer** in modo tale da velocizzare il completamento dell’istruzione. Tuttavia, ciò implica che il valore non sarà in memoria per un po’ di tempo, il che può rappresentare un problema dal punto di vista della consistenza.  
  *Nota*: Supponiamo che un’istruzione sia in fase di ritiro, quindi è totalmente conclusa. In questo istante, il dato dovrebbe passare da Store Buffer alla memoria, ma in realtà non è istantaneo, passa un piccolo lasso di tempo. Ciò crea problemi con $>1$ thread, perchè se pesco un dato in memoria potrei non vedere alcuni dati. Per questo l'algoritmo della 
  “*pasticceria*” non funziona nei processori moderni, suppone che tale tempo sia nullo. Esistono però delle istruzioni per controllare lo stato dello Store Buffer. Questo approccio è l’unico per lavorare con O.O.O, ovvero non esistono altre tecniche per affrontare le O.O.O pipeline.

### Esempi di schemi di esecuzione

#### Esempio 1

Supponiamo di avere tre istruzioni *A, B, C* tra cui *B* e *C* hanno una stessa latenza $d$, mentre *A* ha una latenza $d’ > d$.   
Assumiamo inoltre che:

- *A* esegua l’operazione $f(R1,R2)$ e riporti l’output sul registro *R1*. (in particolare, scrive su un alias di *R1*). 

- *B* esegua l’operazione $f’(R1)$ e riporti l’output sul registro *R3*. (legge da STESSO alias di R1)

- *C* esegua l’operazione $f’(R4)$ e riporti l’output sul registro *R1*. (scrive su UN ALTRO alias di R1). 

Ci ritroviamo dunque nel seguente scenario:  

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-43-05-image.png)

È abbastanza evidente che *B* debba leggere **lo stesso alias** scritto da A, mentre C potrà riportare il valore di output su un **alias differente**. In tal modo è possibile **processare $C$ parallelamente ad $A$** :   
In fondo, anche se *C* genera il suo output prima di *A*, le dipendenze che legano le tre istruzioni non vengono violate. Infatti, *B* sarà comunque in grado di leggere dall’alias sovrascritto da *A* e, ovviamente, rimarrà comunque possibile mandare in commit *C* solo dopo il completamento di *A* e *B*. Il vantaggio che porta questo approccio è la riduzione del tempo necessario per il completamento di *C*.

#### Esempio 2

Vediamo con un secondo esempio riportato qui di seguito come viene associata una entry del ROB a ciascun alias differente:  

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-15-15-11-06-8.png)

E’ importante ricordare che, anche se è possibile eseguire in parallelo, non posso pensare di aumentare all’infinito le prestazioni, perchè ad un certo punto eccedo il numero di istruzioni che posso gestire.  
Questo porta ad un sistema scarico, ovvero non occupo corsie perchè ci sono caricamenti di elementi dalla memoria, oppure eseguo una predizione/azzardo sbagliata che mi porta a svuotare etc...  
E’ come fare un’autostrada a 20 corsie: è molto difficile saturarla il “giusto”.

Che soluzione è possibile adottare? 
Introduciamo i **Processori HYPERTHREAD**.

## Organizzazione architetturale dei processori x86 OOO

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-43-32-image.png)

### Processori hyper-threaded

Come abbiamo osservato all’inizio della trattazione, le architetture moderne sono soggette al **memory wall**. In particolare, si ha una latenza di esecuzione non solo quando si devono *recuperare i dati dalla memoria*, ma anche quando devono essere estratte le istruzioni stesse. Dunque, si può anche avere una pipeline molto efficiente con un **ILP** elevato, ma il processore non arriva mai a processare in parallelo tutte le istruzioni possibili a *causa dei ritardi causati dalla memoria*, per cui la potenza e le risorse del processore risultano sprecate. Per ovviare all’inconveniente, si può assegnare una *stessa* *reservation* *station a più* *program* *flow diversi*. Da qui nascono i processori **hyper-threaded**, che hanno un *unico core* *fisico* *(i.e.* *un’unica information station)* che permette di eseguire le reali operazioni dettate dalle istruzioni; d’altra parte, la porzione di processore che memorizza le istruzioni da fetchare, decodifica le istruzioni per uno specifico flusso (Decode) e tiene traccia dei registri logici dell’ISA (mediante Register Alias Table) viene replicata e viene definita **hyperthread**. Una CPU può contenere uno o più core.  Un core è un’unità all’interno della CPU che realizza l’effettiva esecuzione. E’ un “oggetto engine”. Con l’Hyper-Threading, un microprocessore fisico si comporta come se avesse due core logici, ma virtuali.  In questo modo si consente a un unico processore l’esecuzione di più thread contemporaneamente. Questo procedimento aumenta le prestazioni della CPU e migliora l’utilizzo del computer. 

---

**Esempio**: ho una bocca (core) e due mani con cui prendo il cibo (thread). Per migliorare la prestazione devo puntare ad aumentare i thread (più mani = più cibo in entrata). Se aumentassi il numero di bocche, non migliorerei, perchè sempre quel cibo ingerisco, anche se finisco prima devo aspettare la prossima forchettata.

---

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-50-25-Senza%20titolo.png)

In tal modo, è possibile eseguire più **workflow in parallelo su un unico core fisico**, e l’architettura risultante è riportata nella pagina seguente:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-51-00-image.png)

Tale architettura risulta molto vantaggiosa per la maggior parte dei workload, mentre risulta un po’ più avversa nel caso in cui tutti i thread che girano sullo **stesso core sono CPU-bound** ma non memory-bound. Infatti, in quest’ultimo caso è più probabile che si verifichi un conflitto tra i thread in esecuzione nell’utilizzo delle risorse della reservation station. Un processore hyper-threaded viene tipicamente marcato con l’indicazione su quanti <u>*core*</u> (=”motori”) e quanti <u>*hyperthread*</u> (=”thread fisici”) possiede.   
<u>Esempio:</u>   
Un processore a due core e quattro thread fisici viene marcato come **2C/4T**.   
In un contesto senza Hyperthread avremmo 2 core e 2 thread (1 per ogni core).  
 In un contesto con Hyperthread possiamo avere 2 core e 4 thread (2 thread per ogni core).  
Se ho un caso 2C/4T, vuol dire che il mio programma non può generare più di 4 thread?  
No, vuol dire che ogni core può gestire al massimo due thread con un proprio set di registri aventi alias (quindi due workflow in parallelo su unico core), quindi in totale posso gestire al massimo quattro thread/workflow in contemporanea.  Ci sarà lo scheduling che realizzerà il parallelismo, ma comunque ne verranno gestiti quattro insieme. I flussi sui thread possono essere speculativi.

## Gestione degli interrupt

Ne sono esempi: muovere mouse, premere sulla tastiera.  
L’interrupt è un segnale *proveniente* *da un certo dispositivo hardware* che indica la necessità di **cambiare il flusso di esecuzione** (e.g. andando a eseguire un handler). Poiché è buona norma processare gli interrupt il prima possibile, quando ne occorre uno, si attende solo che una delle istruzioni correntemente in pipeline vada in commit; dopodiché si effettua lo squash (ovvero si svuota) la pipeline e si iniziano a fetchare le istruzioni dell’handler dell’interrupt. Ciò può portare a un rallentamento dell’esecuzione, ma non vale la pena memorizzare da qualche parte lo stato di esecuzione delle istruzioni che vengono buttate (richiederebbe hardware aggiuntivo, inoltre non ho certezza che dopo l’handler, ritornando al flusso di esecuzione, io parta dall’istruzione subito dopo); tra l’altro, anche mentre viene eseguito il gestore di un certo interrupt può subentrare un ulteriore interrupt, e questo può avvenire iterativamente un numero arbitrario di volte.

**Attenzione:**   
Buttare delle istruzioni dalla pipeline implica prevenire i loro effetti sull’ISA ma, se esse hanno sporcato lo stato micro-architetturale, quest’ultimo non può essere ripristinato: rimangono comunque gli effetti dell’esecuzione speculativa delle istruzioni che sono state buttate. A livello hardware non ho meccanismi di gestione priorità o trap, operazioni offending come una divisione per 0 non vengono svolte dal processore, ma passano ad un handler.

## Gestione delle eccezioni

Esse avvengono durante esecuzione di un programma, a livello software.
Le eccezioni risultano più complesse da gestire rispetto agli interrupt poiché vengono sollevate dall’esecuzione di particolari istruzioni. Di fatto, un’istruzione A (cosiddetta **offending**) che solleva un’eccezione $e_A$ può essere eseguita speculativamente all’interno della pipeline e, di conseguenza, potrebbe non esistere nel flusso di esecuzione definito dal programmatore. Ad esempio, poco prima dell’istruzione A potrebbe esserci un’istruzione B che solleva a sua volta un’eccezione $e_B$: in tal caso sarà $e_B$ a esistere realmente e non $e_A$. Una Istruzione è <u>offending</u> se vuole usare qualcosa che non è usabile. Non genera una trap, perchè non so se arrivo in retire. Se l’istruzione successiva in fondo non viene committata, cancello tutto. A valle di queste considerazioni, un’*eccezione viene presa in carico solo nel momento in cui l’istruzione che l’ha generata va in* *retire*, anche se ci si può accorgere prima che l’istruzione sia offending. (Vedi sotto, etichettamento offending).  
Ma quali sono gli stage in cui un’istruzione può rivelarsi offending? 

- **Instruction** **Fetch / Memory stages**  
  (MEM stage = stage in cui avviene l’accesso agli operandi): qui si può avere un page fault (ovvero un tentato accesso a un indirizzo logico di memoria che attualmente non ha un corrispettivo fisico), un accesso in memoria disallineato o una violazione delle protezioni applicate a una pagina di memoria (e.g. si tenta di accedere in scrittura a una locazione read-only).

- **Instruction** **Decode** **stage**: qui può emergere che l’istruzione in esercizio sia illegale. 

- **Execution** **stage**: qui può essere sollevata un’eccezione aritmetica (e.g. divisione per zero). 

- **Write-Back stage**: qui non possono essere sollevate eccezioni.

**Per etichettare un’istruzione come** **offending**, si imposta a $1$ un apposito bit dei metadati. Quando tale istruzione va in *retire*, se il bit vale $1$ allora il commit non viene effettuato, bensì viene attivato il gestore di eccezioni opportuno. A tal punto tutte le istruzioni successive a quella offending diventano *phantom* (fantasma).

<u>Attenzione:</u> Con le eccezioni si verifica lo stesso problema riscontrato con gli interrupt. In particolare, quando un’istruzione offending va in retire, si hanno altre istruzioni all’interno della pipeline che hanno già modificato lo stato micro-architetturale e, dunque, hanno lasciato tracce di informazione. Questa problematica lascia spazio al cosiddetto attacco **Meltdown**. Sto propagando “attività illecite” nella pipeline.

## Attacco Meltdown

Sappiamo bene che *ciascun processo ha il proprio address space* suddiviso in zone di memoria dedicate all’esecuzione *user mode* e zone di memoria dedicate all’esecuzione *kernel mode*. L’attacco ha come scopo ultimo quello di accedere a un’area di memoria situata nel kernel anche se non si hanno i permessi, magari per andare a leggere delle informazioni sensibili di un utente differente del sistema. Andando nel dettaglio, l’attacco viene eseguito nella maniera spiegata qui di seguito. Anzitutto si definisce un array A nella memoria user space e si svuota la cache tramite l’istruzione `cflush`. Dopodiché, mediante una `mov`, si preleva un **particolare byte** $x$ (*e.g*: address) situato nel kernel e si memorizza il byte in un registro; naturalmente questa `mov` è un’istruzione offending. Si accede alla entry con **spiazzamento** **$x$** rispetto all’indirizzo base dell’array A (e.g. caricandone il contenuto in un registro) in modo da farla salire in cache: tale aggiornamento della cache rappresenta proprio il *side effect* lasciato sullo stato micro-architetturale da parte dell’istruzione successiva a quella offending che, chiaramente, viene eseguita *solo speculativamente*. A tal punto, poiché l’array A si trova in user space, è possibile accedere a tutte le sue entry e, per ogni entry, cronometrarne il tempo necessario per l’accesso: la entry relativa al tempo di accesso minore sarà chiaramente quella di spiazzamento $x$, perché si tratta dell’unica entry il cui contenuto era stato memorizzato in cache. Ed ecco qui: **ora è noto** **lo spiazzamento** **x**, che era proprio il byte di memoria prelevato inizialmente dal kernel space. Ricapitolando, il valore $x$ è stato ottenuto in maniera indiretta misurando i tempi di accesso alle informazioni presenti nell’array A. Di conseguenza, abbiamo a che fare con un **side-channel** (o **covert-channel**) **attack**, ovvero con un attacco che fa uso di un canale laterale per andare a rubare delle informazioni. Io parto da un byte *B* presente nella zona kernel, lo salvo in un registro (non potrei), accedo a `array[B]` che va in cache. Successivamente accedo a tutte le entry di array (in un loop continuo, indipendente da *B*). L’accesso più veloce sarà quello ad `array[B]`, e quindi tra tutti gli accessi effettuati, riesco a capire cosa c’è in `array[B]`, perchè più veloce. Quindi prendendo un byte nella zona kernel, riesco da user a leggere qualcosa a livello kernel.  
Meltdown può essere esteso anche al caso in cui si vuole scoprire un’intera stringa all’interno del kernel space, che può essere una password, una chiave segreta e così via. Negli esempi

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-51-41-image.png)



## Insights sui processori x86 e x86-64

*X_86* ha 8 registri general purpose, e Program Counter 32 bit.   
*X_86_64* è backward compatibile, ha 15 registri general purpose a 64 bit e Program Counter a 64 bit.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-54-06-image.png)

- **GPR**: registri general purpose.

- **SSE & SSE2**: registri vettoriali, che consentono a singole istruzioni di fare più cose in parallelo.  

- **x87**: floating-point stack registers.

- **RIP**: program counter.

Vediamo alcune istruzioni fondamentali per il trasferimento di dati nell’architettura x86-64:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-13-19-43-18-15.png)

La parte più complessa però sta nello specificare la sorgente e/o la destinazione **in memoria logica** (e non su un registro). La figura riportata in seguito mostra il meccanismo utilizzato. In *ISA* non ho i nomi delle variabili, solo quelli dei registri, per arrivare ad una variabile di memoria devo usare l’indirizzo di tale variabile in memoria.   
Nota: Le componenti *base, index, scale* sono sempre contenute nelle parentesi, ad esempio *movl (..., ..., ...)*

- **Displacement**: può ad esempio essere un indirizzo assoluto noto a tempo di compilazione. Possiamo vederlo come il punto dell’address space che specifica la sorgente (es: *foo è displacement diretto*) 

- **Base**: può essere relativo al valore di un pointer. 

- **Index*scale**: può rappresentare uno spiazzamento rispetto all’indirizzo base; ad esempio, quando si itera su un array di interi, *scale* vale sempre 4 mentre *index* viene incrementato di 1 a ogni iterazione.

*(nb: in %ebc è dove carico il tutto).*

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-52-02-image.png)

Vediamo ora le istruzioni logiche e aritmetiche:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-13-19-45-55-17.png)

## Codice assembly dell'attacco Meltdown

Nella pagina seguente viene mostrato il codice assembly che permette di effettuare l’attacco Meltdown. La sintassi utilizzata è quella di Intel. Chiaramente il codice può essere incapsulato all’interno di un programma C.

```c
; rcx = kernel address
; rbx = probe array (array A)
retry:
mov al, byte [rcx] //istr. offending. Prendo byte[rcx] e lo metto in ‘al’, ultimo byte del reg. ‘eax’ 
shl rax, 0xc      //shifto rax di 0xc = 12, cioè 12 bit a 0 (verso sx shifto la parte meno significativa) lo spiazzamento dista 2^12 = 4096 byte dal predecessore SEMPRE.
jz retry         //se il valore letto nel kernel è nullo, cioè rax=0 riprovare.
mov rbx, qword [rbx + rax] //qui si effettua l’accesso al probe array con spiazzamento pari a rax
```

Vale la pena fare alcune osservazioni: 

- 4096 byte è esattamente la dimensione di una pagina di memoria. Ma perché gli spiazzamenti che si prendono in considerazione all’interno dell’array A sono esclusivamente la prima entry di ciascuna pagina di memoria? Per evitare problemi con la cache: di fatto, quando si accede a un certo valore in memoria, non è solo lui a essere caricato in cache, ma come minimo una **linea di cache**, che è lunga *64 byte*. Leggiamo sempre lo 0-esimo byte, perchè la cache lavora a blocchi e potrei trovare ‘64 byte’ rapidi, e quindi non essere in grado di differenziare gli accessi. Per giunta, i processori tipicamente applicano il cosiddetto **pre-fetching**: nel momento in cui viene caricata in cache una linea, vengono conseguentemente caricate anche alcune linee adiacenti per il principio di località. Perciò, per evitare che i valori relativi a più di uno spiazzamento in A vengano caricati in cache a seguito di un unico accesso, si prendono gli spiazzamenti in modo tale che siano distanti tra loro, e una distanza di 4096 byte risulta essere sufficiente.  

- Perché se nel kernel space viene letto il byte 0 si fa un nuovo tentativo? Perché un’area di memoria inizializzata a zero o è memoria non valida o è relativa a un terminatore di stringa, per cui si tratta di un’area di memoria non significativa. Resta comunque possibile ritentare ad accedere al medesimo byte all’interno del kernel space perché non è escluso che, in concorrenza, il kernel possa cambiare il valore di quel byte (da zero a un valore significativo e di interesse).

### Contromisure per l’attacco Meltdown

- <u>KASLR (Kernel Address  Space  Randomization):  </u> 
  Quando si fa il setup del kernel del sistema operativo, le strutture dati di livello kernel possono cadere ovunque all’interno del kernel space: in particolare, si stabilisce randomicamente un *offset F* rispetto all’indirizzo base del kernel a partire da cui sono definite le varie strutture dati del kernel. In questo modo, si complica la vita all’attaccante poiché lui non conosce a priori l’indirizzo del kernel space in cui andare a effettuare l’attacco; tuttavia, con un approccio brute-force, può comunque fare in modo che, prima o poi, l’attacco vada a buon fine. Per questa ragione, KASLR non è la soluzione definitiva contro l’attacco Meltdown.

- <u>Cash flush:</u>   
  Si effettua semplicemente un flush della cache ogni volta che il kernel prende il controllo od ogni volta che un thread viene rischedulato. Tuttavia, così facendo, si avrebbe un calo inaccettabile delle prestazioni: le cache sono condivise tra i vari hyperthread, per cui ciascun cache flush impatterebbe su tutti i thread in esecuzione all’interno dell’host.

- <u><b>KAISER (Kernel </b></u> <u><b>Isolation</b></u> <u><b> in Linux)</b></u><u>:</u>   
  Quando un processo gira in modalità *user*, utilizza una page table $PT_U$ all’interno della quale il mapping della maggior parte degli indirizzi del kernel space non è presente: ci sono esclusivamente quegli indirizzi della porzione del kernel che vengono utilizzati ad esempio per gestire gli interrupt (se non ci fossero almeno loro, non saremmo neanche in grado di gestire gli interrupt o comunque di trasferire il controllo al kernel). Dall’altro lato, quando un processo gira in modalità kernel, utilizza un’altra page table $PT_K$ che contiene il mapping degli indirizzi di memoria mancanti in $PT_U$. Di fatto, gli indirizzi del kernel space il cui mapping è presente nella page table $PT_U$ costituiscono la cosiddetta **entry zone** del kernel, che contiene quasi esclusivamente il codice che permette di effettuare lo switch delle page table ($PT_U$ a $PT_K$). Perché quest’ultima soluzione risulta funzionante? Nel momento in cui un processo che esegue in user mode incontra un’istruzione offending che vuole accedere a un indirizzo di memoria del kernel space, tipicamente non troverà tale indirizzo nella page table che ha a disposizione. In altre parole, si solleva un’eccezione di tipo **page fault**, che non consente al processo di continuare ad eseguire le istruzioni anche speculativamente. Inoltre, si tratta di una soluzione che, sì, ha dei costi prestazionali, ma mai quanto il cash flush; in particolare, il calo delle performance viene osservato dalla **TLB -** **Translation Lookaside Buffer** che, a ogni switch da user mode a kernel mode e viceversa, dovrà cachare le informazioni sulla nuova memory view su cui ci siamo spostati (che sia essa relativa alla $PT_U$ o alla $PT_K$). Entrando un po’ più nel dettaglio sulle page table, se ne hanno di livelli differenti (page table di livello 1, page table di livello 2, e così via). Solo le **page table di livello 1** sono replicate tra l’esecuzione user mode e l’esecuzione kernel mode, mentre le altre sono a **istanza unica**; in particolare, al livello 1, la page table $PT_K$ è in grado di raggiungere tutte le informazioni delle page table ai livelli inferiori, mentre la page table $PT_U$ punta solo a un sottoinsieme di informazioni delle page table ai livelli inferiori. Da user possiamo comunque accedere a qualcosa di livello kernel, ma solo per i moduli kernel utili/indispensabili (compile time) per avere il minimo supporto necessario. <u>KAISER</u> sfrutta quindi questa tecnica di **PTI-Page Table Isolation**, disattivabile da GRUB. Il selettore <u>CR3</u>, ad ogni cambio, azzera la TLB e genera cache miss. Però è un’operazione automatica ed abbastanza semplice.
  ![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-53-31-image.png)

## Insights sui branch

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-53-14-image.png)

Per i salti **condizionali** e **indiretti**, l’indirizzo da cui riprenderà l’esecuzione è noto soltanto a partire da un certo stage S della pipeline. Chiaramente, però, vogliamo che venga comunque eseguito del lavoro all’interno della pipeline prima che l’istruzione di salto raggiunga lo stage S, altrimenti il calo delle prestazioni sarebbe certo e significativo. 
A tal proposito, si introducono dei **dynamic** **predictor** (o **branch** **predictor**), che hanno lo scopo di predire quale sarà la destinazione verso cui si dovrebbe saltare con la più alta probabilità. Ciò permette di comporre in maniera speculativa un program flow all’interno della pipeline in funzione della predizione che è stata attuata dal predittore. La reale implementazione dei branch predictor è basata sui **Branch** **History Table** (**BHT**), detti anche **Branch-Prediction** **Buffer** (**BPB**), che contengono metadati che associano un’istruzione di salto all’ipotesi su dove tale istruzione salterà. E’ una zona di cache hardware contenente `[indirizzo istruzione, target da usare se jumpo]`, e l’indirizzo istruzione può anche essere il target stesso. E’ un suggeritore, non so nulla dell’affidabilità. L’implementazione minimale (andando avanti verranno aggiunte altre componenti) per una BHT consiste in una cache indicizzata tramite i *bit meno significativi* di ogni istruzione di salto. Ogni qual volta viene fetchata un’istruzione di salto, si può avere una cache hit o una cache miss, dove la *cache hit* la si ha nel caso in cui sono disponibili sufficienti informazioni che permettano di effettuare una predizione sulla destinazione del salto. Queste informazioni consistono in particolari bit di stato: ciò che succede nel passato è rappresentativo di ciò che si prevede che accadrà in futuro. Nei salti **condizionali** ho due destinazioni, saprò quella corretta in fase di esecuzione, e quindi è register dependent, perchè dipende a runtime cosa ci sarà nel registro).  
I salti **unconditional** e le **call**, dove salteremo è già noto nello stage di decode, salterò sempre in quel punto.  
Anche le **return** vengono sempre eseguite, ma ho più destinazioni note nello stage di esecuzione.  
Per i salti **indiretti** salterò sempre (come per le call), ma con più destinazioni. Il target potrebbe essere in un registro.

### Predittori per i salti condizionali

#### Predittori coi bit di stato

Il modo più facile per implementare un predittore per i salti condizionali è sfruttando un **unico bit di stato**: se l’ultima istruzione di salto ha avuto come esito “taken” (ovvero ha realmente portato a effettuare il salto), allora il predittore prevederà che anche il prossimo salto avrà come esito “taken”, e viceversa. Qui la storia passata è rappresentata esclusivamente dall’*ultima istruzione di salto*, per cui non si tratterebbe neanche di un vero e proprio storico.   
<u>**Esempio Caso semplice**</u>: 

ciclo for, sbaglio la predizione quando uscirò.
Per questo motivo, sono stati introdotti anche i predittori a *due bit* di stato. Di fatto, questi predittori si comportano meglio negli scenari in cui si hanno molte istruzioni di salto con esito “taken” e poche istruzioni di salto con esito “not taken” (e viceversa). Lo scenario classico è quello dei *nested loop*. In particolare, la predizione cambia da “taken” a “not taken” (o viceversa) non più a seguito di un solo errore, ma a seguito di **due errori consecutivi del** **predittore**. La macchina a stati che rappresenta i predittori a due bit è la seguente, dove:

- T = “predìco che il salto sarà taken”

- NT = “predìco che il salto sarà not taken” 

<u>**Esempio doppio ciclo**</u>: 
Nel ciclo interno itero, e la predizione mi dice che salterò. Quando finisco le iterazioni nel ciclo interno, la predizione sbaglia e dice che continuerò nel ciclo. Invece aumento l’iterazione sul ciclo esterno (1 errore). Però poi rientro effettivamente nel ciclo interno, quindi in realtà non devo cambiare predizione anche se ho fatto un errore, perchè stavolta ci rientro davvero dentro. *Solo se sbaglio 2 volte cambio previsione.*

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-52-29-image.png)

Ricordiamo che, in caso di previsione sbagliata, in pipeline vengono caricate istruzioni che alla fine subiranno uno <u>squash,</u> che porterà al <u>refill</u> della cache. Quindi è importante effettuare la predizione con un buon tradeoff affidabilità/supporto hw.

Esistono anche predittori più sofisticati come il **Two-Level** **Correlated** **Predictor** e l’**Hybrid** **Local/Global** **Predictor** (noto anche come **Tournament** **Predictor**).

#### Two-Level Correlated Predictor

Consideriamo il seguente codice:

```c
if (aa == VAL) aa = 0;
if (bb == VAL) bb = 0;
if (aa != bb) { 
                //do the work
              }  
```

Ci piacerebbe avere un predittore tale per cui, se i branch relativi ai primi due if vengono presi, predìca che il terzo branch (che dipende dai due precedenti) non venga preso. 
È quello che fa il **(m,n) Two-Level Correlated Predictor**, dove: 

- m = *numero di salti precedenti*, il cui esito determina la predizione che verrà effettuata. 

- n = numero di bit del valore che indica quanti **errori** deve commettere il predittore prima di **cambiare** la sua **predizione** (esattamente come nei predittori con bit di stato).

**Esempio**:

Consideriamo il caso con m=5, n=2. Si ha il seguente scenario:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-52-51-image.png)

Il **global history** **register** è composto da *m* bit, ciascuno dei quali indica l’esito di uno delle ultime m istruzioni di salto condizionale. Da destra ho i salti più recenti. Tale registro può assumere $2^m$ valori diversi, e a ciascuno di essi è associato un predittore con bit di stato (= una macchina a stati) differente. Il predittore per la predizione corrente viene scelto sulla base dei risultati degli ultimi m branches, come è codificato nella $2^m$ bitmask. Sostanzialmente usiamo il Global History Register come indice.  

**Un esempio semplice con (m = 2, n = 2).**  
Nel global register posso avere 4 casi: 00, 01 , 10, 11, dove 0 vuol dire “not taken” e 1 “taken”. Per ogni casistica associo una entry nel Patter History Table.  
00 mappato nell’entry 0, 01 mappato nell’entry 1, 10 mappato nell’entry 2, 11 mappato nell’entry 3.  
Il fatto che $n = 2$ vuol dire che ogni entry mantiene 2 bit nell’array, ovvero include l’automa a stati visto precedentemente.

Se ho tre statement if, e salto sempre al terzo in modo condizionato, la mia branch sequence è 001001001001...   
Se (m = indifferente, n = 2) mantengo 4 entry con due bit ciascuno (00, 01, 10, 11).  

- Entry 00: ho sbagliato due volte, allora il terzo salto sono sicuro.

- Entry 01: ho sbagliato una volta, resto su 0. 

- Entry 10: ho sbagliato una volta, resto su 0.  

- Entry 11: non capita perchè abbiamo detto di non saltare due volte consecutivamente.  

Se avessi (m = 0, n = 2), avrei 0 elementi per identificare l’entry. Sarebbe un predittore basico. 

### Tournament Predictor

In realtà non è sempre vero che i salti condizionali siano correlati tra loro. Per questo motivo si introduce l’**Hybrid Local/Global Predictor**, che consiste in una “sfida” tra un **predittore** **locale** (come quelli con bit di stato) e un **predittore** **globale** (che si basa sulla storia passata e assume che i salti condizionali siano correlati). In pratica, si hanno entrambi questi predittori e in più una macchina a 4 stati che indica se correntemente conviene utilizzare il predittore locale oppure quello globale: se stiamo sfruttando il predittore locale, *switchamo a quello globale dopo due errori consecutivi, e viceversa.* Ciò è realizzato mediante *Return Stack Buffer RSB*, tipo una semplice cache, con 32 entries (quindi 32 livelli di annidamento), cioè indirizzi associati al return point dell’istruzione call, in cui salvo nella prima entry libera tale indirizzo di ritorno. 

#### Osservazione su RSB

Faccio call di una funzione, salvo indirizzo successivo alla call in RSB, quando esco dalla funzione il return punta all’indirizzo salvato nell’RSB precedentemente. RSB è una cache di tipo LIFO, contenuta nel processore ed è modificabile solo tramite *call* (inserimento valore) *o return* (prelievo valore). Non è esposta nell’ISA.

Questi switch e letture avvengono in elementi mantenuti in cache, allora non ho perdite di prestazioni.

### Predittore per salti indiretti

I salti indiretti sono tali per cui l’indirizzo di destinazione viene caricato in un registro. Se l’istruzione deve saltare, questo è funzione del risultato delle istruzioni precedenti, ovvero di cosa queste hanno scritto nei registri, che verranno usati per saltare.

Quindi, il valore di tali registri può *variare sempre nel tempo*, il che rende la predizione più complessa e con più side effects generati. Per questo motivo, le destinazioni possibili possono essere molteplici, e la predizione può risultare più farraginosa. I predittori per i salti indiretti sono dotati della seguente struttura dati:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-55-04-image.png)

Ciascuna entry della tabella è relativa all’indirizzo di una particolare istruzione di salto (**branch** **address**). Ogni branch address è associato a un **prefetched** **target** (che è il *presunto* indirizzo destinazione del salto, se c’è cache miss non posso prelevarlo, oppure prendo l’istruzione successiva) e a dei **prediction** **bit** (che, come al solito, determinano numero di errori consecutivi da commettere prima di cambiare la predizione, ovvero prima di cambiare il prefetched target). In particolare, la prima volta che si incontra una certa istruzione di salto indiretto, si effettua il training, in cui il prefetched target verrà inizializzato all’effettivo indirizzo destinazione del salto. In queste tabelle riporto solo i bit meno significativi, per questioni di scalabilità. Tutto questo sta nel core, e se ho hyperthreading, la predizione viene fatta da una comune componente hardware per più thread. Ovvero se ho due thread (supponiamo facciano stesse cose) su due hyperthread e 1 core, questo core comune può essere sfruttato dal thread 2 per avere informazioni sui salti ereditate da thread 1, per ottenere un boost delle performance. A livello di sicurezza è un po’ problematico: se thread1 seguisse un comportamento tale da suggerire al thread 2 di fare salti (anche speculativi) che in realtà non dovrebbe fare?

## Attacco Spectre

Chiaramente anche la predizione dei target dei salti condizionali può portare il processore a riempire la pipeline con istruzioni eseguite in modo speculativo. In particolare, se la predizione è scorretta, le istruzioni successive al salto dovranno poi essere buttate. Ma anche qui, come nel caso delle eccezioni, le istruzioni considerate in maniera <u>speculativa</u> che poi vengono scartate lasciano dei side effect nello stato micro-architetturale. (Solito discorso: un salto speculativo non installa nulla nell’ISA, ma lascia tracce a livello micro architetturale). Da qui nasce la possibilità di compiere una famiglia di attacchi denominati **Spectre** che sfruttano un covert-channel.   
Questi attacchi sono anche più gravi di Meltdown poiché:

- **Non richiedono l’esecuzione di un’istruzione** **offending.**

- È possibile effettuare un **training** **scorretto** del branch predictor inserendo nel codice di livello user degli appositi branch / delle istruzioni di salto condizionale.

L’unica soluzione per evitare questi attacchi sarebbe quella di non fare predizioni, ma i sistemi diventerebbero molto più lenti (con o senza hyperthread), a livello di marketing sarebbe una mossa controproducente!

### Spectre V1

È un attacco che inizialmente effettua il flush della cache (come Meltdown) per poi sfruttare i salti condizionali. In particolare, prevede l’utilizzo del seguente blocco di codice:

```c
if (x < array1_size) 
  y = array2[array1[x] * 4096] 
//il prodotto per 4096 corrisponde a uno shift a sx di 12 posizioni
```

- *array1* è un array che può trovarsi in qualunque punto dell’address space, e `array1[x]` è un particolare valore che verrà moltiplicato per 4096 per ottenere un indice di pagina, che verrà utilizzato per accedere ad *array2*. 

- In ogni caso, il valore $x$ viene selezionato in modo tale che sia molto elevato (maggiore di *array1_size*), cosicché il branch non venga realmente preso, mentre magari il predittore prevedeva il contrario; inoltre, $x$ può essere tale che l’accesso ad *array2* porti a reperire (speculativamente) un’informazione segreta ($y$), ad esempio all’interno del kernel space. 

- Quel che si ottiene è che il valore $y$ viene caricato all’interno della cache in modo speculativo. A questo punto, come in Meltdown, si effettuano gli accessi alla prima entry di ogni pagina di *array2* finché non si giunge a quella caricata in cache (di cui si osserva un tempo di accesso ridotto). 

- Quindi ciò che carico è in funzione sia dell’array sia di $x$, se salto molto lontano potrei andare in una zona kernel. Lo scopo è far si che questa condizione venga eseguita speculativamente, quindi il predittore deve essere indotto a credere che tale flusso di esecuzione sarà quello realmente eseguito. 
  **Non devo eseguirlo realmente!**

- No trap perchè sono sempre in user mode e tutto dipende dall’esito dell’IF. Aver *patchato* Meltdown non implica risolvere anche Spectre. La soluzione di Meltdown risiedeva nel fatto che tale attacco creasse una trap poichè si passava da user a kernel, e c’era il cambio del puntatore alla page table. Qui sono sempre in user mode.

### Spectre V2

Con più thread passo alla versione v2!
È un attacco che sfrutta i salti multi-target (indiretti) ed è di tipo **cross-context**. Ciò vuol dire che l’attaccante è in grado di inferire (aggiungere) delle informazioni sensibili da un contesto di esecuzione diverso dal suo: supponiamo di avere due thread A, B che girano sul medesimo hyperthread in modalità processor sharing o su due hyperthread relativi allo stesso core. Il thread A può portare avanti delle attività che vanno a cambiare lo stato del branch predictor all’interno del CPU-core. Di conseguenza, B può osservare il nuovo stato del branch predictor all’interno del medesimo CPU-core e, quindi, le attività che lui eseguirà in modo speculativo (in funzione dello stato del branch predictor) vengono *praticamente decise, e poi osservate mediante side effect, dal thread A*. Tale side effect, come al solito, può consistere nel caricamento di un’informazione sensibile all’interno della cache attraverso il suo accesso in memoria. L’efficacia dell’attacco diventa particolarmente evidente quando l’attaccante si basa su un contesto che utilizza una libreria condivisa (shared library) col contesto del thread B. Qui, infatti, le pagine di memoria della shared library vista dal thread B e le pagine di memorie della shared library vista dal thread A mappano esattamente sugli stessi indirizzi fisici. Perciò è ovvio che qualunque side effect la vittima lasci speculativamente su tali locazioni fisiche di memoria sia direttamente visibile all’attaccante.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-55-22-image.png)

Con riferimento alla figura, il **gadget** è un blocco di codice che è definito nell’address space della vittima e viene sfruttato dall’attaccante affinché la vittima lo esegua in modo speculativo a seguito di un errore del branch predictor; in tal modo, nello stato micro-architetturale, la vittima lascia i side effect desiderati dall’attaccante. Nell’esempio mostrato nella figura vengono utilizzati due registri (*R1* e *R2*), di cui *R1* viene utilizzato per calcolare R2 con una particolare funzione, mentre *R2* viene usato per memorizzare l’indirizzo verso cui accedere in memoria. In realtà, sarebbe sufficiente l’utilizzo di un solo registro *R1*.

<u>NB:</u> **l’utilizzo del medesimo CPU-core tra thread A e thread B è richiesto** **solo** **per** **effettuare un training errato** **sul** **branch** **predictor**. Dopodiché, poiché la cache è condivisa tra più CPU-core, gli accessi in memoria effettuati per stabilire quali dati sono saliti in cache possono essere effettuati anche in un momento in cui il thread vittima (B) gira in un CPU-core differente. Tra l’altro, per portare a termine l’attacco, è possibile anche utilizzare una macchina virtuale su cui possono girare delle applicazioni che, in qualche modo, vanno a cambiare lo stato del branch predictor: in fondo l’hardware sottostante viene utilizzato anche per eseguire le macchine virtuali!

## Contromisure per gli attacchi Spectre

### Retpoline - Return trampoline

Al posto di invocare l’istruzione di salto indiretto (che sia essa una jump o una call), si esegue un blocco di istruzioni funzionalmente equivalente che non consente di effettuare una mis-prediction (ovvero un training scorretto del branch predictor) per portare a compimento l’attacco Spectre. Una versione semplificata del blocco di istruzioni è riportata di seguito. Non faccio più salti indiretti, solo diretti!  
Invece di *Jump su R*, eseguo *Return su R*, non c’è più predizione. Il *RET* usa il *Return Stack Buffer* per la predizione (di tipo *Lifo*), controllabile via software, a differenza del predittore di Branch Indiretto.

```c
      push target_address
      1:  call retpoline_target      
          //put here whatever you would like (with no side effects)    
          jmp 1b
      retpoline_target:
          lea 8(%rsp), %rsp //we do not simply add 8 to RSP since FLAGS registry should not be modified      
          ret   //this will jump to target_address
```

Vediamo nel dettaglio cosa fa questo blocco di istruzioni:

- Carica l’indirizzo destinazione del salto (`target_address`) sullo **stack**. (ora è in cima allo stack) 

- Effettua una call di `retpoline_target` (per cui viene caricato sullo **stack** *anche l’indirizzo* *dell’istruzione successiva alla call*).
  ( Graficamente, nell’address space avremo *target_address* e sopra di lui, l’indirizzo successivo alla call. Questo perché chiamata *retpoline_target*, prevediamo che al suo *return* ripartiamo dall’istruzione successiva ad essa). `rsp` a 64 bit, quindi 8 byte, per questo faccio quello shift.

- In `retpoline_target` si **elimina** l’indirizzo dell’istruzione successiva alla call e, tramite la return, si salta verso l’indirizzo che si trova in cima allo **stack** (ovvero *target_address*). Facendo lo shift di 8 byte, cancelliamo il punto di ritorno della chiamata *retpoline_target.* Dopo ciò, in cima allo stack abbiamo proprio *target_address.* 

- Essendoci una **call** (non è register dependent, mi manda verso la funzione chiamata), il predittore non deve essere soggetto a training: prevede che, a seguito della return, si salti verso l’istruzione successiva alla call. Per questo motivo, dopo la call devono essere eseguite delle istruzioni innocue, come una jump verso l’istruzione stessa di call. La *return* vede qualcosa nell’ *rsb* che non può essere bypassata. La *ret* esegue speculativamente ciò che gli dice *rsb*. Tuttavia, se la CPU specula, l’RSB la porta ad eseguire *jmp 1b*, intrappolandolo in un loop. Successivamente, la CPU realizza che il valore in RSB è diverso da quello nello stack (*target_address*), e stoppa la speculazione. ***O vado in target_address, o resto in un loop.*** RSB ha senso per singolo processo, mentre il predittore si muove tra più flussi.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-57-23-image.png)

## Esistono altre tecniche per Spectre V2?

### IBRS (Indirect Branch Restricted Speculation)

È possibile aggiornare il registro **MSR** (Model Specific Register, è un registro di controllo nella CPU) per creare un’enclave di esecuzione (= uno spazio di esecuzione chiuso entro determinati confini) dove la storia non è influenzata da cosa avviene al di fuori dell’enclave stessa. In pratica, a livello hardware siamo in grado di utilizzare la branch prediction in maniera differenziata a seconda se stiamo lavorando a livello user (MSR=0) o a livello kernel (MSR=1): nel primo caso il branch predictor dei salti indiretti si basa sulla storia passata della sola esecuzione a livello user, mentre nel secondo caso si basa sulla storia passata della sola esecuzione a livello kernel. Sostanzialmente, a tempo $t$ decido che lo stato del predittore non dovrà più essere usato per un certo tempo. E’ un guscio che mi protegge dall’esterno. Utile se ho app che lavorano a livelli diversi (user e kernel), se ad esempio volessi che le scelte kernel non venissero influenzate dall’user.

### IBPB (Indirect Branch Prediction Barrier)

Anche qui ci si basa sull’utilizzo del MSR. In particolare, nell’istante in cui si va a scrivere all’interno di tale registro, stiamo cancellando tutto ciò che il branch predictor dei salti indiretti ha imparato finora, creando così una sorta di barriera. Al tempo $t$ resettiamo il branch predictor.

**IBRS** e **IBPB** sono operazioni software, spesso si usa la syscall `prcrc()` per lavorare col Processor Control.  Se lavoriamo con `exec()` (programma che chiama un altro programma) funzionano uguale, perchè facenti parte dello stesso programma iniziale.

## Sanitizzazione

### Introduzione

Per Spectre V1 abbiamo visto la possibilità di riusare le patch di Meltdown.  Spectre V1 mi permetterebbe di leggere dati kernel? Sì, perchè la predizione a livello kernel potrebbe essere basata su predizioni livello user.  
A livello kernel abbiamo una tabella, che chiamiamo **driver**, in cui per ogni indice ho un servizio che richiama una *system call*.
L’indice è passato dall’user, ma è compatibile con la taglia della tabella? Dipende, con l’indice facciamo un salto verso una entry, ma se <u>eccedo</u> la dimensione? **Speculativamente** starei usando un indice errato come pointer per una zona codice Kernel, perchè se le precedenti `call` erano corrette, il predittore si sarà settato in un certo modo. (Se ha sempre saltato, speculativamente lo rifarà). Soluzione? Sanitizzazione.

### Come funziona

È una contromisura per i salti condizionali. In particolare, ciascuna condizione `if` che coinvolge una certa variabile V prevede dei valori per V ammissibili e dei valori per V non ammissibili. Quello che si fa è ridurre all’osso l’insieme dei valori non ammissibili, facendo sì che tutti gli altri valori non ammissibili non possano in alcun modo essere assunti da V. Questa è una tecnica estremamente utile per gli indici delle tabelle. Infatti, supponendo che per una tabella gli indici ammissibili vadano da $0$ a $j-1$, se per qualche motivo l’indice dovesse assumere un qualunque valore maggiore di $j-1$, viene forzato ad assumere il valore $j$. In pratica, abbiamo imposto che $j$ sia l’unico valore non ammissibile che può essere materializzato. A questo punto, se l’indice vale $j$, viene imposto ad esempio un accesso in memoria innocuo (i.e. alla prima locazione di memoria subito dopo la tabella vengono inserite delle informazioni non sensibili in modo tale che, anche speculativamente, viene acceduta o una entry della tabella o l’unica locazione di memoria ammissibile e innocua al di fuori della tabella).

### Come funziona - for dummies

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-58-15-image.png)

Normalmente avremmo “indici OK” (verde) ed “indici NON OK” (rosso). Però se usassi questi indici NON OK, potrei andare in zone delicate. Introduco la “zona nera”, più ampia. Tutto quello che cade li dentro lo butto nella zona rossa, che sarà la più piccola possibile, per limitare i danni.  
Come lo faccio? Applicando una maschera di bit.  
Perchè devo differenziare zona rossa e nera?  
Perchè se lascio solo zona rossa posso andare in zone brutte. Se questa è piccola (ad esempio un indirizzo non critico) e faccio si che tutti gli altri indici *NON OK* vadano lì dentro, limito i danni.  
Perchè non voglio che applicando questa maschera ad un indice NON OK, questa mi porti ad una zona verde. 
Quindi prima applico la maschera, e poi faccio il controllo.

### Loop unrolling

Ricordiamo che i salti sono azzardi, sbagliare salto compromette performance (squash pipelin) e sicurezza. E se riducessimo i salti?  

```c
int s=0;
for (int i=0; i<16; i++)
    { s+=i;}
```

Questo ciclo si traduce nella seguente sequenza di istruzioni assembly (dove la sintassi adottata è AT&T):

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-58-32-image.png)

Come si può notare, a ogni iterazione del ciclo vengono eseguite cinque istruzioni, di cui tre di controllo (in blu scuro) e solo due di lavoro effettivo, in cui viene incrementata la variabile `s` (in nero): in pratica, in questo particolare esempio, abbiamo un overhead di computazione pari ai 3/5 delle istruzioni totali, il che porta inevitabilmente a un degrado delle prestazioni. Per questo motivo, corre in aiuto il **loop** **unrolling**, che è una tecnica per “srotolare” i cicli: da una parte si riduce il numero di iterazioni che devono essere eseguite, dall’altra, all’interno di ciascuna iterazione, si esegue il lavoro utile più volte. In tal modo, si riduce il numero di volte in cui devono essere eseguite le istruzioni di controllo. Per effettuare l’unroll in modo automatico, è possibile ricorrere alle seguenti direttive di C:

```c
#pragma GCC push_options
#pragma GCC optimize (“unroll-loops”)
//region to unroll
#pragma GCC pop_options
```

È anche possibile specificare esplicitamente il fattore di unroll mediante `#pragma unroll (N)`. Ma affinché queste direttive siano effettivamente attive, è necessario compilare il file C col *flag -O*.

**Attenzione**: il loop unrolling porta alla necessità di utilizzare un maggior numero di registri per eseguire tutte le operazioni della medesima iterazione. Inoltre, porta ad avere le istruzioni macchina del ciclo su un range di indirizzi più ampio, per cui si ha una minore località. Per questi motivi, non è una tecnica che può essere sfruttata in modo spregiudicato. Per sfruttarlo bene, bisogna capire architettura e obiettivi!

## Power wall

Per aumentare le prestazioni dei processori, è possibile seguire due approcci: 

1. Aumentare la frequenza del clock. 

2. Incrementare i componenti hardware a supporto del processore.

Per quanto riguarda la strategia $1$, c’è una limitazione: la dissipazione massima che un processore può tollerare senza che si bruci è 130 W. Ma la dissipazione è pari a $V \cdot V \cdot F$, dove V è il voltaggio ed F è la frequenza del clock. V non può essere al di sotto di una certa soglia minima, altrimenti i componenti hardware non funzionerebbero proprio. Di conseguenza, esiste un upper-bound per F che è stato già raggiunto. Questa limitazione è detta **power** **wall**. A causa del power wall, ad oggi siamo obbligati a seguire la strategia $2$ per rendere più efficienti i processori. In particolare, nel tempo, sono state adottate le soluzioni architetturali descritte di seguito.

### Symmetric Multiprocessors

Si hanno semplicemente molteplici processori, ciascuno dei quali, per accedere alla memoria, impiega la stessa quantità di tempo. Abbiamo per ogni core un thread.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-14-15-05-26-28.png)

### Chip Multi Processor (CMP) o Multicore

All’interno di ciascun processore si hanno più motori (più core). Un hypethread per core.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-14-15-06-27-29.png)

### Symmetric Multi Threading (SMT) o  Hyperthreading

All’interno di ciascun core possono esserci **più** **hyperthread** **distinti**. Dal punto di vista del sistema operativo, è esattamente come se ci fosse un numero di processori pari al numero totale di hyperthread. Il problema qui è che la memoria rappresenta un collo di bottiglia importante, anche perché viene acceduta in modo concorrente da tutti gli hyperthread. Dobbiamo vederla come architettura distribuita. La memoria è esposta in ISA (ma non le componenti cache $L_1,L_2$...).

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-14-15-07-19-30.png)

Successivamente si è passati all’**UMA**: memoria unica ad accesso uniforme, cioè stesse componenti hardware accedute in parallelo. Poi **NUMA**.

### Non Uniform Memory Access (NUMA):

Qui la memoria è divisa in banchi, ciascuno dei quali è direttamente collegato a uno specifico core (o a un insieme di core). Se un thread che gira in CPU-core *i*  accede al banco di memoria a esso vicino, l’interazione con la memoria risulta molto efficiente, mentre se deve accedere a un altro banco di memoria, impiegherà più tempo. Tale soluzione risulta vantaggiosa nel momento in cui si riesce a fare in modo che ciascun CPU-core acceda prevalentemente al *proprio* banco di memoria (ovvero effettui prevalentemente degli accessi locali). 
Ciascuna **coppia** (CPU-core *i*, *banco di memoria $i$*) o (insieme $i$ di CPU-core, banco di memoria $i$) costituisce un **nodo NUMA**. I thread possono leggere da indirizzi diversi (quello che abbiamo detto prima), tuttavia l’interconnect è time shared, si genera traffico, che deve essere ben gestito.   
**Osservazione**:

- Un accesso locale (CPU verso memoria adiacente) richiede un tempo pari a *50(hit)+200(miss)* cicli, quindi è anche facile capire, osservando il tempo, se si ha hit o miss.  

- Se l’accesso è NON locale e SENZA TRAFFICO, si passa a *200(hit)+300(miss)*. Tempi totalmente diversi, che possono creare **problemi di coerenza nella cache.** 

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-59-02-image.png)

**NB**: ISA definisce come il processore interpreta e esegue le istruzioni, ma non specifica i dettagli sulla gerarchia di memoria o la presenza delle cache.

## Cache Coherency

Com’è possibile osservare, nelle architetture di memoria elencate precedentemente la cache è **replicata**: da qui sorge il problema della **cache** **coherency**, secondo cui bisogna stabilire qual è il v*alore corretto da restituire a un thread che effettua una determinata lettura in memoria*. Disponiamo infatti di un processore e di una zona di memorizzazione (cache e RAM). Osservare solo l’interfaccia memoria-processore ci fornisce una visione limitata. Se una istruzione scrive una `mov`, questa passa prima per lo *store buffer*, non viene subito esposto nell’ISA. Se un altro programma dovesse leggere, non è detto che il valore sia già stato scritto. La coerenza viene **definita** in tre punti fondamentali:

- **Causal** **consistency**: se un processore $p_1$ scrive un valore $v$ nella locazione di memoria $X$ e poi effettua una lettura da $X$, dovrà leggere il valore $v$, a meno che non ci siano altri processori che nel frattempo hanno finalizzato delle scritture concorrenti su $X$ (coerenza di tipo RAW – Read After Write). 

- **Avoidance** **of** **staleness**: se un processore $p_1$ scrive un valore $v$ nella locazione di memoria $X$ (memoria qui intesa come RAM, visibile su ISA) e *dopo una quantità sufficiente di tempo* un altro processore $p_2$ effettua una lettura da $X$, $p_2$ dovrà leggere il valore $v$, a meno che non ci siano altri processori che nel frattempo hanno finalizzato delle scritture concorrenti su $X$. 

- **Avoidance** **of** **inversion** **of memory updates**: le varie scritture su uno stesso dato $X$ devono essere viste da tutti i processori nello stesso ordine. Se ho una sequenza di scrittura dalla cache verso la RAM, l’ordine di scrittura in cache deve essere riproposto anche nella RAM. Queste proprietà valgono sulla singola locazione.

Le due principali tecniche utilizzate per mantenere la consistenza, ricordando che la copia master è in memoria, e le copie in cache, sono:

- **Write through cache:** Prima aggiorniamo in cache e poi in memoria. Questo porta al seguente problema: una CPU potrebbe leggere due volte lo stesso dato dalla cache, e tra le due letture un’altra CPU può aver toccato il dato e aggiornato in memoria. Quindi per la CPU in esame, abbiamo una incoerenza tra quello che c’è in cache e quello che c’è in memoria.

- **Write back cache:** Aggiornare la cache e procedere alla memorizzazione in un secondo momento che decidiamo noi. Il problema è che lasciar decidere a noi potrebbe portare a scritture in memoria non nello stesso ordine di come sono state effettivamente eseguite.

## Protocolli CC Cache Coherency

Permettono di conseguire la cache coherency e sono il risultato delle scelte di: 

- Un insieme di transazioni (e.g. aggiornamento di una replica della cache) supportate dal cache system distribuito. 

- Un insieme di stati per i cache block (= unità minime della memoria che possono essere portate all’interno della cache). 

- Un insieme di eventi che capitano all’interno del cache system distribuito. 

- Un insieme di transizioni di stato.

Il design dei protocolli CC dipende da svariati fattori come: 

- La topologia dei componenti (e.g. single bus, gerarchica, ring-based). 

- Le primitive di comunicazione (i.e. unicast, multicast, broadcast). 

- Le cache policy (e.g. write-back, write-through). 

- Le feature della gerarchia di memoria (e.g. numero di livelli della cache, inclusiveness).

Implementazioni di cache coherency differenti possono presentare prestazioni diverse in termini di:

- **Latenza**: tempo per completare una singola transazione. 

- **Throughput**: numero di transazioni completate per unità di tempo; aumenta se si fa in modo che scritture su aree di memoria diverse (e sufficientemente distanti) da parte di thread differenti avvengano in modo concorrente. 

- **Overhead spaziale:** numero di bit richiesti per mantenere lo stato di un cache block.

Esistono due famiglie principali di protocolli CC: 

- **Invalidate** **protocols**: quando un CPU-core scrive su una copia di un blocco, qualsiasi altra copia del medesimo blocco (i.e. della medesima informazione) viene *invalidata*: soltanto chi ha scritto l’ultima informazione ha la versione aggiornata del blocco. In tal caso, si utilizza poca banda ma si ha una latenza elevata per gli accessi in lettura: infatti, un CPU-core che si trova vicino a una replica invalidata, per andare a leggere il dato, ha la necessità di sfruttare l’unica replica valida, che è lontana. Sostanzialmente se aggiorno una linea di cache, spariscono tutte le altre repliche. Leggeranno tutti da me, perchè ho l’unica copia valida. 

- **Update** **protocols**: quando un CPU-core scrive su una copia di un blocco, la nuova informazione viene propagata su tutte le altre copie del medesimo blocco. In tal caso, si ha una bassa latenza per gli accessi in lettura ma utilizza molta più banda.

Per poter invalidare / modificare una replica di un blocco che è stato aggiornato, si ricorre al cosiddetto **Snooping** **cache**: le componenti della cache e della memoria sono agganciati a un **broadcast medium** (= interconnection network, è un canale di comunicazione broadcast) tramite un controller, che ha la responsabilità di osservare le transizioni di stato degli altri componenti e di far reagire il componente locale di conseguenza (appunto invalidando o modificando la replica locale del blocco aggiornato). Naturalmente, il controller utilizza il broadcast medium anche per trasmettere gli aggiornamenti che avvengono in un blocco di cache locale. Mediante il broadcast medium siamo in grado di serializzare le transizioni di stato. *Inoltre, una transizione di stato non può occorrere* *finché il broadcast medium non viene acquisito in uso dal controller.*



![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-59-27-image.png)

Nel mondo reale viene adottato lo *Snooping cache* accoppiato con un protocollo basato sull’invalidazione. Vediamo dunque nel dettaglio alcuni di questi protocolli basati sull’invalidazione. Ad esempio, una componente di cache $L_1$ ha una replica *r*, vuole eseguire operazione su tale replica mediante il richiamo di broadcast medium, in cui annuncio alle altre componenti che, chi ha una copia della replica *r*, deve  aggiornare. Nel mentre, nessuno può eseguire altri aggiornamenti se ho io il broadcast medium. Ciò crea un problema di scalabilità, se lavoro con tanti dati e repliche.

**Osservazione**: devo per forza aggiornare le repliche? E se non mi servissero? Ad esempio, un thread su $CPU_0$ con cache $L_1$ vi esegue un aggiornamento su linea di memoria e comunica in maniera distribuita di cancellare quella linea di cache. Ma se quella linea di cache fosse già invalida per altri?  
Si mantiene traccia di queste operazioni mediante:

### Protocollo MSI (Modified-Shared-Invalid)

È un protocollo in cui qualsiasi transazione di scrittura su una **copia di un cache** **block** invalida tutte le altre copie del cache block. Quando dobbiamo servire delle transazioni di **lettura**: 

- Se la policy della cache è **write-through**, recuperiamo semplicemente l’ultima copia aggiornata dalla *memoria*.

- Se la policy della cache è **write-back**, recuperiamo l’ultima copia aggiornata o dalla memoria o da un altro componente di *caching*.

In questo protocollo è necessario tenere traccia dello stato della copia di un blocco: 

- Si trova nello stato *modified* se è appena stata sovrascritta. 

- Si trova nello stato *shared* se esistono dei CPU-core che stanno leggendo altre copie del medesimo blocco (per cui esistono più copie *valide* di tale blocco).

- Si trova nello stato *invalid* se un’altra copia del medesimo blocco è appena stata sovrascritta.

Il **problema** di MSI risiede nel fatto che richiede l’invio di un messaggio di invalidazione in broadcast (tramite il broadcast medium) ogni volta che una copia di un blocco viene modificata (e questo anche in caso di scritture successive sulla medesima copia). Questo può portare a impegnare massivamente il broadcast medium anche quando non ce n’è bisogno, perché magari tutte le altre copie erano nello stato invalid già da prima. Per ovviare a tale inconveniente, si ricorre ai protocolli descritti successivamente.

### Protocollo MESI (Modified-Exclusive-Shared-Invalid):

Rispetto a MSI, prevede uno stato in più, che è **exclusive**. 
In pratica, un CPU-core *i* che vuole apportare delle modifiche alla propria copia di un blocco deve richiedere l’**ownership** (*l’esclusività*) di quel blocco; questa è l’unica occasione in cui CPU-core *i* utilizza il broadcast medium per comunicare agli altri nodi che devono *invalidare* la propria copia del blocco. Una volta che la copia è nello stato *exclusive*, CPU-core *i* può modificarla tutte le volte che vuole *senza dover comunicare più nulla* a nessuno, finché un altro CPU-core non richiede di effettuare una lettura da un’altra copia dello stesso cache block (momento in cui la copia passa allo stato *shared*). L’automa raffigurato di seguito descrive in modo completo il funzionamento del protocollo MESI. Schematizzando:

- **Modified**: Ho modificato un dato shared.

- **Exclusive**: Sono il solo proprietario del dato, posso modificarlo liberamente, senza bus message (passando a Modified).

- **Shared**:  Ho una copia del dato che un altro processo possiede.

- **Invalid**: La mia copia del dato non è aggiornata.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-15-14-36-45-34.png)

Ogni volta che si esce dallo stato modified, si effettua il *write back* in memoria delle nuove informazioni che sono state scritte. Se volessi solamente leggere? Chi ha l’informazione si trova in *exclusive* e poi passa a *shared*. Potrei introdurre un quinto stato per evitare queste due transizioni. La linea exclusive è a mio uso esclusivo. Solo lo stato Invalid crea interazioni distribuite. Lo stato Modified è importante per cache write back, ma non devo informare tutti.

### Protocollo MOESI (Modified-Owned-Exclusive-Shared-Invalid):

Rispetto a MESI, prevede un ulteriore stato in più, che è **owned**. In particolare, una copia di un cache block passa dallo stato modified allo stato *owned* (anziché shared) nel momento in cui stava per essere sovrascritta ma un’altra copia dello stesso blocco viene letta. *Owned* significa che la copia è tuttora in fase di aggiornamento ma, nel frattempo, altre copie dello stesso blocco vengono lette: se devono occorrere nuovi aggiornamenti quando si è nello stato *owned*, non ci si deve preoccupare di chiedere nuovamente l’esclusività del blocco, bensì si passa direttamente allo stato modified, invalidando tutte le altre copie. Di seguito è rappresentato l’automa completo del protocollo MOESI.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-15-15-36-55-35.png)

Nello stato **Owned** io ho l’uso esclusivo di un dato. Se mi chiedono di condividerlo, gli altri **non** possono scriverci. Tale stato ci permette di transitare tra più stati, in quanto non devo riacquisire l’esclusività.

### Protocolli directory based:

In realtà, i protocolli basati su snooping cache non scalano poiché le transazioni portano a una comunicazione broadcast. Per questo motivo sono stati introdotti i protocolli directory based, in cui i vari aggiornamenti possono essere point-to-point tra i vari CPU-core / processori. In particolare, supponiamo di avere un sistema con N processori $P_0$, $P_1$,…, $P_{N-1}$. Per ciascun blocco di memoria si mantiene una directory entry, composta da: 

- N bit di presenza (l’i-esimo bit è impostato a 1 se il blocco si trova nella cache di $P_i$). 

- 1 dirty bit, che indica se il blocco è stato **modificato** senza che gli aggiornamenti siano stati riportati in memoria.

Se dirty bit = 0 e ho più possessori, linea cache condivisa.   
Dirty bit = 1 se qualcuno lo scrive, però per passare a condiviso deve ritornare a 0. E’ una machera che mi dice chi può fare cosa.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-59-50-image.png)

- **Caso 1**: $P_0$ vuole *leggere* il blocco X, ha un cache miss e il dirty bit è pari a 0. X viene letto dalla memoria, il bit `presence[0]` viene settato a 1 e i dati vengono consegnati al lettore.

- **Caso 2**: $P_0$ vuole *leggere* il blocco X, ha un cache miss e il dirty bit è pari a 1. X viene richiamato dal processore $P_j$ tale che `presence[j]=1`. Dopodiché il dirty bit viene settato a 0, il blocco viene condiviso e il bit `presence[0]` viene settato a 1. Infine, i dati vengono consegnati al lettore e propagati in memoria.

- **Caso** **3**: $P_0$ vuole *scrivere* sul blocco X, ha un cache miss e il dirty bit è pari a 0. $P_0$ invia un messaggio di invalidazione non a tutti gli altri processori, bensì solo a quelli col bit `presence[j]` pari a 1. Dopodiché tali `presence[j]` vengono settati a 0, e `presence[0]` e il dirty bit vengono impostati a 1.

- **Caso** **4**: $P_0$ vuole *scrivere* sul blocco X, ha un cache miss e il dirty bit è pari a 1. X viene richiamato dal processore $P_j$ tale che `presence[j]=1`. Dopodiché `presence[j]` viene settato a 0 e `presence[0]` viene impostato a 1.

## Implementazioni x86

**Intel:** 

- Principalmente **MESI**. 

- **Cache inclusive** (tutte le informazioni che si trovano in un particolare livello della memoria sono riportate anche in tutti i livelli *inferiori* della memoria).

- **Write back** (gli aggiornamenti effettuati su un blocco di cache B verranno riportati in memoria solo quando B dovrà essere rimosso dalla cache - “evicted”). 

- Cache L1 composta da **linee** (blocchi) **di 64 byte**.

**AMD:** 

- Principalmente **MOESI**. 

- **Cache non inclusive** (o esclusive), in particolare al livello L3 (non è detto che la cache L3 contenga tutti i blocchi presenti in cache L1 e in cache L2, magari dato sale in L1 ma non è detto che sia in L3); qui la cache L3 è utile per ospitare i blocchi che devono essere rimossi dai livelli superiori della cache. Sicuramente avere cache non inclusive rende il sistema meno vulnerabile ad attacchi di tipo side-channel che si basano sull’utilizzo della cache. 

- **Write back**. 

- Cache L1 composta da **linee** (blocchi) **di 64 byte**.

## False cache sharing

Supponiamo di avere un thread A che deve eseguire delle operazioni di scrittura su un dato $X$, e supponiamo di avere un thread B che deve eseguire delle operazioni di scrittura su un dato $Y$, dove $X$ e $Y$ sono *independenti* tra loro. Idealmente, i due thread devono poter effettuare le loro scritture in modo concorrente. Se però $X$ e $Y$ si trovano sulla **stessa linea di cache**, abbiamo che A, per scrivere su $X$, deve richiedere in uso esclusivo tutti i 64 byte che costituiscono il blocco e, quindi, anche $Y$; d’altra parte, B, per scrivere su $Y$, deve richiedere in uso esclusivo l’intero blocco e, quindi, anche $X$. Questo scenario, noto come **false cache sharing**, porta all’inondazione di transazioni distribuite dovuta a un ping-pong tra A e B di *Request For Ownership* per la medesima linea di cache: da qui consegue un crollo delle performance. Tale effetto deleterio lo avremmo avuto anche nel caso in cui A avesse dovuto eseguire delle operazioni di scrittura su $X$ mentre B debba eseguire delle operazioni di lettura su $Y$.

Comunque sia, dobbiamo essere attenti anche allo scenario duale: se il thread A deve eseguire delle operazioni correlate tra loro sia sul dato $X$ che sul dato $Y$, stavolta è opportuno avere $X$ e $Y$ sulla stessa linea di cache: in tal modo, diminuiamo la probabilità di ritrovarci dei dati scorrelati all’interno del blocco in cui si trovano $X$ e $Y$.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-00-15-image.png)

Se `ALIGNMENT = 64`, sto allineando esattamente a una linea di cache. Parto sicuramente da li, poi in base alla size potrei eccedere.

## Attacco Flush + Reload

È l’antenato degli attacchi Meltdown e Spectre visti precedentemente ed è stato documentato per la prima volta nel 2013. In quest’attacco si hanno due thread:  A (la vittima) e B (l’attaccante); che hanno la possibilità di accedere alle medesime informazioni in memoria. B può eseguire il **flush** della cache per poi eseguire degli accessi cronometrati in memoria (**reload**): se per leggere un dato impiega poco tempo, vuol dire che, nel frattempo, quello stesso dato è stato **ricaricato** in cache da parte di A (e quindi viene usato da A). Questo meccanismo può essere applicato anche sulle istruzioni macchina: anch’esse, quando vengono accedute per essere eseguite, vengono caricate in cache. Ciò vuol dire che B può essere in grado di capire anche quali sono le attività che A sta svolgendo. **Nell’ISA, l’unica operazione esposta per la cache è il FLUSH. Non posso fare altro!**

L’implementazione di Flush+Reload su x86 è basata su due building block: 

- Un timer ad alta risoluzione. (**RDTSC**, *32* *bit edx, 32 bit eax* (tot 64)per ogni processore).  

- Un’istruzione non privilegiata che effettui il flush della cache. (quindi togliere contenuto cache con cflush, dando l’indirizzo della memoria).

 Le immagini riportate di seguito mostrano i dettagli di queste due istruzioni.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-19-16-36-17-39.png)

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-19-16-36-49-40.png)

- L’istruzione `clflush` accetta come unico parametro una locazione di memoria, che identifica il blocco di memoria da rimuovere dalla cache. 

- È bene utilizzare `clflush` subito dopo l’invocazione all’istruzione `mfence` (che approfondiremo più avanti): per ora basti pensare che `mfence` fa da **barriera** tra tutte le istruzioni che la precedono e tutte le istruzioni che la seguono. In tal modo, siamo sicuri che `clflush` mandi in write back e *rimuova davvero le informazioni che erano state portate in cache*. **Infatti, anche se committo l’istruzione, il dato non va in cache, ma nello store buffer. “Forzo” con** ***mfence*** **ASM, che porta il dato dallo store buffer in cache**. In caso contrario, anche se siamo sicuri che `clfush` venga committata dopo l’istruzione i di accesso alla memoria, `clflush` potrebbe intervenire prima che la memoria cambi realmente stato per effetto dell’istruzione $i$. (Quindi svuotiamo una cache già vuota, perchè dentro non è stato ancora messo nulla!)  
  Questo è un problema di **memory** **consistency**, che analizzeremo successivamente.

## ASM inline

È un modo per utilizzare la tecnologia assembly all’interno di un programma scritto in C. È molto utile se si vogliono incapsulare alcune istruzioni machine-dependent all’interno del programma. La sintassi è la seguente:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-00-35-image.png)

- **AssemblerTemplate** = blocco di istruzioni assembly che si vuole inserire all’interno del flusso di esecuzione di una funzione C. Scritto in ISA, lavoro con memoria e registri, quindi niente comandi C, come *int c*.

- **OutputOperands** = blocco dell’ASM inline in cui è possibile specificare in quali variabili devono essere caricati i valori di determinati registri <u>dopo</u> l’esecuzione dell’AssemblerTemplate (post-movimento dati).

- **InputOperands** = blocco dell’ASM inline in cui è possibile specificare in quali registri devono essere caricati i valori di determinate variabili <u>prima</u> dell’esecuzione dell’AssemblerTemplate (pre-movimento dati). Entrambi servono per collegare il codice C all’assembly. 

- **Clobbers** = registri di CPU che si vogliono memorizzare sullo stack prima dell’esecuzione dell’AssemblerTemplate e che si vogliono **ripristinare** dopo l’esecuzione dell’AssemblerTemplate. Mi basta specificare quali, senza preoccuparmi di altro. 

- **GotoLabels** = istruzioni di jump presenti all’interno dell’AssemblerTemplate e che hanno come destinazione altri punti del programma (fuori dall’AssemblerTemplate). Questo blocco dell’ASM va specificato sempre assieme al prefisso `goto` (che viene posto subito prima delle parentesi tonde). Sarebbero i costrutti del tipo `fun_x: ...` Che troviamo in assembly.

- **Volatile** = prefisso opzionale che indica che il compilatore non dovrà attuare alcuna *ottimizzazione* sul codice assembly specificato nell’AssemblerTemplate (quindi non deve esserci il re-ordering delle istruzioni e così via).

### Direttive di compilazione C per gli operandi

Il simbolo `=` all’interno dell’ASM inline significa che l’operando deve essere utilizzato come output. Se invece un operando non è associato al simbolo `=`, allora verrà utilizzato come input.

### Possibili operandi per l’ASM

- **r**  = registro generico che verrà scelto dal compilatore. Ha un indice associato, quindi è “recuperabile”. 
- **m** = locazione di memoria generica che verrà scelta dal compilatore. 
- **i/I** = operando a 64/32 bit immediato. 
- **a** = eax (o una sua variante come rax, ax, al dipendentemente dalla dimensione degli operandi).  
- **b** = ebx (o una sua variante come rbx, bx, bl dipendentemente dalla dimensione degli operandi). 
- **c** = ecx (o una sua variante come rcx, cx, cl dipendentemente dalla dimensione degli operandi). 
- **d** = edx (o una sua variante come rdx, dx, dl dipendentemente dalla dimensione degli operandi). 
- **S** = esi. 
- **D** = edi.
- **0-9** = indici degli operandi (e.g. se a è il primo operando a essere utilizzato all’interno dell’ASM inline, può essere identificato con l’indice 0). 
- **q** = registro che può essere utilizzato per indirizzare un singolo byte (e.g. `eax` che incapsula `al`).

### Esempio di utilizzo di ASM inline

Vediamo un esempio di funzione che può essere invocata all’interno di un loop e ha lo scopo di misurare il tempo impiegato per effettuare un accesso in memoria in caso di cache miss.

```c
unsigned long probe (char* adrs) {
 volatile unsigned long cycles;
 asm ( “mfence \n” //barriera per qualunque accesso in memoria
       “lfence \n” //barriera per gli accessi in memoria di tipo load 
       “rdtsc \n” //preleva il timer da un registro specifico e 
                   //carica i 32 bit meno significativi in eax e 
                   //i 32 bit più significativi in edx 
       “lfence \n” “movl %%eax, %%esi \n” //carica i 32 bit meno 
                                          //significativi del timer in esi 
       “movl (%1), %%eax \n”  //effettua l’accesso in memoria 
                              //(in particolare alla variabile adrs,
                              // salvata in %1=ecx) 
       “lfence \n” 
       “rdstc \n”  //preleva il nuovo timer  
       “subl %%esi, %%eax \n” //sottrae i 32 bit meno significativi 
                              //dei due timer, che corrisponde al 
                              //tempo impiegato per l’accesso in memoria 
       “clflush 0 (%1) \n” //effettua il flush di adrs dalla cache 
       : “=a” (cycles)  //dopo l’esecuzione dell’ASM inline, il contenuto 
                        //di eax (registro 0) andrà nella variabile cycles 
       : “c” (adrs)  //prima dell’esecuzione dell’ASM inline, il contenuto 
                     //di adrs va nel registro ecx (registro 1) 
       : “%esi”, “%edx” ); //esi, edx sono i clobbers    
      return cycles;
}
```

Eliminando la sola istruzione `clflush`, è possibile misurare il tempo impiegato per effettuare gli accessi in memoria in caso di cache hit.

$NB_1:$ gli attacchi Meltdown e Spectre utilizzano proprio questo costrutto qui.

$NB_2$: esistono delle API di C che implementano l’invocazione di rdtsc e clflush, e sono rispettivamente `__rdtscp()` e `_mm_clflush()`.

$NB_3:$ i registri `eax`, `ecx` non sono stati inseriti tra i clobbers perché sono **caller** **save**: sono registri che, a ogni chiamata di funzione, vengono salvati dalla funzione chiamante, cosicché la funzione chiamata possa utilizzarli a piacimento.

#### Altri dettagli su Flush + Reload

È possibile rendere l’istruzione `rdtsc` *privilegiata*, ovvero si può fare in modo che venga invocata esclusivamente a livello kernel. Tuttavia, l’attacco **Flush+Reload**, per andare a buon fine, non ha la stretta necessità di sfruttare `rdtsc` per tenere traccia del trascorrere del tempo: esiste un modo altresì efficace per emulare un timer a grana sufficientemente fine. In pratica è sufficiente creare un nuovo thread che dovrà eseguire la seguente funzione: 

```c
void *time_keeper (void *dummy) {  
  while(1){
            timer = (timer+1); //timer è una variabile globale 
          }
}
```

**NB**: una variabile volatile è toccabile da più entità, non è nel registro del singolo thread. Evitiamo quindi ottimizzazioni, prendo e scrivo in memoria.

Un’altra cosa che vale la pena osservare è che questo tipo di attacco ha una probabilità di gran lunga minore di avere successo nel caso in cui si abbiano le *cache non inclusive*. Supponiamo che il thread $T_A$ della vittima giri sul CPU-core$_A$ e il thread $T_B$ dell’attaccante giri sul CPU-core$_B$. Se le cache sono *non inclusive*, qualunque blocco di memoria acceduto da parte di $T_A$ viene caricato sulla cache di livello 1 propria di CPU-core$_A$ ma magari non sulle cache di livelli inferiori. A tal punto, $T_B$ non può vedere in alcun modo sulla cache il valore utilizzato dal thread $T_A$: al livello L1 non è presente perché ciascun CPU-core ha la sua copia privata della cache di livello L1; ai livelli sottostanti, invece, *il dato non è proprio presente*. Se lavoro su una cache in uso *esclusivo*, cioè ho ad esempio due core sulla stessa cpu che condividono risorse, le tempistiche sono più veloci in quanto non mi sposto tra stati diversi.

## Memory Consistency

Con riferimento al *memory wall*, se imponessimo che tutte le istruzioni che prevedono un’interazione con la memoria effettuino l’accesso vero e proprio alla memoria immediatamente, avremmo un degrado delle prestazioni, dovuto al fatto che l’*accesso alla memoria richiede molti cicli di clock*;  
Per esempio, se abbiamo un’istruzione A che scrive un dato sulla memoria e un’istruzione B che legge il medesimo dato dalla memoria, B deve attendere che il dato sia disponibile in cache o in RAM prima di essere finalizzata, allora le ottimizzazioni effettuate sulla pipeline vanno vanificate. Di conseguenza, è necessario un meccanismo che disaccoppi le visioni di:

- Come (e in quale ordine) le istruzioni di accesso alla memoria vengono viste dal **processore che le esegue** (**program** **order**) 

- Come (e in quale ordine) le istruzioni di accesso alla memoria vengono viste dagli **altri processori** / program flow mediante l’utilizzo delle risorse condivise nell’architettura di memoria, come la cache o la RAM (**visibility** **order**).

Tale meccanismo prevede l’utilizzo degli **store buffer**, che sono delle piccole aree di **memoria** **private per una CPU-core**, che mantengono temporaneamente i dati prodotti dalle istruzioni finalizzate ma ancora non riportate in cache o in RAM. In particolare, l’ordine con cui saranno viste le operazioni in memoria da parte degli altri program flow non corrisponde necessariamente con l’ordine in cui le istruzioni sono uscite dalla pipeline, e tale ordine dipende dal modello di consistenza della memoria utilizzato. *Non stiamo parlando di Cache coherency, perchè qui ancora non sappiamo se la scrittura in cache sia stata effettuata.*

## Consistenza sequenziale

### Definizione di Lamport, 1979

Un sistema multiprocessore è sequenzialmente consistente se il risultato di una qualunque esecuzione è lo stesso rispetto a se le operazioni di tutti i processori fossero eseguite in qualche ordine sequenziale e le operazioni di ciascun processore preso singolarmente apparissero in tale sequenza esattamente nell’ordine specificato dal suo programma.

In altre parole, per avere consistenza sequenziale, *non è possibile* *avere un’inversione delle istruzioni* *di uno specifico* *program* *order all’interno della sequenza globale delle operazioni.*

#### Esempio

Supponiamo che CPU-core$_1$ debba eseguire le operazioni $a_1$, $b_1$ (dove $a_1$ viene prima di $b_1$ nel *program order*), e supponiamo che CPU-core$_2$ debba eseguire le operazioni $a_2$, $b_2$ (dove $a_2$ viene prima di $b_2$ nel program order). Allora, una sequenza che rispetta la consistenza sequenziale è data da:  
$a_1, a_2, b_1, b_2$   
Invece, una sequenza che non rispetta la consistenza sequenziale è data da:   $b_1, a_2, b_2, a_1$.   
Infatti, tale sequenza vede $b_1$ prima di $a_1$, il che rappresenta un’inversione rispetto all’ordine di programma proprio di CPU-core$_1$.

Nel mondo reale, la stragrande maggioranza delle macchine hanno dei chipset che non sono realizzati per soddisfare la consistenza sequenziale. Ma come mai questa scelta se la consistenza sequenziale è fondamentale per la correttezza di molte applicazioni concorrenti? Per *motivi di scalabilità* dell’architettura di memoria e di *costi* legati alla sequential consistency; tra l’altro, la consistenza sequenziale impone un ordinamento fisso per tutte le operazioni, anche per quelle completamente scorrelate tra loro. Algoritmi come *Bakery* o *Dekker* non vanno bene per le architetture odierne perchè *non lavorano in questo modo*. Come si comportano quindi i computer moderni?

### Total Store Order TSO

È il modello di consistenza preferito nelle architetture reali, come x86 e SPARC. È basato sull’idea per cui *effettuare lo store dei dati non è equivalente* *al riportare effettivamente* *tali dati* *n**ell’architettura di memoria**.* Quest’ultima operazione viene tipicamente **ritardata** rispetto al commit dell’istruzione di store; ad esempio, si potrebbe dover attendere che la linea di cache su cui si dovrà scrivere il nuovo valore passi allo stato exclusive.

È proprio questo il modello di consistenza che prevede lo **store buffer**. In particolare, nel momento in cui un’istruzione di `store` viene committata, il contenuto da scrivere poi in memoria viene nel frattempo inserito all’interno dello *store buffer*, che risulta essere un componente intermedio tra il CPU-core e l’architettura di memoria (cache + RAM). Ricordiamo che, dopo aver committato un’istruzione, questa *non passa subito da Store Buffer a Cache*, bensì passa un certo tempo. Solo dopo che va in cache, il risultato di tale istruzione risulta *visibile*.  

*Non sarebbe meglio andare direttamente in cache, in modo che i dati prodotti siano subito disponibili?*  

Il problema di questa idea risiede nell’automa **Mesi**. Come sappiamo, la linea di cache su cui scriviamo deve essere esclusiva, e questo richiede step intermedi come l’uso del *broadcat medium*, la richiesta di esclusività etc... Solo quando ho effettivamente queste condizioni passo a copiare in cache.  
Capiamo subito che operare sulla cache è un’operazione abbastanza delicata. Lo Store Buffer, invece, è a uso dedicato del flusso in corso, non ho conflitti con altri thread. L’unica limitazione è che altri non vedono ciò che produco. Come vedremo dopo, gli Store Buffer, in x86 hanno una gestione FIFO, e possiamo usare alcune funzioni per forzare la scrittura in memoria.

Il TSO è un modello di consistenza che offre anche dei grossi vantaggi:

- Se nel program order di un CPU-core si hanno due istruzioni A, B, di cui A effettua una store di un dato $X$ e B va a rileggere quel dato $X$, allora B ha la possibilità di recuperare il dato aggiornato andando semplicemente a leggere nello store buffer. In tal modo si risparmiano diversi cicli di clock per finalizzare le istruzioni perché chiaramente un **accesso allo store buffer è molto più veloce di un accesso alla cache.** 

- È possibile effettuare il packaging delle informazioni da riportare nell’architettura di memoria. Se si hanno molteplici operazioni di scrittura che insistono sul medesimo blocco di memoria, si hanno altrettanti accessi allo store buffer ma poi lo store buffer dovrà *interagire con l’architettura di cache solo una volta*. Questo chiaramente riduce i costi di accesso alla memoria.

Tuttavia, il TSO non offre consistenza sequenziale perché, se abbiamo due istruzioni A, B in cui A viene prima di B nel program order, è possibile riportare nell’architettura di memoria prima gli effetti di B e poi gli effetti di A. In particolare, la presenza dello store buffer causa il **load-store bypass**, che è un fenomeno che si verifica quando si hanno due istruzioni A, B di cui A è una `store` di un dato $X$ eseguita da un certo thread $T_A$, mentre B è una `load` del medesimo dato $X$ eseguita da un altro thread $T_B$ in un’istante successivo rispetto ad A. Di fatto, in tal caso, quando l’istruzione A viene finalizzata, il dato da essa prodotto potrebbe trovarsi soltanto nello store buffer. Di conseguenza, se il thread $T_B$ gira su un CPU-core *diverso* rispetto a $T_A$, nel momento in cui deve andare ad accedere al dato $X$, *può farlo solo mediante la cache / RAM, per cui esegue la `load` di una versione* *vecchia di $X$.*

**L’effetto finale è che l’istruzione B viene resa visibile prima dell’istruzione A.**

Un’altra considerazione da fare è che *non necessariamente lo store buffer segua la disciplina FIFO*. (in *x86* si, in altre architetture no). Nel caso in cui non lo si segue, si ha lo **store-store bypass**, secondo cui due istruzioni di `store` successive possono essere invertite nel visibility order.

### Memory Fencing

Il programmatore ovviamente deve avere la possibilità di prevenire i fenomeni di `load-store` bypass e `store-store` bypass per rendere corretto il software che sta sviluppando. Corrono così in aiuto tre categorie di istruzioni di **memory** **fencing** (= sincronizzazione delle attività che vengono eseguite sulla memoria), che sono:

- **SFENCE** (Store Fence): serializza le operazioni di *store* verso la memoria; tutte le store *precedenti* a lei vengono riversate in memoria prima dell’esecuzione di qualunque altra istruzione di store successiva a lei. 

- **LFENCE** (Load Fence): serializza le operazioni di *load* dalla memoria; tutte le load precedenti a lei vengono completate prima dell’esecuzione di qualunque altra istruzione di load successiva a lei. 

- **MFENCE** (Memory Fence): serializza tutte le operazioni in memoria; è un tipo di istruzione che unisce le capability di *sfence* e di *lfence*.

NON devo abusare di queste istruzioni, ma usarle con criterio per contesti delicati, altrimenti è come se stessi flushando la pipeline in ogni operazione.

Queste istruzioni sono garantite essere ordinate rispetto a qualsiasi altra istruzione serializzante (serializing instruction), come `cpuid` (che, se ricordiamo, effettua, tra le varie cose, lo squash della pipeline).

Inoltre, esistono delle istruzioni che, se precedute dal prefisso **lock**, diventano istruzioni serializzanti. Con *lock* si ha un approccio del tipo *blocco, lavoro, rilascio.* Quando lavoro è linearizzabile, grazie al lock vedo l’effetto delle altre attività.   
Queste sono: `add`, `adc`, `and`, `btc`, `btr`, `bts`, **cmpxchg**, `dec`, `inc`, `neg`, `not`, `or`, `sbb`, `sub`, `xor`, `xand`.

#### Esempio cmpxchg

Significa *compare then exchange*, ha due operandi ($o_1$, $o_2$, dove $o_1$ può essere una locazione di memoria) e compara il contenuto di $o_1$ col registro `rax`/ `eax` / `ax` / `al`.   

- Se i due valori sono **uguali**, allora il contenuto di $o_2$ viene riversato in $o_1$; 

- Altrimenti, il contenuto di $o_2$ viene copiato in `rax` / `eax` / `ax` / `al`.

Si tratta di un’istruzione che può effettuare un primo accesso in memoria, una comparazione e poi un secondo accesso in memoria, per cui **non è atomica**. Se la si vuole eseguire in modo atomico, si utilizza appunto il prefisso **lock**, quindi ho una linea di cache esclusiva per me. Eseguire `cmpxchg` in modo **atomico** vuol dire riversare gli aggiornamenti in memoria già al completamento dell’istruzione stessa, per cui *non ci si può appoggiare allo store buffer*. Di conseguenza, è richiesto che, prima della `lock cmpxchg`, il contenuto dello *store buffer* venga riportato all’interno dell’architettura di memoria. È tale caratteristica che rende l’istruzione *serializzante* (ma, a differenza di `cpuid`, non effettua lo squash della pipeline).

La `lock cmpxchg` viene utilizzata anche per implementare i *lock* (e in particolare gli *spinlock*) per gli accessi in sezione critica. Per fare un esempio, di seguito è riportata una funzione C contenente un ASM inline, che implementa un trylock mediante cmpxchg  
$NB$: trylock = se non riesco a ottenere il lock, non rimango in attesa e lascio perdere).

```c
int try_lock (void *uadr) { //uadr = indirizzo dove si trova il lock
     unsigned long r = 0; 
     asm volatile (  
          “xor %%rax, %%rax\n” //rax = 0, sto azzerando il contenuto.  
          “mov $1, %%rbx\n” //rbx = 1  
          “lock cmpxchg %%rbx, ($1)\n” //if (uadr == 0) uadr = 1
          “sete (%0)\n” //if (“cmpxchg had success”) r = 1 
          : : “r” (&r), “r” (uadr) //prima dell’esecuzione dell’ASM inline, 
                                   //due registri qualsiasi vengono popolati con &r, uadr 
          : “%rax”, “%rbx” //rax, rbx sono i clobbers
       );
     return (r) ? 1 : 0; //if (“cmpxchg had success”) return 1; else return 0 }
}
```

Le istruzioni come la `cmpxchg` che eseguono la `load` di una locazione $L$ di memoria in un registro, modificano il valore di tale registro ed eseguono la store del nuovo contenuto del registro all’interno della locazione $L$ di memoria sono le cosiddette istruzioni **Read-Modify-Write** (**RMW**).   
Ci permettono di rendere le operazioni globalmente visibili.

Anche qui esistono delle API di C che implementano l’invocazione di sfence, lfence, mfence e cmpxchg, e sono rispettivamente:

`_mm_sfence()`,`_mm_lfence()`, `_mm_mfence()` e `sync_bool_compare_and_swap()`  

In ogni caso, utilizzare le istruzioni **RMW** per implementare i lock non è una soluzione particolarmente scalabile per realizzare degli schemi di coordinazione. Infatti, con lo spinlock, si ha un thread in sezione critica e tanti thread in *busy waiting*, per cui se disgraziatamente il thread in sezione critica viene *deschedulato* (ciò avviene comunemente se giro su una VM), si ha non solo un ritardo ma anche uno spreco di risorse e di energia da parte di chi è in *busy waiting*. Con lock, la linea di cache è a mio uso esclusivo.  
Per questo motivo, si preferisce proporre degli algoritmi che prevedono un utilizzo alternativo delle istruzioni RMW e, a tal proposito, si hanno due possibilità principali che **non richiedono Lock**: 

- **Non-blocking coordination** (lock-free / wait-free synchronization). 
  Nel caso *lock-free*, posso ottenere degli abort, e quindi ritento (alg. Linearizzabile). Nel caso *wait-free*, non ho mai abort, ed è consistente.

- **Read Copy Update** (**RCU**). Include *Read intensive + aggiornamento*. 
  Tecnica che *non è bloccante solo per chi legge* la struttura dati, mentre per chi aggiorna deve serializzare. Qui stiamo totalmente cambiando approccio, è un diverso modo di fare.  

Cosa usare è influenzato dal "con cosa sto lavorando"!

## Linearizzabilità

Supponiamo di avere una struttura dati $S$ e delle funzioni che accedono a $S$; diciamo che un’esecuzione concorrente di tali funzioni è corretta se è **linearizzabile**, ovvero *se è come se le operazioni fossero eseguite in modo sequenziale* (dove quella successiva viene eseguita solo dopo il completamento della precedente). Questo è vero se: 

- Gli accessi concorrenti a $S$, nonostante possano durare diversi cicli di clock, possono essere visti come se i loro effetti si materializzassero in un unico punto del tempo.

- Tutte le operazioni che si sovrappongono nel tempo possono essere ordinate in base al loro istante di materializzazione selezionato.

#### Esempio

Supponiamo di avere tre funzioni A, B, C che accedono a una stessa struttura dati condivisa, e supponiamo di avere due thread $T_1$, $T_2$, di cui $T_1$ invoca la funzione A mentre $T_2$ invoca la funzione B e successivamente la funzione C.  
Allora vale ciò che è riportato nella figura seguente:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-19-19-08-11-42.png)

*Siamo solamente sicuri che B venga prima di C, non possiamo dire altro.*   
Tuttavia, lo studio di algoritmi concorrenti che utilizzano la materializzazione istantanea delle operazioni non è così banale. Ad esempio, in presenza di un salto condizionale, una determinata operazione può essere materializzata in istanti differenti a seconda se il salto viene preso oppure no.

**Osservazione**: Lavorare con istruzioni *atomiche* vuol dire *bloccare una linea di cache*, quindi *non ho concorrenza su un qualcosa che è solo mio*, al massimo posso averla se opero su linee diverse.   
Prendiamo l’esempio sopra:  
Siamo sicuri che il thread $T_2$, quando esegue l’operazione C, riesca a vedere tutto ciò che è stato fatto in B? (sopra è quasi stato dato per scontato!).  
In un caso di *Sequential Consistency*, sì (anche se noi non operiamo in questo contesto), altrimenti non è scontato. Ad esempio, il thread potrebbe essere stato spostato su una CPU diversa, e prima di andarci lo Store Buffer nella vecchia CPU non è stato flushato. Quindi nella nuova CPU non posso recuperare il “vecchio Store Buffer”.

## Linearizzabilità vs operazioni RMW

Le operazioni RMW (Read-Modify-Write), nonostante implementino accessi in memoria non banali, appaiono in modo atomico sull’intera architettura hardware. Di conseguenza, possono essere sfruttate per definire dei punti di linearizzazione delle operazioni, in modo tale da ordinare le operazioni in una storia linearizzabile. Inoltre, le operazioni RMW possono fallire; di conseguenza il loro esito, come per i salti condizionali, può influenzare l’esecuzione o la non-esecuzione di una particolare istruzione e l’istante in cui essa viene eventualmente materializzata.

Sappiamo che con le operazioni RMW è possibile implementare un meccanismo di locking. I lock basati su RMW incentivano ancor più la linearizzazione, poiché portano le operazioni a essere eseguite in modo sequenziale.

![43.png](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/50b82687af4964513805ec4a7d0a751fe8a041b4.png)

Ma, come dicevamo in precedenza, preferiamo delle tecniche alternative all’utilizzo dei lock per sincronizzare i thread mediante operazioni RMW. Analizziamole ora. Con *lock* si ha un approccio del tipo *blocco, lavoro, rilascio* come è già stato detto. Utile per operazioni in tempo reale su strutture condivise, ma poco scalabile. Poi, con *fence, le rendo effettivamente visibili.* Vediamo delle alternative:

### Non-blocking coordination

È un tipo di sincronizzazione **non bloccante**, che prevede due possibili approcci:

1) **Lock-freedom:** almeno un’istanza di una chiamata a funzione termina con successo in tempo finito AND tutte le istanze di chiamata a funzione terminano in tempo finito (o con successo o no). *Se fallisco, posso ricominciare da zero.*

2) **Wait-freedom** tutte le istanze di una chiamata a funzione terminano con successo in tempo finito. *Tutto quello che faccio va “sempre bene”*. Dipende però con che struttura lavoro.

### Sincronizzazione lock-free

Prevede la seguente logica: se due operazioni ordinate sono incompatibili (ovvero portano a fallire una qualche operazione RMW), allora una di loro può essere accettata ma l’altra deve essere rifiutata ed eventualmente rieseguita con una nuova try. Perciò, sono algoritmi basati sulla logica **abort** **/** **retry**: se una qualche operazione non va a buon fine, viene semplicemente abortita e in caso si effettua un nuovo tentativo. Chiaramente, per essere un approccio efficiente, deve essere caratterizzato da un basso numero di abort, in modo tale da non sprecare troppo lavoro eseguito in CPU e nell’hardware in generale. 

Un grosso vantaggio della sincronizzazione *lock-free* è che non dà problemi nel caso in cui un thread dovesse crashare. Infatti, qui il comportamento di ciascun thread è *indipendente* da quello che succede a tutti gli altri thread; nel caso in cui si utilizzi un lock, invece, il crash del thread che detiene correntemente il lock porta all’impossibilità per tutti gli altri thread di acquisire successivamente il lock. (Vedi descheduling di un thread su Macchina Virtuale).

#### Esempio

In questo schema, supponiamo di avere in memoria condivisa un certo *val*. Quando lo leggo, e poi lo voglio usare per una `compare and swap`, il confronto lo faccio tra il valore in una certa locazione e quel *val*. Se sono uguali eseguo lo swap. Se qualcuno lo ha cambiato, ho un fallimento.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-21-15-04-48-44.png)

- **Insert**: supponendo di inserire il nodo $20$ tra i nodi $10$ e $30$ all’interno della lista collegata, si procede nel seguente modo: si ispeziona la lista fino al punto di aggiunta, si imposta $30$ come successore di $20$ e poi, tramite un’operazione di `Compare And Swap` (**CAS**, che è un’istruzione atomica. Sarebbe come il `compare and exchange`: o aggiorno io, o aggiorna un altro. Vince chi lo fa prima, il secondo farebbe un confronto errato. Se fallisco, ripeto!), si imposta $20$ come successore di $10$. 
  
  Con l’approccio **lock-free**, tale operazione non dà problemi; l’unico caso in cui si ha un fallimento (e quindi un abort) è quello in cui c’è un altro inserimento concorrente nello stesso punto della lista collegata. Ad esempio, se concorrentemente a $20$, un altro thread tenta di inserire un nodo $21$ tra i nodi $10$ e $30$, solo uno dei due inserimenti avrà successo, mentre l’altro fallirà; viceversa, se si hanno inserimenti concorrenti in posizioni differenti della lista, avranno tutti successo nonostante non ci siano lock / attese. 

- **Remove**: supponiamo di voler rimuovere il nodo $10$ dalla lista collegata. Non possiamo farlo semplicemente deallocandolo ed eseguendo una `Compare And Swap` sul puntatore al successore del nodo testa (come nella figura in alto a sinistra). Infatti, può succedere che concorrentemente venga tentata l’esecuzione di un inserimento di un nodo $20$ proprio subito dopo il nodo $10$; se l’operazione di rimozione nel frattempo dealloca il nodo $10$, poi l’inserimento è impossibilitato a cambiare il puntatore al successore di $10$ perché si ritrova a lavorare su un *path* non più valido (vedere figura in alto a destra). Quello che si fa, dunque, è marcare il nodo $10$ come da eliminare, per poi deallocarlo effettivamente in un secondo momento (vedere figura in basso a sinistra). Di conseguenza, vengono utilizzati dei bit all’interno di ciascun nodo che indicano lo stato del nodo stesso; questo a discapito dei puntatori, che si ritroveranno quindi con meno bit a disposizione. Ne consegue che i puntatori non possono più essere utilizzati con la massima granularità. Dopo aver marcato il nodo come da eliminare, si può procedere con una `Compare And Swap` per correggere il puntatore del nodo precedente (come nella figura in basso a destra).

**Attenzione**

In tale contesto è molto pericoloso eliminare un determinato nodo per poi riutilizzarlo per inserirvi delle informazioni differenti.   
*In breve*: se un thread stava lavorando sul nodo $10$, viene deallocato, e nel mentre il nodo $10$ viene eliminato per far posto ad altro, quel thread, quando ritorna, avrebbe un indirizzo a qualcosa che non fa più parte della lista, come ad esempio ar ee sensibili! 
Il thread esegue **traversing**, si muove solo sulla lista, non conosce altro!.  
*In lungo*: Supponiamo che un thread A debba effettuare una lettura sul nodo $n$, e supponiamo che venga deschedulato subito dopo aver recuperato l’indirizzo di memoria di quel nodo ma prima di leggere il valore contenuto; supponiamo anche che un thread B deallochi proprio il nodo $n$ e riutilizzi l’indirizzo di memoria di $n$ per scrivere una nuova informazione da inserire nella lista collegata (o in una qualsiasi struttura dati). Allora, il thread A, quando verrà rischedulato, leggerà la nuova informazione anche se non era previsto dal flusso di esecuzione. Questo può anche rappresentare un problema di sicurezza nel momento in cui nei nodi sono riportati dei dati sensibili oppure, ad esempio, dei dati relativi agli utenti che stanno effettuando l’accesso a un determinato sistema.

### Sincronizzazione wait-free

Qui non abbiamo né una logica di abort né una logica di retry: tutti i thread svolgono sempre lavoro utile, indipendentemente da quello che stanno facendo altri thread in concorrenza. Chiaramente si tratta di un approccio molto più “challenging” del precedente.  Come risolviamo il problema del non poter riusare quegli spazi di memoria nella linked list?

Un esempio di struttura dati wait-free è il **registro atomico (1,N) wait-free**, che prevede un *solo scrittore* e $N$ lettori ed è un caso particolare del registro atomico (M,N) wait-free. È un registro arbitrariamente grande in cui le operazioni di scrittura e lettura devono essere effettuate in modo atomico e potrebbero richiedere un alto numero di cicli di clock per essere eseguite. In una situazione del genere non ci piace l’utilizzo dei lock, perché farebbe crollare vertiginosamente le prestazioni; piuttosto, si procede nel seguente modo: 

- Si hanno molteplici istanze del registro atomico e un puntatore che referenzia l’istanza più aggiornata.

- Lo scrittore, quando deve aggiornare il registro, ne alloca una nuova istanza; nel momento in cui ha terminato la scrittura, aggiorna con una `Compare And Swap` il puntatore per farlo referenziare verso la nuova istanza. 

- I lettori sfruttano il puntatore per accedere all’area di memoria dov’è allocata l’istanza correntemente *più aggiornata* del registro atomico. Una volta che la lettura è iniziata, il lettore è sicuro che non ci saranno mai interferenze con l’istanza da parte di scrittori (per cui l’operazione andrà certamente a buon fine).

Questa soluzione presenta però una difficoltà in particolare: non è banale stabilire quando è possibile effettuare la garbage collection delle varie istanze del registro atomico. Comunque sia, la letteratura stabilisce che servono almeno $N+2$ buffer (istanze) per far funzionare correttamente il meccanismo:

- $N$ buffer sono (al limite) per gli $N$ lettori. 

- $1$ buffer è adibito per contenere l’ultimo eventuale valore che non è stato ancora acceduto da alcun lettore.

- L’ultimo buffer serve allo scrittore per inserire un eventuale nuovo valore. 

Quindi sostanzialmente, ad ogni modifica creo un nuovo buffer, dico che quello è il più aggiornato, e chi lavora col vecchio lo usa finchè non ha terminato. Un limite da gestire è che non posso mantenere infiniti buffer, però qualcuno potrebbe puntarci ancora!

Scendendo in qualche ulteriore dettaglio dell’implementazione di tale meccanismo, si ha un’unica variabile di sincronizzazione composta da due campi, $32$ per identifiare l’istanza e $32$ per il contatore: 

- nel primo è indicato qual è lo slot (tra gli N+2 totali) che è stato aggiornato più recentemente dallo scrittore.

- Nel secondo è riportato il numero di lettori che si sono attestati esattamente a quello slot; questo secondo campo viene aggiornato dai lettori mediante una chiamata a `fetch_and_add` **atomica**, un’istruzione che esegue la lettura, e l’incremento di una determinata variabile in modo atomico. Conto chi ha preso il riferimento sostanzialmente. Ovviamente le operazioni devono essere finite, sennò non posso contarle. Incremento solo se mi sposto tra aree di memoria, altrimenti non aumento se sto sempre sulla stessa.

- Il reader decrementa il counter se ha finito di leggere.

- Quando lo scrittore deve effettuare una scrittura, esegue una`atomic_exchange` sulla variabile di sincronizzazione, ovvero legge e mette da parte il contenuto attuale della variabile di sincronizzazione e riscrive tale variabile con: 

- L’indirizzo di memoria del nuovo buffer (nel primo campo).

- Il valore 0 per indicare che inizialmente non ci sono lettori che hanno acceduto al nuovo buffer (nel secondo campo). 

Chiaramente ciascun lettore dovrà essere in grado di visualizzare sempre la versione della variabile di sincronizzazione associata allo slot in cui l’operazione di lettura era iniziata. Nel momento in cui in uno slot non ci sono più letture pendenti (per cui *#letture iniziate $=$ #letture terminate*), tale slot può essere sfruttato dallo scrittore per inserirvi dei nuovi dati aggiornati; tra l’altro, con $N+2$ slot totali, esiste sempre almeno uno slot che soddisfa questa proprietà, per cui lo scrittore non rimarrà mai bloccato per eseguire le scritture.

Esistono anche delle *ottimizzazioni* del protocollo: ad esempio, è possibile fare in modo che ciascun lettore esegua un’unica `fetch_and_add` sul contatore dei lettori per ogni diversa istanza di registro che va a leggere. In tal modo, si riduce il numero totale di operazioni atomiche eseguite e questo è un beneficio anche per la *cache coherency*: sappiamo che le istruzioni atomiche di tipo RMW portano un particolare CPU-core a prendere un blocco di cache nello stato exclusive, lasciando così gli altri CPU-core bloccati nel caso in cui vogliono accedere al medesimo blocco di cache.

## Read Copy Update RCU

È un tipo di sincronizzazione che fa da trade-off tra l’utilizzo dei lock e la lock-freedom. Infatti, non offre le stesse garanzie della lock-freedom (in cui tutte le istanze di chiamate a funzione terminano in tempo finito) ma, di contro, semplifica il meccanismo di garbage collection; questo rende RCU più scalabile. Qui possiamo ammettere, su una struttura dati concorrente, *un solo writer* e $n$ di reader per volta: 

- I reader, per eseguire le *letture*, non devono attendersi né a vicenda né col writer.

- Il writer, per eseguire una *scrittura*, deve attendere solo eventuali altri writer.

Si tratta dunque di un approccio vincente per le strutture dati **read-intensive**, che nella pratica sono tantissime; infatti, Linux implementa RCU per molte strutture dati usate a livello kernel. (Ad esempio, la lettura di una *hash table* per vedere il thread control block (*TCB*) di un thread!)

RCU prevede che un buffer o un nodo di una struttura dati non può essere deallocato finché non siamo sicuri che sia diventato inutilizzato. In particolare, tra l’istante in cui viene invocata la deallocazione (e il buffer/nodo viene marcato come “da deallocare”) e l’istante in cui il buffer/nodo viene effettivamente deallocato, si ha il cosiddetto **grace** **period**.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-01-39-image.png)

Nella figura qui sopra si hanno tre *reader* (escludiamo quello che conclude prima di *grade period*) che eseguono una lettura concorrente alla removal e che quindi devono essere attesi prima della rimozione vera e propria (*reclamation*): il grace period dura fin tanto che tutti e tre questi reader non hanno concluso la loro lettura. Il Grace period è un periodo di grazia in cui, anche se sono pronto a cambiare indirizzo, lascio “attivo” il vecchio indirizzo per far concludere le letture. In particolare, è necessario attendere tutti e tre i reader indistintamente perché lo scrittore non sa qual è l’istante esatto in cui avviene la linearizzazione della removal, per cui deve assumere che tutte le letture concorrenti siano iniziate antecedentemente a tale istante. Non posso modificare *removal* finchè qualcuno la usa. Quindi, se reader concorrenti e su *cpu diverse*, non vedono che un “pezzo” è stato sganciato, allora devo aspettarli. Questo perchè chi linearizza prima di me, non potrebbe rientrare se togliessi la struttura.

### Funzionamento

#### Il lettore

1) Segnala la sua presenza. 

2) Legge la struttura dati.

3) Segnala che se ne sta andando.

#### Lo scrittore

1) Acquisisce il lock di scrittura.

2) Aggiorna la struttura dati.

3) Attende che i lettori “*standing*” terminino le loro operazioni; notiamo che i lettori che operano sull’istanza della struttura dati già modificata sono dei *don’t care reader*.

4) Dealloca la vecchia istanza della struttura dati.

5) Rilascia il lock di scrittura.

## Non-preemptable RCU vs preemptable RCU

A questo punto è necessario risolvere il seguente problema: come fa lo scrittore a distinguere un lettore standing da un lettore che opera sull’istanza della struttura dati già modificata? Di seguito vengono proposte due possibili soluzioni.

- **Non-preemptable RCU**: qui è necessario che i reader disattivino la possibilità di essere interrotti (“prelazionati” dalla CPU, cioè thread su cpu non interrompibili, non rilasciano la cpu su richiesta) durante la loro esecuzione. In tal caso, lo scrittore, subito dopo aver aggiornato la struttura dati, invoca: `for_each_online_cpu(cpu)`,  `run_on(cpu)`. In pratica, lo scrittore si fa un giro su tutte le CPU della macchina e ne richiede l’utilizzo. Appena riesce a essere schedulato sulla CPU$_i$, significa che sulla CPU$_i$ non è più in esecuzione (o non lo è mai stato) un lettore che era standing al completamento dell’aggiornamento. Di conseguenza, quando lo scrittore verrà schedulato su tutte quante le CPU, sarà possibile concludere il grace period senza problemi. Il grosso svantaggio di questo approccio sta nell’impossibilità di interrompere l’esecuzione dei lettori: se a un certo punto dovesse subentrare un thread con priorità arbitrariamente elevata, dovrà in ogni caso aspettare che un qualche lettore termini prima di essere schedulato.

- **Preemptable** **RCU**: Qui potrei subire un *interrupt*, ma stando al “ragionamento” di prima, lasciare la CPU vuol dire aver finito. Si usa il concetto di **epoca**:   
  Si ricorre all’utilizzo di un **presence-counter atomico** che va a indicare quanti lettori stanno correntemente insistendo su una determinata versione (**epoca**) della struttura dati; è atomico perché, come al solito, vengono acceduti in lettura e in scrittura con un’unica istruzione atomica (i.e. `fetch_and_add`). Nel momento in cui lo scrittore aggiorna la struttura dati, redireziona il puntatore al presence-counter verso una nuova istanza di presence-counter (*quello relativo alla nuova epoca*), in modo tale che i lettori successivi aggiornino quest’ultimo; d’altra parte, i lettori standing, quando completano le loro operazioni, **decrementano** il presence-counter della vecchia epoca (last-epoch), in modo tale che sia tutto consistente. Chiaramente, il grace period termina quando il last-epoch counter diviene uguale a zero. Nella pagina seguente è riportato uno schema riassuntivo sul funzionamento del preemptable RCU.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-02-00-image.png)

## Vettorizzazione

È un meccanismo in cui le singole istruzioni hanno un vettore di sorgenti e un vettore di destinazioni; in altre parole, vengono coinvolti molteplici registri contemporaneamente. Di conseguenza, si ha un miglioramento delle performance. La vettorizzazione è una forma di **SIMD** (**Single** **Instruction** **Multiple Data**) alla base delle GPU; in alternativa al SIMD esistono:

- **MIMD** (**Multiple** **Instruction** **Multiple Data**): è la forma di calcolo realmente utilizzata nelle macchine reali; rispetto al SIMD prevede l’utilizzo di molteplici processori/core. Chip con hyperthread, ad esempio un hyperthread (MI) e speculazione (MD). 

- **MISD** (**Multiple** **Instruction** **Single** **Data**): è una forma di calcolo più rara, anche se qualcuno sostiene che un processore speculativo sia MISD; di fatto, i processori speculativi introducono la possibilità di eseguire più istruzioni in parallelo su uno stesso dato, sfruttando anche molteplici istanze del medesimo registro logico.  
  *Nb*: i renamed register non sono esposti in ISA. 

- **SISD** (**Single** **Instruction** **Single** **Data**): è la forma di calcolo più banale, dove è previsto un unico CPU-core non speculativo. Sarebbe l’architettura di Von Neumann.

Per poter implementare la vettorizzazione, la macchina chiaramente deve fornire appositi registri, apposite istruzioni macchina e appositi meccanismi dell’hardware, come ad esempio:

- L’**hardware data** **gather**, per raccolta di dati dalla memoria verso un registro vettoriale.

- L’**hardware data** **scatter**, per il riversamento di dati dal registro vettoriale verso la memoria. 

Tramite flag `-O` posso implementare calcoli vettoriali senza API, esistono anche `–O2` o `–O3`, più cresce più ottimizza, ma deve essere opportunamente gestito, cioè sezioni critiche vanno regolate con `mfence` per evitare problemi ad accessi in memoria. Alcune ottimizzazioni abilitabili sono il *vectorize* e *loop-unrolling*. Il *volatile* è invece una non-ottimizzazione, che però può essere utile per cose più delicate.

In x86, la vettorizzazione è detta **SSE** (**Streaming SIM Extension**), mentre in x86-64 è detta **SSE2**.   
In SSE si hanno 8 registri vettoriali a 128 bit, che sono $XMM0$, $XMM1$,…, $XMM7$. Tali registri sono in grado di ospitare:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-11-22-14-58-10-47.png)

In SSE2, invece, si hanno 16 registri vettoriali a 128 bit, che sono $YMM0$, $YMM1$,…, $YMM15$.

Le istruzioni di `mov` che coinvolgono i registri *XMM* e *YMM* (caricamento di dati nei registri vettorizzati / store dei dati dai registri vettorizzati in memoria) potrebbero richiedere che le informazioni siano allineate in memoria (e.g. agli 8 byte, ai 16 byte). L’utilizzo delle istruzioni che richiedono l’allineamento sui dati non allineati causa un **general** **protection** **error**.   
Esistono più modi per allineare le informazioni in memoria: 

- ` __attribute__ ((aligned (16)))` 

- `mmap()`, che alloca delle pagine di memoria allineate ai 4 KB.

### Vettorizzazione esplicita ed implicita

- **Vettorizzazione esplicita**: il programmatore utilizza esplicitamente le istruzioni che coinvolgono i registri vettorizzati. 
- **Vettorizzazione implicita**: il programma viene compilato col flag `-O` in modo tale che il compilatore `gcc` scandisca il codice sorgente e lo mappi, ove possibile, su istruzioni vettoriali.

Per quanto riguarda la vettorizzazione esplicita, in realtà in C sono offerti degli instrinsics (delle funzioni ad hoc) per sfruttare la vettorizzazione:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-02-23-image.png)

# 

# Kernel Programming Basics

Abbiamo visto che il comando *cpuid* manda la pipeline in squash, scopriremo che è possibile risolverlo!

## Indirizzamento della memoria – come vedo la memoria?

La memoria può essere indirizzata secondo più modalità possibili. Una di queste è data dall’**indirizzamento lineare**, dove si utilizzano appunto gli indirizzi lineari che sono caratterizzati esclusivamente da un *offset*, indipendentemente da se stiamo operando in memoria fisica (i.e. ram) o in memoria logica (i.e. address space del processo). Un thread, ad esempio, ha associato un contenitore di memoria, in cui si sposta mediante *offset*, e.g. : byte 44 del contenitore.

Un meccanismo più interessante per indirizzare la memoria è la **segmentazione**. Qui vediamo l’address space come suddiviso in più segmenti, e ciascun indirizzo deve essere espresso con l’id del segmento e l’offset da applicare a quel segmento.

Nelle architetture moderne, l’indirizzamento lineare e la segmentazione vengono *combinate* per avere una gestione molto potente dell’indirizzamento della memoria. In particolare, con la presenza dei segmenti all’interno dell’address space, è sempre possibile specificare l’ $id$ del segmento e l’offset $D$ da applicare a quel segmento; da qui si può ottenere il corrispettivo **indirizzo lineare, che è dato dalla somma tra la base del segmento e D.**

Quando abbiamo raggiunto l’idea di esprimere in maniera lineare un indirizzo, non è detto che sia **l’indirizzo definitivo dello storage effettivo**. Di fatto, come abbiamo già accennato, *sia la memoria logica sia quella fisica possono essere espresse in termini di indirizzi lineari*. Se abbiamo a che fare con una memoria logica, è necessario mappare tale rappresentazione logica nello storage effettivo utilizzando la **paginazione** e la **memoria virtuale**: in particolare, si dispone di una *page table* che mappa ciascuna pagina logica dell’address space in una pagina di memoria fisica all’interno della RAM; ricordiamo inoltre che la memoria virtuale è data dalle pagine logiche di memoria che **ancora non sono state materializzate in RAM** (per cui non esiste ancora un mapping tra indirizzi logici e indirizzi fisici).

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-02-39-image.png)

**Osservazione**: 

- Con la **sola** **segmentazione** divido in segmenti (testo, stack,...), e questi segmenti me li ritroverei così in memoria se non usassi altre tecniche. Se ho un intero segmento associato ad uno scopo, non posso usarlo per altro (può portare ad uno spreco dello spazio), ma permette al programmatore di organizzare le aree di lavoro. 

- Con la **sola** **paginazione** ragioniamo su pagine (più piccole dei segmenti), le quali possono essere non contigue in memoria. Però fare accessi non contigui è un po’ più lento.  

Normalmente si possono **usare insieme**: prima organizzo in aree di lavoro (segmenti), e poi mappo sulla memoria fisica.

Comunque sia, se i numeri di segmento non sono specificati all’interno delle istruzioni macchina, viene utilizzato un qualche segmento di default per raggiungere un certo dato in memoria. Questo offre trasparenza alla segmentazione anche ai programmatori assembly.

I processori moderni sono equipaggiati in un modo tale da supportare la segmentazione in modo efficiente, in combinazione col meccanismo di paginazione accennato poc’anzi. (Stanno supportando il Kernel). Di fatto, quello che avviene in pratica è che ciascun indirizzo lineare viene prima tradotto in una pagina logica col relativo offset di pagina (page address) e poi, con l’aiuto della page table, viene convertito in una pagina fisica all’interno dello storage col medesimo offset di pagina. In definitiva, lo schema di mapping completo è il seguente:

![](data:image/png;base64,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)

In realtà, si possono avere anche più livelli di paginazione. Nella paginazione a due livelli, ad esempio, l’address space è diviso in sezioni, ciascuna delle quali è suddivisa in pagine, per cui gli indirizzi sono composti da una parte alta indicante la sezione, una parte intermedia indicante la pagina all’interno della sezione e una parte bassa indicante l’offset all’interno della pagina.

**Esempio**: 

```c
mov (%rax),%rbx 
push %rbx
```

Qui stiamo accedendo al valore puntato dal registro `rax` (che in questo caso specifico è un puntatore) e lo stiamo salvando in `rbx`; dopodiché memorizziamo tale valore sullo stack. (facciamo infatti una *push*).

Ecco, stiamo utilizzando ben tre segmenti di default: 

- uno relativo all’accesso in memoria tramite la `mov`.

- uno legato allo stack

- uno legato alla sezione `text` dell’address space dove si muove il program counter (facciamo fetch delle istruzioni infatti!)

### Supporti alla segmentazione

I processori *di sistema*, per lavorare in maniera efficiente, sfruttano dei particolari componenti hardware che consentono un accesso veloce e trasparente alle informazioni sui segmenti di memoria. Tali componenti sono degli appositi **registri di CPU** e delle **tabelle di memoria** direttamente puntate dai registri di CPU. Badiamo che i puntatori alle tabelle di memoria possono puntare sia alla memoria fisica sia alla memoria logica; in questo secondo caso, il meccanismo di paginazione è richiesto per mappare anche le pagine logiche delle tabelle di memoria sulla RAM.

### Segment selector

Detto anche **registro di segmento**, contiene l’*identificatore* del segmento target a cui vogliamo accedere. (quindi non il nome del registro bensì il nome del segment). Perciò, gli indirizzi di memoria sono in realtà composti dall’identificatore del registro di segmento usato e da un offset. Il segment selector viene utilizzato per motivi di modularità e flessibilità: se usiamo il medesimo registro di segmento, a seconda di come lo popoliamo, andiamo su un certo segmento target oppure su un altro. Tipicamente è il kernel del sistema operativo a manipolare tale registro. Un esempio è nel caso dei thread: non devo riscrivere nulla, il *blocco di codice è lo stesso*, bensì *riprogrammo* il segmento target, in modo che ogni thread vada dove deve andare.

## Accesso alla memoria nei sistemi x86

### Real mode

È stata una modalità primitiva di accesso alla memoria, in cui **l’indirizzo lineare e quello fisico coincidevano** e *non si aveva la paginazione*. La segmentazione c’era, e tipicamente veniva utilizzata direttamente dai programmatori assembly. Non c’era il concetto di indirizzo logico nè supporto alla memoria virtuale. Qui avevamo: 

- Quattro registri di segmento a 16 bit che mantenevano l’ID dei corrispettivi quattro segmenti target.

- Registri general-purpose a 16 bit che mantenevano l’offset dei segmenti. 

- Un meccanismo statico per calcolare l’indirizzo base di ciascun segmento, che era uguale al suo ID moltiplicato per 16. L’indirizzo fisico a cui si accedeva era così calcolato: $SegmentID \cdot 16 + Offset$

- Un limite massimo di 1 MB (ovvero $2^{20}$ byte) di memoria consentita: di fatto, se i registri di segmento erano a 16 bit potevano esistere al più $2^{16}$ segmenti diversi, noi moltiplichiamo per 16, allora stiamo esprimendo un valore con 20 bit ($2^{16} \cdot 2^4$), quindi abbiamo $2^{16} \cdot 2^4$ byte totali a disposizione.

- **Nessuna** informazione di **protezione** **dei segmenti**: non si specificava chi, come e quando poteva raggiungere ciascun segmento. In definitiva, la real mode non è adeguata per i sistemi moderni.

### 80386 protected mode

È stata una modalità di accesso alla memoria in cui è possibile lavorare con o senza paginazione:

- Se la paginazione viene sfruttata, allora gli indirizzi lineari $=$ indirizzi logici

- Altrimenti gli indirizzi lineari $=$ indirizzi fisici.

Cioè noi abbiamo un indirizzo lineare (*segmento + offset*, dato da  segmentazione e indirizzamento lineare). Ora, questo indirizzo è esattamente l’indirizzo di memoria fisica?   
Se **non** **ho** **paginazione**, deve per forza esserlo, perchè non faccio altre trasformazioni di indirizzo.  
Se **ho paginazione**, posso passare per un indirizzo intermedio, che è quello logico. 

Qui avevamo:

- Registri di segmento a 16 bit, di cui 13 bit erano utilizzati per mantenere l’ID del segmento target, mentre gli altri 3 erano bit di controllo (di protezione); questi tre bit di protezione mettevano dei paletti per l’accesso ai segmenti, per cui non era più vero che qualunque processo potesse utilizzare a piacimento qualunque segmento. Potevo creare viste sulla memoria!

- Registri general-purpose a 32 bit che mantenevano l’offset dei segmenti. 

- Una **tabella** **di segmento** che teneva traccia dell’*indirizzo base di ciascun segmento*. Di conseguenza, gli indirizzi lineari (indipendentemente dal fatto che fossero logici o fisici) venivano calcolati nel seguente modo:  
  *address* *= TABLE [**segment**].base* *+ offset*.  

- Un limite massimo di 4 GB (ovvero $2^{32}$ byte) di memoria lineare consentita.

### Long mode

È la modalità di accesso alla memoria utilizzata dai processori *moderni* (anche se è tuttora possibile impostare la protected mode per motivi di retrocompatibilità). Qui abbiamo:

- Registri di segmento a 16 bit, di cui 13 bit sono utilizzati per mantenere l’ID del segmento target, mentre gli altri 3 sono bit di protezione.

- Registri general-purpose a 64 bit che mantengono l’offset dei segmenti. In realtà, per questo specifico utilizzo, sono permessi solo 48 di questi 64 bit: di conseguenza, è possibile esprimere $2^{48}$ locazioni di memoria differenti.

- Una tabella di segmento che tiene traccia dell’indirizzo base di ciascun segmento. Anche qui, gli indirizzi lineari (che, da capo, possono essere paginati o meno) vengono calcolati nel seguente modo:  
  *address = TABLE [segment].base + offset*  

- Un limite massimo di 256 TB (ovvero $2^{48}$ byte) di memoria lineare consentita, visibile da un thread che esegue.

## Tabelle di segmento

Come accennato poc’anzi, sono tabelle che tengono traccia dell’*indirizzo base* di ciascun *segmento*, per cui consentono di tradurre gli indirizzi segmentati in indirizzi lineari. In realtà ce ne sono $>1$ in memoria fisica, e si hanno due registri di processore che puntano a una di loro. Di conseguenza, sono esattamente due le tabelle puntabili in ogni istante di tempo dal processore/hyperthread; esse sono la **Global** **Descriptor** **Table** (**GDT**) e la **Local** **Descriptor** **Table** (**LDT**).  

### Global Descriptor Table

Determina dove, all’interno dello spazio di indirizzamento lineare, sono collocati (almeno) i segmenti che afferiscono alle locazioni di livello *kernel* (e.g. segmento testo di livello kernel, segmento dati di livello kernel). 

### Local Descriptor Table

Determina dove, all’interno dello spazio di indirizzamento lineare, sono collati i segmenti relativi alla parte *user* dell’applicazione che non appaiono nella GDT. Deprecata.  

Se nella CPU ho un registro che punta a una di due LDT, allora su tale CPU posso passare da un flusso di esecuzione all’altro, cambiando la vista della memoria, cambiando questo pointer. Magari thread$_1$ usa LDT$_1$, e thread$_2$ usa LDT$_2$. Le LDT ci dicono `segmento codice` e `segmento data` a cui il thread può accedere, e dove sono nell’indirizzamento lineare.

In x86, quando abbiamo un `segment selector`, abbiamo un ID e le tabelle considerate possono essere 2 per ogni flusso di esecuzione, cioè GDT o LDT. Specifichiamo quale delle due con un apposito *bit* di controllo. In sistemi moderni, si considera solo la GDT, che ad ogni istante di tempo dice, per un thread in esercizio sulla CPU, esattamente ogni segmento toccabile dai selettori dei registri usati dal thread. La GDT è un vettore, in cui per ogni entry abbiamo la *base* di un certo segmento ed alcuni flag sull’utilizzo.  
Quando usata, sale nel processore, e coi flag aggiorniamo i registri nel processore usati nella gestione.  
Ho una GDT per CPU, e a seconda del thread posso cambiare un certo valore della entry, portando ad un cambio di contesto.

## Segmentazione e paginazione

- La **segmentazione** è nata per *regolamentare i permessi di accesso* al codice e ai dati delle applicazioni (vedi i tre bit di protezione). Quindi posso fare differenziazioni in base ai thread. Se due thread eseguo stesso blocco di codice, ma volessero andare in aree di memoria diverse, NON potrei farlo solo con la paginazione, mentre con la segmentazione basta aggiungere un selettore del segmento.   
  **Quindi se parlo di** ***contesti di esecuzione*** **parlo di segmentazione, non di paginazione.** 

- La **paginazione** è nata per migliorare l’*utilizzo della memoria fisica* andando a risolvere le problematiche legate alla frammentazione esterna. Di conseguenza, la paginazione lavora a grana molto più fine rispetto alla segmentazione (i.e. una pagina è molto più piccola di un segmento). Basti pensare che, nel momento in cui bisogna accedere a una qualche informazione in memoria, tutta la pagina che la contiene deve essere materializzata in RAM; se la pagina è troppo grande, la sua gestione può risultare complicata (ad esempio, è più agevole effettuare swap-in / swap-out di pagine di memoria piccole). Non differenzio in base ai thread.

In realtà, all’interno delle page table, non si hanno soltanto le informazioni sul mapping delle pagine logiche sui frame fisici in memoria, bensì esistono anche dei bit di controllo che indicano delle regole di utilizzo di quei frame. 

###### Ma a questo punto a cosa serve mantenere la segmentazione che era nata proprio per motivi di protezione?

Tramite la segmentazione riusciamo a implementare tecniche efficienti di gestione dell’accesso alla memoria in architetture multicore e multi-thread: di fatto, possiamo fornire delle viste di segmenti differenti a thread diversi (vedi il **Thread Local Storage – TLS**) o anche a CPU-core diversi. Nella segmentazione, la grana di protezione è più “grossa” in quanto con pochi bit si possono definire comportamenti su un’intera area di memoria, ma è utile sopratutto quando si lavora con TLP, quindi in maniera concorrente, inoltre la segmentazione è stata portata avanti quando la paginazione era già supportata dai sistemi.

### Modello di protezione basato su segmentazione

A ciascun segmento è assegnato un numero intero $h$ che indica il suo livello di protezione (di privilegio).  
0 è il livello di protezione massimo e, via via che $h$ aumenta, il livello di protezione descresce. Ciascuna routine (e ciascuna istruzione) assume il livello di protezione del segmento a cui appartiene. Ciascuna routine $r_1$ avente un livello di protezione pari ad $h$ può invocare una qualsiasi altra routine $r_2$ col medesimo livello di protezione $h$, sia se $r_1$ e $r_2$ appartengono allo stesso segmento (per cui parleremmo di **intra-segment jump**), sia se non vi appartengono (per cui parleremmo di **cross-segment jump**). 
Invece, per saltare da una routine $r_1$ con livello di protezione pari ad $h$ a una routine $r_3$ con livello di protezione diverso da $h$, è richiesto un **cross-segment jump**. In particolare, è sempre ammesso saltare dal livello di privilegio $h$ a un livello di privilegio $h+i$ (con $i>0$) poiché porta ad *abbassare* il grado di protezione. Per migliorare i propri privilegi e, quindi, per passare da un livello di protezione pari ad $h$ a un livello di protezione pari ad $h-i$ (con $i>0$), è necessario sfruttare dei particolari access point detti **GATE**. Ciascun GATE è identificato dalla coppia `<seg.id, offset>`, dove *seg.id* è l’identificatore del segmento e *offset* è lo spiazzamento all’interno di quel segmento dove si trova il GATE. 
A ciascun GATE (e.g. appartenente a un segmento con livello di protezione $h$) è associato un massimo livello di privilegio $h+j$ a partire dal quale è possibile passare al livello $h$ passando per quello stesso GATE (perciò, se si proviene dal livello $h+j+i$, con $i>0$, quel GATE non può essere utilizzato). 

#### Esempio

Ho segmento livello 3, ho un GATE (porta) che mi dice che posso diventare livello 3 solo se sono livello 4. Se fossi livello 5, non rispetto i requisiti minimi per attraversarlo. Senza i gate non posso migliorare la protezione. A seconda della configurazione di un GATE, posso fare o non fare determinate cose. Io definisco queste *porte*. Posso sempre peggiorare il mio livello, non servono GATE, ma poi posso migliorare il mio livello solo se c’è un GATE *che me lo permette*. Il meccanismo appena descritto può essere schematizzato col **ring model**. Nei sistemi x86 moderni si hanno esattamente 4 livelli di protezione, che sono schematizzati nella seguente figura:

![](img/2023-11-24-17-22-52-image.png)

Nei sistemi operativi convenzionali, i GATE sono tipicamente associati a: 

- **Gestori degli interrupt** (invocazioni **asincrone**). Ad esempio da livello user a liv. Kernel uso un gate.

- **Trap software** (invocazioni **sincrone**), che siano esse delle eccezioni (e.g. page fault) o delle system call.

Tutto dipende da ciò che c’è nella GDT comunque. Inoltre per codificare questi livelli ci servono due bit, che sono proprio i due bit dei tre bit di protezione visti nelle pagine prima. Infatti se vediamo:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-03-05-image.png)

I due Kernel routine sono nello stesso segmento $S_1$. La user routine è invece in un altro segmento $S_2$.  

- Il GATE kernel routine **A** ha livello 0 (del segmento), un certo offset rispetto $S_1$, e il “max” livello di privilegio per usare questo GATE è 0. Quindi User non può andarci, essendo livello 2 e non 0. 

- Il GATE kernel routine **B** è anch’esso di livello 0, ha un certo offset$_2$ e il “max” livello di privilegio per usare tale GATE è 3, quindi l’User può usarlo, essendo livello 3.

User entra in Kernel routine **B** mediante **cross-segmento** (perchè passo da $S_2$ a $S_1$) e poi da Kernel Routine **B** a Kernel Routine **A** mediante **intra-segmento** (perchè parto da $S_1$ e rimango in $S_1$).  

### Composizione degli indirizzi x86 con la segmentazione

Come analizzato precedentemente, all’interno delle architetture x86 gli indirizzi vengono indicati nel seguente modo:  
`<segment_selector_register, displacement>`.  
I **registri/selettori di segmento** sono 6: 

- **CS** (**code** **segment** **register**): indica qual è il segmento di memoria che contiene il codice che stiamo correntemente utilizzando in CPU. 

- **SS** (**stack** **segment** **register**): indica qual è il segmento di memoria che ospita lo stack su cui stiamo correntemente lavorando.   
  Esempio: la push prende `ptr` stack come offset del segmento SS. 

- **DS** (**data** **segment** **register**): indica qual è il segmento dati corrente, ovvero il segmento che bisogna utilizzare all’occorrenza di un’istruzione macchina che prevede un accesso alla memoria. Di default. 

- **ES** (**data** **segment** **register**): ha la stessa funzionalità di DS, ma è riservato ad alcune specifiche istruzioni macchina (i.e. le istruzioni che coinvolgono le stringhe, come stos e movs).

- **FS** (**data** **segment** **register**): è stato aggiunto nei sistemi 80386, e viene utilizzato solo nel momento in cui è previsto dal programmatore o dal compilatore. In particolare, può essere sfruttato in maniera esplicita a livello di programmazione. Usato di solito con *Thread Local Storage*, per avere viste diverse per ogni thread.

- **GS** (**data** **segment** **register**): è stato aggiunto nei sistemi 80386, ed è perfettamente analogo a FS. Usato in contesti *Per CPU – memory, cioè varia per ogni CPU.*

Abbiamo già accennato la struttura dei `segment selector`.
Analizziamola nel dettaglio: 

- I primi 13 bit rappresentano l’indice della entry della GDT / LDT relativo al segmento d’interesse. 

- Il bit successivo (**Table** **Indicator** – **TI**) indica se correntemente stiamo utilizzando la GDT oppure la LDT. 

- Gli ultimi due bit (**Requestor** **Privilege** **Level** – **RPL**) indicano il livello di protezione a cui stiamo correntemente lavorando.

Per il registro di segmento CS, il RPL è chiamato anche **CPL** (**Current** **Privilege** **Level**), che rappresenta il livello di protezione corrente del thread in esecuzione.  
**NB**: Queste cose appena viste hanno un ruolo *paragonabile* alla segmentazione, quindi Linux usa la segmentazione per il minimo necessario. Per questo si usa principalmente una **tabella**, ed il selettore di segmento ci porta da una parte all’altra sulle possibili due tabelle (ma alla fine se ne usa una e ci si spiazza su quella). Dipende dalla struttura software.

Torniamo ora al primissimo esempio che abbiamo fatto in questo capitolo: 

```c
mov (%rax),%rbx
push %rbx
```

- L’accesso in memoria effettuato dall’istruzione `mov` coinvolge in modo implicito il segment selector **DS**. 

- L’accesso in memoria effettuato dall’istruzione `push` coinvolge in modo implicito il segment selector **SS**.

- L’accesso in memoria effettuato per eseguire il `fetch` delle istruzioni coinvolge in modo implicito il segment selector **CS**.

## GDT Entries

Ogni entry della GDT ci dà informazioni sul segmento associato a un dato indice. La tabella è necessaria, perchè il registro può essere cambiato e quindi devo mantenere le informazioni.

### 80386 protected mode

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-05-38-image.png)

- **Base**: indica l’indirizzo base del segmento puntato dalla entry. La GDT ci porta alla base del segmento. Per esprimere un segmento utilizziamo  
  *base 0:15*, *base 16:23*, e *base 24:31*.

- **Limit**: indica la dimensione del segmento.

- **Flags**: tra i flag rientra il **granularity** **bit**: 
  
  - se vale $0$, il campo `limit` viene espresso in byte.
  
  - se vale $1$, il campo `limit` viene espresso in pagine da 4 KB. Se lavoro con blocchi 4KB, ho *limit* 0:*15 e* *16:19* cioè 20 bit, che combinati con 4KB = $2^{12}$ mi danno fino a $2^{32}$= 4 GB, la taglia dei segmenti.  

- **Access byte**: qui si hanno i bit che descrivono la **protezione** del segmento. Tra questi rientrano i due **privilege** **bit** (che infatti vengono copiati all’interno del registro di segmento) e l’**executable** **bit**, che indica se all’interno del segmento c’è del codice che può essere eseguito.

### Long mode

Sarebbero $64$ bit, anche se effettivi sono $48$.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-05-59-image.png)

### Accesso alle GDT entries

È possibile accedere direttamente alla GDT (che è in memoria lineare, in quanto noi con essa gestiamo la memoria segmentata) via software sfruttando il **gdtr** **register**, che è un registro di tipo *packed* composto da due campi:

- La parte *bassa* tiene traccia dell’indirizzo lineare in cui si trova la tabella (32 bit per la 80386 protected mode, 64 bit per la long mode).

- La parte *alta* indica la taglia della tabella (16 bit). Cioè il numero di elementi.

L’istruzione (non privilegiata) che permette di *leggere* il `gdtr register` è la **Store Global** **Descriptor** **Table** **Register** (**sgdt**), i cui dettagli sono riportati di seguito:

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA8UAAAGSCAYAAADKJmMKAAAAAXNSR0IArs4c6QAAIABJREFUeF7s3QVYVFkfx/EvIRKiooBiYQuCgI2IgiiKgd2J3YrY3d2xtojdq66BhSh2B7YYKIqUiIjkMO8zg7rquu/qqruy/u8++zzueufecz7nzJn7u+eGhlKpVCKLCIiACIiACIiACIiACIiACIiACPyEAhoSin/CVpcqi4AIiIAIiIAIiIAIiIAIiIAIqAUkFEtHEAEREAEREAEREAEREAEREAER+GkFJBT/tE0vFRcBERABERABERABERABERABEZBQLH1ABERABERABERABERABERABETgpxX4QygODQ1l8ODBGBsb/7QoUnEREIH/LxAREYGRkRHa2tpCJQIiIAI/nUBUVBSGhobo6Oj8dHWXCouACIhAehdQKBQULFiQvn37vqvKH0LxvXv3GDdunPpfWURABETgUwJDhgzB09OTnDlzCpAIiIAI/HQCEyZMoFmzZhQpUuSnq7tUWAREQATSu0BkZCTz58/Hx8fnO4dipZLUVAWK1N/f9qShqYW2lua/aqhUpqI6M6BUaqClrY2mxr9aHNm5CKRbgb8dipVK9Xcw9c2b4DS1tNF680VUfz9TFKhHDQ0NtLS00NRIb19S1dinGmdS+RHGvHTbwaTgIvCDC3xNKFamKkhRpP6hhv/2mPG2XF9UDtXxnlKJhoaGatgmNUWBQgmaqvFbU4P0NoL/4N1OiicCIvCNBP6xUPzo1CbmLl7J7qO3SHxTeNPSdejXriXVaziQPeM3qtEXbib2/gkG9uvJxdhyzN+0lPImX7gBWV0EREAt8LdD8cvbTOnjydIjN0lFn9azfmVCQwv1NoP8F9KtxzSC4iGrXS0WzZ5GhQKZ0pl4PMdXj2fAqPUUG7qNVV1Lp7PyS3FFQAQ+R+BrQvGNzUNpNXoD0fEf7sm0dAOG9PSgeiVbMmX4nFJ823WCtgym2sBNOPVfy6rejn+58VRFEpd2z2fNvXyM696QzHovWNe7JcOPajNk7hw6VymC1l9uRVYQAREQgX9e4PuH4pR4zm6eycCp3jzVyEHFSpXJm1V1v81LLvv6cz1ah4rdR7Ckrzv6r0PYc/g0iQZ5KG6s4MKNhyhSjShfpwrFsv1+IBz/7Ab7Ai4Rm6AAclCjlSs53ptxjrjuh++FJ2rNTLlK4VbNGv33bF/cPcFvp+6BhiZ585qyafagD0JxXMRDThwL4Nkr0M1ZlGoVy5DNQO6T/Oe7p+wxPQl8fSi+g46uNlnLdGPv2n5kA9YNcGbinlASEhPJbJMWii0z3ufoocsoCpahpEEYpwMfk6yfjbIOTljmMkwjUyp5fPkg/oHPQFOXQiUrUc7KjAwk8eTKSQJuRGBuYUny0zsER71C39yOOmXyc+fiUS4/eIFRbisqVSqFeqhSLakpPL5+ghOXgkkCjArYUaW8DZne/P21w+u4GJKF0tWsiDh5jEevwcisJM6uJTAkmZBrJzl87AbZKzSgtl3a5eUJkffxP36GiJfJgDGVGrpQIJNuempyKasIiMB7Al8fireSqaA9FUrlRz1P8PoJvrsDeJ4xP15zltDLpZB6b7ERNznie45oNMiWxxpHx5Lvxqqk+Ef4bTlChHpNXQqWcqCcdR7e3eWc8ILzp45y43EMkJFC5ZxxKJYDDY1oTm8/xB3NbNhkj+fq/efo5y1BhezR/HbiNvnKuVO7dDaCTp3kbHAMxYoXI/LhDcJeJGBi4UDV0oXRefWYnZsXMW7KBpItqtK3dR0cXZxIuXqAgMea2Fetiq15NlTXByZE3GK371leq0qZxRSHKm7kyawqcyLB544SEBSHZbkSJF+7zN2Y15CpEA3qO2Aol/PJd04EROA7CXz3UBwfHsTUfk1Ze04fr5VraF/OHL0MqiExhcjgUwxt0YWDkcVYdnQdrq+P4d5hCDdCUylmV5qCRhrcunqZGN0iDJm/hEbWWbm2fy5jJ6wgwrg0NtkTOHP+BoZWboyeOIoKZsnsXjiUOSsPo29TncLZYrl27BZGDo0ZNbI7tjm1eHRwNZ1HLSFG3xzb4rlIeHKTM4H3yZzXVT1TnDd0DX06LOJV/gIUzmHAk6DbROuXYd7Kmdhk/U6tIJsVgf+AwFeH4lPRVKpQiOCHMXgu30L97BdpXH0oWgWycufmVZSF0kJx9icr6dF6JsGZTSlT3h5T5VMO+l/ByLEDq2d7UihjLFvmD2H27iDMLezITCS3rz7CqtMEfulSmqNzB9Fz/n608xSnvGV+Yh5d4vK9lxQsWoSsprnI8uoOBy9FUbXnBGZ3r4F+ajS7F4xk1LqLmBWxxDxzKrdvXUejeCNWTB2KeVZY1NGCqX4KTIqUooKVEaFXznE5IjPtRk7Fq3EJLq77cKb40fn1DB04jQd6lpTJo8PVy1dJNinF8FmzqVVMfWQoiwiIQDoT+PpQvIdy7SYyeYi7+qQgigSu7FtEX6+5vKw4mBPeHoTt9ab9tI3omxSmoKkuwTfPE5e/OT6/9CFriD+DB07iclQWrEuakxx5n+uBMbiOnMvEpqUg+h7DerVm/+PM2Fnk58XDQO6EJdJ20g761o5jrHNb1oXEUMC6LCXy5aRYlSY4xm+j3rDNb2aKi7J56ABGbzyBnrklpSzNSYy4TeDNSCq0n8a0NmYsnjkF780nUOayoHqVSjTt0IrgOV1/nymulIeb+5YzbOYaojIUwMYiB+E3T/BAtxSTJk7EzUaHfeN60NPnDLp5i+NcPC/PQ65z6UY4lXstZHa/Khiks34hxRUBEUgfAt89FEc9OMLAlh6c1GvJgcOTyPeeizIpjq0TWzJw1XU815zHM9dpdSh+rGvDxBmzqWmZiVt75tB5zBoK1BrFrLEOLKhVg9UvbVi0ch41C2lwaNUvBJrUpm01G1If7aBtw0GElu3KocVDMDZI5Lz3cFpO3Iuj1yKWNjVm/MDebL+RkeFLNtHILjNPT2/Ga/BwHmm7MH/tME4N7szCWxq07dodx0KZuX98Cwu3HMV58BamtLJG5ovTR8eWUv7zAl8dis+8pFX7etzYv4uc7qPoYh6Ax/xAOjaqwBbv5cTkdf0gFMc4dGPz0v4U0IlndFMbVl0rxXy/xdgG76b7wEm8LtyCXh7VyJoUyo5ls/F9WJxfT88jeskgei44TjmPsUwdWIenB2bRx3MxKdbtWbpuOAViD9LEvju37TtzbkV/4q9spGO/mWjYtGf65J5YZEkiYMUoBi04gEO3JYzv5cg6dSjOQqe5yxhcz4r4owso1X4u1k1HsHRkC+5sez8U52Fh2yZMu5aV0fPm0t4+Gye3LueYwg6POhXJkUVmi//53it7FIGvF/jmoRh48egiIzo15FBEHTbv68A6T09872elvVcvSppqcOWANys2XMZjTQANE9bTbtA8UvK60K1La3LoxqOT0YRcBQtSNHcmrq70ouHEU9TynMiErlV5cXkPi/xD6dy6BflyhTJaHYr16bnwFwZWt1KDfHj59JtQ/Os1XPtOZ0JnZzKEX2Cc12D2Pc3GRJ8NOCVvx9VtMMraA9k3oxtZPrp8umXRV0zy7Myu4CLM2riUagUNCT65mgF9RhFRrD+b17XhiioUr7pN9d7jmdyzOgmXt9G93xhizJoxb8UYrOW84dd3VtmCCIjAHwS+eyh+/jCAIW06cORVRVYdWUaFLL+/qiAl/hnzezZi7mEFE/YcoLXuSdw7DCMhf13mzBqDVXbg7h5qdRhOcuGGzJtRj+kOjTlcpC77l42lmNmH9xY+2jGCyp5rceizknX9qqgf8BB6ZRWt640mquZwjg8uwZB+3Tj9vBTzt3pTwQQ+uKd4cTc2efVhR1AM+czNyaL79s4XbUq49qB/r6oYSScSARH4pMBXh+LL8fSaNInMO0axJjoXNsoIbmVwYkIPM4b0n0x0LpcPQnFis+kcm9pEXZbZrQow90QJZh9ZTKHLa+g7fBHheubkz5313YksTa1MdJu5GN3fBtFz6Xlq95/P6A7lCD3mjWevCaTUm8/Oce4oXh6lrU07zpXpwKVVngRtn0afyduwav8Lswa4oDoeCzmykNb952Ps0I9ZM7qwp4cqFBdi8r7ltLAwg8veFGk0HouGw1g+pjV3PwjFBgxzasN6bRtW/TIVJwt51Z18pUTgvyDwPUJx2I09eLbryeXsHuxY4Mz0vn05ek8D80LmvH9Xl22bCYyobsyOJWNZd/guD4MfEZOkTb5CxXBo0JvR3UpzVBU2Nz2h47h59G9km3aJ9rvlFsNVoTjVgiULp1PDOsefhuJx+x7QZeZ6+rjkBcLYONCLcX4h9Jixlva5Tv7fUFw3x00GtOnDjXzd2bd9MKqbSV4GX2RUn9b4PbVnxeFZPJ+dVs4O4+YxoJEt8dd307XPEMKz1mPu8onYyIHYf+HrInUQgR9O4LuHYkVcOOun9mXy+jOYOragf8dmlMibGeJC+HXtClZvOEaqXUt2rRuB+bPD6pniEP2STJk5m+rFDAjaP58OI7zJV304M8dXZJ6bG+tfl2bxihm4FcvKtb2L2RFqSfuWTmg/2EbrRsOIcuzD4YX9yKqbzJW1o2g6ajvl+y7Eu4UpYwf0YudtA0Yv30x9awOend+O18DBPNCswvw1Qzg+sAuLgg0YM3UeLR3yEBcdwfPYRPSz5cQk87/0NLAfrttIgUTgjwJfHYoDk/CasozqLxZRc+AWVE8McOy7Fu/a0bi3H06YieNnhOJllHy4i+4DJ6NhN4gF8zpgrp1M5LNw4hV6mOXX57Tq8ulPhGJls6XsHlad+A9C8UDiLq6jY/856JTuyoxJXSlimMyJVaPpP9uXcp1+YaKnM+vVM8WfG4pzMa9lU2bdMWbMnBl4OOTjzpF1bAo0oI1HHfJl0VPfcyeLCIhA+hL4+lC8C6v6Xgzo6kLa3VphbBgxhpUnH2DvuZgVTQwZ6tmXw09zMnbJKmpZ6BEb+YQXrxVkyZEHveQXRETHobpDLeTJAx4H3WTTyvlcf6kKm4vJsMmTxlPPUfvNTLHiwSmW+pyhSq+OlDR7xhhVKNayxmfBNJwt007WfXKmePt13LxmM76DIxmiLjPBayC7HhkyYcUmqmjsws11AAk1vDg4uwdZ9WM+eNBWiyIxTOjdhb2hVizYvASnfPo8OruRgb2G8KRAH7Zu6sDVN+FdQnH66v9SWhFI7wLfPRSrgGKf3GDNrEEs9L3L69eJvH3pgFZGAwpZuzFg4hCqWZigeW+fOhRff5JM0dIVsDHTIfD8aUJT8zJ4kQ8tbI24vGsqI8b5EJGzLM6Fdbl04iwvslkzZPJcaltqsHN2P+asPYVJhQZYZI/hwv7z6JRqwPgJfSmdS4sHe5bjMWoFKSaWlLXJS8zdMxy/+ggj87R7inM/Wk6XtjOJyl2CitZmPLp2gQcv8jJi3S80KKK+y0cWERCBTwh8bSheeTOVobN9qG92jlbV+nBdkY0Je07QWsePmh7DCP2sULyCBtlTWDvTi4nb71K8pD15M8VyIeAsJi5DWDanIde+KBQPwUgrhm0zBzN6yw2K2JSkYFYFVy+eIb5QPVbNGUcho7f3FH9uKC7Ng1Mr6e81nXsGVrjZmnLj7BlClCb0meJDG8cccpuGfMNEIB0KfH0o/uPTp7UyZsbKuQ2TxvfE2hSCdiymzdg16OQqTknLHDw470eQfll8Fs/B/PkBBg6cwd3kXJQpXwit2AgunT+NUaWheM9sg1HUbTw7N8c3JDsu9tbEPwnkwrVnVPNczvjuRkz+3FC88Rg6eS1xKFWclPBrnD3/iFLtpjNneG10X12hn0tjfFML0Ni9Og3aNObB7PfvKc5N4G8LGThrA0lZrChtbUbo5UNcVVgyedoM6pbSTbunWGaK0+E3QIosAulb4B8JxWlEqYQFncHv0BVevjEzsalGI4fCvwu+CcUxuaoyoqMbj+7fIyXVmEqNa2Bl/OapsuoHMl5l56EzxMSr5pIMqdqiBUWy/D63EnvvOOsOXlNv1zBveerXLvnBgxme3/Rn89Hb6neGFitXicT7pwlLykm1um7k0lcS/fgqhw+dIkL17ii93FSrU4XC2dPba2DSd8eU0qc/gb8dihOfc9rPj+vRGjhUrU0Ro1RO713DtbBcuHesTe7kMPbtPMSzjDlxdXFG71UgB3efQ2HhTEvntFc3ndu1hAtPjHFpUZOiWfRRvd/4+pENHL8dC2hhVqwcLo62GGZI4tH5Ixy68oyCZatR0caMV2++71jUoFGFAiQnPmLvyr2E5iyBRy17dHVUt1EoCL19msP+gai2aFykHDUcS2H45uKRS77LOROclcpN3CiuGivCrrJs5ymyFbHHrWJxou+cwv/4DbLZ1//96dPhd9nnF8CzGNXTpw2wr9sQu1zyCJn01/OlxCKQJvA1oTjy1lF2H79JQsqHmsa2NWhcocAH//P5vVPsOngF1dubMhqbU9XFhXzZ0gajpNcP2LN6P2Hq/9ImbwlHXMpboPf2gSjxzzl19CBXHkar18hVqibuZc3R0IgiYMMebmiYUMvViXzZ097ZEX3rCJuO3CJv2TrULq2T9qCtPfdoO2gsVjpPePo8nhzWztSytyCjah+pCh5d9cfvdBCJulkoXdkZg/vH3jx92gWbfGlPn36/nHpGZjjXqKd+aCEkcP/EQQ7dekUJx6qULWZKSmQQBw4FEKdbmKpulTGVxy7IV04EROA7CPyDofgzSv9eKJ47eyYl095cIosIiEA6EPjboTgd1E2KKAIiIAJ/JfA1ofivtv1j/H3476F44kqGuhf9MYolpRABERCBbyDwY4XiiGssWLWd+CwWNGvahHxZvkENZRMiIAL/iICE4n+EWXYiAiLwgwr890PxS85v38quwEjs67Wjpm3aw7hkEQEREIH/gsBnh+IOHTrQrFmz/0KdpQ4iIALfQWDdunXUrl2brFnlhd7fgVc2KQIi8IMLbNu2DQcHB8zMzH7wkkrxREAEREAEPhaIjY3l5s2b+Pj4vPsrDaVSqXx/xXv37jFo0CD69+8vgiIgAiLwSYEpU6bQsWNHTExMREgEREAEfjqB+fPn4+7uTv78+X+6ukuFRUAERCC9C0RHR7Nly5a/DsUzZsxgzpw56b2+Un4REIHvJNC9e3dGjBhB7ty5v9MeZLMiIAIi8OMKDB48GA8PDywtLX/cQkrJREAEREAEPikQHh7OyJEjf6JQnPSKp1GxZMluhoGO9AoREIFvJSCh+FtJynZEQATSo0BaKG5L/jw5ufTbQhb63k6rho4h9nU707qGNVn1VAceKbwICydF14hs/8h7yZUkxcUQGXWNZSOXcleR9mJM/bwlaNmkOfYl86GroUHKq0i2LRnLrktpT6Z+uxiYl6RNk6aUtcuL6hnXhxf3wfv48082kY5eaUYsa8eDRYtYc+ImHz1Mm5y2DenV2Y28WfVRPdf//SVVkUJ0eBiaWYzJqp8RjfTYCaTMIiAC6VbgC0PxLMLvXmT7r1sIfqlFxhzFaNSwAdZ5MqsBIq7vZf5yP5L1dNF8M5rldGhB79rWfwmkSI7m7N4dHDx9lwR0KOLkTlOXUhjoaIBSSVLCa8JvHGDe2vOUqN2CxtWs0fvLrX60gjKVh7+No82ql8xfPgu7bEoUKUncP7aFtf43SElJJYttHXo1qIC++jUssoiACHyugCoUDx82FN1X91m14zDPX6W9Mq2GR1cqFjFSHwApFcnEx99j/dR1PEhNBS0drGu0pYl9foKPLGf+ntvo6WZEUyOVpBxlGNrOjcyGBsQ/PsHCpXvVr3NLTogjGR30dDOgoZ8X95ZNKF8guxxAfW5DyXoiIALfRUAVils2cuPgooHMCszPqM7V1cdCSa+i2OW9iDi3cRyZ4YE2d+nv2IKYxjOY4+nM937hY2JsGEsHN2bmr6HU6tMfO+O018w9DfRnw6ZLNPH5jbFulihiHjO+kxM7FfXoVevtbHcKIZcOsv7Xm7Rdu4vh1Ypw58g6jt2NUw3o3Dqyjp33TenZxpVMOlpo6+TH3cOKHR3aM/NmTjq3d+T3F2rGsHvefCLL9WLDbE/Ms3w4M/EqMpDeLs3JPX4NY+uV+kNo/i6NJhsVAREQgTcCXxaK+1fHrdECms78hdYVcnJl02Q6LHrAxt1rsMoK9/dNoJd3HDMXTsbS+MuMd05swqInTiyd1AnT5LtM7+NBUNkFLPSqAA9OMGPGVvRrOvNw+AAS281jlldN0qL45y+JoRcZ0nkoBYb70KeCGaQmc9x7MJP2ZGTqylGU0HnOyuFd2aBswprJ7cjxxan788sia4rAf01AFYrbVy/M2Nm+NJvsTduK+YBYrhy8Tm5Xe4wVSZzbMIa+6+/g4TWZLtWKQEoiQbcuoZnTjmdr2uJ5pRRb5g7BPEsM53cspv/wI7RbupQ2FfOS4Q2YTy8HdmbuyfLRrcj+5j3B/zVLqY8IiED6E1CF4sY1S7Fw6AyKj1/FgGrF35ysU/DsxnF2HQilVvfq3Nu5iEGei0i2qUr3IaPo5FwIXt5lxeLNBL9KRFMrA24dR2KfR3UWMJbzB7ZzT98CzUu7CXyRj5aD22Bh8JKDS9dzLCQKyELd7r0oY/bpAfHssk50WZnKVJ8ZVC+a7YMTiE8PjqOTtwELVvQnT2JaKD5vtxjfkdXfa4DXXF3cl/prElixdilVCrw5OEpNxm9BF4aeKsLe5QMxNng7Sj9hWYf2rExqzI61XTB9b0s3fMfRcPQ9NmyeS8n87z+UMZwd06Ywatp6jKrVxXPoJBrYGhMXHcja2Vt4oppwz56Puo1bYpM77R3K7y+vo+/y64YALGo782jbKi6/AAu3jrR0yIS/9wb8H4aTpbgL3RpUwiCjTHqkv2+XlFgEvr/AF4TikThphrDEoD/bxrmh+TKYHd6/sGXDZrL38mVZW8u/H4rDfKlVdxqtFu+ipW1G7p//jY0rN/HbZQ2mbNmEc+5U1WQxGppP8CxZlbg2c788FCsVHFvRl+kXLFgxoxsmBtokJz6gm2tzrIeuoo9bYcKvH2ftxpVs8w9jwLzVNC79/lD+/RtD9iAC6VlAFYqblkykx+w7tJu0gCEN7D6oTnzMKVqV7Y39TG+86pRAW+PDi+NOzm76XihWfVTJL22LsSOLF6undMPMIG1zXxqKo+7vx7PzeDJYlyXl0UO085uQMUKT+9Gv6D5tBvWt5IXo6bnfSdlF4EcRUIXidi0bE3NpCx3H+GDq0pV6JbKBjgF2Lg2popotSIjC/9dfGNR/CSnWznQdMoYG2S7SxaM/4YXr4VTEkJTnN9hyMJRec7zxrGbKmpEdmbYtBFt3NwoUd6BfrZzM6tWRQymlcbVTjV9hHNl2naazN9CjTiF0PwAJZqJ7C+5Wm8riPpXQ/fiaZKWSVKUSDU1NkqP/LBRDcmIANa2G03z5Wjo5m6ft4S9C8fRAI9q0tH9vJjyGvUtWoHQbzqrxHcht+P5McRjbJk1k9KxNZHWuhefwiZSL2UnrrlPJUMqdsuYGRAafxvd8KjPXbqZ5+Q/H7aiHB+hUpxNBGYvg5FqWTBHXWXf4CvlKVMHGLCt6RHBgvy+2gw+zrnvJH6XLSDlEQAR+IIEvCMW9MH8QxhHnaSyqFoP3ptOUatSc6GW9WW3gycbp9YjeN4HWY87g3roRZm+uByru3JRy+f94Vu8Dg4tLse65mUmL16F31odTcUVpXVVJh3Zz8Vi8DY9yb6edH9P3b4ZiRegRGreZRINxq9Wz3OpLmhKOUtt6JC28l2AR5su+B4Y0bmjDrFa9KD7KB6/aVmj/QI0lRRGBH1lAFYqHDunFk/MBbD18DP/9t7Fp1BR3t7rUqmJJyjUfyjRaw+iVq2hqZ8C54we4/TQenex5capUieCVrT8KxeA/pS4dTltycNlYCpukHer9nVDcsbYnlmNWUyNiMV13GrJ9bgdWDulMaotFzGxR6kdmlbKJgAikE4F3D9oqWoiYl7EkvY7i2M4tHLr6kIjHt4jN3ozVq3thSiBdbT1QtJ/JnD6OHBnvzrBbFdj1y1DMs2VAmRTL9mkdGHGpBEcXd2DX5G7MCnflwqq+qCY5r27wotGk8zRt04IipqpZ2xTu+G8kIKUyq+cPo2C2949c7jHarTUhdWezqIc96hgadoJ2DXrg90g1ywyYWjFm1hLa2mr9yUwxpCQdo2bxYTT7glA84WQSTk7F0EtN5t75gxx/lImec5YztnE5DPQy/OGWl9jwU3Su0InCs9YwtpoJi/p3ZJ12C/xmtVXf0pYS+5Dlg7vhk9KUw0s78P6RpToUV+lG3rFrmd3WAa2UhwyrUY8gh1EsHN2AbISwtGtHNhj34ujUeumkR0kxRUAE/kmBLwjFnliEPWN+ghXNHMvSrEUzihlHs7BzS06Um8vqnqUJ3jeBzvNCGDDai0JGadUwMiuIieFfRMvrq7FrPJnilVvgWrcuTavboXl7FTW7bGfwmq3ULPT2838zFCdFs3N8G1bQGe9R9TB+c4VPUsJpGlu3RcvBBZe6rWldyx69uDO0bDCShtNW08ohj9yn+E/2RtlXuhZ4/0FbqalxPAl6wv1z3nhOOk7zKcvoZnkT11oz8PjFhy5VzHn+7AmPzq+n85RLTPXxJpNv5z+EYp8edixL9mDzzD7kzqz590Nx8+k0WLAU87MTGHS8IFsnNWK+ZztSmi1mdisJxem640nhReAHEVCF4hr5ohl7MAOjp42nyrtLlVOJvriFxh7DabImiG62H4biw6NrMj6sHr6ze2BsoKmegQ1Y2Zsum7NwdHVP9kztwRrN1vjPaK6u6cXlnXAbc5xSpazIrPv7pcBZbNwY3asVebK+fxl1CgfH1WPAGSuWLBlF+TyZ0Eh5zZPHocQlq577cJUubjNovGQ9Xcpk+JNQnMTD7WNwnXyHuau8qWX55ua1z718WplK2HU/xo8aye3sDZkztS9W2f54qfeHodj86rGiAAAgAElEQVSYBZ4d2GXam0MT34TYlCi2j+/OpDsVObChL28OM9UmaaF4EOVWrGeoS3HgKePq1OdJjRnM6l0ZA57i3bUjq7N244iE4h/kGyPFEIEfS+ALQvEU+lQzpfnkQEYsW0odi0wEH11Jj3F76LViM7ULZvz7l08nBTOmRRtuW/Vg3rAmGClC2TSmN9u1mrFgfHNyvr1Nhb8TihWEnFiNx8CDjNm9Esf3BuLUlFiWe9ZnS7I7q2f1xEwnnqNLBjDhfGHmzfTCMrvME/9Y3VVK8yMLqEJxzw5NMSpSkdxZ0y6LexW6h9YuI7Ee5cPQBnlY2bcBezVqMHPcQCxNMxB9cSk1euxnwsehOOMLbpzZQb9RW6k3fAadq1mQIS0T/72ZYgnFP3LXkbKJwH9CQBWKm9Qow9qZY/F7Ys2gud0x19BAER/D/tWT2HYtP+uOb6Cc4U36lG3GgwqdGNm/FfpXF9F58AYqdJ9MfduspIRfZNSIpRTqOI2FXcuwaUynD0Jx2NVf6dF5OIZ1htHBKe1S5uMbpxNh0Ynhneth/NHzUOJCrjLaqwv+wanU6zEV5wJvgnT0PdZsXIX/HWMmLplHg0IKdSg+aNSLaW3LvGmTRO6c2MlynwDsBy1kYjtHDN4eGn1uKH6zpVdhR+lXvy+h5XqwYJwH+T960FZsxEV6VG6MZtvhDPVwJ2rPNHr+copGvYfhVNiQsNu+zJq0jQoTtzGrZYkP+syXhuKU5w+5+DieYsUsyfLh9eb/ib4olRABEfhygS8Ixar3FE8mYP1Cdp58iI6hHgptQyrU8aBB+bzqPYccX8qkHfEMGN6Xgu+fwvuMcsU+OsuyZZt5Gq+NZrKSzJalaNOqEeaG2iS+esS2hUu4HpPAjeNnUOQujmXhvNhVaU7DKkXUrwj4syXl1WMWDuvP1QKdWN7v/QdHqD6hJC7qDtsWLedyrBZ6qbGkmFSgQ7tGFJOnbH1Gq8kqIvC7gCoUd2rkyJnAIJ5EJqn/4uVLJfbu1anq4EzOTEpeRTzgqu9alpyNJ08WTZJfhhCSUpwR471I8h1Kv80hlCxeCL3k57zIYk3z+vUpb5s77ZK/N8vOSW3wN2jOmO61eZO9/28zvAg5weiBPrgMG02ua0uZdTEPs/pWY/3U4SjcRjKotmpWQRYREAER+DqBtMun22BqoMGxLYuYuOE0StUmtfSwrdqc9h2a4ljYBEjg1OJB9F5+EouWE1nbw57rJ7cyepw3D18loqGVgVp9ZtO5pi159F+zff5odmnUxntAzbQCJr8m6MYBFo5eRID6QVtg22gAA1rXoGjetCf9f7zERz3mcuBJ1kyZydnItFcyoZ9H/fT+GpVcKGVlhsbLZywZ3R6fYxEffNzEwoGWrbvS2M3qw7d+pCZzesM45l7Jx8IxHhjpv53BCGPrqFHsTHZlzuTGZH9va8GnfBg4egPW3aYwquGH9/YqEmL4dWZv5my/QXkvH2Y1MiNg3xpmjl/77kFb9dp40bFReYz13s2WqLf+4slJxnSchfXYqXQqXwgIZ3GvvoQ7DGBAy9LoE872caPZZdgU735VeHVqEc2XP2L8xMmUlMdKfF3Hl0+LwH9E4AtD8Zx0V+0nxxbRe+VDRo0bi10eOR2Y7hpQCpxuBOQ9xemmqaSgIiAC30Hg3T3Flm9fZ/QddiKbFAEREAER+C4C//lQ/F3UZKMiIAJ/EJBQLJ1CBETgZxaQUPwzt77UXQREIL0LSChO7y0o5ReBH0RAQvEP0hBSDBEQgX9FQELxv8IuOxUBERCBbyLwWaE4MjKSyZMno60tD576JuqyERH4DwqkpKSgpaWFxkfvH/4PVlWqJAIiIAJ/EJAxUDqFCIiACKRfAaVSia2tLa1atXpXCQ2l6v/KIgIiIAIiIAIiIAIiIAIiIAIiIAI/oYCE4p+w0aXKIiACIiACIiACIiACIiACIiACaQISiqUniIAIiIAIiIAIiIAIiIAIiIAI/LQCEop/2qaXiouACIiACIiACIiACIiACIiACEgolj4gAiIgAiIgAiIgAiIgAiIgAiLw0wpIKP5pm14qLgIiIAIiIAIiIAIiIAIiIAIiIKFY+oAIiIAIiIAIiIAIiIAIiIAIiMBPKyCh+Kdteqm4CIiACIiACIiACIiACIiACIiAhGLpAyIgAiIgAiIgAiIgAiIgAiIgAj+tgITin7bppeIiIAIiIAIiIAIiIAIiIAIiIAISiqUPiIAIiIAIiIAIiIAIiIAIiIAI/LQCEop/2qaXiouACIiACIiACIiACIiACIiACEgolj4gAiIgAiIgAiIgAiIgAiIgAiLw0wpIKP5pm14qLgIiIAIiIAIiIAIiIAIiIAIiIKFY+oAIiIAIiIAIiIAIiIAIiIAIiMBPKyCh+Kdteqm4CIiACIiACIiACIiACIiACIiAhGLpAyIgAiIgAiIgAiIgAiIgAiIgAj+tgITin7bppeIiIAIiIAIiIAIiIAIiIAIiIAISiqUPiIAIiIAIiIAIiIAIiIAIiIAI/LQCfwjFycnJhISE/LQgUnEREAEREAEREAEREAEREAEREIH/rkCmTJkwMTF5V8E/hOJ79+7RqlUr3N3d/7sKUjMREAEREAEREAEREAEREAEREIGfTiAuLo6nT5/i4+Pz/0PxuHHjUP0riwiIgAiIgAiIgAiIgAiIgAiIgAj8VwQiIyOZP3++hOL/SoNKPURABERABERABERABERABERABD5f4PuH4leheE/xYv6eWx+VypRqHk1o3bgltrn1P7/E32zNaHaP6c1IvwS6jZlEx6pF0f7LbT/Hz3sPT4xyU7+BCwQdZeiwETzUcmLSLxOwzfaXG5AVREAEREAEREAEREAEREAEREAEfiCB7x+KY5+wcFQXpu+8RbFy1TDPoqq9gujHt7l6+wl5nTsxY6IXtjl11Swxjy5z6sYz9Z+NCpehfGHjd1zxYbc4diWY1FQlmhkyUsi2AoWM0z6nWpITogg8fY7wBEA3M5bWdpgb65MU85SLV26QksGITBmSCY98hUmBQmR4epFj91MoW6Uqtrn1CAo8y+PoDBS2zE3Y7dvEpOqSt5gNFvmMiI94wIFVkxm3+DRFaraiTQM3Kthm5ayfH9Ea+alWpyo59dSlIOzWZa4ER5GqBL3c1jiVyJNWwMRYbl2/wuOYVIoULULY/etEx6WQJY8lpSzMyfjXqfwH6jpSFBEQAREQAREQAREQAREQARFI/wL/WCietfchI7dcp52NCi2VV5F32TDWk4n74+g6dQ5etQpyZutC5q/cw0vDPGTViePJYy1cO/Wmb2snos/vYOrUaVx8lYsCxrq8Cr9PVPaKjBkxiBq2OXh59wjjxs7nfHAs2XMbExZ0FfK4MnH2OGxf+dOxzwiuRxpQqGgBDDNlpXqbDhgenMQg33j6TZ9LpzIZmdm/GSsDYiliWwoTAwXhD+/wXMOS7tNG46Z3iykjxrH3RgxGuQtS3LIW/QdYM7tvP+5pVWPe6tnYZorCd+lkFqz2JzlXIYy1YnkQmkrFeh3x6l2fvAkPGD+4JyuPPKZIiXIYGyh4cvsC4akF6Dd3GZ0d86b/HiU1EAEREAEREAEREAEREAEREIF0JPAvheI0obB94ynfzYeK3eYwua4Oozr34rxRHRZP6EL2jLFsGt2bdU9LsMxnDEn7pzBw+m4KNBnLqA7lSAm9R7giK4UsrbDIFs/qCQOYvusO7SZtpK97Yc6sHMGu4Fy07tyevFH71KH4Vqol4+YsomEpEzR5zq+D2uP1USj2OZlA7/m+dHfLw9OTPvTvO57HBbqzd/MAwtZ60mzsUar1msL4vjXg9iH6vBeKcwevpkWLMSQ7dGH9vAHkzRjLzuk96bv2IR3GLWB4FQMmDenJqlPRdBi/mn51rbjy6yA8B23GqMMv+I6qnY66jhRVBERABERABERABERABERABNK/wL8YihXc2TSY6oP3Ut1rDl4VHuPZZDx3dDNjmvX9e4xz0W3+bOpkvsv00XPxv/uIF9ExpGbITlnnujTs1JpGBVKYOKQnGy4nMn7tMRpZfNgw0Ve3q0NxlHEt5iyaTkn166c+HYrXni3IqrObqGAICRF3meTVgs2XCuN9ciOGv/3/UMxvXWk49jQNRv7C9PaOaGtCqP8sXNvPI2/bGezqXYLJQz8s580js+jpMQ9lq9n4T2yQ/nuU1EAEREAEREAEREAEREAEREAE0pHAPxaKZ+55wJC152llnabz/K4fk4eOYu+zPIycPYfq2S/i2WIgd6374L/Wk2xakBifgAItMmbMgDIliaSUVBJehnD2yCkePAtkzZytxFYbwMUZtVg4sh9LjofjtWgvHcob8ezWAXzPK6hbvyraD/aoQ/HLnE2Yu3gMVln/PBSvOq3BxO0naFo8Ay/uH2VYl64cVzRkl/8kXq3rR7Mx/lTtqZopdkPjzoczxdkuTqV+lxXkbzeeDcOboKet5MpqT+qNOUytIYuZ38hUPVP8fniXUJyOvi1SVBEQAREQAREQAREQAREQgf+cwD8Wiqdtv/4HPA2tjLj1msuEHm5kTg5l4/R+TNt0CQvXVlQoEMfuRTtRlGvFghm9eHVoNl7TVpPVvjWultmIe3KRjduuUWHwNJZ0c+bpsdV07jubFya2VHcpw6OjPhy5qUfX5avpZnrjs0Ox99FIzApXxq2WLWEnNrH3goLGU39hRrPyxJ5eRMX2c8hSxIE6ro1oWF2XCe9dPm2dMZhF/Trxy8FnOLVug2XGZ/y29RBKm2bMn+mJjVaI+p5iCcX/ue+RVEgEREAEREAEREAEREAERCCdCnz/UJzwguO+mzkcmPZE6d8XE6q2aUh5c1O0NTUAJakKBbf8vNl6Om3d7Hkq0qStMyZaWqBU8PzGARbvOIciFcigh51rC2qVyoWWpiYaylRePb/HrlUbuPsK0MmGvVs9nG3zkBIayMZf95JgaEeDpm6YqZ8SHceV3zaw82YyTnUbUNbkNTP6N2P1mayMWTya12cP8yzFELsq9ahevgC6qjKmKji5dSaHbiWQQTc3dRo5cvXgDqI0i9KgVQPy6itJTU3h8ZltrPG7o376dOYSNenpXgptbS004sLZv2srF5+kUKt1H2xzwLOgI2xbH4CydH161VY/hUwWERABERABERABERABERABERCBf0jg+4fif6giX7ubhMj7TOvfjDVns7PQbx+uub52i/J5ERABERABERABERABERABERCBH11AQvGbFkp6+YxtK6bhf8eQ7hPGUjL7j950Uj4REAEREAEREAEREAEREAEREIGvFfjsUNywYUOcnJy+dn/yeREQAREQAREQAREQAREQAREQARH4YQTi4+NJTk7Gx8fnXZk0lEql8v0S3rt3jxkzZjBnzpwfpuBSEBEQAREQAREQAREQAREQAREQARH4WoHw8HBGjhwpofhrIeXzIiACIiACIiACIiACIiACIiAC6U9AQnH6azMpsQiIgAiIgAiIgAiIgAiIgAiIwDcSkFD8jSBlMyIgAiIgAiIgAiIgAiIgAiIgAulPQEJx+mszKbEIiIAIiIAIiIAIiIAIiIAIiMA3EpBQ/I0gZTMiIAIiIAIiIAIiIAIiIAIiIALpT0BCcfprMymxCIiACIiACIiACIiACIiACIjANxKQUPyNIGUzIiACIiACIiACIiACIiACIiAC6U9AQnH6azMpsQiIgAiIgAiIgAiIgAiIgAiIwDcSkFD8jSBlMyIgAiIgAiIgAiIgAiIgAiIgAulP4BuEYiVKJcTcOczCjYeJTUgF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ZtPWhjKlQ2OulxvB8hHtEpfxSba9+zyIVRliY29DQmS4vu6Js43rnl+RhEVqsLHXfSbqrmcC4W/fEptYCSx13wveLzWX6luaxOdCqP7HjKRvB9ikT4fpu+uiiiM0PII4/cX4sBmaWZPOOrV113Tf/8KJUZhhb5WyW3B02GvilOZYW374Tqp/9MVHExIehYGptd4zZSdqNdGhYUTGJSR9NlhhaRBPRIIh6W3NiIuMIFprgr2+LO+ucSzm9raYGij1k5W++9w0NLPCXBFPpNoIB9uPh/gkeUbrvmtZolRqiQkLIVz/ZfnDplSaYutgk+pcAfr3T4wWaxvd9fjwGt33jdAYsEv6/vfhLyrCX4eQYKj7vmKJJjaCyHglNta671P/T2s0pn5byL+KwD8q8PeF4n+0mHJwERCB1AR0E0N1GLQVn/2nqf+VS7z+e0VjOb7USx+Kt18OoGDSF9Z/b3n/nSULvrmPUf2Gc/hpJAYKQ3Tf5LOUa8AQbx8q5zH7ZMbjf2ct/selUsWwa4q7PhTf3jH6sz86/o9LKqcXgT8t8ObeKSYP7svmO1HoZo7QEkP6Qs3wGt6fGoUd5Fnxp2XlhSIgAt+SgITib+lqSVlF4CMB3YQ0dx69JesPxRLXxv0uNt1azI+4+1RFwRJ59EupyPbnBKLfPObW/aDEHjiYkLd4cRzer9v55475n3qVVk3Is3vcDTGmZKHsKYbV/KccpLLfvUB8WBBX7zwlTtfUr1CQo3B5/VrcsomACIjAf0VAQvF/5UpLPUVABERABERABERABERABERABD4RkFAsN4UIiIAIiIAIiIAIiIAIiIAIiMB/VkBC8X/20kvFRUAEREAEREAEREAEREAEREAEJBTLPSACIiACIiACIiACIiACIiACIvCfFZBQ/J+99FJxERABERABERABERABERABERABCcVyD4iACIiACIiACIiACIiACIiACPxnBSQU/2cvvVRcBERABERABERABERABERABERAQrHcAyIgAiIgAiIgAiIgAiIgAiIgAv9ZgS8KxY8fP6ZLly4ULVr0PwslFRcBERABERABERABERABERABEfj+BOLi4jA3N2fcuHHvK6fQarXa76+qUiMREAEREAEREAEREAEREAEREAERSFtAQnHaRrKHCIiACIiACIiACIiACIiACIjAdyogofg7vbBSLREQAREQAREQAREQAREQAREQgbQFJBSnbSR7iIAIiIAIiIAIiIAIiIAIiIAIfKcCEoq/0wsr1RIBERABERABERABERABERABEUhbQEJx2kayhwiIgAiIgAiIgAiIgAiIgAiIwHcqIKH4O72wUi0REAEREAEREAEREAEREAEREIG0BSQUp20ke4iACIiACIiACIiACIiACIiACHynAhKKv9MLK9USAREQAREQAREQAREQAREQARFIW0BCcdpGsocIiIAIiIAIiIAIiIAIiIAIiMB3KiCh+Du9sFItERABERABERABERABERABERCBtAUkFKdtJHuIgAiIgAiIgAiIgAiIgAiIgAh8pwISir/TCyvVEgEREAEREAEREAEREAEREAERSFtAQnHaRrKHCIiACIiACIiACIiACIiACIjAdyogofg7vbBSLREQAREQAREQAREQAREQAREQgbQFJBSnbSR7iIAIiIAIiIAIiIAIiIAIiIAIfKcCEoq/0wsr1RIBERABERABERABERABERABEUhbQEJx2kayhwiIgAiIgAiIgAiIgAiIgAiIwHcqIKH4O72wUi0REAEREAEREAEREAEREAEREIG0BSQUp20ke4iACIiACIiACIiACIiACIiACHynAp+E4qioKPbv3/+dVleqJQIiIAIiIAIiIAIiIAIiIAIi8F8WyJ49O6VKlXpP8EkovnfvHj179sTd3f2/7CR1FwEREAEREAEREAEREAEREAER+M4EwsLCOHr0KEuXLv18KPbz80P3n2wiIAIiIAIiIAIiIAIiIAIiIAIi8L0IvH79mpkzZ/7zoTgu4hUXD29h2+HrxCbpOZZthHvdMtjYWGGo/F+RqokJC+fqiQtkq1eTjOoELu2cx/LD96nu6kejolb/q4LJeUVABERABERABERABERABERABP5hgX8+FGu1vLp5jKmjBrL61GuMjIxQKnS10qKKV2GTpSL9J42mdbkcGGo1xCUkgMIAA4UWlVoDKDA0NsYw8UX612lUKuJVav3/KQ2MMDI0QKEArUZFfLwKDAxRalSotWBgZIyREhISElBrtPrXKBQGGJkYodBqCHl0hsmD+nE87BfmbB1KQUMlD8/tZP9vzylRx5kKucwTz6pR64+ReAglRsZGGCSVSaOKJ16lQWlopD+vSreTQomRkTEG/7Ow/w/fOXJ4ERABERABERABERABERABEfgOBP7xUKwKD2L+CHembbtNGecRjO7RijzpTYEQji6bgZfPEp5lrs/uvZMpFHyEhq5DeKzORKlMao5fuI1K40Cdzl0Z0teNnJbw4vpeZo2bzqYT14lWQ9ayDfEcOIQWP2bh+cl5NGk3jpgfypH16RmuhzsyaMUqyofswGfsUq48D9VfMkv7UvQc503rSjb4/VKDzUHvrmR+vNZMJ8thH3oGnKXrgvN41UpPQuxDlo8Yx+I9ewgKB8yz07idE56ebuSyhHMBXWjpv4/8VZpi/3w/p+9GYp4uF+4+s+hWrzBmht/BnSJVEAEREAEREAEREAEREAEREIHvUOAfD8Whj8/i1akVh6IasfXkdAoavGvxBU1cOMuHNWPkhlcM23AMd7tT+lB8K8IBj5GT6FLZgR3zvRm18hzVu89hvLMtfWu35Hz6RsydOYRiJk+Z7NWf7a/yMXH2FPI+XaoPxS8ty7DywArK2CrRxkewf90cLkUVxblFYS6vn4b3/P3Y/NiW+RO9sX68h4H9evPYzJn5upZipYY9k5yThWIj1g/qyKBdL2nTfyJerYryYPcCeoxaQeZ6/Zjs7cKLVYmhOEu5jiyYNYz0z9fSsrkfb0u3Z8tML/I4mH2Ht45USQREQAREQAREQAQyibPzAAAgAElEQVREQAREQAS+fYF/PBS/vr+f/q3dOWPail3HJ5A7mZkmPpK1vq3wWvWAAatP09NRF4q9iMxWl+lTRlMsgxLVjS00cBuJ8oe2THPOSBMXX+INzLG1ssBAqSE2IpRws1wMHD+HRuYHaN5uHBHV+nN5SU8MFQpUsREcXeXPtFWHCFXYkS+HPZdPnENTvDFLpvqR8c0x+vfuxkOzzizZPZx8qjh2TOj4IRTn/53WroN4YluBqdOnUy6rAYRdol/r7uylIDOmTcX62CB9KG7ou42ZzsWA33Et2IJDeRuxd4EvBTJZfvt3itRABERABERABERABERABERABL5DgX88FMe+ucuUAS4sPh5B0+FT6de4AplsTSE+jEuntuDbcxS/KSuw9tB8yoUe07cUh2SswfSp4ymd2ZCoS4E09RiLWanOTHNNT5O23lhX7MCY3m1xtEwasKs0wt4xE/FXl9Gs3TiMW47m2IT2KBQKnp1ZSnunkbws3ZntY13IqL5Bu1Z9eZK7zpeF4iI3cXXux2XTkkybPp3KuUzh1Wm6tuvNGdMSzJg2BbOD/fShuMnonUzrUFhC8Xf4RpEqiYAIiIAIiIAIiIAIiIAIfJ8C/3goRpPArcOr8PWfyMknCnLlzoODtQkkRHD35j1ijHLRcqgPw1qWx+ThPn0ovv7KlEZunrQtm479a2ay8uhzWvssYWhjS8a1b8uaO+Z0GjyYmhkj2bh1J28si+HRwx3Hh8v13aeTh+Ln51bi5OzNk6yNmTu2OY82L2Ni4GFMSjXTh+LcsRcZ2LcHZ98WY6C/F9WLZeH8HPdk3actODyrDz1nnKJ0mz50b1iIBwcDmbLyJBW7jWVEl1+4vzSx+7SE4u/zTSK1EgEREAEREAEREAEREAER+H4F/vlQnGT35u5ptu/cyratZ0ic7goy/tiEXq3qUrRoPiyNgHt79KH4uWkhGpSw59SFGyRoHKnf1RXnxrXQzc8VFnSBVbMWsOPM7cSlnbJXZMyA7pQukpnQS4H07B+AUR1PVg5sqG8pVsWFc2TlOOauP01IvBUlazcg/fNdHH1TEG/fgVTObMDh1ROYtPYUMQkZaDtiJHlvzmPUusu0HrWRrpXsUCW85tT69azYvp27L2PBIifNO7anVaMaOJjClbXD6TP/BDU95zO0UT7gJkPr9uF09uosGtWLXBksvt87SGomAiIgAiIgAiIgAiIgAiIgAt+wwP9bKP4io6RQHJZZ1316MiUzftGrZCcREAEREAEREAEREAEREAEREAER+FMC/7JQvJcm7kMJy/QzUyZPlFD8py6pvEgEREAEREAEREAEREAEREAEROBLBf5dofhLSy37iYAIiIAIiIAIiIAIiIAIiIAIiMDfIPDFobh58+bUqFHjbzilHEIEREAEREAEREAEREAEREAEREAE/h0C0dHRxMTEsHTp0vcFUmi1Wm3y4t27d49JkyYxbdq0f0eppRQiIAIiIAIiIAIiIAIiIAIiIAIi8DcIBAcHM3z4cAnFf4OlHEIEREAEREAEREAEREAEREAEROAbE5BQ/I1dMCmuCIiACIiACIiACIiACIiACIjA3ycgofjvs5QjiYAIiIAIiIAIiIAIiIAIiIAIfGMCEoq/sQsmxRUBERABERABERABERABERABEfj7BP7WUJx8ei6F4qNCaiHF7F1Jf36/n1aLNvQ5vz8KJ3eJglj/fXX8nx4pxZxlCgUfs3xaOC0pHdN+xf+0gv/gybXqBF49vEuUbRZy2Fuh/OSm+oKT6+6rZLsp/swxvuA0sosIiIAIiIAIiIAIiIAIiMC3KfA3hmIl7vkMOV9Szeo5agqlTwkSd19Br6GGhNtoyZNeS8YiGto21pLePHG/6FfX2LP9NLbFqvFzmTwfXvz6Fss27+NVWByQlVZ9WpLdyOCb0Y5584RBTepiN2gFIxuWRAk8PruRdcce6Otgl6UE9ZvUJKPZuyppuXdsHi5t+pJ+0AE2eVb+Zur6xwWNQLF7N4pHUWgbtEKb1SLlrlFPUa7bgeJNJJAFTa8WaE2MUCfEc+/0Xo5cfkHxhi0ol93uqy00T07Tc/AIgi2K0sipJ05Vcn31MeQFIiACIiACIiACIiACIiAC36/A3xiKISoMVAZgaQ4GuvSXbNsxzJApL7Usn68m68eZNuo12zZtQpG/KjXL5sdMmdg6+vzCJnynbKVCV28aFU3Pk1OLGTnrIu39p9K4RAYMv4HrkiIU18nLobmDmXTKklHjvMhrDWFB9wlWWVOiRD6M9fXRok6IIyoqBqWpJZamRt9ALf+4iIpzyzFYdhfND3EYzj+Kes421JUyvH+BYvcCDNceRNNmOOpymUF3VW0t4V2LrkbN09uH2X38LZXq1eOHLJZf5XF6alOG3m/FmqmtcTT86Kb8qiPJziIgAiIgAiIgAiIgAiIgAt+jwF8PxVq4f9qANTvg/g0l8QXVjPfWkDmpBfjaUQW33ig4Mt+A01ZaerXTYGGgJVcRLUXz6CJQAndO7uLYY1PqN6tJRuN3iTmaKW2rcb2kD5P718dG/88qVvWtxRqjTizxasTBGf3YHlmE/AZ3iTcw59mNWBqOGES9EjkwjQ3ltyNrmLXhFo6OFkQFPSFrYw+cfqlABotIji72Z8ZR+KWwIXdfqYl5cxeD0i6MdKmJnVEM108dYduBc0So1YQ/vQw/dmdoxxpkMgphzQQvdoYWprBlECEaM0IfBVOnrx8NS2fCiGjunj5L4LZ1xCjsUMWEc2TTYWrPXMHIatZM7NWJbcoGLB7bmwKO75uHk+6tNxxdsoZ9V2/w24WzVBi0Be96Wd7fd8/Ob2bxjvPEJIBaFcyJAzeo0mscIzpUxtQwjrsnDrJw6QriM+RGHRuKZcaadO9alyzWpv+7ezfkORg7wO1lGLsuRD1r64dQHHMLo/Y9UfddiaaK42fKGM/R1YsJylSJRlWKYvkVv4acmNQQ32euBE5piv3/TkHOLAIiIAIiIAIiIAIiIAIi8C8V+OuhOFnF9ow2ZtIjNYunqcme1EM26KaCF1EKdowx4KCtBr8eGqwUkD6rlqwZwEAVzK87tvHcuhItfy6U7Gi/075YFwr5LmVo00L6bse67cyibvTalY7A6T05OL4Vw2//yOHFPhTKYsaVLWMYsjyacfP8sby5kN6zfmfgqFH8VCA9Ma8u0qV1D8oPXUm3mhnYP7UfPaYGM+fALKrkzkbo9bX4zL+P59CeFHY0JOhZGHaZHTA3NCDk4V6cnSbQcuwSOpQ0JGBwZ6ZcK8SaFSMolsWWg34N8H9ei9UTe6G9HohH3/V0W7WI+jntSdl9ugghT84yZ/gsLoZHExqfnV6D2lOiQGFyOlq9ryMvfqNXlw4YdtzJ1JY5Pr11ol+zbloPNj6vi79/O/JYGRN9YxvOnstoMW4uTUtmQPPyN3y6D4WWYxjfpuRnb7/I4EdcvvWAOFXKUd+m6XNQoWh67l2+zuM3MSmPoTAmb8lKZLP5wjv70qJPQ/HlJRi7rELTqjHa8Bcool6DfTHUrs5os6ZsEQ46s4Et10xp06IW6axNvuykCeFsGt6cFWaDWeZT87sZp/5llZe9REAEREAEREAEREAEREAEvkTgHw/FiYVQsKyLIRvSa1jhr8Y2eckigziwbTthWWrQvGq+ZH95Qp8qjTHuPJdRncrxrq3z0MQWDL9ejsCxndgzphnr7Qaxe2RDfXftFzeX06bjDkYsn4tilwfdAyOpU70k5kagm/Dq/sUrlHQfQe/mBTk6tR+9j+Tl9tbBnzglRIVwZf8iFh57jZ2ZAaq4YPZsvUzHGUvoW9WWhYM7s9G6C/vGNNW/9sSUlvS7Uob10/rwdNsIXFcZcWmbH2bGBh+F4sQxxboW7zdPbnP9ZhAbZvXmiFEbtgQMIpd9UsvxZ0KxOj6EAwGjWfYwK+OH900KpQlcWu1Dp7FHqdqoGla6U6jjeHrnGkbVBrCwV43P3gsJsZGEhkeh+WgmNKWxBQ52JkSEhBEdr/7oGEos7RywSOzznfb2R6G400ZU8xejKZsBIh9j4OWMUtmVhOltUhzzxZ0dbDwYTas29XGw/WhMcipnf31xM1M3X8HC0oJyTd2pkf97mbotbWrZQwREQAREQAREQAREQARE4MsF/vehmFDO793Otbh8NGlUnuQNjzv9mjDjaUVmjetLPnsj4sLv4NvZA5MW4xhSPxfLvZp8CMXaWC6u9GbAflvmTh9M7El/es97y7S5oyiZ/eNAFMGePwzFGu4dWYBLr8X0CNxL68IWvLx7DI9WQ6k4Jq1Q3JfQwxPpNPEea3bNp4Clmru/rqez8ySqzlzKiLo/EBEVh5WlFYYGieOmT6/vT1efl8w+MJvKmZNq/4ehOJ5La6Yw4bgKL59+FHNM6qOuG399ciEdB++i/9Jl1Mpj9VXjrWPDXvPkxSsS1ClTsZFVevJls+Ll4yDeRManvKsUhjjmyE+6D0X4/F2XWiiOPodR3cFoRq1GXTkjqN5i4OeCUuVMwrhmKY53b+9y9ofkpHXDSthZfOFEa3FvWe3Vgs3pR7BkaDW+bjTyl7+JZE8REAEREAEREAEREAEREIFvV+Avh2KtBk5vMmDHJXh8wYDfIjT8XElLoeJaWrfX8G6+4NW9DdmSTkOAjyZlSzEQcusEG399xI/1G1A0o/X7ZYsiX99h++xpbH9hSC57S4KfBlOmaRfaNCmLTcwbFgxqwvjfM9Oqcl4UMUG8Mv0RJ5fWVM6fjvjwFxzfOpt5u9+QP1diKUwcctG0VTuKZlazf/ZQBh3PzaXAvh9dPQ0hT04wobsPdzKVooCDAQZKOy6f3MvPg+fSo7INy0b0YKu1C1tHNEwMtrOc8LpWkuXj+pJN+Yz1Mwex7F5WilsbYJ4tK89P7SWjqy8DK2fk+L4NHPv9OeqkAPrqVThVO3SlaYUimIffZsmaTdy994DjRw+izF+PSnky8mMzJxqXzsqz8wvo5DoNszK/UCRTUhrNXgEv5zpYmkZyat02lm3ahEmewkkBMCMNPNpTIev/cDTt3YMYLDkEr29gcPgGmip10Wa3Q+M2HG0WUOwLwDDwOFqH7BAeAQ65UPfpiTbdhwnG1KogNizahn35OlQrnouvmXpMxhR/uw8nKbkIiIAIiIAIiIAIiIAI/H8I/OVQ/HcV8vLu5ZwKc6BWg2rktvx4AqpUzpIUipN3n/67yiLH+RcJRLzh2L5tPDIsRP1fyvOuh/mXllBC8ZdKyX4iIAIiIAIiIAIiIAIi8N8U+NeEYm1MJPdPH+D4GxtatKiedldXCcXf/R2riY/m/J4N3DLOT5uaZTEy/MJu08lkVPcO0r7vKDKUbELNRi30Le6yiYAIiIAIiIAIiIAIiIAIiMA7gX9NKNYXSK0iTqXB0MSYNOOPVkNMZBhxSnNszE3eL2srl/b7EdBNjpYQFwtGxhgZGLzvVv81NdQdIzbiLZFxGowtbLAx/9KZwb7mLLKvCIiACIiACIiACIiACIjAtyrw7wrF36qilFsEREAEREAEREAEREAEREAEROCbFJBQ/E1eNim0CIiACIiACIiACIiACIiACIjA3yEgofgrFdVx0Tx7cp+w2A8vzJCzEBks0+zw/UVn0mrjCbr3CCOHrDjYmCWta5zspfGh7F8+nWX73tJrznTKpf+iw6a5k1adwKugR8RbZCKLvUUq3dFDORwwk+WnnuPsM4dqOdM85JftEB3G1TPHuRtlgo2FIRYOP1C6kCMGek4thL9CERQMumWSbR3RZnIg7b71X3ZqEiJQ3HsK5nZoM2fk/TpW8THw+B6KZNcYm8xosyXO4h0TGsyNGzcJjYojIjyajEWrUS5f8sXEvvD8f2I3jTqSRzceEqV7rYExDplz4GhtROiLhzx9E/3+iIY2mSiYLV1SeZ/z6OkbVB+fz9CKHLmyYJIQzpOgZ8QkJO6gNDQmU8782L1bHPyz5VQRGvSYUGV6smWyTv3SRL5k3fyxbLyQkdGrh5B8NfI0CWJfsW3BNDZd0NJnsj8lE6uk3zSqeF48eoRBhqxksDL7U93r0zy/7CACIiACIiACIiACIvDdC0go/spLHHLvDL1at8e4WS9q5nSAoNMEXjejUZsOtK9ZBLOk9Ye/8rAfvuir79OlQjOyDV6KV/MSfDICVh3Lvd9OceluDOUb1COrxZ89U8rXJYS/YKx7Ix5Xnch8j6p8Wo1YHpw/zW9PIilRvQG5bP+e8xL+muPb1/HEsSntamZKedDnxzD0XAwlS6FJr0Vx6jSKqn1QOZX/ayfXxqM4sRHl3mcory5GYdKUhNmj0b4LXA8vYuTmirZWFzTZkiqaoyyaSinjXPTb5+zZvBmjEi1pWNrhr5UprVdrVLy4coDZ69bzLKIANcpnBU0CMRaZqfdTWY6Ob8boG4Xp37ICJoavOLz9N7KUqoWTe0tsQy9z5OQtouIi2LlwEi/ytaJzrcIYmGemas3yqC6spEPnmfzsM5AChkqu7J7JdYeOjB/UiYIZ01qI+jVrurdkuaUnqyc0fr8EW4rqxEdy9fxxrj+zpEaLKiTLtWnVGlRR3Dx/iuvPoEKdmrxbiUz3wqhXDxjUtBEOw1biU7e4hOK0NWUPERABERABERABERCBVAQkFH/lbZEYintScf46upfOpX/17xsH0c7/GXM3zOSnXDao4l6xecYMLoXqGvNMqdisG78UTo+BUoGuRfb5+c3M2PI7BkpwzFOTts5VsYsL48DG+Ry78YQ9KzZjXa4+5QtkwAAHarm2o1qeDPDsPOMW7yA8MgaNIj/dx3Ym+7vyB19hzqpf+aFyaW4e3sLjEFMKVmlIszolsFQqdM1q3Dq6muUHboFWi1W2wrRs1YbcVhGc3L6B3aeu8uuejYRnr06dEtn0LcWlm3nSTBf2Qq4yedIa3mhUGFrkoUPvLuS3fndiLTFvn7Nv0xLOPIgGjQUl6zWhQcVC+h8IXpxdS+BVK0pmDObwqdvEGmWjmXNrfsyRtHbyH4VibTgGg9qhsO+DyqsWqKNQLh6K4dTfUe07jCar4iuvXLLdVSEoD51GU74uBlN+xuBmxU9Dcc+haPwXoy6W+Q/P8/8ZiiOenmJAm94o3Kcwz7nKR79oRBM4rAHztW5sH9MOS2OIDr1Kt6rNSN93KeOcKmKshITI10x0r8edCmMJ6FkDI2XiYR4dWUiHzuvwv7GLKsYGPD0zh3ruB5iwch51ijmm4fz5UBx26wCzAo8SGR2HwrESg/o1TlynPD6ME9u2E+yYm6hft/Ewa02aZHjMikNPqdzWnYYlMsHTk4wM2E1cfBxG5iXoOqIdWXSvjXzJri1rOHLhLkc2b8SsQgMq5c6AAmt+ce1K1TyJP2RoY8O5c+0KbwwzUa547k97Xfz5O0heKQIiIAIiIAIiIAIi8B0JSCj+youZWih+cW0X3ZoNpHLANnoUfM2QDiOx7e7P4KYlSbhzAJcuk/nFZwZdquXj4XZf2vieY8zOHdRyhCe3zxNmmIciue30JdGk1VIM3Nk5AacBZ5l5YwNl3pX/9jaqtu5DZPFuLB3lQZb4i/RyHUl5v8X0qppbH6jXPEhP20o5UcWGsGhwQ9Zr3NgxxQlTIyVptxTD80OTaDrsNGM3b6B6xqQTv/gV53Z+FOk9hR5NChPz4BC+rkOJ7zibea5luL7cjQreJ+ngNYNJnStyabk3PVcp2XF4Evq4+UehOPg4Rs36oR2+FVVtLQYj/CF3KZTzFqEduAxV86/qhPuHV9lg5B+E4k5toUhjNI5WkK0c6rY/g4lhiuN8bSiOj33J9Uu3ifioH7OxVWYKFciD9WeW575/bAoNPc8yf81sKhf4qK014dNQrIkJY37f6iwy6M7RKa5YmCjTCMUTKNixPdkNorl6+gmV3XrQoV4l7EzSeoN8QUsxMZxeNJTuq4zYdmgC+kWxop8TMKQzfvtg9uweLPLvS+bKE6nruJcxx3JxIHAg7353ub5+KJ3HBTPvwkKKJytOWi3FMS8fsnPLRoIti9G2fa3UW7HTqp78XQREQAREQAREQARE4LsXkFD8lZc4tVD88tpuujXvR4V5m/g5eDUuY8/SqVN9THRNwQlRnNy6iDdVJ7PTpyFRdw8zxsePw29z07xhSXJlr0idRqV4NyL1r4Timk5eNJ91BY8ySqKfXWVwZ1es3Jfi3+wHfS0v7QzgxIN4IIF7Z7cT+KwC93b5YW5s8CdDcTxn5vWi/5H8rF/Tn0z6xlstlxZ70Gt7DlZt9iJquTsd19mzZMU4itkpuL3NH+ehl5l9NZBSaYbi3mibd4V7d9F4jERT6DFG1d3Q9lqKqkX+r7xyqe+eaijWaCAhXj+kmZhglPN8MdilQL1uBppk/Xe/NhRrtRrUak0qBVFgoFty6jON33d2+FJrxA1WrplNafu3bFy/lhPHDnEyqhgrZ3lzbXarFC3FulAc0K8GAXTh+DS3LwjFgfhcWkemwwH0HHWO/puW0yD7l/TN/2uheJ25K+s7muHcaSRNF+8g33Ff+m5Pz9bdfok/mgB/NhTrekSo1Wq0CiWGuveibCIgAiIgAiIgAiIgAiKQioCE4q+8LVILxacDPek1NZRJa6fgcG0xzmMuMXv1OLIaf5h8y8TSHnsrU33wUcWEERwSBU9+pWu/8VjUGczcga30Exv9lVBcy3koLWZfpWspPgrFGdg6vA9Tb+Vg/JieZLOI48w6f/rvyMDVvxSKNdwIHIzbGiOWBPqTX9/SGcK24e7MDmlM4KyOPF/eBaf16Vi6YixFbPnyUKx+gmHThihN65IwZQTaLGZwbiFGvdehDtyNJmeSbegDFIcvochaAk3Z3B9dzTgUZ4+iCFaiqVgF7D9t9kw1FH98T5yYirHnXlRL1qEp8r7fOF8biuNjX3Dl/A3Ckya0encaE+usFCmUD+vPDN99e/cgHq36kX/kSkY1Kqp/6Y0t3jjPC2Xh/JFc/ygURwVdxK1lB7J3XczoDuUxMvjC7tMGanZOcGLO/YrMmNKdPFZG+nOp4uN4+vAOkUpbiuTVt/UmbX8tFG+wdGNdexOcOvnSbMkO8h4b+feF4oQYXgY9ISTBlCz5smP1le912V0EREAEREAEREAEROC/ISCh+Cuvc2IodsLWaQj18joSdHofpyK11G7Zl6Y/5oSQGyyYPIML0dmpV7s4+pxjbMsPJYuTI50h949v59g9BY4ZEvvKHluzALsmQ+jVtBzmStBqYlnn60RgcAHa1qmApZEl+cuVJG86K8KfXOHM9Sc8Or2RKYtv022uF3lNM1GxclFsH+7ij0OxA7tGD8F3nzE9hjTEOvg+O7avY2dUFe5tS2wp1sZHcnipL7571QxwqaEf/5yt2E8UzWpJzPNrHL70iJDLmxi9/BbOw7wobp+eCnV/xCLyChN6jOehfRFq1ypK9LMrnDrwgiZjh1M7Vzqu/9lQrMO5sw1D761oa9RCa69CcXQfVPBE3U7fxqzfFAcmY+jsj6LGQBJmD0GbPPlE3cHQuR0GF4xQLVyBukaexBdp1CiuHEMRFINy9VCUTwuh8nBCmzsX2hIFIfohihPXEyduCn6C8sKvaCv3Rt287IcZqnU9gP8fJ9rSqKI4vy2AFVuOY1fZDd08W09Or2b51WwsnDmQ36e3YNz9soxwqoppyDU2nnpAluKN6eH8M47micH2y8YUGxL+5Ff6th2ItcdkJrergFKhIDLkBuuXbuWlQU5cerfhw0jj16zxaM6U19UY6FIOS/2ZjMlRvCyFs5gTfPsyl+494freZcw5YshwfxfS2+WkZmEblnq787lQbP7wIqdvvODR8eVM3xBKj2m9yWWWhapVi2GhVKCJDmHrVE9mPspJ/yblUGBKgR8rkCd94nsrLuw5R3Zv4coLBZXqNaNC/gxf+W6X3UVABERABERABERABP4LAhKK/4+9swCvumz/+OfEujtZjx7N6BJQQBSlRZBGJAWlQ0pKkFCUVKQllRBRVJDuGmPBurt3tp36X+dswIbUBOv9P897XV6vnic/z/M7O9/ffT/3XcldVipyiQi5Sbo+J46uWFKraS1s5OVTMhUTcfUKSYVlrrIGFvhUq4qLtS5tTAERV26TpNC5MYOlS3Vq+NpTKltKi86SfDcshPQ8nUnRFM/a1alibUp+SjhBESmoynvgGtlTt54/FspsboVFY+/XEBdzUBcXEBUehsy5Kt72ZlCcwbWroRSoNcgN7fHxNSUhRUOd6p56AawvynwiQ8JIzClN7ePk3wB/J1OK0iO4HJJUgZREYk2dFrX11jelIpOwW8Fk6ZZkZIGffzWcrUvz+RSkhBOWLqdqNW/M5FCYEUtYdAF+DWuUCqgnRZ9GAylRSMJ1Y8vAzQetpxMVIiYVpCK5HQ12Xmh1wcgqFCXcvYMkV4K2anUwL6Os1UD4VSSp5XMuScDGFW01byhKRHI9sqwnY6haFa3jAwvxvSH+TlF8b0x1ViznbseW/asUa2dv/L0cyYm7TVhC7v3V2/vUpbprRduoRq0kPjyIIgsv/FxtuLftRdnJhIan4dWwNla6/6guISnqDglaRxr6OSORSFCrlGSmJVMkMaWKc/k7zUpSw4MJS8krR94Al6q18HU0JjMmnND4DNQ6V/R7xdKVJtVdSY+7S7rUmRqOUkLDYrCvWgvjnFgiM+XUrO1FSWIIt6LS0ZRva+xIwwb+mNyffBa3Q8LJytcdPkO8atfF3brMI0Ct4Napo5wIzqFV17eo5/FMOaYeOkPiXwUBQUAQEAQEAUFAEBAE/tcJCFH8v77D//b1lYniSMuX6NrcAZmhOVbmRk+8X/tPL0mtLCY/P5+8zDROHz+OWaM+f31Kpn960f+x8TWaJC7/eoPEQgnVa9fB28eFp8YM+4+tUUxXEBAEBAFBQBAQBAQBQeDFEBCi+MVwFL38WQIlRaTERb420YIAACAASURBVJNSUGo5N7LywL+KNdJ/cVykkoJsYuPiKSzRmexlWLv64mEvrJB/9giIdoKAICAICAKCgCAgCAgCgsA/SUCI4n+SvhhbEBAEBAFBQBAQBAQBQUAQEAQEAUHgHyUgRPE/il8MLggIAoKAICAICAKCgCAgCAgCgoAg8E8SEKL4n6T/Z8ZWFXLnwm+cv1NA27698S4N9/s3lELCTp/gQlQuTbr0pWr5WEvPM3qJgsTouyTllbpPG9t4U93Llv9uWlklmUmxxCZllwaXkltQNcAfi3uBoZ6HlWj7DxAoIjbzCjcLbenqXuMP4xcVxnM2NQgPh474mZUPtvdip6rWZHIu9gKWdk2oZWGrCzv3yBKTcpxzhVKaOQbiafa3fTk8ZbEasvPvcC71Njm6GwdSe5q4NcXb6Ak5yEpyuJ56lkKjZjR3sH6xMP+u3jQlxKSdJ1jpRCe3qvqAdeVLoSKR88lBeLq3xtfg33n9QqvVcj12D6G6mI8SY6rZtaS+te1fQjA14yxXisxp5laHyu54TuZlThVIaObUEDvDv2R6olNBQBAQBASB/3ECQhRXcoNzYq4xe/Rwkqq0wN/WHDLDyfLty7DuranrY//YH6vPOoxGHcvUN0bg8t5yRnepxR/+vpfkcHL3enadyGLYkoU0fEHiVJmXypopQ0lsOoNFA5oiq/j7Dcjh9JaN7L6cQp9JS2lR5VlX9JR6ZYG2oqw70q2lIzIDU8xMDEoDbRWnI/3pGJLTx5FeyUW9bAOaeuV+kBWkI7mwD9nOELSOuh/YNmg//ACNzR8mX7nJpt5GtmkH5OvyLqUjLbRCNWEK2up2uoS9SH7fguxQKFpjQyQZ+dCsLeo+b6LV/8bXoCwuQlGsID70DL9czOf1kX3x/MtVfiF3z59n366viZR7YG8EZpa+dOj9Ou6Ks0we9QnygEDcLI0pTIjBtFVfBnRug78tnNj3Bb8G51KQEcWFK/HUbBGIs5kRNg1eY+IrrmyYPYlvoy1oVsMJbX4cwZk1mPjREJr7OSF/ItkUdk35kDW3ZbSu64ZamUdqkim9p4+jQzVX5P/ie+P3lqXIv8WKi2ux83yfd339K65WU8SlsNWsSrbks+bDsTGUoci4xrbon0kzNEZbnEhmSRX61xxMfevyArCQy8GrWBB1GgubEWxt3u2p51OpCmbysVn41lnAu1VqVIhWX77xjbtfsD1HSj/f3tSrIF4S2HvlEy4a9GVpnaZPHe9FVijKO8+0M1/gVXUk3Z29kWOIlbE1ptInvETIj2DFhUkk2S5haf2HuL/Iyf2VfalyOXp1Ouvzm7CvXX99arPyJSX9FDPOfUmXlz6nu9lfIzSfd3k6UZxXlEyBNpQlJ9fg5jeXSf41n7fbR7a/fGsyizI9WNJmDH6VHCEyeAFjE2QsbjqNAJGQvJL0RHVBQBAQBAQBHQEhiit5DkrzFI+h+brdjGrorRdNu1dNYOl5Nzavn0VtJzNAwZ2zZ4jL1yA1MMInoAk+5QIxFSbd4fStOP3IlvZVqdPAC+MSBXdvXyQqJYZVE+bh0OtD+rT0QY4Zfo3q4qMT4LkJnLwSQrFSjUzmSKP29bC6N/+CVC4HxeHk6Upy+C2yFIY4+9aghq/T/R/QWdHXuRSWqm9haudGQK1aWMkVxIQGERIeyY6Vc0irM4xxXQP0WY/carWglpsZKFI4feoGukRNhib2BAQ2wK5cKF9NSSF3gy4RnV6ss/VSpWZtqrqXWrPyE24TnG6Ci1kuYVGpqA1sqdOwNs4WZZaRJ6Rkkh77HIkiELX5SQw/OIx6wz7Ugfb3d0yyfDiy/EDUw/qidfuLfgmVpCCbNhipZCjKZT0g4UcM3vkC9cJ1aAJdoCAa+egh0GElqgF1yp0mJTG3f+HwyUy6vvsXi2KNkhtHlvPBx1d5b80COtWtiplciyI3hyIMKIg6xNDh2xm9dROvV3OkJCeRdR8NYF/ha2xbOgZ361JpG3NxM0PGfM/U3Rvp6FX2tiU/imVjhnCu1mz2TWqHpiiD2d1bEtliIV9OfhOr8rnE/vAsJbJp+BC22Y/it0WvoynOYtO4V9ljO579c/tgbqh7x5DG1RPXyNa1NTTDr2Y9fBx1z1BpyUm8w7WgOEqQYuXkQ+1aPvrUXrqiKikk7Npp4nN0Edos9VGmPezKiU9VMZlpqRRKzXF3sqnkk15a/dLteXyV5cGMhgNwN6ko4gpz77D4/Ar8as3kbVcP/YskpSKVJK0hLqbWaBVhbLo8n9OyPmxv3rW0Q7WC4KgtrIgKwV6WyR1JJ75r99ZT5/ZAFE+mjRHkatSYGvpS37Y0Y3SxMpWwzLvkakEms6GqlR+2hqWbk5Z9g7CiaH6+s5kgeScm+AfoA8TZmvnjZ2Gr/34oLkzgVl4cxbp0ZVJ76jv4Y/qQiHvsJBXJXMqNpkSrQSIxxd+mHg7l3ublha+h591Y5gV+TBO7J79GuT9GmShOsJ7PGE8FCaoSTAzdqW7rUZr7XVcK4zmTW5qeTCoxxseqAU7lDK5JmVeILNF9J0mwNatJDYv735ZoNJncSg3Rv/eSSc3wtaqLwzOGJ1ep07idFq5vi8QET8uquJs8OLO5eeHcKUhDpS7k0t3N/KJ+he/LRLFKrSAy8xppasjKDWLznRP061Aqigvy7hKuMsHVoIio/BRUGOBkXgM/81KLv1KVT0TmTTJ01naJBf7W/jgalS1YqyYzN5wwRSZqpFgae1HV0hmjshdPKl26vew7pKmVIDHD09ofNyPT0lzsz1RuMe3Yx9j6zH5IFKvJKYwhPC+ZYp1njMyRxnbeGJa98FCWZBGWE062WgUY4GxeE1/zB6zyC2MJyYvXtw2L3sTBovp80rZMFKvyicwJJ0mp0Ld1swjAy+zBBuu8NHRntkSrJSl2J1/nuApR/Ex7KSoJAoKAICAIPIqAEMWVPBd/EMVA3LUdDOmxil679zCkppptH3/KWZUv3TrXQxtzlo0/pjN65mQ61HIm7eIOJi3aTrU+k2juDBkpabg3aE9jL1OiQ64RkxbN8jGzcew7hX6t/ZBjinfdWnjamEFeEuduhBN5egdLNqTzVcReGt2bf9hB2vWdiqbuGwzu3ATr4ki277nBO0uX8lp1R4g/z+oTqdRxt0RVlMOhrz5G0XwRa0a1ICUyhLDISLYtm0lq3XeZ+HpdfQ5bl2qBVHMxhaI0Lpy/TcK13czbnsyKw/tp53zvh2kkq6cuItapIe1aVEMRcYGDBy7RaupKhresQvCW4bRfcJNX+rzFW639uX1sLyeKm7HzsxHofxo9MU9x2RiX12A4dHdFUVx8E4OXx6L5cBkaV72BFuw90Xo58ELyOWUlIolJQJIYjHTzIbTjVqFu6QZB2zActgPVZ1+jaeQERZnI5gxAqngL5er+5U5TJUWxVktRdhqZCt2Px3JFIsPM2hoLE6MK6ZnLV1EX5bF6RBt+857Gzhk9MDOsaIJNuLGLIeVEsa7tneNLeOu9syw+upFOfg767p4kin+06sOi/g3RxvzOtK1X6Df2Iwa+VO0p1t5SUbxO9TJrRrVCqQjli5nfUmfKx7zfuQ6G0jR+2XgchZ+LPmd1xMmtbAx1ZuPyqdRysaD41m56zfqW5t2G0NTbmLSUXLzrt6JhVXskhdF8OWsRwcbVeaVjffLvnmD/0XzGrZhJS49S58vC1BiOfr+PFJPa9O3/MpW1xRUXXeWj39dSr/Ycerm6PuQFouDstY/ZpqzLzPq9cH3EywGlIopNl6dzQvo2u1qUiuK78dtYFXKLTjUHo4lbzdeFrdj/rKL4x7FkWbbiZZeO+Mli2R51ioZ+U+jn6YlamU5kdhTJKcdZFpPI1MD5tCpzO07PuU1kcTTHgjdxU9aFSdXqlkZNN/XGx9yG3NzrfHn5c6ROvWnvYANZEaRav0xXp6cQ02pJTDvJ9js/YOb8Go1sjImI38epQleG1B6Oe8Gv7MyMoCTjMgdyCmnj0hpnE7A1CeR1j6bYPMnNVS+KZ3NS60U391bUspXxY9BeTL2GMdKrMeaKGL6LuYWLnZP+cb8etZbrqnZMrvsWXuaFXI7YwoaYFLrWfg1HrYaUjFTqer6GpxkU5dxgfegOcoyb8YqzGynxRzlc6MzEev2oViZAH/9nIZXfI85SbOGmfyEZHb2fvYX2LAx8Fz8jKcFRO9iSUkgLj2Y4yQu5EL6Rn1Uv8127/hQVXWfjzcNILesTaOdEZs4tNgUf560yURwWNJdB0SE0sG9DT4+apKYd5/sUOdPazaa2JpK11zaSYlKLNi6+ZGWe5pdkLSMCx1LH1Jj0qG1MirxJe6/XqGoBibmF1HRtQVVT3ZNVzK7zEzlPXV7zrI9FSQZ3lU709qmL/JnD/D9aFIdHfc2axGRecm+Os0zBmeifSTYJZExAH9xkJVyJPEi6oQt2JhLikn/mSGoxIxoupKkNhCRtY3NkMq09mmBvZExo1Dr2K+rpRbF3SRo/3FzF8RJP+vrWpSD7KoeSY+hSbRavOJtyN2kvWyPCqe3VCk9DIxJjtrEh21mI4kr+nhHVBQFBQBAQBB4QEKK4kqfhUaI4LeQEo/sMpfbiw/SRHmPgx1f4ZO1MXI3kaAoz2bpgLGFNF7BtfAdSfv+CwVN3U7PvaAa91gA7E1ucXW3uW3M16khGNOtOlSmbmdaj3h/dp4HwI0t558OLfHanoihuP2Aq7T8+w/QONhQmBjFl6BAshm9mYfdSd7fspEgyCnWv84u5uO8T5p/y5vK+GZgaylDmJrNo+OvEtvmEde+1eYT7NCT9uow3Z5xn0YG9ZaJYQ8S+WQzaJuPrnfPw07/EV3Dy05HMvNWM774eScqW4fTcYsDXW1bSxNWQsIMLGTj9JmuCdtHgeURx7HcYtp6Jduj7qGrZIcm6i/SH02h7z0PdR/ej/zlLYgiS63eQ5KQiPXcNqnRCNf4NIAvp158juxKDxt4JzB2Q3PkOicVglF8MfC5RnJcUTWLZ3er7HUnkWDm74Ghp+lhRrCzMZkbX6iR1/pr1E9oQefIgB45fJy6pkFbDx9DK/CojHhLFMZc2M7j7Bt758VsG1XJ/qij+jpf4oJUR6778gtqTT7Cot9djXXgfQCgVxZ9nNWD2241RFSdzbMsBLN+YzILB7TE1kKAuyCA6WW8nJjv6KnOnrKbHVzsYWKcKhRfX0+a9rTR/ayxDujbEztoGR0dbDKUaog59TL9VMcxZOQ0/E93LlSg+++gj8l9bwcbhgaVTKCkkOTERhaEN3q6VvGegTuXQtYUcVHfg0yZdqeiHoCEt5RAzbhyjR91lvOL0iLuxylz23pjPV6lZDG+0mDcd7SnKOMXkK9tpVG0SfZ3tOHZ9eiVF8WQcq81nol99jCRw6dokVpc0YnHjPriVvQfJjdvGwJsXmFhOFJfCiOWbczM4ZTCMjY3aVHg40rLOsvTipxTYv8F71dpghc6zww6Dp1iKNRolu0+P5IrtAD6q2RZzKahV6az8dSyFfh8yybshxhLIC11F96gUFgUupNGzvpkosxQHW0xhQ2AT/XzvxCxjUZichS3ew93UiKLiNFKVRfrPMvOPMv9yEJOazaapnQG/h3zGyugE3qw+lDb2TpgYOOCgs6pqCzgTupxV8WbMa9pbb3UuLIhm7dXP8Kq6kPd9n+64qy7JIqFEbycmKyeIVVe30an1cnqoY5lycQU1q3/JEC9rqOA+3Z1zwYtYne7N+jZD9YL6YfdpnSgek6BiYeAsGtkYUlyYyI2ceDxsG5If/SmT44uZUH8gnrqXCfl3WXvzC0zdFzKzpj9JYV8w4u4lWnkOoaeHN2Zya+yMzZHrTcEFbDg5lGOaWgwP6EUNY2usje2wkBs8n6VYHcnHv87C2mcu7/rqXuDqYJ5m1Mn1tK61gr4etpSocskoykV3JZncmyy9sYlaVdfznq+KhT+NxdBnJuP86ur/zpV3n7ZN2MXYm2d5K2Asdax1f1gUHLw8izCbocyr244tP/cmo8oUplRtiqkUhPv0c/69E80FAUFAEBAEhPt0Zc/Ao0Rx2KlVDBp0lImHN+AdtJHBiy7y7sgemJS7NOlcpz2dGnrqLbC5EWfZezIE4k6zZE8ig+fPZWzXJpgZwPOI4o4Dp9NzTRDvNuAhUezJtX1fsXDjUWp36UkVMyVhZ/fzTXQjIn6Y9xyiuISL68Yx8Vcfdu+cjKv+h3khJ5e/y4yzddi5bxJ5W0bwzh47Nm9dRG1rXpwozj+JYbsFqDbuR1O3VLJINw9GttsD1d659+/3UpCP/heZzgL08CVWTQnkFOh8wsHUWOdl+egSsgPDId+g2nwMTdWHqihjkb/dH15ahmpkmRjTV6mspVhDevBlbqUWVBxAZoRbtRr4Otk89r66pjiftWPasd1wKEeWD8faWEZxXjozXmuFfNRmRlaL4t2HRPHlbz+k/9I0vjmwiiZlltVncZ9OOvEJvWffZvbmVXTwsSpDpkWtVqIsUSOVG2NocA9kRfdpUHH9+4UMWprA3qOrcEg5z7LFiwm170SnapYUpEawY/3PDNq/h3freeo5pIWf4+dTd0iPOcv2g+F0mrqC2b0CuLFlEkPWRtN/2OvYljOMuzXsxCt1da4DgFaDsqQEtVaKgbHhs9/316pJSj7AjOuneKf5ItpaVRS9mqIkdlybzXn5QD5v3LLifmm1lOSF8O2tz9ipcGBs45G0t3LBkEwOX/mI9dlGNHP0wFhdxN2U37mlrEJvn5foUKUL1S0euJU+fBD/eKdYw6nL41lT3JAlgYPwLLNU/xlRrH9q88I4mXGHtJw7fB9/g8b+Ixni1wbHJ9z7VmtKWP9Lf+K8JjDTrxmmElCpClj5Sz+yPKcxs2pTTKTPJ4rL3ym+FfYxs6KkrGo5BqniHGuvb8XY8U1qmkvIK77CtruZzG0+hxZ2jnp8d5OOcUNRSFTiAU4W+TCu/nDaWZtxPGgua5KMGVA1sNyZMMTbpgUNbJ4c4ik7/Tybbm8i1rQFre2syC+M4fu7Z3mz3Sq6KoKYeHktXRrspJerIVplDoeuTOarwpbsb/cKB2/MZVteG3a36o1Ub2X/lRnnN/Fa+1L3aZ0o/iDZhMVNJlOrwluYEi4EzWVugoLufq0oHzLBzao1Te3sQKMiMeMSl/KSSUz5jeM5RXSt+hGDfdxKv41KsriecpaoomzORH5PpllzZjQdS3X5swaHe4SluOgyH5xYQe3qSxjk5V76XZB3mhGnvqR5zcX0c8th1fm1JJtWJdCmCnJFNPuijhNYbS3v+6cz5vBiatWcx0ifaki0as7dnMwnWd4sbTsGy4gvGBR8iZd9ulJFd4j0RYaDZR0a2UuZf2Qs1jXmMt6nHsaoCQ2az8QkI2EpruwPGlFfEBAEBAFB4D4BYSmu5GEoFcWjaba29E5x/PldTFu4EruuC5k/qD3E/MzogXNwf38lM3o3KnURvlckJUSeOkGGW2Mae5fecdw4tDHHvCazYWpvvTuhRp3J3O6tiWi+kDXvv4ZlmYuhLnKpLuiJrjzKUiwJP8TjRbEFa/sPZJvsLQ5sHoZJ7CmmjZ3MrsL2xJSJYnVhBhunvs03qp6cXD0EeVmkrfLj/sFSLJFQEH2A/t1WEjhzFeN61kERcZyPhi7Fa846JrfzJfh5RHHZevmD+7QEJLnIRnZH4jce1ZiuUHAX2Yf9kbTegmpwtVLiBeHIB/ZDdsUA1catqNv7Vtztq5swfHUKtByJ8ovZaO9dhLw3rq52TizSJeORKbqiXDgMTEr3QF8SbyBbOB0pr6BaPB5thR+ylRTFlTyHFaurSTy/ncHjvqbx6AVMeac5BnpR3BqD0WWieNg2RunvFFsQfHQXs5etoeGob3j/jdqYll3zfBZRrNWo2TSiGbusR/Dt/EHYmch1h5aIMzv57kw8Lo160q/DPWtbqSjeavee/k6xuqSAzVP7csSwJ1vnDyDhh4X0n36E2T+do6tbDvvmT2be+uuMPlwqiuPP7iDCuQetvQ3Rnc/1k9/iR7uR7J/TnaL4Hxjy5hJqfbCSCW/Vr2DJvRfltzgznp8PHSAsz5KXevWgntOzRWNWqwrYemYkt22HM69Wa72wK19iYnYy6851xjWfTiPLB/dU9Ucu/TTzr64iyqAZcxqNp7rOfKovkope/cpsDl2tpKX42Ex8AkoDbWVnneDTKxvx8V/OCC/n+98NfxTF98bN5ccrU/kqvwGfBg7F7d7VTImE9Lxr3C2yor69N0YUcv7GbJbn1eSTwKF4P+merVbN1ZCPWRydz5hGH9HK3pTwuPV8HBLJ8IYzaGlnqV/581iKE20Wlwbayg9l4flPwG0EE6sFcDV6MTODFHz12mK8imLYGvY5m+KKWKgTxRZyzieF4uJSDw8DY1SaCCb9MJmqdRYw3NOfjLjdjL/1K6/Xn0s/51LReK88HCH64ccyJGINU++cZVSLbXS0zuLg9RWsjQ6l30urGGBYwOeXZhBrNZ3ZdeoQHrmR1SH7yDZ5m33tepMQuYkJEdF80GQJTSTBrLqyksPZKka/vPwpohjyso4w/uxuGteaxjue1R7cq9adLImEu/Hfk2f2OvWsoaQgii8uziLJdgJL6+ku2MTzW1QCAV6B2KEmOuFbplz/nfFt1uhZPanc+5sDfxTFEkk+P5ydzAZ1HZY1fAcfmYKzwatZnevOiiYjsErfRa8rPzCw8QJ62lvoXcmXRvxC2xobeN/fij2/j+e4yRt8HNCJrMR9bAzfT4hRO5a3HY2L4iZzT8zH0HUMcwJaISvntaBb7/dnh3JQ1p7F9buRl3uYHTcOc05TU4ji5/o7IhoLAoKAIPD/m4AQxZXc/8KMWA7uWE9Qyr2GngycOQh/4/KXCrM5uHolF1PL7oeauPPqWz1p6mOPhBQOrvyGi+m5+g48A/vw9usBFX7kFGdEcWDPDoLidQFGHOgw5C3a+jiSdOUAXx2+gkLvi1ZWrGozcnR33AvusnHPMQK6TaCJG5TkJnN0716MAnvRqbYT5Nzh81XfklyiwtiiNq++5sTpqyW827cjhvcsqIVJHNm5m3NRafrOG3Yfz5sNHMgOOsSyXRce+vHoy4j5g9EFoS7ICGXfxq2E5QFW7nTr0YfGPqWiP+XqfnbfNKVXn076+4Rpwb+x51gS3Sb0Q/9z9El3im8fRbbzTMUdMrVCM3gSWhedC2EKku92Ig1J14UOg9f6oQ70KmfxLUD6/XYk0TI0vd5C6/qQm2tuGLI1+6B6W9SvNuO+r/rtY8h2niob1xptz15oyiyXOpdc6f41SIJywNQezZv90dZ4EPzrwWT/TlF8b9Qcjn6xmjOJuuBCumDc3vTu1RNPg2j2bt5D1D0jtHVdxo3vjqNBRStRVtwV9n4fTNu3u+Ovu8OuK8WZ/H5wL7GO7enfRvdSQUtG1AX27LhG81HvUEdfT0N22h2Cb6dh7dOMmh73lFQul/bt5ci1SPRPgtSAgFeH0qdJqbu2Lrz3hV1fc6jsYWrx5lCKr5/EpXM3mrjqzk82h1av5IL+OTLAr1FXerzR8L4ALsnP5Ietn3I54d763ej5fn/q2d97O1HMnTNHOXY5gcYd3qJFrWfz3U1I/IqZIcmMD3yfeuYPu0Yns/r4dEq832eMbx0eTqQTHLODY7kZFc6sgdSCNu6DCCivn9UK7iQc47LSiwG+9Z76LaRzVb4cuZUzirJNlLrwsvfL1DItFZ5pqSfYl3IL3TfGvWIid6G9e0/8y72sORv+JReKSnn62r/Myy4+GCuzuRz/E2fzU1DrGhvWZXzVVn+Ilvy4SSal/sp3KbfROTLLDWrSv3p7yoc1K047w9bMPDpV6YT7E7IwVey/gDvJv/BbWgxlp5mmLqNoZl92ZouT+TX2J24U6aKs2dPCK4D4xLs0cO+Aly4VVU4Qm+JPkavRrVVKfad+tHV8MCuVOpK9wUdIujeo3JveXi/hZvK0CeZxOeo7TuWXuvzXs3mT4oKLOHp2oIGxbi/i2Bf0PbFaLe5WHWlsFsv5LHt6+9bX84yMO8D32fFIcOVV3yaExl7Cy+cVahuakpZ8nCN5BnT2aIPTI15GKIpS+SXqW8Lvhx1w5NUab1JVbohSlcjRsH1E6DfQGH+ndrR39EN3s0BXUlJ+4UBqcOn5kLnxmkdH/MyfHpxQo41lT9D3JFbYHAn1nN6mnY6nqoCgxGOcyEnQO+Q4mbenu0dNjHXbpFESErufo3m64I6m1HZugCw3BEOrzrS0t6akKJUTMd9zu0SJu3VLmhhn83ueAZ18mqH/Ri1O4UTsT1wrKmUtk5jSxKUnTeys9HEuTsQd5VpRHs7mgXQy1fJdbgGdPdrh/IwB05760IkKgoAgIAgIAv+vCAhR/P9qu/+Fi32WQFv/wmk/fUr/hCh++qz+v9TQajMJvXibO5HxmFepSeNmdbF+Jk/RdE6EfU+a6Uv0cPf+wz3urLQT7ErN5BXvN/DRXWYURRAQBAQBQUAQEAQEAUHgP09AiOL//Bb+xxdQmMudK+e4myfD3ESGmUNNGtZwQvZMAubfuPYSUmNCCY1Kp6hEQaHKguavtMDhL89T/G9k8c/NSastJi+7EI3cCEszE6S6y/yiCAKCgCAgCAgCgoAgIAgIAo8gIESxOBaCgCAgCAgCgoAgIAgIAoKAICAICAL/bwkIUfz/duvFwgUBQUAQEAQEAUFAEBAEBAFBQBAQBIQo/q+dAa2a/Kx0svLV2Lm63o8c/NcvQ01+ZgbZhUqsHd0wL4uK/dzjatQUFRZQrC6N6iyVm2BualgxUu9zD/J3dqChpEiBorgsGo5EhpmFGfKn5Hz9O2coxhIEBAFBQBAQBAQBQUAQEAQEgQcEhCiu5GkoSIti98ZVBOeYYKi7J6ouoVHvKXSubY2RofyxqW6fdRiNJo3tS9dj+8o7vFK/Cn9ImFGUxvb5TqJcqAAAIABJREFUY5izNZnV507SuWJGkWcd5g/11Iocftz+JZn+3Xm7dVV9PuWKJY3dU8cx/0gUs789T6+af3qoig3LAm0FS2rSuLolxtZeVPOypcIVXHUJsrVTkYQ4o5k2HI0+MrEucnUCku/2Iw1JBrUl9HoTdQN/HjH5PzdZVSGSvV8gOxOD5t3FaGqbQcIFZF8cLNefFhRFUPsV1P1eAWMlWcmxxCZlkpYYyq1IKd1H9cXzr75TrIuym3Id2Rffg0YDMh80U99Ga/KE/Mt/jopoJQgIAoKAICAICAKCgCAgCPxPERCiuJLbWZqneAzN15XmKSbpCu+P/5A7Hm+zec5AXMzLp2aqZOe6LBbqSEY0606VKZuZ1qPe/SxBle+pci2UucksGv46sW0+Yd17bShLU1y5Tv5M7adGn85GumIq8l3RkJiN5se9qGrpUvpkIxvWHYnvaFTvd4PkE8j7fQgzD6J61ePPzOQPbaRHZiKf+BMQi2ZlMKrOj0jpk3oR+cAxaIfsRN2rfB7kvzP6tAbJlT3IZ+9EPXsNmiZuSI7MxGBxAqqvV6Lxq5hL94XAEZ0IAoKAICAICAKCgCAgCAgC/yMEhCiu5Eb+QRQDkRfWMqD3Hsb+sJW+tcy5dngny9b+glNdfyQZYSTbdWXeuJ74OplREHuZjasXcSKvOjXtQStz4bWhA2jsoOH4vnX8fieOH7cewLLJqzSt5ogMBzoO6UdbX0dIvMzirw4Te/ssP5+zZmf0bhrdm3/YIToO+Bj75u1xleShKsghSenHzE8mUsfODJKvs3LHUdIy8lEVF3D71lXaj9vEuPYOnD+yl6Pngjj94z5yPdrRqV4Vvftyw+7v072hA2QFsXzZTuJiL/NzkBmfH91PO+d7A+dz+psNbD91ExMnF4riosgy8GbC/JkEupoSvHUkPT5PolVzT+yM5ESFxOL66mg+Hd6utIMniWJVEZJvZiE/oEWzoBOywTPRbCsTxZfWYDjhDKqd29E4K+DoTuT7diFJbYFq/xy09xJ0VnJ/S6sXweE1GHx2BdWcMchmD4GJZ/8oipWZSBeNRXalBqrvZqKtYF3/G0VxSQHS2X2QGw6mZGZ3yL+LdNMO5Pt/Qjt8EcpBrXWpWlGkhPPtt9+j9m7PwC71kP9tbz7+1CaIRoKAICAICAKCgCAgCAgCgsDfQkCI4kpifpQoTg/9ndF9BlLz46MMs7/MkGnHmb/7cxrZm6POjmXx6MGkdJzPqoHNiT40l57TzjB6/Re83cIPebECtcQQY8PSHETPYikOP7KUdz68yGd39pYTxQdp9/ZkAsbtY2nf6qhSbjF56LvYj9rMvG41QKkgRynDytQQraaQ4+snMOuEP79tmYCJoYxnsRQn/bqMN2ecZ9GBvfdFceapz+i1KIQFXy2nibMRmpJU9s8axQZVbw4u70PUlmF0+TKfzzas4dVaNoQcWMDguWFsuLGNOk8RxZJfliBfGo1q9TzQBGPQb8p9USz97kPkq4pQbZiIds9WZJ5tUVW5hOHk06h2fofGq5IbW7762e0YLDiAZv4K1E4JyAcPerQovvAthlO3o179JeqAh/3YKymKtRrSgy9zK7Wg4sRlRrhVq4Gvkw2PzVJVlId8RHukAXMpaaNGtucm9O2GducY5AajKJnXCwygpDCBS6dvIXGrS5MazshEmqLnOCSiqSAgCAgCgoAgIAgIAoLA/woBIYoruZOPEsWxV7cyuMeX9Nu3ldqhmxgy/xRdX29VaonTqslJS8C+3Thm9W2MtiiTGz9+w2dHI3EySOV6sg8TPh7NS9XcMZQ+nyjuOHA6PdcE8W4DKEwMYsrQIVgM38zC7n4kB19l3crFpFjWwsZIRdytkxwtbE/MD/Mw/dOiuJizn49i8pna7Ns5ASc9SyUXvhzJhMNebD8yC8WWEbyzx47NWxdR2xrCDi5k4PSbrAnaRYMnieKYXzEYMB5t+8lo6ltBfBDyT7egeX8a6lbtIGkDBmNPoO3cBfWg3mga+MLRGRguL0K1bzmaP+sxrAhD3r0f+PVC81INyApF+tlqeH0x6tcboQ2oht6nXZGMvP+b0HwWqvGdQC596CRVVhRryU+OITGvpGI/EjlWTs44WJrqjL2PLkV5yMa+jCzeB02rTqjffROtqQrpmDeR1Z+B8r0OPF5RV/IBENUFAUFAEBAEBAFBQBAQBASB/zECQhRXckMfFsV5iXfYuHwiJ4q7sHL+uxiF7WXY+O0M3rieN2q76Qx05Yqa7PhYFOYuuFgbQ14SC4Z35bz3+2z5aAC2xjpRnMDEDp2h/+csHNQa00eYBx9nKX68KLbiqyED+Ype7F/3LjaKKDYvnsK8i/6EloliVX4qK8f25LT3RPbO7Ib8EVbER1mKk89+Tv/Jpxn9xWq61nFAmR3Ml6MnEdF2JiuHN+funxXFuclI7saBUqPnJ4m5hnzWGjRzFqNuGojWIQp5+3EwfCkqnXtwXhDyoWOh8yJUw5uWMlemIFs4E2mwHPX0uWjqOlbc7ejjyMeugEa9UU3sDxYyKMlGciscVKXjkhqEbMF8eGsD6q410Hrp7jMXIF0/AdlBY1Qbl6B1f5SvduVFsSIrlUxFWdTqezPVRa+2tsHS1OjxolijRLJvPvKlIaj2f422ihnc2IbB6O9Qf7YKTf1SK3ZJUTq/HfqBTENvunRtjpXssbbnSj4VorogIAgIAoKAICAICAKCgCDw3yUgRHEl9y437iYLJ40j3r4+nlam5MRmE/BOb7o0bkoVayNQ5hJy/RRb1h9A6ehUGijL1J2ub/WiqY81mVFn2fXVryRqlKW6TepMr2FvUd/TXh9pWqvVEn7yG77Ydw4DM3sMZQ/uFCdePsBXhy+TnhDJjZBsarVugJVVbd4b0wP31DOMmLmajtMP6CNDK1LDWfHRbMx6LGB8B1diTn7L1CU/4VTfG0u1JTaOmfwc5ca+T0djYiADjZLkoJ9ZsuYIJnZWSCSS+3eKs4IOsWzneYozIrkSmk21hg2wN/Hj3fmDqUIu5/d/y65D5zBwdUap0uLr15peAzrgbGxAxMG5zPjJivkL38ffEqJ/28DM1WFMP/AJ+gDWTw20VbZBUZeRT16BdtFy1H5lF5pvHEG242fADIlSi7ZOa9QDX+F+PqeSJGQfTUJ6S4563mI0De5fhC7tNOIo8hFLkAT2QzltCFj+IdY3JN9ANnsWDNiKulWZ+Tn8d+SzPkU7eg3qVo8L/11JUVzJc/iH6oosJD9uRPZLJlorKZICQzRDhqCpU+V+VXVRCqf37OVcopQOQ4fRyP75gsI975RFe0FAEBAEBAFBQBAQBAQBQeDfQECI4n/DLvx/nsOziuL/HKO/WRQ/hY9aWUx+bg7nf9pPgmEDenZrhOUfXL7/c5DFhAUBQUAQEAQEAUFAEBAEBIHnJiBE8XMjFB08F4HcdM78sJ+gEjeqVjHFzKEmDWs48d/17C0hNSaU0KhUsjLiiU415o0RvfD4q/MUP2UTFJnJ3I1NRGbtireXM88VnPu5Nlw0FgQEAUFAEBAEBAFBQBAQBP5dBIQo/nfth5iNICAICAKCgCAgCAgCgoAgIAgIAoLA30hAiOK/EbYYShAQBAQBQUAQEAQEAUFAEBAEBAFB4N9FQIjif9d+iNkIAoKAICAICAKCgCAgCAgCgoAgIAj8jQRegCjWkHjnF3ZtO8iNFBdGzHiXJt52+kjKoggCgoAgIAgIAoKAICAICAKCgCAgCAgC/2YCL0AU31teAT8vGMXKtNZsWDwUVxHJ59+872JugoAgIAgIAoKAICAICAKCgCAgCAgCwAsUxRD89VjGnfXnq5Xj8DATfAUBQUAQEAQEAUFAEBAEBAFBQBAQBASBfzeBFyqK72ybwOjjbmxcPREfS+m/e+VidoKAICAICAKCgCAgCAgCgoAgIAgIAv/vCbxQUZyXfpMDm48Ska/AM7AXfbvUwvT/PWIBQBAQBAQBQUAQEAQEAUFAEBAEBAFB4N9K4IWK4oifFzJoRQafbZhHPTfhP/1v3XQxL0FAEBAEBAFBQBAQBAQBQUAQEAQEgVICL1QUizvF4lgJAoKAICAICAKCgCAgCAgCgoAgIAj8lwgIUfxf2i0xV0FAEBAEBAFBQBAQBAQBQUAQEAQEgRdK4AWIYi25qXe5ef0Gh9dvx7DnNCb3CsRc9kLnKToTBAQBQUAQEAQEAUFAEBAEBAFBQBAQBF44gRciivPSo7lzOxaNqSsBjf0Rt4lf+D6JDgUBQUAQEAQEAUFAEBAEBAFBQBAQBP4CAi9AFP8FsxJdCgKCgCAgCAgCgoAgIAgIAoKAICAICAJ/AwEhiv8GyGIIQUAQEAQEAUFAEBAEBAFBQBAQBASBfyeBv1wUK/Php70yzoaD1gg69tTQuqaWv+vKsVarJP76cfYcPI2xT2f6DmiJbSX3okQVzt7Qq9T36EQNC6uHWmu5Ffktd2S16OIWgLlMixYo/aeuSEr/J7nXTItW+9CnDz58wswU3E36mfMKF7r5NMbiMTWz80I4GnsMrUVn+nlUrVBLN+69InmmMR80L53z49ZUSaD/QPWcjAt8n5ZCa4/X8XqG5Nl/XC9UZJbAgaDvyDVuzBuegVgZ/AOLEkMKAoKAICAICAKCgCAgCAgCgsBzE/jLRfG9GZYUShnRVk712So+7KpB/txTf7YOkq5tZcR7exmwbh296zo/W6MKtQq4cn0Ba4oasaR+DxyMHuoi5wzvXdhO5zrzeN3ZHopTOBn3M9cUWfqK0cmXqFJlAkN862NjUExc+jG2hFzHzMoGsm9yXF2HJQ0GUMvS+ilzy+HXm3NYm12H1a0H87iV5OSF8mPcT2gtOtG3in+FPoODFzAjTsrylhPwMTN5dhYFd/kybCMJRbbYG2uJz0zFu8pQRlet+ex9/MM1EyI2MDYsmA+arqCFzZMnU1AUwZ7rG7kmN8PbSPcSRIuj1Ut086hd7r58At/dPkiecSNe92gsRPE/vL9ieEFAEBAEBAFBQBAQBAQBQeDPEnhhojjstJSzIaACqjTS8Eq9ilN6kiiOvSTll5ug1oJDHS3dAh9YNMmSsP8nCZl5pf11GaTBtRKKOub4YkZ+mc4nXy6jtmPlMWWn/sSsGwd4rf5nvGz/0MDKLH64PoufpH2Z06Al1vetwQ/GSYr8kvFhCUxrMpP6Nkao1EUotXJM5AagLmbF8W7ctZ3AwnqvPEVY3RPF1ZkSUJf4rAQ0MgcCHZvgZqJT6grCk09zvTBXP7i7ZVua2dsBGrLy73AxLYTQxB/4LlNCT78OOBgZgNyXN93rIJdKHw9GEcn6y7OIsZ7FnFpVMZBAVspxpl/9mpYB63nbIY/TaWHYG3sRX3CdLI0EF4uGNLFzx0DfrYacgjAupN4mRwuGBp60dqqLjWGpafVO4nEKTP0xVYRyW6HbZFuae7bCTaZjrSIl9wYX06Mp0lWWufOya32sDAyBPC7GXcDa1IPk/FBS1CWYGgXQxdX/vkVXURDD2fTrZKpVZKWd5kC6hpnNVz1VFF+4PI5FOb580mQs/ua6RagoUmkwlBsi1ahIyLjIxbwkVMhwMKtLE3tvTMpcHwqKIrmQdI2MckfY1MCTJk6NsNdNmyJiUs9zMT9Dv35H8+a0cXSp/MEULQQBQUAQEAQEAUFAEBAEBAFB4IUQeG5RrNXA4ZUGbAjTMmesCptCCatXyzHuombuWxr0OgB4pCjWwsU9ciatkzBvlRIPM4i/IcWhnYbqVpARIWXhRzKsOqsY0FxL3DkZK/ZK+GCVipZVnm39zyOKVao0DtxYwgXZKyyu1/Eh67aahKSDzLtxnqGt5xFoWt6EnMnlBJ0wyuFyxG+YVBnEMK+GWD6sPYsSmfrLIJTu05hTqx0WTxT7paJ4UVwur3v1o6OrH1FRm9ie68TS5sNxNZSRV5ROTl4YX934lHz7OSytV1dv5SxR5ZFZnMud8DUsT5IyvdEQPHRCWmqOq4kV0ie4UqcmHmbC5a283XIXXWzLVL8mmo1npnHVfAwrPFSMPLuIPIsODK3ZBU9tPNtu78DLcwEjfN3JyDzI7OtnaV6tDy3NTbkesZO9+W6sbj0cncF2w6/t2VXiS5cqb9PH055fbq3md3kHFjTuhY0yjN/jk/B08MWsJJMjd9ZxRtqadc36YEI00w8P4LZhM/pXG0IzkzhW3diEj88a3vO1IyZpL6tDb9GyWh8aW1iSHPst86PjmNxs5VNFcVzMNuYG78XAqgdveFYjwLY2riZlPtdaDYqSLDKVCo5emsRZ414sadgdh7KDrlLnk1mUTYlWQ07WOVYHfUfdanMZ6lUVA20uP4es5ECOHaPqdMNWEc1Xt3ZiVmUYo/3rY/xsR1rUEgQEAUFAEBAEBAFBQBAQBASBF0jguUWxKl9Kr6Yyqo1U07GmFp1sivpRzrq7WrZsVlHd8smi+NZPcmZ9JMHpDTV9ArVYemhp5Ffa5uQqA6b9quX9EWrs9d6+UlZNkFJvporpvbQ87MlcnosiO4HgW6EEnTtChHE7xr7XFYdK3vuMS9rC9JvhjGv2AY0fcm9WKlNYf3YqKdbDmBnQHENpeTNxATFZseSjJTb+Jw7lFPBWrZG0tLHT89FZT/MUN9lxdSU/KfyZ1GACgbam6DRzYX4kNwvSypYiw9rUEx8LBwwpFcVrMvz4tNVoPOWQkXaKGRe30LXVp3S1LLtlXBDGioszSbaZwRK9KH5Q/oz7dGz8Xj68fJAxnb+htdG9NSbz7blJHDMYwEpvIyaeX0PDGksZ4eOFjEyOXZ/DTkUH1jVrysFzU/hO24J3fQP0L0iUmZdYEfEb/Rruo6eLThR35ardSBbU7oqdDAoK40lWG+Bm4YSxRkVqTgiRJQX6RcQkHGBbqiGLO82jlk4UHxmDkd9sJvkHYiqNZuPpqVwxm8CX9eux8/QIzlsMYE5AB2ykUBn3aTRKMgsTiE0/xzdx51BpFBhadGJSza44Gz84dftPvcNh+RsVRPE92oq8UNZd+5wCm7eZULsJphIJOQVnmXbiM/z9+9PUyl5/FmIjvmZHSS2WNR6Ln8hl9gK/2kRXgoAgIAgIAoKAICAICAKCwLMReH5RnCejW0Mptceq6VBTqxd2umJmA7UCtFiUCdEnuU+n35VwKwYiz8vY9rOEzhPUfNBNw++fGDD5lJYP74tinQsteFTV4uOq/7+PLYrseG7fDCXo/A9EmbzEmJGvVk4Uq+L44tRsUp3e44PqgVg8ZOVNiPiCiVHpTGk0mQbWj7fxKYri+OTEVMzqzGCCa009n6Ss46y+tp5EeUtmNxiGr/mDyE86UXyjILWcKPbCt5wofnCnWEtiyjGmXfqWt1uv5uW/SBSXZJ5l8oVFVK22k1E+5vp5qfKuMf/8Esx9FjPJOoYRF9bSvOanDPJyAU0Se67M5qi6B182bcC+sx9whNaMKBPFuvYS5HhaNsLFRCeK3+C282jm1OzIw7eqg0JWsSwhgfY+XfAzNS4VxSkyFnZeSB2dKP7hfayqz2G8Tz2MKS+Kffjyt7GEO4zko9ptsUJJaNgaJt+NfiZLccVDpSQjfg+Drx7gtYAlDPf2uf/x40SxsjiaXdfWEG/1JmP9mmNe9gxkF5xh8m8rqeE/kCbWpaJYV4zlzlS18sKsEtcCnu3xFrUEAUFAEBAEBAFBQBAQBAQBQeBpBJ5bFGvVsHWaAVvytHyic58u03emtuBoCWolpCdDbr6UaW/J8R2nYkQHDbZ2YGME185KSTPUUtVZC/lSVuvcpfupmNZDS9oVKbPmy/DuXeo+rSsyQ7BzANNntPr+OfdpFWF3P2dBbCEfNptOnYdiUqnzQlh6aSHyKjMY71/tvou4bn5qtYLMYp37bOl8g6K3cCzLhH51htLQ3JiIhIMsurWWYutefFi9PQ5GOkFthJ2JDcZPuttLLr/fms/KdHdmB/bCTlPCT8HLuSPryJx6r2IuUZFZnIWi4C6bbiwnzWo0U2vWxFhuj51RqW9vXPK3zL/+O+3rv0dLc1uQmOFiYvlE92ko4MrtlXyaJmFYtV5UNYUrd7fzS3E9Zjd/A7uMkww//zm1/WbQ092elKxf2BIaTJd6M3jZzpKEqE1MiwqnU/W+tLJy1L8UkEhMcTS11rujP0kUH7/6Hmuz3RlfZzAOhPLD7S0cK3Dhky5PE8VNCLqzjE9TlAyu3Qcr9RVOhP7KD3kmzGr+6VPdp29E7aXAtDme+ncACsJi9rE1OZcBAVNoa29GXlEqeRoNP16ayK+yl5kS0AkXEytsjMygOJFDNz7haHEg4xu00Qt9icQAa0NbDDW5HLg2nx81vrwf8Aa2erd1CSYGNlgbGt9/ofS0h1Z8LggIAoKAICAICAKCgCAgCAgCL47Ac4vie1MJPS3lTHBpoC2dCcy7qZaOAVoU2RJOHJYQV1hu0sbQoKWGRj5QnAW//SYlNr30c9/mGtrXLlc3S8K+HyVklAXaMrGFNh01eDycGekxTCovirXk511n+aV1eNSYyWAX9wo9a7X5XAhdzYZkF5a0HYz9Q+MWFcZzLu0yqSo9CUxN6vKaa1kUaFU+IWkXuFWYhaZ8O6kTrdwDcTV4kkM45Ofc5nhGCMV6wS3FybIxzRyqlLqRF6dyLuUSsUpFhRm5W75EC4d7SaiUJGdd50JWDEW6Lgx86eFe98mBtsp6S0u/wJmcOIqRYmdakyYO1UvvQGecZOi55Vg6dqOpnRUGcgcaOzShiuk967mG7IJQLqTcJrss+JSBgQ8dPRro00oFJ/xIlkktGtmWraPc7JWqVM7H/U6iBozkDtQycSG6OIcGVRpjRy4XYs5iaNOIAEt75ORyJ+kCaQZ1aG3vBGoFYcmnuVaUg4WhL03Mrbian0Jtx2a4PBkzxSVZXE76hfjSLQS5N2+418NIJkOjLiE46SduF+tDf5UVKQ4WdWni6Iu2KEIfaCu93AbLZTY0dGiOlz7idxHRKee4UBZoC4khHtaNaWjrUuHlyot7xEVPgoAgIAgIAoKAICAICAKCgCDwJAIvTBT/WzHrUzJ9+AOj1nxB5+pPycWjX4SGlNzz/JqqoZt3U0z1UZAfFGVxBufiTyK3aktz+8pmPP63UnqOeWWcrOg+/RxdiaaCgCAgCAgCgoAgIAgIAoKAICAI/N0E/udFsVZbROjpwxw4eg2rGp3pO6AlQsq+wGNWEMGe2HN4Ob1OY9uyqGovsHvRlSAgCAgCgoAgIAgIAoKAICAICAJ/JYH/eVH8V8ITfQsCgoAgIAgIAoKAICAICAKCgCAgCPy3CQhR/N/ePzF7QUAQEAQEAUFAEBAEBAFBQBAQBASB5yAgRPFzwPtHmmpKSI4KJTKphKqNG2L/lKBRL26OJaTcDSMqXYF3QGOcXlROXZWS7IxUcovV+qnKTexwtjejQtrnF7eIF9KTqqiQ9IwMStSlAc9MbRyxtyiN8C3KIwioioi9e5u4TBPqNK+pD7D2zEVdRHxEKPGZULV+XWz/tvP+zDMUFQUBQUAQEAQEAUFAEBAE/uMEhCiu5AbmJYWwdtFHRMg9sDMxBEUGTm1H0bOlH862ps+dVkejTmL1xAU49JpI75a+/CHzVHEG338+h1X705i9fxdtnSq5gMdUVxVmsnvVXFIDhjH21QBk95Lo3q+fwZGl8/js1zjGfbafLmUBtZ979Nx0Th3aTZhxY9rWs8XQzBE3Rwv02amUWUi/34vkUmjpME410PTshdbjee8uayEnBUloELItW8C9PapRA+Fetyl3kS2djQR3tMZlO1CnG+o+gfppKBX56B6cnKwMrpw9j3WTvrzW0OG5UTytA1VhFncjTrN9zW9o7EzA0Jw6L73J6408ubhjLmvP5OHlbI1UUkyuSQDjB3TC3d2JzFtH+GbPWfI0KtLioykxdcbN3hyJRVUGDOuBTeJpPlm5BZWzF2YSCYW56TTqO5M3GrliZvSkbOC6GedwYs1CfjF+g8lDmz1a8OYmsHHJJDafcWP9iU+o+bSFlv+8MJkdy2bzzRktc7ZuoJnjgw+LcpLZNH8uVn0m8XZjn/t5nyvTvagrCAgCgoAgIAgIAoKAICAICFFcyTOQFXGBsX3G0HzdbkY19IaMMBbPnsjRknZsXjoGb13yZVRkp6SQr9QikcqwsHXE0viBuNCJm+TMAv3IBsZW2NlbINOoyM1MI6cwiimvD8d11KeM6VILAwywtLfFUifOSgpISs9GrdEikZjg4Gb3II2PUkFaVgEm5qYocjMpVkkxtbTB2tLkvlAvzssgLac0ZZPcyAxbWxsMJSryc7LISInns8mDSWg6kyUDmuottWY2TtiYGYCqkOTkTH26LancGFsHe8otB61aRW5WGnlFOmuvDHMbW6zMjPQiRVmQRVaRDFMDJTl5CrRSI2ztbDE1LONRJorjnN6kXweXcruhRrJ3BvLtxqi+nIjWWoN01VjkZ6qg3LsQ7fMYZlWpyFYuA/vXIWQasug2KNcsQGtXNnz0VQzGTEez8CvUdVwfe0IKM5P48cABDOr1+stFsTovmW+Xfci6OA8+nvoBLavaQUk+d+OSsLN34tjHb7BOO4xDH/fD3DCX8//H3l1HVZX9fRx/30t3GSAWdnfn2DF215jY3YGJ3Ymto9jd3Tp2C4rYBdLd3HgWoKOijvIb9NHxe9aaP0bP2Wef1z5c+dxdO5YxatI5Oi1ZRJvSmRO/5IiPCGBm17o8LDuV5X2qoZfwxQPw/PRK2nXZyhSPg1TU1+XOvlG0Hf+AOa5LqZE/+aZjyTkC2NSrOa6mA9g4oyHJ13dXx4ThGxiORqtFqWdKuvRJ+1OjURMRGopa3wBVWDDxBhZY6sYSEBaPmU0aLIwS3vcIvPxD0SZcq2NMGjvrpPddHU9ISBB+Xk+Y4tgJ674LGFglHwp0sEiTFjPDNyvGa9TExkSjUuhhYiTicXDHAAAgAElEQVRdzCn8qJPTRUAEREAEREAEROCXEZBQnMKm/igUA8+urqJ9M1e67t9Iu/wGnP5zGcsOv6RElUJovW9wISgv40c4UiizBWGeJ5gxcy4+GepS3BaiIpWUbtSCcpl0uXJyFzeevmDT7JVYVW9HzSL26GBF6Qa1KJ7RGgI8WLvnHM9uHGbjfiUbnm+nxNv6P9hL1dZjMShanTIONhjE+nL1gR5D5oymbAYLeHWJaTuuY66nQBUTzrkj28jTcSXjmmTn7vkTnL91n8OblhOUoxGtK+ZIDLR5q7amSsI2VuGPWb/uCK8enGDdaQ2LDu+iiu2bG2uC2DtnNgefRpMjf3aiHt/B7QV0nTqdmjksuefalbozH1GhaklKZk/Hg8tXiC7UjhXDG5AYiz8XisPd0G3VDTqvQ9XUAe4dRnfjfhR7LqNZfBJ1RcsUttynT9cZXxWd++U+DsW9h6MZuwR1ATvQ0QMDPVB82H2e0lCs1WpQq9S82a75XYUUSnR0dP5xyLi3+wZat3Cl78ZVNCvy4d7ZxEex2anee6E4IU8GMvWP4lwrPJetTo0w0lN8IRRvYuz1nZTTi+bwjIHMupURl8UTKGZv/AXnfw7FEc+vsPXoZe6f3cOuZ8U4dW4GibWPes3yEX3Y9EKfslmtOecdTFVLG56HPyaqYE82j6qP0vcOy3df4NW1Pey8aM8G95UUTrg2Oojzp45w1f0Ru1csx6xWe+rkswdMKNOgCcUyJg3QjvJ/zpE9u3htmI9W7WrKqvOp8hMjhYiACIiACIiACIjAf09AQnEK2/RToTjwwXn6tGpLrgkH6WR+nvbO11h1YBE5DfVQR/gxv19L3EqNY0W333hxwJnGQ0/Rae48HOsUxjTZ/TXqJ3Qr24RMw9cwsmmRdz3B75338MAM2g+5wkKPZKG43XDKjTnJpPp2RHm7M7xLZ8y6rmFKk+QDVmM4u2YEg/am4+zm4Ym9tvFhPkzt2oAXlWeyrGflTwyfhtcnZ9HY6RJTd23/OxT7HJlK80VBLN00k/yJDxPO4UndmeJVi4NLOvDCtSsNV2tY7epCxcyGPNg7hQ6j7uDivpli/xSK/c6h12QQ2jFr0YTuROmeGdWAEug17ILWcRmqDoVS2HIpCMUhr1FuX43CF4j1R3nVC02Drmh61vwg0KY0FMfH+nHv5gPCE7rc3zv0zTKQN1c2zIw+/0gP90+gxlgP1m9yoYRNCHt27cDzdQwmWYvT9vfynJ7e5INQTGw4653q4+zfkBvL+2FqoPOFUDyTvB1aor1ymPPBVdh7fjo5vkr4n0NxUhHRXFo1il4b9Nh78v1Q3IVlgXXZPcqB3h0HUnXBOUrcnMDAfWnYc8iZt33097aNoss0P5ZefxOK39Qr0v8pwxo3IK3TesbVKfzx8OnoMB553ifM0I5ieTJ91dPISSIgAiIgAiIgAiIgAr+egITiFLb5p0Lx06sr6dB0Hd0OrCGn+wo6TzxHvQYV0U2cmKtFrVKRpXJ7utUugBIVPtd2MXfHdXQDbrPztg1OC8fQvFTuxCHJ/yYU1+gwimYu7nQvRrJQnI0n548yfdpMVDkrYWuk4qXbGQ5FVeP5Qed/EYpjubCoF8POF2DHpoEkTW9O+LMeDDmUjQ0HxhDt2o3222xYs24qBSz5+lAcfhXdmh1RZCyNpmlf1M2KQOg59BoNQzP1MOoK37Cn+P13QquBq8vQ774B1ZJdaMq8mzuc8lAcwMO7T4lMWlPs70PPJD05smXG1PDzL+OL80to0nU3wzesolnhDKhU8dzbMw7HVRGsWjaeey4tPu4pblec60XnsWVUw6/oKU4YPn2A8lFPGNWxI3H15jPRsRRfXk/t34Xi7aaObG1rQPuOE2jy535ynB2feqE4hT/bcroIiIAIiIAIiIAIiMCvKSChOIXtnjwUB3qeY+ZUJ1459GTW4BboPNpL9+6LqDpzCY6VcvFhzonH55474TY5yZneNHGO8MJuv3Es4wDWjGmbuLKuRu3LiDrVCW04l9ndq2P6Znrk+9X8XE/x50OxOcvbd2CdXht2L++CSZAbc0cPY+HjYjx6E4pVkf4sHtiSA9bdODC55ZtA/yHOp3qKg+6soW2X7TSbtZC2lbMS53OFmd3Gomo/g0nNCuP5v4ZiVCiX90J3XxriV41Gax6PcskgdK7lQrVmONq3K5BdWo1u77koKvUhfkp3eL+3NeYlOoN6oHNLF9VsFzRlkw07TpgB/anh0+8/dogXymXD0LmXH9W84Wit3s0NT2ko1mriiY6ORZNs/LRCqYehoQE6b+b4fuqVjA19zpLhHTlKNeZMGk2eNOCxezQdloawMnkojn7Bjg2LmHcgknGzxlEtT7rEkd9fO6f45YWldBx0lN7LXWhcyC6xBzYq9CkHtu3HVycr7TrV591XEv9/oTg26CXOHRry6vcZ/Nm9Gspkw9vjQ19z7uhhHkWaU6lRXfJY/kNXfAo/B+R0ERABERABERABERCB/46AhOIUtmXEa0+WzRjPI2VGrA31iQnWpWrvtpRzyIaVsS6oY/B9dY8tS1zx1jFJmjdrnJF6rZtTJps1UYF32b50Dw+ikha8MrYrTqs2NXGwNk1cECthUSEf9+Os3X6EkLiEoJSWGp3b8Fv2dHhf28Xq/dcIDQ7Ayyca2xyZMLIoQM8+TckYfJMxc10p19OFOtkhNvA5axbMx6jWANqXsyPo7nEmzdqHTgYrTHTtyVdQy6n7Zswb3hYDPR3Qqgl7eZ2VK/cQoEqaPlu8yQCaFE9LsPs+Zm26hCoykJd+UaTLlAlT/Rx0n9iJTMTw8PJJtm45RLiROWpdE0qVrUOtaoUw19PhxclFzP3LjAGDOpDFFLwub2Wu6zN6ugwjewLAZxfaSlilKwjlzo0oLr+EhIW5shVF07g+2rTvfdXw4Cg60zagKN4SVfe6JK3i9OZQBaJ0mY7yvi7q/kPQ5rFO+gu1CuXOeShuBaPwfw6xRmjt0kOe8mha1kEbdBGdxfuTzo3Vg3LlUVepCFYffsWR0lCcwlct2ekaokL8eHZhJwuPe2FtBLHhwRjmqEG/jrW5v2MSy86HkjmdBcr4cEwLN6ZdzRJkSGeW9A4mLP8WHcbORePxztOBPr8XRvdNCPdzO8rsBedov3g8+fV0UEf6sWvxDK6mq8/U9pUSw2ZMZACXTp0mQMee+nXK8m7ZqjDOLJ7CyhtR2Kd/ey8TyjTrQP2i1nge38HmM3cJDfLjdaiCTFnSo5e5HKPalOLcRhfOG9VkeGU95s7bRNkBY8ngvokVV8wZPaEt0Rc2svzQ3cTn9g5QYZctA4ZWRRk4sAlpEr5B0KgI8jjFvE0nUGsTntKcmp27Uzl7UmTXqCK4deYAp938KVm9BRULvLd09b9rDLlaBERABERABERABETgPyQgofg/1Jg/5aP8Uyj+wR/o+4biHxzjB6ueVhuJ75MXuN++RbBeBirWqIztPwxP/8GqL9URAREQAREQAREQARH4jgISir8jttzqEwIRwVw7dZj7MVbYpzHAJG0+iudNj86Xtsf9f8SMDvHDw+M+QeFR+L32x67E71TJ/6YX+v+xXnLrdwJabRgvHvmiNjQnk11a9N52iwuSCIiACIiACIiACIiACCQTkFAsr4QIiIAIiIAIiIAIiIAIiIAIiMAvKyCh+JdtenlwERABERABERABERABERABERABCcXyDoiACIiACIiACIiACIiACIiACPyyAhKKU9j0MaE+nD2yi8eB7y4sXq8LpTLpp7CkT5+u1YRyavshTItXo3j2tH+vHPz32TF+rHfuzbi1Piy8co669qlyW9RxkVw/eYAI+/L8VsAeZcI+PB8cfmwZ3pcJ+54yftsVWuRPnfsmrD59/tBO3OPsyZXR+BNzisNRHDmGIkCLtnpdtOmTb6sTiHLTAQiJTFx9WNu2DVrzjyr/v1VWHQ+X9qO844O2bie0WQzB7y7KHWeTlacEh2JoqpYE/Tj8nnvi+dSP4MBXPPM3olHXZmT+p/2W/rfaffKqRxe2c+y2P6AgTdZiVK9aCr3wB5zcfwKvpAXPATOqtmpFbitd1HFR3Di5nWtPE/w+PMzzVKRN+czcOnuCqw99eLu9coaCNalVIXuy7cY+VZ1I7p08wV+eXm+uVWKXozzVaxTANBWf+ZsWFe/H9jvTOa2pw6KS1ZPdSs2r13sZc+ccfUtPo5jl28+AaJ75HWSu2zGs0uXDAn1ypq1Jddts/2gWHnOL3Q/P4hvizqloG8YVn0opmze31Kh48HwHByJ88Xh1ErPMvXHKX4OvmsmujuOxz2muRAe/KcyCopkqksfg7S7U0TwNuMK1EB9UCSviGxamgX1uFMm2uPrYWc1d74U4uUWyvPIg0hl+esur2Pi7jDnSnbsmHdlUoSPmeu8tER/myd4gb4qmq0Im469tyTjuPl/OWA8/ZtWagMMX6/m15X7f8/wCzjP+ykpqVZ5NQ5PkLRnGac+ZzPXKzJ6qXb9vxVJwt7Dom+x5dA6fEDfOxKRnfPFJlPiqlzIFN0k81YPJJ6ehaz+M4blT+o+PFwtOjSDQrg9D85T+eT57Ukok54uACIiACPwrAQnFKeRL2qe4G3mdl9C+YCbwusTo2RvQL9ORab3rY2P471aI0qif0K1sEzINX8PIpkX4KGpr1USGBhESocba1hajT+xjnMJHSjw9PsyHqV0b8KLyTJb1rIzOR7lSTWRwMKHRKizS2mLydp/g/+Vm71/zD6tPKy67orP5KdpsQeisuIl65U7UpdK8u/qvTehuOoq2XEfUlbKRuB+TnS3opk4oVlxejG7HpSgivNAsf4iqjjXERYDv23CRsKWUB7oDR0DTZai6liRxX60kUZ7fPcH+M0HU696KLN80FGsI9b7C/MHz8MlRijZtm5PFREvw8xfEpMmMbewFunZeRcs5M6mRzYZQj2OMX7qNPA2dGNmqLKpwX8Ki1Xjd3saQ0UfptWQmFTNaomtiha2eP7P7duZUxp4s7V4WTdAdBnaZRNYeU5jYqQom//i6e7Oqa2dWG7Rg8/AaqGK8WNy3LwG1J+HSuxbGqfUO/dt38B+u93q9hQnu9+hZYghFrcw+OFMdF8KGS8N5YNORcXnLoPf2m6QwNyZeGY3Wdi6jCmT7YJewr6lq3KOl1Hn4kMmlZlPmbSh+78I/TzXhRtpuTChQ++tCsVZDVGwwYZp4II7nz7eywCuAvmWnUcYE/MPPcdornmIZ8kG0GyvclqOffijDCpb6QoBQ4+Y1h6G3I1lbdTjpPxOKtdo4QmKCiFeYksbA5MP9pJ9voM7dMwwuvpzq6b9GJ+GcONyeLWbEXR8W1p1Ktp80FPsGnMPp4hLqVl1Ek0+E4pP3JzP9ZVaO1Oj5tTD/b+dFP3Sh/uPnTCk1g1LfJBTfY/wxZ3QzOTE6T8EUPucrZp8YRGCGgYzKW1ZCcQr15HQREAER+FUEJBSnsKWTQnEfyi3bSq/iDolXe56cQdue5xi7dxUNcpvx/NZZli/eTlzadCijAzEq2JJeTcuRztyA2MCnHN2ylJ33dclgBkaW+WjcqTG5jWM5vmMZZz1ecnjdLsxL/06Z3OnQ4d0+xXhfY9rq/fi8eIDHEzvmHJ/N39+ZPztNN6c/yVS+Alrv+4SFxaFIX5Le/VuS1dQAQl+wc89urnv6oomPxT8snLqOzjQqaMDF/ds5dNGdvw7vICxzFWoXyfTBPsUEuzN71iZeBz7lvn9axi6bz7tsGoPn6aPsOHaSYIyJDwrF2KEEnbu1IYelAY/3OTNsZzRlChgRGhiOr188RZp2pnedQkny/7Qlk+/TxD2e8VyOfpetqFfseC8Uh6DbtjHalotR18v7XhhNYYN+8vR4uLwDvckbULfvgXLZYBh0ISkUv3+ow1EuHYnOTiXq/QvQfNBR9v1CsTY+ii3jWzDvRUV2LxuEbbK06XV7M527bqD3uoT3M2mv3kvr+tBhcQybts2hWEbzxD97fmUNnfvsYcTWldTI+iaNRTxlVp/OXMw/lh1Dq6AJekSXpnUwaOzC7J41v/DlSFIoXp+mF6emNkAd/Yo5XdtwJf9Q1g6pj7FeBB7nTrH/8CVCgBB/L8zLtGdk64qYG+lB6HPWu67gkmcsFhb6GKfNS+MWjcmbwQQFsXiePcaG7TuIMstAXGwUmfL8Tue2lbFJuDYhOoX6cvnMSXz0s/N77VJ8dUfk320cxooz/fFL15MBuUth8vcXHkkneD91ZezTl4mBuZi5AYoYP26EPiUq1J0lnuvJZD+Behl0UCoMyWZRHFtDN8acWkeZvP353dYeIjxZemcJOrZD6Zrt3ZCPVA/FH7y0cfg920S/Bx4MLTWN4klbOr93RHPy+kBcokows6IjCV81ff5ICsVON1/RLktBXhJFdPhTbNL0oHXW3FjqR/PQ7yTHfR7wMuQuatP2jC9UKfGLvDjVA7Z7HMY39B7bAl5Q0rY2WU3AQNeB3zNXJ4vJp3udk+ryNhQ/oE3eUgSEhhET44OxdWM6ZCuKuR4Ehrtx4tlFvFChifXDl/x0zF+PPEZmKONDuRd0jC2PPbA0swCtLoXTNqeCXdrELyHDwh+w9/5GHupYY6YTRawmKw3z1CWfkfm777w+gxId8YSDj4/wQhmPSh1KcIwV9XP+QRlrCxSKcNy9r3PG+zxxBmZERr3irPcretRMCsWayOfsf32Yh6GxKPVjeR54kevxNTiXGIrvM/fccnTNiqBVh6BWhOEZpU+3/F0pZmVFfPgDtj7axVONLoZKNXGaNNR0aEEJ66QxGQ9f7WO31y00hhboa/TIkKYKzTLmRkehIDbqMXue7+VJlAoDfR10NLlokKcmWQ2+fvTTp0KxRqPiyat97PN9gtpAj5hofwxNytIme10yGEFU3BP+enEWj+gwNPGheEQZ0T1/R4pbpQFNPD4h5znw4i6hSjUKRQB/Pb9B0RxTE0NxdJw3Zx9s45IqHnMdNS8jTeiYpwV5LNOhr4nHN+wGR59eJCBx1flwrjy/iEN2JwnFqfHPo5QhAiIgAv9RAQnFKWzYT4ViP48T9Greg6JzDtAj0wN69XGl2by5NCxoj/q1GyN6Dsay/XTGNS7K030TaDHmEiM2rqNR/jREBXgRq7QmnXXSL4Ff7ClO+AXnwAzaD7nCQo/tlHhb/wd7+a31YNI2m8+iXlUxDLnNoC6DyDHkT0bWzgXhXrgFG1MwsxXq+HB2z+rMvAeVOba8F4Z6yq/oKYbXJ2fR2OkSU3dtp4pt0o2j3DbRavB+Os6cS73CaVEF32fFwAGczTmQzU61eejqSLVZzxkzexFdqzrgvsWZbvP92HB5ObkSCviafYqvuXwcin0Pol/dGW2bdmiiXkN0GAqLAqgd26C1+7BHL4VNDPdPojtqHnRyRlU0Bt1OHT8diu8dR2/ATDSjFqD+LXey26QwFGs1BNy7hptfsmHMOgbY585L9vRWHw+lf3PH+KgQxjctzIuqS1k+sAbRvs945hWECgNss2dH8Wo/jslC8bMrq+jQdA2ORzbzR76kQPZPodj1VUbqF7HA8+Zf2LRcyrjmhclg9U/BJaHEpFA83cOC5pVzoIp9ze1rWjrPnUCTwpnRVUbxws0Xq4IOJLTYy4tb6DxyHf2XraJe7vSEnJxMycEXGL9sBS1KpCci0B+1njk2lsZE39tBu4HbaDV1Ho2K2RL39AyDek4j1xAXhlRPinLxwa+5cPY0gcY5qVOjBF+q7YcNGMfjZytxfhrFsLL9yG/4YUCIi/XA5eJssB9Or5w5MUi4ODYQ9/AXRIe4seD+n2S2n0oje12UCgMymxUkreEVOu6ZQ41iU2mbyQHCbjPh0jh0M83DKW/Wv2//TUJxrB+nXx7hZrQfr4K9SJOuBt0c6mCTWPE3h1ZFiN9pJtyaj8LWicmFy3zBLCkUj7pyhxZlnGhilwdV6AVGXlhBjSJTaGhnlxQi1dEcvNidddqWrCz7Oybvj275Nz3Ft8/Rrsgs6ts7oAq9wpirK6hYfBwt0toSHOFNnI4t6Y30Uce8ZsaZQUQ7DGBkztIYBZ2n75WppMk0ncF58qNPCEFxamyMbVBEPmXF9ckEp+1HnxyFMFEEsvvGWI5oajO/5O8YfWHER0zkC3xIQ1YTY1Rx3my67MQ53T9YWqYyj1+sZNJDb3qXG0opY1M+6Ck2iGTrlYmcM2zDpIK/YaEXxoc9xbcYtM+JMNsWDMrXjHz6Iey8t4z7eo0YlSsD26+O54JhK8bmL4+ZMpJjdyezLrQIyyu1xYRgph9pw7O03Rlb8HfsiOZ5dDyZzKwTe+2978+m4+NnDCg2njq2FoRG+aMxtMFa59+F4mCvPQy7d45mhUZTPZ0lsTGerL06kSdWfRhdsAz6cX4ExuuR3sQKvfgwDtwewYa4Kiwo1xyDsBOMOr+dCvlH0jxTZpSKD3uKT18fyra4Qgwt3pKs+mpeeS6l76t4nEsNJLPiKlMurCVH7oF0zZIHkJ7iFP8bKBeIgAiIwC8oIKE4hY3+qVDsdXs7jk2n8Pv6zZR8uobOE89Rr0FFdBPGIKvjeOZ+Cf3qE1jRryqqwIfsXjWbFeejKJrLDLVRSRwHNiWPtVnikOV/E4prdBhFMxd3uheDKG93hnfpjFnXNUxpkpuIAF/2rJjMjVBLDHVUvHQ7w6Goajw/6Iyxvs7/GIpjubCoF8POF2DHpoEkjX5Uc31lT/rtzsT6/WOIdu1G+202rFk3lQKW8GDvFDqMuoOL+2aK/ZtQ7L0P/WpTUc/fiLpaVojxQ2diW5Q+LVGtckT7v45iV71Gp3NrFJn+QN22EgTeRmfkcOi0BdXv2SCtNYnpND4CnX4NUdp0In50a/ho2HxKQ7GWuMgwIuLeztx982IqlBgYm2BsoMfnBoUnhGLnpoXwKL8A1+F1CHl0h6u37rNm6hRyj15Dj9xP6Z4sFHuemUvbTscYe/hPGuRKarkv9hT3ysemaY6sD2zCkrntyWzwJeRkPcXxQWyb0oMZN/NzeMMorJVRPDy7ifmHnmJjoktMsBfH9t6j9/5tdC+SBYIfs3TBTA7eiCS7gxX6NgVp07k1hTLocWXlIDq7eFD99zfDIVWRPLx9A+tmM1jqWCaFP9XJT9cSF3aTqVcXYe0wjr7Zsnx4giaSy57zmOdjxfxyvUj3frBMODPwEv2ujCNPzv30yvH+GPH/x1D83hOERdxkweUpaDKMY3DeAiTNLI7lZdBx5l5eSYhZMyaVaEMGw6Q3LjD4Fge9zxKgSSrE3Lg0zbOXxpyPh0/Hq8KYeqwt+vkmMjBLkaQvC75VKH5v+HRMlDfzzg0iLvtoxjrkJDDoKutfXEajr4dWq8Ht+WGMbYcwvWh1TLXB3PY/wPJ7Z7G2yomuBspn6kyltFaEBJxixJW5mGasgoNuQttpCI56wN2YQqwt3wXTxD/73BFPaPQjdnrswF/PHD1NLE98zvJErwX7qtTh0B1n1oZXYmuFZokFfBCKoz3od3UKRfMcoFPiAKRPhOJD08iaazz9sicEvfcO/7N0vzodjUUt8iUN+iA84gmPYuwYUWU4+RJm5D7fwqonp9E1z4q+WodCGetS1y4vxgoFMZEP2PZ4NeeC9MlmoYtCWYTm2auTzfTrx1Z8qqf4wvUBuKhKMq10WzK9qe61G8OYGZWLaaUcSRt9jwPPjvEcEqce+Pif5r6yKrN/64PZ/Tl0exHFpNKjKWiRcPH7odge54NNuWdWgeKWaROnJ2hjXnMjXEvXAsPJHruNQe7PcCo7isKWCT3lEor/5QeiXC4CIiACv4SAhOIUNnPyUKyKDmf/Ykdmn82Gy7LRmN5bT0enU8zev5LiNqbJhttpiY+OQq1riKGeDvi509/xDzxz92eDc0dsjBJC8TN6VmhImv4rGdOyJG9+L/2glp/rKf58KLbGtUd7lsU2YPviPqTXDeHQshH03W2D+3uheEaPRniWnMjq/tXR/XilrU/2FD87NJE/5ngzc/08SqXXRxvvxYZBvTmQrjtrxtTl6bcKxTxAr4ojmpF/oq6RHTRxKJe0R+dWNVQuXdEm/DauCUW5finKRzqoO3VD6/DmN8a3mgG30Zm2DgrUQt2yOhgpIPIVyj2nIDZhySEg+Ak6f66GGiNRN6yApkwR0FOh2DMO3RmPUa9ehiZv4m9tyY6Uh+LQFw94FhLzYTkKPWwyZSaDVfJ36b3TNLGcWtGfPuuVbNg2lUK2FsSHB+BUvyK6vZKH4jTERUbgOqoBm6IasWZmLzK9WSDqi6E4Yfh02GN6NGyOXY9ljGxeAsOE90SrIdD7Jjdv+2KdqxLFcrxdRuvDUJwwt/TS5nH0XRXDzl3TUJ9fQKuh+xm69yDNHAx5deMY/TuNpebapFCc8LMVr2uKkZ6CKK+rjO3Vi6vZ+nN8VtvEd7HdVA+mbFhMOTvDTw5r1UaHcv/OTbxizChYvijpE4dSfvnQauK46DGZ5X6ZmFKhIxneXxgqIXAE32LK1fnkyjuRTpkyflzgZ0PxDbrsmUalolP4I1M2gnyOMOrGbLJkW/nte4r/rqWWeNVzFp8bS7DdAEblKYaOJox7XhuZfucwuTINom+eSlh9VSdh8lBsQHj0WYadXE/N4s40tM3w5Z7il5v5/c5x+hRbSm073c9+8fMh8sdzigNCLzD+wipqlHCmpq4/Ey6NR5txPNMLFiE2LpiVZxy5Z9kzMRQbK2KJ1igw0Ut4yEAO3p3BwudKZpQfSS71Q8ZenUXWvHNxzGiL3te9MknVi/Fk3kUnHpj1ZEqJapjF+LLr5ljWR1dgZ5X6nLk7hUUBOVhasRtpiOXmo2WMvXeZzjUX0iTuKSOvOGOTdRkDc9sSE/mEtTed2BRd6c3w6VsM+lwojvVg2nln1HYTGJY7B3rK5JVWERWvwkDPEIU6hsueC5j04Db9qnbnnXkAACAASURBVKyhloUe8aoo1AoDDHV0CIk8j8vV2dw36Ma6srW//MPy5oxPheLX9+fQ0zuGMSWGUsxMD43Gn82XhnDDzBHnQhXZfqoRR42bMatoK9LqxHPBbSTzQnIw47c+WDxeTtcHjxheaiylrQzx8z/AsGuryJV9cuLw6T9Pt8LNohOjC9bAOtnP9Wvf9fS/dpX+pcdQ3tqSqMCz9Lk6H1uHETJ8+qtbVE4UAREQgV9PQEJxCts8IRT3a9WcwMINKJreAt9b7pjXa0Snhi0pmMEYYvw5s38TS/88h12RXEnDD40zUq91c8pkM+fltb24brpB9Ju06/UynMYDB1GnaNbE+WwJvRqXN45h6q6HZM+WEyO9d3OKva/tYvX+a3h7XuHg6ddU69wQW4sC9OzTlIyvDlOzoxNNF7n93VM8wrELZo5/MrlJRm5tmEO3yecp0bgUlhEqQiLvcdC3MPd2TEjsKUYdy4PTaxgw4ziFi+VEqVRQvMkAmhRPS7D7PmZtukTki6vsOudNpUYNyWKWg+4TO5EJP3bOmMOG0w/JUjQ3MaEBGBgVoefYzuQyM+Sea3c6bLfhT9cpf/cUd3RyY5Hbpi/3FN89iM7G8+BzE53DnmhrNUST3RZN52Fo7YDjS9BdewGtbWaI9kepSINqxGS09m/6VKOfoNu5DcpreqhWrEPz27shqonNfscVvTpDUVTqRdyikWDziSTw6hI6nTvBwPOo384p9jyGXqfBaIdsQ9Uk+bDpty9UCkNxCt/Dj04P9+bQoc24ul7EtnAuDOKiOXf6Eq2mrKZhult0az0Bi8q1yWGt5NEdLwo1bkjrxq3JZvWupIRQ3KXvXoZvWfHhnOK+XbiUbwzbh1ZJDMBXNgyl50I/Fu5xoZytOWjVPLm4ld1nn5OhVEtaVU2aa584fLpbF2Z6mNO0Ug40Gg2hMYa06OpIxXz2hD48xphe/XiRtQmF0oUTH6nLpWO3abthdWIo9rm5HpeNHmj0E77ziCcwKI4afQbTtEgmlIoADrm4svnUOaxy53vT22lPs4F/UDRN0vD5uEg/zh/dy7WnUZSq1oTKhT8RYD/hHhN3l9HHp1K4yCTaZMiabNi6ltNXh7JOU4TJRVtiq/+JnsPAS/S/Mp7cOfcl6ymGo25O7AyJJ7OpLbGx/rwIuUmOLEsTQ3Gg9xFcAz1RB99ie3AwFe2qkN3MgTpZ6pPRMI4zD5ZyOx7cXuzG16gw5dPmILd1TerY5/zH+dLxqkhOP1qFe8I6W8QRHBFNFqty1M9TjYQZ5u73p9D/3k50TH6jTobMSSJKG36zr0NRy39aNUnDk9dbGHl9NwXtS2OiG8fjwEhq5WxFZfv8mMeFcunlPi5G+PHE+yh3yUPtDLnIalmBOvaFMEscRu3L1tvzOBGqIIeVLSZfNadYzfOXWxh6ex95M5fBUqHAK+g1RbO1oZ5tQQxVPmy/PY4dEZZUTG9PRHgMMRHXCbXqyrSi1VFEP2Srx25CjJK6+KODXmKcvg0dsxXFUj+GZ35/sc59O+Fm+bAzTDhDnxzWtahj58A/fq8SF8Clu/MZ4xfCbxlyYhQRyUvtXZ7H1GJ7lXYoIx4x78ZUHugVIYcyGqWxGbdeutHgt8mJc4pf+GxistspMtgWQBGpxlL5kqPhOdlfLWFO8S0GH5pOllzjPu4pTlD0Oc7yB/uJMrAnnXHSc9ma16R14vBhH/Ze38BdfT0M0RAQ6Y+FURkcC/2OtULJ81cH2fzqFvomphAbjk+Mkuo5elMj4Wf7C4e/1yHWBz1EFXyTnSFhVLStTHbzbNTJXI8MBv7su+PCoeBIctpkIizCHyOLfLTJ1pqsxnDOYwyLn70mb/oCGGjjUYV4cl23KDMq9yaLKoy9dyZwPNaELPpW6OuYEBJwAv2MoxNDcWDkNTbf2sxjozRk0kvq0U5rWpa6DiUxjw/nqPtsdoWqyWdmRbzSnujgbcTZDWakLLT1pSaVvxcBERCBX1ZAQvEv2/Q/yIN/zZziH6SqKavGdw7FKavcr3F2XCQ3Tx/gwgstNZu0JOdXrYobxJ5LYzioX58ZxWqTfAxAaNBuBlw+Tuvi06iZ7qfZWOrXaG95ShEQAREQAREQARH4HwUkFP+PcHJZKgm8CcX3FPkoldcCQ8us5MpixTfdwSiVqv7pYuIJ9nnJS58g/L3uc+eJkia9vvWWTN/0gX7KwjWa11w740GUYRqKFcqNqYnBF1cOTnpQNbGqGDQKA4x0Pt7vTKNOGHqrwUDXKLV2/vopfaXSIiACIiACIiACIvBfEpBQ/F9qzZ/xWTRqYqIiiVElreKj1DPGzFg/cUuon/PQEBcTTXRMPNqEB1DoYmJugt7P+0A/ZzNIrUVABERABERABERABETgKwUkFH8llJwmAiIgAiIgAiIgAiIgAiIgAiLw3xOQUPzfa1N5IhEQAREQAREQAREQAREQAREQga8USIVQrMHb4wSb1x/F37QE3Xo1IIuF0VfO3/vKWsppIiACIiACIiACIiACIiACIiACIvANBFIhFL+tVSCbB/Rgi0Ejljq3JX3SrhByiIAIiIAIiIAIiIAIiIAIiIAIiMAPK5CKoRju/dmXfhdysnpePzKb/LDPLBUTAREQAREQAREQAREQAREQAREQgUQBCcXyIoiACIiACIiACIiACIiACIiACPyyAqkaioNenGapy2nMsmchV5Gq/FYqCzKK+pd9t+TBRUAEREAEREAEREAEREAEROCHF0jVUPzqyiqGzntAx35/UCB7VmzTmqLzwxNIBUVABERABERABERABERABERABH5VgVQNxTKn+Fd9jeS5RUAEREAEREAEREAEREAERODnFJBQ/HO2m9RaBERABERABERABERABERABEQgFQRSIRRriYsOIyjQi50TR3Erd3em96uDlW4q1E6KEAEREAEREAEREAEREAEREAEREIFvKJAqodj/6RWOHb6B2qoAv7eqiPU3rLAULQIiIAIiIAIiIAIiIAIiIAIiIAKpJZAKoTi1qiLliIAIiIAIiIAIiIAIiIAIiIAIiMD3FZBQ/H295W4iIAIiIAIiIAIiIAIiIAIiIAI/kICE4h+oMaQqIiACIiACIiACIiACIiACIiAC31dAQvH39Za7iYAIiIAIiIAIiIAIiIAIiIAI/EACXxWKvby86N+/P9myZfuBqi5VEQEREAEREAEREAEREAEREAEREIF/JxAXF0fatGlxcnL6uyCFVqvV/rti5WoREAEREAEREAEREAEREAEREAER+DkFJBT/nO0mtRYBERABERABERABERABERABEUgFAQnFqYAoRYiACIiACIiACIiACIiACIiACPycAhKKf852k1qLgAiIgAiIgAiIgAiIgAiIgAikgoCE4lRAlCJEQAREQAREQAREQAREQAREQAR+TgEJxT9nu0mtRUAEREAEREAEREAEREAEREAEUkFAQnEqIEoRIiACIiACIiACIiACIiACIiACP6eAhOKfs92k1iIgAiIgAiIgAiIgAiIgAiIgAqkgIKE4FRClCBEQAREQAREQAREQAREQAREQgZ9TQELxz9luUmsREAEREAEREAEREAEREAEREIFUEJBQnAqIUoQIiIAIiIAIiIAIiIAIiIAIiMDPKSCh+OdsN6m1CIiACIiACIiACIiACIiACIhAKghIKE4FRClCBERABERABERABERABERABETg5xSQUPxztpvUWgREQAREQAREQAREQAREQAREIBUEJBSnAqIUIQIiIAIiIAIiIAIiIAIiIAIi8HMKSCj+OdtNai0CIiACIiACIiACIiACIiACIpAKAhKKUwFRihABERABERABERABERABERABEfg5BSQU/5ztJrUWAREQAREQAREQAREQAREQARFIBQEJxamAKEWIgAiIgAiIgAiIgAiIgAiIgAj8nAISin/OdpNai4AIiIAIiIAIiIAIiIAIiIAIpILAR6H46dOntG7dmuLFi6dC8VKECIiACIiACIiACIiACIiACIiACPwYAjExMRgZGbFo0aK/K/RRKH78+DHOzs6J/8khAiIgAiIgAiIgAiIgAiIgAiIgAv8VgYCAABYuXMiaNWskFP9XGlWeQwREQAREQAREQAREQAREQARE4OsEvn0ojgpg37oF7LrqS+tRy6iR7W3FVHgeWMSUrTeBjPSYNZqyaY3+udbxYVw5uYPNG08TCFg5FKFZmw6Uz2mFQqEg6NlNtq5fycWHEYnl2BWuTofWTchrZ/KZcrWEvbzJyqXLuP0KCtVoS5dWlbDU/Tq8T58VwLEFS9jwMIbmXfrxe5H0H50W5HGACdO2olexPTO7VEWhiOX5LU8eB0VSomo5zP/N7ROujQ7msvs1VMr8lC+e4d+W9tXXazWxeN85z5Zde7n9LDjxOh29nLQf1Z7iGewxM9T56rK+54mx4QE8v3aQ51naJ76f/k+Ps2D8OgKKt2ZJv4rc3LYMl+MvqdiyJ62r5kI/WeUiQ64zp/8CHuWuy/KhzfC/vp3Za4+TodQfdO1UiVd7ZjFzpxuVukylS6UMEB/GtUvXiDNzoGQRB/S+58PKvURABERABERABERABERABD4Q+PahONyLxWO7MefgM8Zsu0uHQkn3V4e4Md6xFxtvvk74P8p1WcqC4bWw+mxuUvFwz2SaDd5C5irNaFrehr2L5uNh1JC9p2aRLfQ+oxw7sdMvA93at8Cel2xas5yonH34c9VAMn8ieWg1Kq5sHsuAcZsJVCgwyFSF2YunUzO3TVIlNSrC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)

Su x86_64 utilizzo 8 byte per l’indirizzo, e 2 byte per la size, in totale 10 byte. D’altra parte, esiste anche la **Load** **Global** **Descriptor** **Table** **Register**, che è un’istruzione **privilegiata** (ovvero invocabile solo se ci troviamo nel ring 0) che modifica il contenuto del gdtr register.

**NB:** non esiste un’unica GDT, bensì *una GDT per ogni hyperthread* presente all’interno della macchina. Questo fa sì che ciascun thread possa avere una visione diversa della memoria a seconda di in quale hyperthread gira.  
Se ho 2C/4T $\rightarrow$ posseggo 4 GDT.  
Per memorizzare le informazioni del registro `sgdt`, necessito di una struttura di tipo *packed*.  
Se vediamo l’indirizzo in cui si colloca la GDT, troviamo un indirizzo *alto*, cioè in fondo all’address space.  
Come già detto, ho una GDT per ogni hyperthread, che mi permette, mediante una struttura comune, di cambiare alcune entry, creando **viste diverse**. Nei Sistemi operativi moderni, non posso saltare da una GDT all’altra.

### Schema di accesso alle GDT entries, livello hardware

A questo punto della trattazione, possiamo pensare che, per accedere a un qualsiasi dato in memoria, è necessario un accesso preliminare alla **GDT che si trova sempre in memoria**, proprio come rappresentato nella seguente figura:

![](img/2023-11-24-18-40-28-image.png)

Ciò però non ci piace perché introduce parecchio overhead di esecuzione. Quello che sia fa, dunque, è *portare nel processore* *le* *informazioni* *di **alcune** entry della* *GDT,* *in una sorta di meccanismo di caching.* Chiaramente, se una entry della GDT viene aggiornata, l’aggiornamento viene riportato all’interno della cache, in modo tale che quest’ultima sia sempre consistente.

### Segmenti code/data in Linux

Come riportato nella figura nella pagina seguente, **in Linux si hanno diversi segmenti (ma non tutti) con un indirizzo base pari a 0**, il che porta a una *sovrapposizione*. Questa scelta è dovuta al fatto che in tal modo è possibile programmare software *molto portabile*, poiché adatto sia alle macchine che prevedono l’utilizzo della segmentazione, sia a quelle che non lo prevedono.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-06-27-image.png)

La tabella vale in particolar modo per i sistemi *x86* a *32 bit*. Per quanto concerne l’*x86-64*, il fatto che alcuni segmenti abbiano una base pari a $0$ viene imposto non più dal software mediante la GDT, bensì direttamente dall’hardware. Questo vale in particolar modo per i registri di segmento `CS`, `SS`, `DS` ed `ES`, che puntano necessariamente a un segmento con base 0.  
Se abbiamo un offset per identificare un dato o una istruzione, in realtà questo è un offset assoluto (in quanto, assumendo che le basi siano tutte $0$, non sono discriminanti per capire la posizione), *si identifica in maniera univoca una posizione nell’address space*. D’altra parte, i registri di segmento `FS` e `GS` possono puntare a una entry della GDT relativa a un segmento con *indirizzo base arbitrario*: ciò permette, a parità di istruzione macchina, di accedere a locazioni di memoria differenti semplicemente andando ad aggiornare `FS`/ `GS`. Da qui si può avere la **per-thread memory**: `FS` (così come `GS`) può puntare a una entry della GDT relativa a un segmento TLS, e questa entry può essere modificata a piacere in modo tale che possa puntare a un certo Thread Local Storage all’interno dell’address space piuttosto che a un altro. In particolare, quando è in esecuzione un thread A, quella entry della GDT può contenere come indirizzo base TLS$_A$, mentre quando è in esecuzione un thread B, quella entry della GDT può contenere come indirizzo base TLS$_B$, cosicché thread differenti, a parità di istruzione macchina, possano accedere a punti della memoria diversi (i.e. a sezioni TLS diverse), ove richiesto. Quindi,  `FS`/`GS`, associate al contesto del thread nella CPU, vengono aggiornate a seconda del thread in esecuzione, e un thread può vedere in GS una certa base, mentre un secondo thread vede in GS un’altra base.  
Inoltre, sia per spiazzamenti *kernel* sia *user*, si parte sempre da $0$ per gli altri segmenti. La particolarità è che in questi altri segmenti carico anche il livello di protezione, quindi **posso arrivare ovunque, ma non posso modificare tutto!** La protezione normalmente è statica, ma posso cambiarla.

### Regole di aggiornamento dei segment selector

- Poiché **CS mantiene il CPL** **(Current Privilege Level)**, può essere aggiornato soltanto mediante dei “**control flow variations**” (i.e. dei salti che permettono di *spostarci da un segmento a un altro* all’interno del flusso di esecuzione), ma non può essere aggiornato in modo esplicito dal programmatore.
- Tutti gli altri segment selector possono essere aggiornati esplicitamente, a patto che il nuovo **RPL** (**Requestor Privilege Leve**l) non sia relativo a un livello di protezione migliore rispetto a quello indicato dal CPL corrente. Chiaramente, con $CPL = 0$ è concesso qualunque aggiornamento degli altri segment selector.

### Quali sono le GDT entries in un sistema Linux x86?

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-06-47-image.png)

- Mentre viene eseguito codice di livello *user*, il registro CS referenzia la entry *user* *code* della GDT; viceversa, mentre viene eseguito codice di livello kernel, CS referenzia la entry *kernel* *code* della GDT.  

- Quando vengono acceduti dati di livello user, il registro DS referenzia la entry *user* *data* della GDT; viceversa, mentre vengono acceduti dati di livello kernel, DS referenzia la entry *kernel* *data* della GDT. 

Sono presenti **tre** TLS, uno associato al segmento FS (TLS vero e proprio), uno al segmento GS (usato dal kernel in contesti per-CPU-memory), ed il terzo perchè è sempre possibile dover lavorare in kernel mode.  
   
Ricapitolando:  
GDT ha entry che descrive, nell’AS osservato dalla CPU, il segmento in questione. Noi vediamo solamente gli offset, perchè i vari segmenti sono posti “*uno sopra l’altro*”, (quindi in uno stesso rettangolo non ho solamente CS, ma CS/DS etc...). Questo perchè non si usa molto la segmentazione.  
Se prendo `CS`, ho anche le info di controllo (rilevanti), non c’è solo l’indirizzo. Questo perchè, come abbiamo visto, CS e DS sono *sia user sia kernel* (e le differenzio mediante i bit). Le tre TLS implementano Thread Local Storage (cioè *vista della memoria per un thread*). Esse vengono aggiornate a seconda del thread, portando alla visione di zone diverse; stiamo lavorando con il segmento FS, e quindi una entry è usata per l’offset rispetto tale segmento.

## TSS Task State Segment

È il segmento in cui viene descritto lo stato di un **task**, dove il task è **il thread correntemente in CPU**. Qui sono riportati gli **snapshot** del CPU-core in cui il task viene eseguito e le informazioni necessarie per supportare correttamente il modello ring. Più precisamente, esistono in tutto *più **aree** TSS*, ciascuna delle quali è relativa a un CPU-core. Di fatto, ogni GDT mantiene all’interno della entry associata al TSS un indirizzo differente. Ho un array di TSS (non per forza contigui, anche sparsi va bene),*uno per ogni CPU (e puntato da una CPU)*. Salvo **tutto** ciò che c’è in una CPU (stack, registri sia general sia specific purpose) in un’area puntata da TSS. Ciò mi permette, quindi, di salvare un’immagine e caricarne un’altra, in un’operazione simile al context switch. Oggi viene usato solo per avere informazioni sul thread corrente, non per context switch. Il TSS ha un **DPL** (**Descriptor** **Privilege** **Level**) pari a 0 poiché viene usato per l’operatività a livello sistema; di conseguenza, racchiude delle informazioni che possono essere sfruttate esclusivamente a livello kernel. Di seguito viene raffigurata un’immagine che riporta in maniera più dettagliata il contenuto del TSS nei sistemi x86 a 32 bit. Questo segmento TSS non viene fissato a base $0$ (come altri segmenti), in quanto non sarebbe identificabile se tutti partissero da base 0. Se due thread eseguono stessa operazione, con stessi parametri, tra cui l'offset, *cadrebbero* sulla stessa area. Allora discrimino con la *base*.
Solo per `SS`,`DS`,`ES`,`CS` si parte da $0$. 

segmento FS, e quindi una entry è usata per l’offset rispetto tale segmento.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-07-13-image.png)

- Le zone di memoria riservate ai registri EDI, ESI,…, EIP concorrono a mantenere lo snapshot dello stato del processore.

- Le zone di memoria riservate ai segmenti GS, FS,…, ES mantengono gli indici della GDT in cui sono riportati i segmenti a supporto dell’esecuzione del thread (del task).

- Le zone di memoria più in basso tengono traccia della posizione in **memoria degli** **stack** utilizzati dal thread corrente. Di fatto, per ciascun thread, devono esistere per lo meno quattro stack, uno per ciascun livello di privilegio. Questo perché le informazioni riportate sullo stack quando il thread esegue al livello di **protezione** **3** non devono mischiarsi con le informazioni riportate sullo stack quando il thread esegue a un livello di protezione superiore (e così via); in altre parole, quando si cambia il livello di privilegio, è necessario cambiare anche lo stack. In particolare, si tiene traccia di tre stack pointer: 
  
  - ESP0 (= stack pointer usato quando si accede alla modalità ring 0), 
  
  - ESP1 (= stack pointer usato quando si accede alla modalità ring 1), 
  
  - ESP2 (= stack pointer usato quando si accede alla modalità ring 2). 
  
  Per quanto riguarda lo stack pointer relativo alla modalità ring 3, viene salvato da qualche parte in memoria quando si passa a un livello di protezione superiore. Ho anche supporto ai RING, perchè da liv.3 a salire, mi servono i GATE.

Per quanto invece riguarda i sistemi x86-64, le zone di memoria contenenti gli stack pointer diventano a 64 bit. Vengono sacrificati tutti i registri general purpose (EDI, ESI,…, EIP), per far spazio a info stack area. Ciascun TSS viene **aggiornato** ogni qual volta si ha context switch, ovvero ogni qual volta nella relativa CPU un thread viene deschedulato a vantaggio di un altro thread. Inoltre, quando un thread in CPU necessita una risposta per proseguire, la CPU legge la risposta proprio da TSS.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-07-48-image.png)

## LDR Load Task Register

È un’istruzione che permette di aggiornare il **registro di TSS**, che è un registro che serve a mantenere informazioni sul TSS; in particolare, il TSS register è un registro `packed` (= con più di un’informazione) che tiene traccia di: 

- L’indice della entry della GDT usata per descrivere dove si trova il segmento TSS in memoria RAM (o eventualmente cache). Quindi posso raggiungere informazioni più o meno velocemente.

- *L’indirizzo lineare dove si trova il TSS*. Questo registro permette dunque di **non passare per la GDT** quando si vuole ottenere la posizione in memoria del TSS. Ciò è importante nel momento in cui un thread cambia molte volte il livello di privilegio durante la sua esecuzione e ha necessità di accedere al TSS per recuperare lo stack pointer relativo al livello di protezione in cui è entrato; se c’è bisogno di accedere ogni volta alla GDT, si ha chiaramente un alto overhead di esecuzione.

## Replicazione della GDT

Sappiamo che **ciascuna CPU ha la sua GDT**, e sappiamo che questo permette di avere un *TSS differente per ciascun thread in esecuzione*, cosicché ogni thread sappia dove andare a pescare le informazioni necessarie (come lo stack pointer opportuno) per passare dall’esecuzione in modalità user all’esecuzione in modalità kernel e viceversa. In realtà, si hanno altri motivi rilevanti per cui la GDT è replicata: 

- **Performance**: nelle architetture NUMA, se ci fosse un’unica GDT, questa sarebbe vicina ai CPU-core di un solo nodo NUMA, mentre rispetto agli altri CPU-core sarebbe molto lontana. Avere una GDT per ogni CPU-core porta tutti i CPU-core a poter accedere alla propria GDT in modo efficiente.

- **Trasparenza** **alla separazione degli accessi ai dati**: se due thread eseguono la stessa identica istruzione macchina di un programma utilizzando gli stessi parametri, è possibile, **avendo GDT diverse**, che essi vadano ad accedere a due locazioni di memoria lineare differenti. Ciò è possibile grazie al segmento `GS`: supponiamo che un thread $t_1$ in esecuzione sul CPU-core$_1$ abbia un segmento `GS` con base $B$ e che un thread $t_2$ in esecuzione sul CPU-core$_2$ abbia un segmento `GS` con base $B’$; supponiamo inoltre che i due thread debbano eseguire una stessa istruzione che prevede un accesso in memoria nel segmento `GS`. Allora, $t_1$ e $t_2$ faranno riferimento al **medesimo offset** della propria GDT e, all’interno di tali offset, sono indicati indirizzi lineari differenti, che corrisponderanno a indirizzi fisici differenti (che sono proprio le locazioni di memoria a cui i thread accederanno).

Alla base del meccanismo appena descritto si ha la **per-CPU memory**, secondo cui ogni CPU / CPU-core deve poter avere a disposizione e accedere direttamente ai suoi metadati e alle sue informazioni. Se non avessimo la per-CPU memory, all’interno del kernel bisognerebbe avere un array $A$ in cui ogni entry mantiene i metadati relativi a una singola CPU; dopodiché, per accedere alle sue informazioni private, ciascuna CPU dovrebbe invocare l’istruzione `cpuid` per accedere alla propria entry di $A$. Ma sappiamo che `cpuid`` è un’istruzione devastante dal punto di vista delle prestazioni, poiché è serializzante e causa lo squash della pipeline.

### Esempio di utilizzo della per-CPU memory:

```c
DEFINE_PER_CPU(int, x);  //definizione di una var x di tipo int che è per-CPU
int z = this_cpu_read(x);  //load del valore di x all’interno di una variabile z
```

Lo statement appena descritto è equivalente alla seguente istruzione macchina: `mov ax, gs:[x]`

Comunque sia, per operare senza particolari *define*, è anche possibile recuperare l’indirizzo lineare in cui è posta la variabile per-CPU x:   
`y = this_cpu_ptr(&x);`   
Ogni CPU ha la sua variabile, ovvero ho associato un’area per ogni zona usata da per-CPU-memory.  `GS` è “assicurato”, so che c’è perchè anche il kernel lo usa, ciò che faccio io è aggiungere altri pezzi all’area.  

*Posso scrivere funzioni in cui definisco variabili per una CPU, le modifico, e poi le faccio leggere a quella CPU?*

No, concettualmente è sbagliato, perchè in qualsiasi istante il thread in esecuzione potrebbe essere deschedulato ed essere riassegnato ad un’altra cpu. Soffrirei quindi la *preemption* e le *interrupt*. Dovrei, per risolvere, lavorare SOLO su una specifica CPU, mediante `get_cpu` e `leave_cpu`.

## TLS Thread Local Storage

È una zona di memoria all’interno dell’address space dell’applicazione che contiene le variabili locali riservate a uno specifico thread. Esiste dunque un TLS per ogni thread. Questa zona di memoria può essere utilizzata con l’aiuto del segmento FS. In particolare, nel momento in cui un thread $t$ viene creato, viene allocata un’area di memoria all’interno dell’address space (un TLS, appunto) e viene comunicata al sistema operativo la presenza di tale TLS.   
Ogni qual volta che $t$ viene schedulato in CPU, una particolare entry della GDT (`TLS#1` / `TLS#2` / `TLS#3`) viene aggiornata in modo tale da puntare alla base del TLS di $t$, e il nuovo contenuto della entry viene caricato all’interno del segmento `FS`. Sarà proprio `FS` a essere utilizzato direttamente dal codice macchina per accedere al TLS. Il meccanismo appena descritto è alla base della **per-thread memory**.

### arch_prctl

Abbiamo visto quindi che GS è importante per il kernel (*per-CPU memory*), mentre FS è di supporto al TLS (*per-thread memory*). Ecco le system call che servono per la gestione dei segmenti FS e GS. Variano in base all’operazione:

- `int arch_prctl (int code, unsigned long addr)`

- `int arch_prctl (int code, unsigned long addr)`

Ad esempio:

- Se si vuole eseguire una **SET**, il contenuto del registro `GS` (= indirizzo base del segmento GS), bisogna settare il parametro `code` con un valore che indica “voglio eseguire una store su GS” e il parametro `addr` con l’indirizzo base che si vuole assegnare al segmento GS (dove addr è un unsigned long, che è un valore a 64 bit).

- Se si vuole eseguire una **GET** dell’indirizzo base del segmento GS o FS del thread corrente, il parametro `addr` è invece un puntatore a **unsigned** **long**, in quanto risulterà essere un parametro di output anziché un parametro di input.

In definitiva, il parametro code può assumere uno dei seguenti quattro valori: 

- `ARCH_SET_FS`

- `ARCH_GET_FS`

- `ARCH_SET_GS` 

- `ARCH_GET_FS`

Quindi con le GET ottengo l’indirizzo di memoria in cui c’è la base di FS o GS, mentre con la SET posso dire dove devono puntare FS o GS nell’address space (non modifico il contenuto, solo a dove puntano).   
Vengono anche aggiornati i relativi registri. In entrambe le system call ho a che fare con indirizzi (forniti o ricevuti). Posso usare queste chiamate per *superare* il TLS, in particolare:  
Prendo l’indirizzo TLS di un thread $A$ e lo salvo in una variabile (`ARCH_GET_FS`).
Successivamente, posso far puntare un thread $B$ a questo address (`ARCH_SET_FS`), se poi questo ultimo thread $B$ scrive, lo farà dove ha lavorato il thread $A$.

La system call restituisce $0$ in caso di successo, $-1$ altrimenti.

### Registri di controllo in x86_64

Originariamente i processori x86 disponevano di 4 **registri di controllo** (**CR0**, **CR1**, **CR2**, **CR3**) ma, in un secondo momento, è stato introdotto anche un quinto registro **CR4**. 

- **CR0**: baseline; è il registro che determina qual è l’**operatività** del processore. Il suo 0-esimo bit indica se stiamo operando in *real mode* (la modalità primitiva di accesso alla memoria senza paginazione) o in *protected mode* (posso usare o meno la paginazione). Per discriminare se stiamo operando in long mode (il che comunque è possibile solo se CR0 ci dice che siamo in protected mode), in realtà, bisogna ricorrere a un bit addizionale posto nel registro **EFER** (**Extended Feature** **Enable** **Register**), che appartiene alla classe **MSR** (**Model** **Specific** **Register**). Inoltre, il trentunesimo bit di CR0 indica se stiamo utilizzando la **paginazione**.

- **CR1**: registro riservato per l’operatività interna del processore. 

- **CR2**: registro che tiene traccia dell’indirizzo lineare che ha causato un eventuale fault di memoria: tale informazione è utile per il gestore del page fault. Usato dal kernel (es: uso `mmap` ma la pagina non è ancora allocata). Poichè possono incorrere diversi page fault, non posso aspettare “troppo tempo” per esaminarlo. 

- **CR3**: Se CR0 supporta *memoria virtuale* e paginazione, allora ho puntatore che referenzia la page table in memoria fisica. (quindi indirizzo fisico di Page table, perchè supporta la risoluzione di *indirizzo virtuale*).

La tabella illustrata di seguito riporta in modo più dettagliato le informazioni incapsulate nel registro CR0:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-08-24-image.png)

## Interrupt e trap

Sono i supporti che abbiamo per accedere al software di livello kernel. In particolare:

- Gli **interrupt** sono eventi **asincroni**, che consistono in una richiesta da parte di *dispositivi esterni alla CPU* di passare da un flusso di esecuzione in modalità *user* a un flusso di esecuzione in modalità *kernel*. 
  Possiamo chiamare una **interrupt** in modo *sincrono* tramite la macro `INT` (interrupt), la quale sfrutta i GATE invece che le JMP. Essa permette, tramite i GATE, di passare in kernel mode.

- Le **trap** (o eccezioni) sono eventi **sincroni**, che possono essere causati dalle istruzioni *eseguite in CPU* e possono a loro volta portare a un passaggio da un flusso di esecuzione in modalità *user* a un flusso di esecuzione in modalità *kernel*. Molteplici esecuzioni del medesimo programma, a parità di input, potrebbero (ma non necessariamente) sollevare le stesse eccezioni; questo può dipendere anche da ciò che avviene dal punto di vista della concorrenza: se per esempio nel programma abbiamo una divisione per una variabile $v$ condivisa tra più thread, si può avere o non avere un’eccezione in prossimità di tale divisione a seconda se nel frattempo un qualche thread abbia impostato la variabile $v$ a zero o meno. **Storicamente, le trap** **sono state utilizzate come un meccanismo esplicito e on-demand** **per passare all’esecuzione in modalità kernel.**  

In conclusione, gli interrupt e le trap portano a *migliorare* il livello di privilegio con cui il thread gira. Sappiamo che, per far ciò, bisogna ricorrere al meccanismo dei **GATE**. 

Il kernel mantiene una **trap / interrupt table**, che nei sistemi x86 è chiamata **Interrupt** **Descriptor** **Table** (**IDT**). In generale, si chiama **Trap Interrupt Table (TIT).** Ciascuna entry di questa tabella contiene un **GATE** **descriptor**, che fornisce le informazioni sull’indirizzo destinazione associato al GATE (*i.e.*`<segment.id, offset>`) e il livello di protezione massimo (ovvero peggiore) necessario per poter accedere al GATE. Di conseguenza, il contenuto della trap/interrupt table viene sfruttata per determinare se ciascun accesso a un qualche GATE può essere abilitato o meno, e questo viene fatto con un confronto con i registri di segmento (in particolare `CS`) che specificano appunto il *current privilege level* (CPL). Le varie entry della IDT, in realtà, possono avere anche altri metadati, come ad esempio un’informazione che indica se, a seguito del salto verso il segmento destinazione, il thread è interrompibile o meno. È possibile avere all’interno della trap/interrupt table più entry associate al medesimo GATE, di cui una può prevedere ad esempio un livello di protezione massimo differente rispetto a un’altra. Se uso un GATE non permesso, genero una TRAP. Uno stesso GATE può avere più entry uguali nella IDT.  Non ho limitazioni!

Ricapitolando, le variazioni del flusso di esecuzione possono avvenire in tre modi possibili: 

- **Intra-segmento**: avviene con un’istruzione standard di **jump** (e.g. `JMP <displacement>`). Qui il firmware si limita a verificare se il displacement cade all’interno del segmento in cui stiamo correntemente effettuando il fetch delle istruzioni. 

- **Cross-segmento**: avviene con un’istruzione di **long** **jump** (e.g. `LJMP <segment.id>,<displacement>`). Qui il firmware *verifica se* *non stiamo migliorando il livello di privilegio* e se il displacement cade all’interno del segmento destinazione. Quindi NO GATE. 

- **Cross-segmento via GATE**: avviene con un’istruzione di **trap** (e.g. `INT <table displacement>`). Qui il firmware controlla se il salto è permesso andando a comparare il livello di privilegio attuale col massimo previsto dalla entry della trap/interrupt table specificata come parametro dell’istruzione. Se il salto è concesso, viene acceduta la GDT per capire qual è il nuovo livello di privilegio da registrare all’interno di CS.

Nelle architetture x86 la IDT è accessibile mediante il registro `idtr`, che è un altro registro `packed` contenente l’indirizzo lineare in cui è ubicata la IDT e il suo numero di entry. Questo registro può essere modificato tramite l’istruzione macchina `LIDT`, in modo tale da cambiare la IDT a cui far riferimento.

Per quanto riguarda i sistemi Linux e Windows, il **GATE** per l’accesso al livello di protezione 0 on-demand (i.e. mediante l’istruzione **INT**) è **unico**. In particolare: 

- È la **entry 0x80** della IDT per i sistemi Linux (per cui l’istruzione ammissibile è INT 0x80). 

- È la entry 0x2e della IDT per i sistemi Windows (per cui l’istruzione ammissibile è INT 0x2E). 

- Qualunque altro GATE è riservato esclusivamente alla gestione delle trap e degli interrupt. Con INT, sto puntando al registro di tipo *packed* `idtr`. 

Puntiamo ad una struttura contenente indirizzo logico (non fisico) e la size. Tramite istruzione macchina LIDT, posso eseguire il load del contenuto. 

**Osservazione**: Se caricassi un modulo per cambiare la gestione delle interrupt, questo avverrebbe per la CPU in opera, e non per le altre CPU, che punterebbero alla vecchia gestione. Se facessi puntare tutte le CPU a questa nuova gestione delle interrupt **romperei tutto**, perchè, per via della mitigazione PTI dovuta a Meltdown, starei facendo questi puntamenti solo a livello kernel, mentre a livello user non so dove è stata memorizzata la mia nuova gestione delle interrupt.

Il blocco di codice del kernel raggiungibile a partire dall’istruzione di INT è detto **dispatcher**, che è un modulo software in grado di triggerare l’attivazione delle system call. Il dispatcher identifica quale *entry* usare. Questa organizzazione è importante per motivi di scalabilità: di fatto, viene impegnata un’ **unica entry** **della IDT per tutte le system call** **che il kernel mette a disposizione.**

## Dispatching delle system call

In base a quanto detto prima, per gestire le singole system call, si ricorre alla **system call table**, che è una struttura dati software che, per ogni entry, mantiene l’indirizzo di memoria di una specifica system call. Perciò, quando un processo deve invocare una system call, si rivolge al dispatcher, e lo fa passandogli l’indice numerico indicante la entry della system call table associata alla system call da invocare ed eventuali altri parametri. Dopodiché il dispatcher invocherà la system call mediante l’istruzione `call` che accetta come parametro l’offset del segmento corrente (che è quello relativo al codice di livello kernel) verso cui bisogna saltare (i.e. in cui inizia il codice della system call). La system call, a seguito della sua esecuzione, fornisce il suo valore di output all’interno di un registro di processore. Più precisamente, restituisce il controllo al dispatcher che si occuperà di attivare l’esecuzione del blocco di codice che ha lo scopo di ritornare alla modalità user: è qui che si ha l’istruzione **RTI** (return from interrupt) e si fornisce l’output della system call al chiamante. Di seguito è mostrato uno schema che fornisce un quadro d’insieme di quel che succede.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-08-47-image.png)

Nelle architetture moderne, in realtà, il dispatcher è più complesso di così: ad esempio implementa anche delle facility di sicurezza.

### Atomicità dell'esecuzione del dispatcher

Il dispatcher di default è **interrompibile**. Per proteggersi da eventuali interrupt, è possibile fare uso di due istruzioni: 

- **CLI** (clear interrupt bit), la quale elimina la possibilità per gli interrupt di interrompere l’esecuzione del dispatcher,

- **STI** (set interrupt bit), la quale ripristina l'opzione precedente.

Ciò potrebbe non essere sufficiente per l’atomicità dell’esecuzione del dispatcher: nelle architetture multiprocessore, si è soggetti a un accesso concorrente ai dati. Per ovviare a questo problema, si può ricorrere alle soluzioni classiche di **spinlock** o **Compare And Swap**.

### Componenti sw per la gestione delle system call

- Lato **user**: Si ha un modulo software che fornisce i parametri di input al GATE (e, quindi, al dispatcher), attivi il GATE e recuperi il valore di ritorno della system call. Il gate è `INT 0x80`, gli altri gate sono in IDT e si usano per runtime errors e interrupt. Quindi c’è una trap (appartenente alla IDT) che permette all’utente di usare il dispatcher. Il suo handler è interrompibile (ma abbiamo visto prima come settarlo).  
  In x86_64 non si usa più il meccanismo di trap.

- Lato **kernel**:  Si hanno il dispatcher, la system call table e il codice vero e proprio della system call (il quale, a sua volta, potrebbe anche invocare altre funzioni e così via). Non ho problemi in questa modalità, visto che sono elementi usati anche dallo user. Con una politica *per-cpu-memory ancora meglio*.

Per aggiungere una nuova system call, si possono seguire più possibili approcci: 

1) **Definire un nuovo dispatcher**:   
   Questo lo si fa nel caso in cui si voglia dispatchare la nuova **system call con regole diverse da quelle previste** **dal** **dispatcher** **già esistente**. Tale approccio richiede che esista una entry della IDT libera e che la si impegni per l’utilizzo del nuovo dispatcher. Non è consigliato soprattutto per le system call che devono essere montate in modo *definitivo* all’interno del kernel poiché è giusto avere tutti i servizi allineati nel dispatching e nell’attivazione. 

2) **Ampliare la system call table:**  
   Il problema grosso di quest’approccio è che porta alla necessità di effettuare enormi modifiche all’interno del Makefile del kernel, per cui non è agevole nella pratica. Ad esempio, ampliare la tabella senza altre modifiche nel kernel potrebbe portare a un overlap delle strutture dati in memoria. 

3) **Sfruttare le entry libere della system call table:**  
   Come approfondiremo meglio tra breve, abbiamo la fortuna di avere delle entry libere all’interno della system call table, che è possibile utilizzare senza dover apportare grosse modifiche al kernel e al suo Makefile. Di conseguenza, è *questo l’approccio che si adotta nella pratica*. Chiaramente ciò è possibile nel momento in cui il formato della nuova system call è **compatibile** con quello predefinito per il sistema operativo su cui stiamo lavorando.

### Indicizzazione delle system call

È un problema che consiste nell’associare ciascuna system call (*più precisamente* *il puntatore* *a* *ciascuna* *system call*) a un particolare codice numerico. Originariamente i sistemi Linux avevano lo schema di indicizzazione `UNISTD_32`. Oggi invece hanno `UNISTD_64` ma ancora con una **retrocompatibilità** con `UNISTD_32`. A livello user troviamo le informazioni sull’indicizzazione dei servizi del kernel all’interno di appositi header di programmazione (`unistd_32.h`, `unistd_64.h`). 

- Per lo schema di indicizzazione `UNISTD_32`, viene utilizzato proprio secondo le modalità che abbiamo descritto: si accede alla entry `0x80` della IDT per passare il controller al dispatcher che poi si occuperà di passare il controllo alla system call. 

- Per lo schema di indicizzazione `UNISTD_64`, si fa uso di *un’altra system call table* e di *un altro* *dispatcher*, il quale però **non è accessibile tramite la IDT** e, quindi, tramite l’istruzione `INT` (ne approfondiremo più avanti il meccanismo). Il formato `UNISTD_64.h` è *retrocompatibile*, ovvero posso usare il dispatcher mediante TRAP, mentre nell’applicazione senza retrocompatibilità non devo usare la TRAP. Questo mi permette, ad esempio, di accedere ad una syscall indicizzata da $k$ mediante il dispatcher $D$, e da $k’$ mediante il dispatcher $D’$.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-09-15-image.png)

### Task di livello USER per accedere al GATE

Sono i seguenti:

1) Specificare i parametri di input tramite dei registri di CPU, di cui uno è per il dispatcher (che sarebbe il codice numerico della system call da invocare) e i restanti, se esistono, sono da passare alla system call vera e propria.

2) Utilizzare istruzioni assembly (e.g. le trap) per triggerare i GATE: l’uso dell’assembly porta questo task ad essere machine dependent (chiaramente le istruzioni assembly dipendono dalla specifica architettura che stiamo utilizzando).

3) Recuperare il valore di ritorno della system call da appositi registri di CPU: anche quest’altra operazione è machine dependent.

### Formato predeterminato per le system call

È una regola che stabilisce come devono essere scritti i moduli che realizzano i tre task di livello user di cui sopra. Avere un formato predeterminato per il modulo user delle chiamate delle system call permette al modulo user stesso di eseguire delle attività compatibili col funzionamento del dispatcher: questo porta ad avere uno stato del processore che il dispatcher sia in grado di leggere e fornire al dispatcher i parametri in modo tale che lui abbia la possibilità di interpretarli e di manipolarli correttamente. Per ottenere questa compatibilità, si ricorre a degli **appositi** **file** **header**, che contengono delle macro associate a particolari funzioni. Queste funzioni implementano proprio i tre task di livello user per accedere al GATE in modo da seguire il formato predeterminato. Non solo: nei file header è anche possibile sfruttare le macro per definire delle nostre nuove funzioni, che possono essere composte da delle parti scritte in `C` e parti scritte in `assembly` (ASM inline). Queste funzioni sono anche chiamate **stub** **di system call**.

Un vincolo che abbiamo è che al software di livello kernel, quando si vuole invocare una system call, è possibile passare al più $7$ parametri: uno è appunto il codice numerico della system call che serve al dispatcher, mentre i restanti (al più 6) sono i parametri da fornire alla system call.

Vediamo un esempio di invocazione a una system call che non accetta parametri in input (e.g. `fork()`):


![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-09-44-image.png)

- `_syscall0(type, name)` è la **macro** associata alla funzione `name()` scritta successivamente, il cui tipo di ritorno è specificato proprio da `type`. Nell’esempio, `syscall0`, passo $0$ parametri, oltre tipo di valore di ritorno e nome della funzione di ritorno. 
- In `"0" (__NR_##name)` , il valore numerico (**l’indice**), viene associato al nome della system call  `__NR_##name`. ( *i.e.* nel caso della `fork()` il nome sarà `__NR_fork`).
  Tale valore deve essere posizionato all’interno del registro `eax`/`rax` affinché lo stato del processore sia coerente rispetto a quello che il dispatcher si aspetta. `name` viene usato per richiamare il simbolo `__NR_##name`, e prenderne il codice numerico. 
- In `"=a" (__res)` si impone che il valore di `eax`/`rax`, a seguito dell’invocazione dell’istruzione `int $0x80`, venga registrato all’interno della variabile `__res`.  In pratica, in `__res` viene inserito il valore di ritorno della system call. 
- L’ultima riga del blocco di codice, infine, prevede che il valore di `__res` venga processato in qualche modo dalla funzione associata alla macro `__syscall_return(type, __res)`.

Approfondiamo quest'ultima riga:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-10-05-image.png)

- Tipicamente, se l’esito della system call è positivo, il suo valore di ritorno è $\geq0$; altrimenti il valore di ritorno è nel range $(-124,-1)$.
  In questo secondo caso, viene *restituito $-1$ al chiamante* e viene impostato `errno` col codice di errore *specifico* (che è dato dal valore assoluto dell’output della system call). 

- Il blocco di codice è racchiuso all’interno di un `do-while(0)`, che prevede dunque un’*unica iterazione* (non è di fatto un ciclo). E’ “*one-shot*” perchè ritorna subito qualcosa, in quanto passiamo forzatamente per il `return`.Questa strutturazione permette di inserire la macro `__syscall_return(type, __res)` in qualunque punto del codice: ad esempio in tal modo è possibile aggiungere un “punto e virgola” dopo la macro (i.e. alla fine del blocco di codice) o incapsulare il blocco di codice all’interno di un costrutto if. Vengono anche chiamati blocchi “*all-or-nothing”.*

Vediamo ora un esempio di invocazione a una system call che accetta un unico parametro in input *“arg1”* (e.g. `close()`):

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-13-23-image.png)

-  `_syscall1 (type, name, type1, arg1)`, come è possibile notare, prevede $4$ parametri:
  
  - I primi due sono in comune con `_syscall0`.
  
  - `type1` è il tipo di dato che la system call accetta in input
  
  - `arg1` è il valore di input vero e proprio da passare alla system call. 

- All’interno del blocco di codice della funzione, l’unica differenza rispetto al caso di `_syscall0`, sta nel pre-caricamento dei registri: in particolare, oltre a inserire in eax/rax il codice numerico associato alla system call da invocare, il blocco di codice carica in `ebx`/`rbx` *il valore di input (castato a long) da passare alla system call stessa.*

Per quanto invece riguarda le system call che accettano 6 parametri in input:

```c
#define _syscall6(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4,type5,arg5,type6,arg6) \
type name (type1 arg1,type2 arg2,type3 arg3,type4 arg4,type5 arg5,type6 arg6) 
{ 
long __res; 
__asm__ volatile ("push %%ebp ; movl %%eax,%%ebp ; movl %1,%%eax ; int $0x80 ; pop %%ebp"
: "=a" (__res) 
: "i" (__NR_##name),"b" ((long)(arg1)),"c" ((long)(arg2)), 
 "d" ((long)(arg3)),"S" ((long)(arg4)),"D" ((long)(arg5))
 "0" ((long)(arg6))); 
__syscall_return(type,__res); 
}
```

Qui è interessante osservare come, in realtà, le architetture `x86` non dispongano di $7$ registri general purpose, ma solo $6$ (eax, ebx, ecx, edx, esi, edi, o comunque i corrispettivi dell’x86-64). Di conseguenza, quello che si fa è sfruttare anche il *registro* `ebp`. In particolare, in fase di pre-caricamento dati (prima di `INT 0x80`), in **eax** non viene inserito più il codice numerico della system call da invocare (che invece viene caricato in una locazione di memoria intera), bensì il **sesto parametro di input della system call** (quindi settimo parametro totale). In tal modo, subito prima dell’istruzione `int $0x80`, viene salvato il vecchio valore di `ebp` sullo **stack**, viene aggiornato il valore di `ebp` col sesto parametro della system call e viene aggiornato **eax** in modo da contenere il codice numerico della system call stessa. Chiaramente, a valle dell’esecuzione dell’istruzione `int 0x80`, il registro ebp dovrà essere ripristinato mediante una `pop`. Con `movl %1,%%eax` il valore $1$ coincide con primo elemento notazione, cioè dove ho `__NR_##name`, ovvero il **numero della syscall** da attivare. Non potevo caricarlo direttamente in **eax**, in quanto usato come registro tampone per scriverci ebp (`movl %%eax, %%ebp`).

## Convenzioni per l'invocazione delle syscall

### Convenzione di UNISTD_32 per l'invocazione delle system call

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-13-39-image.png)

Nell’immagine qui sopra è descritto come si presenta lo stack del kernel nel momento in cui viene invocata una system call. 

- Ebx, ecx, edx, esi, edi, ebp sono i registri contenenti *i parametri da passare alla system call.* 

- **Orig_eax** (che corrisponde al vecchio valore di eax) contiene il codice numerico della system call da invocare.

- Il registro **eax**, dopo che il suo vecchio valore è stato trasferito in `ebp`, dovrà contenere il valore di ritorno della system call. 

- Si hanno anche:
  
  - I *registri di segmento* (ds, es, cs, oldss),
  
  - L’*instruction pointer* da cui bisogna ripartire dopo l’invocazione della system call (eip),
  
  - Lo *stato dei flag del processore* (eflags)
  
  - Il *vecchio valore dello stack pointer* (oldesp), poiché si tratta di informazioni che devono essere memorizzate affinché vengano ripristinate a seguito dell’esecuzione della system call.

Tale organizzazione dello stack è **details**, in modo tale che il dispatcher sia estremamente semplice, le operazione compiute sono:

- *Posizionare sullo stack* tutto ciò che va da *ebx* a *orig_eax* nell’ordine giusto, i registri restanti vengono salvati sullo stack dal firmware.

- Far sapere alla system call *dove accedere sullo stack* per reperire le informazioni che le servono. Quindi c’è un intermediario, detto **wrapper**, che vede tutta la stack area, ma quando chiama l’oggetto mette solo i registri necessari (definiti dallo standard **ABI**, non c’entra nulla *asmlinkage*) ed aggiunge entropia.

Lo stack alignment 32 che abbiamo appena descritto è definito all’interno di una struct chiamata **pt_regs**, che specifica appunto l’ordine con cui devono essere collocate sullo stack le informazioni rappresentative per lo snapshot di CPU. Tra l’altro, il kernel ha la possibilità di accedere alle informazioni relative allo snapshot semplicemente tramite un puntatore a una struttura di tipo `pt_regs`.

### Convenzione di UNISTD_32 per l'invocazione delle system call

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-13-56-image.png)

Qui vengono definite soltanto lo stato dei flag del processore (tramite il registro`eflags`) e le informazioni relative ai registri general purpose. Infatti, in **x86-64** lavoriamo primariamente con un’**architettura di dispatching completamente diversa che non utilizza i GATE** (tant’è vero che non si utilizza l’istruzione `INT` bensì qualcos’altro come syscall/sysret) e non ha la necessità di memorizzare le informazioni associate ai registri di sistema (eccetto eflags). 

- Il registro `rax` contiene il codice numerico della system call da invocare. 

- I registri $rdi$, $rsi$, $rdx$, $r10$, $r8$, $r9$ contengono, nell’ordine, i parametri da passare alla system call. Il quarto argomento (`arg3`) può essere inserito nel registro `rcx` anziché in `r10` **solo** nel caso in cui stiamo lavorando con del **codice puramente C** (senza ricorrere a costrutti o operazioni machine dependent); altrimenti `rcx` verrà popolato dal firmware con l’indirizzo di ritorno dal quale bisogna riprendere l’esecuzione una volta che si è tornati in modalità user.

- I registri $r12$, $r13$, $r14$, $r15$, $rbp$, $rbx$ sono gestiti al livello del codice C ma non vengono toccati quando si passa il controllo al kernel. In particolare, se la funzione *callee* ha la necessità di utilizzare questi registri, sarà lei a dover preoccuparsi di salvarli all’inizio e ripristinarli prima di restituire il controllo al chiamante; il salvataggio e il ripristino degli altri registri, invece, sono a carico del chiamante. Questa regola, data dall’**ABI (Application Binary Interface) System V AMD64***, vale in generale e non solo per le system call, ed è molto utile nel momento in cui il *caller* e il *callee* si spartiscono il lavoro di salvare i registri sullo stack.

Il fatto che diverse informazioni, come l’indirizzo di ritorno, non vengano più salvate sullo stack per l’invocazione delle system call rappresenta un grosso vantaggio dal punto di vista prestazionale perché evita parecchi accessi in memoria. Un altro effetto che si ha è che il software è l’unico componente a registrare le informazioni sullo stack, anche quelle direttamente gestite dal firmware (come eflags).

### Dettagli sui passaggi dei parametri

Come abbiamo anche accennato in precedenza, una volta ottenuto il controllo, il dispatcher prende uno snapshot di registri di CPU e lo memorizza sullo stack di livello di sistema. Dopodiché invoca la system call allo stesso modo di come si effettuano le chiamate a *subroutine* (i.e. mediante l’istruzione di `CALL`). La system call vera e propria recupererà i parametri secondo l’ABI appropriata (non per forza lo farà mediante lo stack, ma potrebbe farlo leggendo i registri, perché magari il dispatcher ha dovuto eseguire delle attività complesse, ad esempio orientate alla sicurezza, che possono aver toccato i valori posti sullo stack). Lo snapshot dei registri di CPU può essere modificato contestualmente alla return della system call, ad esempio per lasciare al chiamante il valore di output.
![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-14-15-image.png)

- La porzione colorata in verde è relativa ai registri che vengono salvati nello stack per *opera del firmware*. 

- La porzione bianca è relativa ai registri che vengono salvati nello stack da *parte del software* (qui in particolare si hanno il codice numerico della system call e i parametri da passare alla system call stessa). 

- La porzione colorata in blu è relativa alle variabili locali *utilizzate dalla system call.*

**NB:** Nello standard `UNISTD_32`, anche quando vengono invocate system call con $0$ parametri, viene comunque salvato sullo stack l’intero snapshot dei registri di CPU. Ciò implica che il **kernel è in grado di visualizzare anche le informazioni che non gli competono**, il che rappresenta un’importante problematica per la sicurezza. Il sottosistema kernel prende i parametri sempre nello stesso modo, non posso decidere arbitrariamente di prenderli una volta dallo stack, e poi da altre parte. Dalla versione $4.17$ del kernel, **una entry della system call table non punta più direttamente al codice della system call**, bensì punta ad un **wrapper**, che sarà colui che la chiamerà effettivamente, passando anche i parametri dallo stack.  
Il wrapper si trova nel kernel, e svolge anche il ruolo di *allineatore di parametri*, ovvero adegua la taglia, poichè, causa retrocompatibilità, potrei avere un *elf 32 bit* e un *kernel 64 bit*, e lui ha il compito di risolvere queste incompatibilità. Inoltre, maschera dallo stack i valori non utilizzati, risolvendo il problema di sicurezza precedentemente esposto.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-14-25-image.png)

### Esempi di creazione di system call in UNISTD_32

#### Esempio di aggiunta di nuove syscall

```c
#include <unistd.h>
#define _NR_my_first_sys_call 254
#define _NR_my_second_sys_call 255
_syscall0(int,my_first_sys_call);
_syscall1(int,my_second_sys_call,int,arg);
```

### Esempio di override della fork

In *unistd.h* posso usare le macro, viene esposta la nuova syscall. Prima si prende il valore `__NR_##name` e dopo si chiama `INT 0x80`.

```c
#include <unistd.h>
#define __NR_my_fork 2 //same numerical code as the original
#define _new_syscall0(name) 
int name(void)
{ 
asm("int $0x80" : : "a" (__NR_##name) ); 
return 0; 
} 
_new_syscall0(my_fork)
int main(int a, char** b){
 my_fork();
 pause(); // there will be two processes pausing!!
}
```

## Implicazioni dell'uso di int 0x80

Questa istruzione di `trap` porta in primo luogo a effettuare un accesso alla IDT (sulla porta `0x80`) per accedere all’unico GATE che permette il passaggio dal livello di protezione 3 al livello di protezione 0 on-demand. Il passaggio per tale GATE comporta poi la necessità di accedere a un *segmento differente* dell’address space, per cui bisogna ricorrere alla GDT per recuperarlo. Non solo: tipicamente serve anche un secondo accesso alla GDT per reperire il *segmento TSS relativo al thread corrente*, perché è qui che si trovano le informazioni utili per recuperare lo stack di livello **kernel**. (infatti nel TSS mantengo l’indirizzo stack sia a livello $0$ sia a livello $3$). Quando creo un thread, automaticamente alloco stack. In generale, per gli accessi in memoria conseguenti all’istruzione `int 0x80`, possono trascorrere numerosi cicli di clock, e la loro varianza può essere molto elevata nel momento in cui abbiamo a che fare con hardware asimmetrici (vedi l’architettura **NUMA**). Questo è inaccettabile quando abbiamo a che fare con system call che richiedono un’alta precisione con il tempo, come `gettimeofday()`, che ha il compito di leggere il registro di CPU `rdtsc` per restituire il valore corrente del tempo.  Infatti, in queste condizioni, tale system call fornisce un risultato inaffidabile.

## Fast system call path

A causa della problematica appena esposta, è stata fatta una rivoluzione nei sistemi x86 che prevede la possibilità di passare il controllo al kernel **senza effettuare alcun accesso in memoria** e, quindi, senza accedere mai alla *IDT* e alla *GDT*. Affinché questo sia possibile, è necessario mantenere a livello di processore *le informazioni che ci permettono di transitare al livello kernel* e, in particolare, quali devono essere il *code* *segment* e *l’instruction pointer* nel momento in cui inizia l’esecuzione in modalità kernel. L’accesso alle informazioni senza ricorrere alla memoria è possibile grazie alla presenza di registri particolari **MSR** (**Model** **Specific** **Register**). Essi, infatti, mantengono: 

- Il segmento `CS` per il codice di livello kernel. 

- L’indirizzo dell’entry point del segmento `CS` relativo all’esecuzione in modalità kernel. 

- Il segmento `DS` per i dati di livello kernel.

- Lo stack di livello kernel.

Questo meccanismo è chiamato **fast system call** **path** e, a differenza dell’invocazione a `int 0x80`, *non crea più dei side* *effect* *sulla memoria*, bensì soltanto all’interno dell’architettura di processore. Per fare uso del fast system call path, si ricorre all’istruzione `sysenter` nelle architetture a 32 bit e all’istruzione `syscall` nelle architetture a 64 bit (long).

### Sysenter 32 bit

- Imposta il registro `CS` al valore contenuto in `SYSENTER_CS_MSR`. 

- Imposta il registro `EIP` al valore contenuto in `SYSENTER_EIP_MSR`. (per i riferimenti ai registri MSR).

- Imposta il registro `SS` a "$8 +$ valore contenuto in `SYSENTER_CS_MSR`". 

- Imposta il registro `ESP` al valore contenuto in `SYSENTER_ESP_MSR`, cambia la stack area.

### Syscall 64 bit

- Imposta il registro `CS` al valore dato da una *bitmask* presa da `IA32_STAR_MSR`. 

- Imposta il registro `EIP` al valore contenuto in `IA32_LSTAR_MSR`. 

- Imposta il registro `SS` al valore dato da una *bitmask* presa da `IA32_STAR_MSR`. 

- **Non** imposta il registro `ESP`.   
  Di fatto, quando viene invocata l’istruzione syscall, non viene effettuato uno switch automatico dello stack, bensì sarà il kernel a implementare il suo stack switch funzionale alle sue regole.

### Sysexit 32 bit

È un’istruzione usata nelle architetture a 32 bit per *tornare all’esecuzione in modalità user dopo l’esecuzione di una system call*. Più precisamente: 

- Imposta il registro `CS` a "$16 +$ valore contenuto in `SYSENTER_CS_MSR`.

- Imposta il registro `EIP` al valore contenuto in `EDX`.

- Imposta il registro `SS` a $24 +$ valore contenuto in `SYSENTER_CS_MSR`. 

- Imposta il registro `ESP` al valore contenuto in `ECX`.

### Sysret 64 bit

È un’istruzione usata nelle architetture a 64 bit per *tornare all’esecuzione in modalità user dopo l’esecuzione di una system call.* Più precisamente: 

- Imposta il registro `CS` al valore dato da una *bitmask* presa da `IA32_STAR`. 

- Imposta il registro `EIP` al valore contenuto in `RCX`. Serve per uscire dal kernel e tornare allo user. 

- Imposta il registro `SS` al valore dato da una *bitmask* presa da `IA32_STAR`.

- **Non** imposta il registro `ESP`. Esso viene utilizzato solo se serve salvare qualche cosa fatta!

Lo slow path esiste ancora oggi, usato da trap e interrupt. Ovviamente tra *unistd32* e *unistd64* si usano GATE e tabelle delle syscall diverse.

## Aggiornamento dei registri MSR

I registri MSR hanno delle macro associate a dei codici numerici in modo tale che queste macro possano essere sfruttate per effettuare delle operazioni di scrittura o di lettura sui registri stessi. Per le scritture si utilizza l’istruzione *wrmsr*, mentre per le letture si utilizza l’istruzione `rdmsr`.

```c
/arch/x86/include/asm/msr-index.h (kernel 5)
#define MSR_IA32_SYSENTER_CS 0x174 
#define MSR_IA32_SYSENTER_ESP 0x175 
#define MSR_IA32_SYSENTER_EIP 0x176

/arch/x86/kernel/cpu/common.c (kernel 5)
void enable_sep_cpu(void)→ 
wrmsr(MSR_IA32_SYSENTER_CS, tss->x86_tss.ss1, 0);
wrmsr(MSR_IA32_SYSENTER_ESP, (unsigned long
(cpu_entry_stack(cpu) + 1), 0);
wrmsr(MSR_IA32_SYSENTER_EIP, (unsigned long)entry_SYSENTER_32, 0);
```

## Costrutto syscall()

È un’API universale di `stdlib`, che permette al software di essere agnostico rispetto alla modalità in cui viene chiamata una system call (che può essere l’istruzione `int 0x80` o l’istruzione `sysenter`/`syscall`). Infatti, al suo interno può invocare una o l’altra istruzione in base a qual è disponibile nell’architettura corrente. Tale API accetta un numero di parametri variabile, che sono il *codice numerico* del servizio che si vuole invocare e gli eventuali *parametri da passare*a tale servizio. Ciò che ne consegue è una trasformazione in blocchi assembly che chiamano **syscall 64bit fast** oppure **int 0x80 32 bit slow**.

### Esempio echo

funzione echo: `time ./a.out > /dev/null`, compilo con `gcc –nostartfiles`, e poi testo con `flag –m32` (che risulterà essere poco più lento).

### Esempio stub system call

Di seguito è mostrato un esempio di utilizzo di syscall(), in cui vengono definiti due nuovi stub di system call:

```c
#include <stdlib.h>
#define __NR_my_first_sys_call 333
#define __NR_my_second_sys_call 334

int my_first_sys_call(){
 return syscall(__NR_my_first_sys_call);
}
int my_second_sys_call(int arg1){
 return syscall(__NR_my_second_sys_call, arg1);
}
int main(){
 int x;
 my_first_sys_call();
 my_second_sys_call(x);
}
```

## Virtual Dynamic Shared Object VDSO

È una piccola libreria **condivisa** (che occupa una o poche pagine di memoria) contenente l’effettiva implementazione dei meccanismi dati da *sysenter* e *sysexit*. Il kernel mappa tale libreria automaticamente a **run-time** nella zona **user** dell’address space di tutte le applicazioni. Lo scopo ultimo del VDSO è offrire un’interazione più efficiente e migliore possibile tra le applicazioni e il kernel, in particolar modo quando devono essere invocati i servizi del kernel. Quando si scrivono le applicazioni, non è necessario preoccuparsi esplicitamente di questi dettagli dato che tipicamente il VDSO viene chiamato dalla libreria C. Questo meccanismo ad oggi è molto utilizzato per implementare le invocazioni alle system call poiché, rispetto all’uso dell’istruzione `int 0x80`, riduce di molto il numero di accessi in memoria necessari e abbassa fino al 75% il numero di cicli di clock richiesti per avviare la system call. Per giunta, il VDSO è randomizzato all’interno dell’address space in modo tale da avere un maggiore grado di sicurezza. Ne abbiamo uno per ogni **processo** (ad esempio chiamata `exec()`).
![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-15-13-image.png)

Il VDSO può anche essere utilizzato direttamente dal programmatore mediante la seguente API:  
`void *vdso = (uintptr_t) getauxval (AT_SYSINFO_EHDR)`

Tale API ha lo scopo di prelevare dei valori ausiliari sull’operatività del VDSO, come l’indirizzo di memoria in cui quest’oggetto è posizionato. 

#### Ulteriori dettagli sulla system call table

Come abbiamo accennato in precedenza, il modo più opportuno per aggiungere nuovi servizi nel kernel consiste nel riutilizzare le entry della system call table attualmente libere. Non possiamo infatti incrementare l’address space, poichè potrei avere sovrapposizione tra strutture allineate in memoria, ciò è dato dal fatto che per qualche struttura abbiamo una mappatura $1-1$ tra indirizzo logico ed indirizzo fisico. Ciò richiederebbe la riconfigurazione del kernel, che è delicata. In particolare, nelle versioni del kernel più datate, la system call table era “oversized”, per cui presentava una vera e propria zona composta da tante entry del tutto inutilizzate. Nelle versioni più moderne, invece, non si ha più questo fenomeno (anche per motivi di sicurezza: meno memoria libera mettiamo a disposizione e minore è la probabilità di poter fare danni) ma esistono comunque delle entry sparse della system call table che sono fatte in un modo tale da puntare a un particolare modulo kernel che, quando viene invocato, l’unica cosa che fa è restituire il controllo all’applicazione utente. Tale modulo è detto `sys_ni_syscall`.   
**Queste entry a syscall non sviluppate puntano a “nessun servizio”**, non a “null”, altrimenti avrei segmentation fault.

## Definizione della system call table

- Per la versione 2.4 del kernel e le macchine i386 la system call table è definita nel seguente file: `arch/i386/kernel/entry.S`.
- Per le versioni 2.6 del kernel, la system call table è definita in: `arch/x86/kernel/syscall_table32.S`.
- Per le versioni 4.15 del kernel e UNISTD_64, la tabella è definita in: `arch/x86/entry/syscall_64.c`.

Attualmente, la table è prodotta a **compile time**, ed è un array di *size syscall_max+1*, quindi si ha una entry in più non usata. Tale entry serve per la normalizzazione, implementata per salti speculativi, ovvero salti ad indirizzi scorretti vengono mappati su questa entry che non fa nulla.

Possiamo notare che inizialmente questi file avevano un formato *.S*, erano cioè scritti con delle direttive ASM pre-processore. Nelle versioni più recenti del kernel, invece, ha iniziato a essere possibile definire la system call table direttamente in C (mediante un **array**). 

Inoltre, questi file contengono anche i GATE che vengono utilizzati per accedere alla modalità kernel. (Gate se slow, o l’equivalente dei gate per le fast syscall).

## Costrutto asmlinkage

Supponiamo di aver inserito all’interno della system call table dei puntatori a delle nuove system call in prossimità delle entry libere. Come possiamo fare per far sì che tali system call siano compliant (conformi), ad esempio, al passaggio dei parametri tramite lo stack di livello kernel? Basta utilizzare il costrutto **asmlinkage**. Per esempio, per il modulo `sys_ni_syscall` abbiamo:

```c
asmlinkage long sys_ni_syscall (void) { 
    return -ENOSYS; 
}
```

Ciò dipende dallo standard **ABI** adoperato, che definisce quali sono le istruzioni in linguaggio macchina da usare per fare le chiamate (system call) al kernel, il modo in cui devono essere passati i parametri per tali chiamate e come ottenere i valori di ritorno. Con ***asmlinkage*** il dispatcher effettua l’allineamento, ovvero genera codice che sa dove trovare i suoi parametri. (in realtà bisognerebbe citare anche la presenza del wrapper, qui per semplicità ancora non viene introdotto).

### Dispatcher con INT0x80, kernel 2.4, UNISTD32

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-15-42-image.png)

- L’istruzione `cmpl $(NR_syscalls), %eax` si occupa di confrontare il valore del registro *eax* (che contiene il codice numerico della system call che si vuole invocare) con *NR_syscalls*, che è il numero totale di system call che il dispatcher può gestire (comprese le varie *sys_ni_syscall*); in altre parole, controlla se eax cade all’interno dell’indirizzamento delle system call supportate dal kernel. Se la risposta è no, allora viene eseguita una jump verso una zona del codice etichettata con badsys. 

- Nel caso in cui il registro *eax* contenga un valore lecito, viene invocata la system call che, all’interno della system call table, si trova a spiazzamento `eax*4`, proprio perché ogni entry è di 4 byte. 

- restiamo molta attenzione alla porzione di codice evidenziata in giallo: qui si ha la possibilità di passare come parametro al dispatcher un indice numerico arbitrariamente grande (che eccede le dimensioni della system call table) e, attraverso un branch mis-prediction, anche se in maniera speculativa, di andare a invocare una call a un indirizzo di memoria che va oltre la system call table. Questo può lasciare degli effetti micro-architetturali importanti all’interno della macchina. Per ovviare a tale inconveniente, nelle versioni successive del kernel si è ricorsi alla tecnica della **sanitizzazione**.

### Dispatcher con SYSCALL, kernel 2.4, UNISTD64

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-16-09-image.png)

Ricordiamo che qui non ci sono gate, c'è altro, ma si usa sempre il dispatcher.

- La seconda e la terza istruzione (le `mov`) si occupano di eseguire lo switch dello stack dato che, come sappiamo, contestualmente al fast system call path, non viene effettuato alcun cambio automatico dello stack. (Qui ci serve, ma visto che la fast system call non lo fa in automatico, lo “forziamo” noi).

- L’istruzione `swapgs` porta ad aggiornare il registro di segmento GS. Swapgs switcha due registri MSR, uno contenente la GS area corrente e l’altro la GS area alternativa. Si lavora sempre col *current*. All’inizio parto da user, poi con swapgs passo a kernel. Questo è importante perché, quando si entra in *modalità kernel*, si inizia ad avere a che fare anche con la *per-CPU memory*, il che richiede di avere ***GS*** *settato* in modo tale da portarci in un’area di memoria **contenente le informazioni relative alla CPU su cui il thread corrente** sta girando, oltre a dove è posta **la stack area a livello sistema.** 

- La zona di codice evidenziata in giallo è del tutto analoga a quella del caso precedente e, in particolare, senza sanitizzazione è vulnerabile agli attacchi basati sul mis-prediction per i salti condizionali.

### Implementazione del dispatcher in kernel 4

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-16-30-image.png)

- Questo modulo, a differenza dei precedenti, non va a invocare direttamente il front-end che implementa il servizio richiesto, bensì un oggetto intermedio (uno **stub** o **dispatcher secondo livello**), che poi a sua volta passerà il controllo alla system call effettiva. Tale stub (che è mostrato qui di seguito) serve ad innalzare il livello di sicurezza.

![](img/2023-12-01-16-20-52-image.png)

- Al codice che identifica la system call viene applicata una maschera di bit che fa sì che il valore risultante non superi il numero di system call supportate dal kernel. Tale mascheramento viene effettuato prima del controllo su se il codice è compatibile con gli indici della system call table. Se la risposta fosse no, si accederebbe all’unica entry al di fuori della tabella che porterà a svolgere lavoro dummy. Ed ecco qui come abbiamo introdotto la sanitizzazione.

- Consideriamo lo statement `regs->ax = sys_call_table[nr](regs)`. Regs è il puntatore allo snapshot di CPU che viene salvato sullo stack. Inoltre, `sys_call_table[nr]` è proprio il puntatore alla funzione che si vuole invocare e che accetta come parametro proprio lo snapshot di CPU regs. Di conseguenza, l’istruzione mira a modificare il campo *ax* di regs inserendovi il valore di ritorno della system call. Non solo: stiamo anche facendo vedere in maniera semplicissima l’intero snapshot di CPU (con tutte le informazioni di livello user) alla system call stessa. Ovviamente questo non ha senso quando la system call invocata non accetta parametri in input. Per risolvere il problema, a partire dalla versione $4.17$ del kernel, dentro la system call table non sono più registrati gli indirizzi di memoria dei front-end dei servizi (i.e. gli indirizzi di memoria delle system call vere e proprie): piuttosto si hanno i puntatori a delle funzioni intermedie che, prima di invocare a loro volta le system call, offuscano lo stack di livello kernel (**wrapper**). Quindi non devo fare il disaccoppiamento user-kernel. Una tecnica per farlo è aggiungere del padding sullo stack in modo tale che la distanza tra lo stack pointer e lo snapshot di CPU con le informazioni relative alla precedente esecuzione in modalità user sia indeterminata. Per creare in **modo automatico** **questo doppio livello di funzioni**, si ricorre alle macro `SYSCALL_DEFINE0`, `SYSCALL_DEFINE1`,…, `SYSCALL_DEFINE6` (una per ciascun numero di **parametri** che possono essere passati alle system call). Quindi mediante queste macro si genera sia il wrapper sia la vera syscall (con il nostro codice). Decido io che nome dargli, e servono per essere identificate.

#### Esempio

```c
SYSCALL_DEFINE2 (name,param1type,param1name,param2type,param2name) {
   //actual body implementing the kernel side system call
}
```

La macro crea una funzione dal nome `sys_name` oppure `__x86_sys_name` (questo è il nome che affido io al wrapper) la quale passa all’effettiva system call soltanto i valori strettamente necessari (i.e. param1name e param2name), offuscando tutte le altre informazioni sullo stack.  
La system call prende il nome di`__se_sys_name` (dove “se” sta per secure), oppure `__do_sys_name`, dove “*name”* è lo stesso della macro vista sopra. È proprio quest’ultima a implementare il body di `SYSCALL_DEFINE2`.

### Implementazione del dispacher nelle versioni più recenti del kernel

![](img/2023-12-01-16-31-53-image.png)

- Poco dopo l’istruzione swapgs si ha uno `SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp`, che permette di conseguire la **Page Table** **Isolation** (**PTI**) mediante uno switch della page table (dove si passa dalla page table relativa alla modalità user alla page table relativa alla modalità kernel). Quindi col corretto `GS` posso utilizzare la per-cpu-memory. Essa fa alterazione dei registri, ma in maniera *speculativa*. Abbiamo due MSR come già detto: GS corrente e alternativo.

Notiamo che, sebbene si tratti dell’implementazione della funzione `syscall()`, qui stiamo pagando dei costi computazionali notevoli, soprattutto in termini di sicurezza: rispetto alla versione $2.4$ del kernel, vengono eseguite molte più attività prima dell’invocazione vera e propria della system call, e questo pesa in particolar modo sulle applicazioni system call intensive.

## Attacco swapgs

È basato sull’esecuzione speculativa di un pezzo di codice del kernel mediante la branch miss-prediction e sullo sfruttamento del cache side channel per determinare il valore acceduto speculativamente.
Vediamo un esempio:

```c
if (coming from user space) 
   swapgs
mov %gs: <percpu_offset>, %reg
mov (%reg), %reg1
```

Di fatto, qui è possibile dare luogo a una misprediction sulla condizione data dall’if e far sì che il processore, durante l’esecuzione del kernel, preveda che “coming from user space” sia *true* quando invece non si proviene dall’esecuzione in modalità user; di conseguenza, speculativamente, si cambia il segmento `GS` di riferimento (passando da quello utilizzato in modalità kernel a quello utilizzato in modalità user). I page fault sicuramente capitano a livello user, ma a livello kernel? Capita se a livello kernel devo specificare una pagina user (kernel scrive su una page su cui già opera l’user). Caotico! Le istruzioni successive consistono in un accesso al segmento `GS`; nel nostro caso, vengono lette in modo speculativo delle informazioni relative all’esecuzione user mode che, appunto, possono essere recuperate mediante un cache side channel. Devo fare l’operazione *swapgs* dentro l’if, sennò avrei problemi a non cambiare!

### Contromisure

- Effettuare l’**override** **di qualunque** **swapgs** mentre si è già in esecuzione in modalità kernel. Questo, però, richiede un’operazione di patching piuttosto onerosa lato kernel. Cioè sovrascrivo in ogni caso!

- Utilizzo istruzioni serializzanti, così se opero speculativamente e sbaglio, tutto viene squashato.

- Sfruttare la **SMAP** (**Supervisor Mode Access** **Prevention**) dall’hardware. Questo evita l’accesso a una qualunque pagina di livello user mentre si è in esecuzione in modalità kernel. Vedremo successivamente com’è possibile adottare tale contromisura. Usato in *memory management*.

## Compilazione del kernel

Qui *configuro* cose che posso usare durante lo startup Linux, non stiamo facendo lo startup di queste cose! Stiamo solo creando contenuto file system.

Avviene secondo i seguenti step: 

1. `make config`: per ogni sottosistema software, chiede all’utente se il kernel deve includere quel sottosistema software oppure no. È buona norma seguire questo step impostando un apposito file di configurazione; in alternativa, si potrebbe effettuare la configurazione a mano, come:
   
   - *allyesconfig*, ma può dare problemi di conflitti.
   
   - *allnorconfig*, che invece non da mai errore in quanto è un *set minimale*. Con questo secondo approccio, nel core del kernel non c’è supporto al *virtual file system*. Non viene incluso alcun sottosistema software, ottenendo verosimilmente un kernel con non offre abbastanza servizi.
   
   - Scegliere io cosa mettere e non mettere, ma è lungo e non banale.
   
   - Prendere un file di configurazione dal web
   
   - Se ricompilo la versione del kernel che già possiedo, posso usare il file di config già esistente, nella directory `ls /boot`. Qui ci sono info su compilazione kernel, risultati (cioè immagini dei kernel) e mappe (danno metadati).

2. `make`: esegue la compilazione vera e propria del core del kernel, basandosi su quanto indicato dal file di configurazione. Alla fine della compilazione viene generata un’immagine I del kernel. Utilizza i moduli.

3. `make modules`: esegue la compilazione dei moduli, che sono oggetti che non fanno parte dell’immagine I generata col comando make. I moduli vengono agganciati a I per dare luogo a una nuova immagine I’ del kernel. Chiaramente i moduli possono sfruttare le funzionalità già presenti nel kernel (i.e. nell’immagine I).

4. `make modules_Install` (**ROOT**): effettua l’installazione dei moduli all’interno del sistema, andandoli a inserire nella directory `/lib/modules`. Poiché va a scrivere su delle porzioni del file system che non possono essere modificate da chiunque, è uno step che può essere seguito solo nei panni dell’utente root.

5. `make Install` (**ROOT**): effettua l’installazione dell’immagine del kernel, della system map e del file di configurazione, andandoli a inserire nella directory /boot. Anche questo step può essere seguito solo nei panni dell’utente root.

6. `mkinitrd -o initrd.img-<vers> <vers>`: crea un RAM disk, che è un file system *montato temporaneamente* dal kernel *durante la fase di boot*, e contiene alcuni moduli compilati. Quando il RAM disk è montato, i relativi moduli vengono agganciati a run-time al kernel; dopodiché il file system viene smontato dal sistema. Tale oggetto deve essere generato! **Initrd** è un file system usabile come tale solo su finestra temporale ben precisa, perchè lo monta, estrae e monta i moduli, e poi smonta tale file system.

Infine, affinché il kernel (coi relativi moduli che sono stati compilati, installati ed eventualmente riportati su un RAM disk) sia avviabile a seguito della compilazione e dell’installazione, è necessario aggiornare il **boot loader** attraverso il comando `update-grub` (approfondiremo i dettagli sul boot loader più avanti). 

**Esempio**: `grep HZ /boot/config-[version]` , mi da info sugli switch da interrupt.

**NB**: oggi è anche possibile agganciare una directory al Makefile per la compilazione del kernel; chiaramente tale directory deve contenere a sua volta un altro Makefile per eseguire correttamente gli step di compilazione aggiuntivi.

## System map

Sono dei makefile o anatomie (o tabella o mappa), compilate. È una serie di informazioni che indica qual è la mappa del kernel all’interno dello spazio di indirizzamento lineare. Mi dice cosa posso trovare ad un certo indirizzo logico. Più precisamente, ci dice qual è l’indirizzo lineare in cui si trova ciascuna routine e ciascuna struttura dati del kernel definita a tempo di compilazione. Tuttavia, non tiene conto della **randomizzazione**: perciò, per ottenere l’indirizzo lineare effettivo in cui si trova un oggetto kernel, bisogna sommare un offset randomico all’indirizzo indicato dalla system map.

All’interno della system map, ciascun simbolo (i.e. ciascun oggetto) è associato a un tag che indica di che tipo è quel simbolo:

- **T** = funzione globale.

- **t** = funzione locale all’unità di compilazione.

- **D** = dati globali.

- **d** = dati locali all’unità di compilazione.

- **R** = dati read-only globali. (qui neanche il root può scriverci!).

- **r** = dati read-only locali all’unità di compilazione.

La system map viene utilizzata per il debugging e per l’hacking a run-time del kernel. È inoltre riportata (anche se in modo parziale) all’interno dello pseudo-file  `/proc/kallsysm`, il quale soprattutto in passato è stato sfruttato per il montaggio di nuovi moduli del kernel: di fatto, se un modulo fa uso di una funzione o una struttura dati già presente nel kernel, è necessario averne un riferimento che, appunto, viene fornito direttamente da `/proc/kallsysm`. Questo file è leggibile sia con root (con effettivi riferimenti), se lo leggo a livello user dà indirizzi tutti posti a 0.

## Startup del kernel

I componenti che entrano in gioco durante lo startup del kernel (i.e. mentre il software del kernel viene caricato in memoria) sono: 

- **Firmware**: è un programma codificato sulla ROM (Read-Only Memory). Presente sull’hw. 

- **Bootsector**: è un settore predeterminato di un dispositivo che mantiene il codice dello startup del sistema. Ne sono esempi disco o ssd, è la “prima” zona del dispositivo. Tipicamente prelevo il bootloader, che caricherà il kernel del sistema operativo.

- **Bootloader**: è il codice eseguibile effettivo che viene caricato e lanciato prima di passare il controllo al sistema operativo. Viene mantenuto in parte all’interno del bootsector, in parte in altri settori.  
  Può essere utilizzato anche per parametrizzare il boot effettivo del sistema operativo.

### Task dello startup

1) Il firmware va in esecuzione, e carica in memoria e lancia il contenuto del *bootsector*. 
2) Il codice del bootsector viene dunque eseguito e carica a sua volta le altre porzioni del bootloader. 
3) Il bootloader, in ultima istanza, carica in memoria il kernel del sistema operativo e gli passa il controllo.
4) **Il kernel esegue le sue azioni di startup**, che possono comprendere l’attivazione del codice software, delle strutture dati e dei processi. Tra i processi attivati figura sempre il cosiddetto **idle** **process**, che serve essenzialmente a far sì che all’interno del sistema *esista sempre almeno un processo in esecuzione.*

**Il bootloader fa il boot, il kernel esegue lo startup del sistema operativo.**

## Bios - Basic I/O System

È il firmware tradizionale dei sistemi x86. È possibile colloquiare con lui lanciando particolari interrupt (e.g. tramite i tasti F1, F2,…). L’interazione col BIOS serve ad esempio per parametrizzare l’esecuzione del firmware all’avvio del sistema, dove la parametrizzazione può determinare l’ordine con cui i bootsector vengono cercati nei diversi dispositivi.

Comunque sia, il primo bootsector contiene il **master boot record** (**MBR**), che mantiene del codice eseguibile e una tabella (la **partition** **table**) con *quattro entry*; ciascuna di queste entry identifica una *partizione* del dispositivo, e il *primo settore di ogni partizione* *può operare come un bootsector*.  
È possibile anche che una partizione sia suddivisa a sua volta in quattro sotto-partizioni, ciascuna delle quali può mantenere il proprio bootsector (in tal caso parliamo di **partizione estesa**). L’evoluzione è UEFI. Nella pagina seguente sono riportati il MBR e un esempio di schema del dispositivo con il BIOS:

![](img/2023-12-01-16-50-34-image.png)

Il limite di 2 TB per la quantità di memoria a disposizione per i dispositivi sui quali è possibile effettuare il boot è stato superato dalla **UEFI** (**Unified** **Extended Firmware Interface**), con cui si possono raggiungere anche i $9$ zettabyte (= $9 \cdot 10^{21}$ byte).

## UEFI - Unified Extended Firmware Interface

È il nuovo standard per il supporto di base dei sistemi (e.g. gestione del boot). È in grado di eseguire gli **eseguibili EFI** (Extended Firmware Interface) piuttosto che caricare e lanciare semplicemente il codice del MBR. E’ più flessibile, perchè posso impostare delle condizioni che devono verificarsi o meno. Inoltre, per essere configurato, offre delle interfacce al sistema operativo anziché essere raggiungibile esclusivamente tramite l’invio di interrupt.

In UEFI, il partizionamento del dispositivo è molto più complesso rispetto al BIOS ed è basato sulla **GPT** (**GUID** **Partition** **Table**, dove il GUID è il Globally Unique Identifier). Questa tabella è più complessa rispetto alla partition table introdotta precedentemente (taglia variabile) ed è replicata: quest’ultima caratteristica fa sì che, se una copia della GPT dovesse essere corrotta, continuerebbe ad essere possibile raggiungere e utilizzare le partizioni del dispositivo. Con essa identifico le partizioni, poichè fornisce degli *id*, il numero di caratteri è ampia, e permette un numero di collisioni molto limitato. Con GPT possiamo accedere ad una *partizione EFI SYSTEM PARTITION (STARTUP)* ed identifica la zona in cui ci sono gli eseguibili (`/boot/efi`).  
Il type che evidenzia questa zona è “*vfat*”.

## Task BIOS/UEFI durante il kernel del SO

1. Il bootloader / EFI-loader carica in memoria l’immagine iniziale del kernel del sistema operativo. L’immagine include un **machine setup code** (= codice che effettua il setup dell’architettura), che deve essere eseguito prima che il codice del kernel vero e proprio prenda il controllo.

2. Il machine setup code passa il controllo all’immagine iniziale del kernel, la quale inizia la propria esecuzione a partire dalla funzione `start_kernel()` che si trova in `init/main.c`. Richiama lo startup di altre cose. E’ altamente configurabile, posso dirgli di gestire un tot di memoria rispetto a quella totale che ho, ad esempio. All’inizio **non c'è** per-cpu-memory, però con `smp_processor_id()`, che richiama `cpuid`,  posso riconoscere il primo processore che esegue lo startup. Non posso fare tutto a compile time, e alcune cose vengono generate ed inizializzate dal processore.

**NB**: Tale immagine del kernel è differente sia nelle dimensioni che nella struttura da quella che prenderà il controllo in steady state (i.e. dopo che il sistema è stato avviato del tutto).

**Quindi prima *boot* del bootloader, poi startup del kernel, e poi kernel diventa *steady state.* Per il kernel, possiamo anche parlare di *boot* del kernel, sinonimo di startup.**

## Startup del kernel in macchine multicore

Nei sistemi multi-core o multi-hyperthread, per effettuare il boot di un sistema Linux si possono adottare diverse soluzioni. La più importante consiste nel far eseguire lo startup soltanto a una CPU (detta **master**), mentre le altre (dette **slave**) attendono mediante un busy waiting che venga caricata in memoria l’immagine del kernel in stady state. In questa soluzione, la prima cosa che fa ciascuna CPU è invocare l’istruzione `cpuid`: se risulta essere la CPU$_0$, allora è il master e procede con lo startup del kernel; altrimenti, è uno slave e si limita a fare busy waiting. Il codice che decodifica queste (e altre) attività si trova all’interno del file `head.S` (o una sua variante), il quale viene eseguito da tutti i processori.

# Kernel Level Memory Management

Allo startup, eseguiamo attività inizialmente esterne allo stack kernel, poi faccio setup stato processore e memoria. Il software usa indirizzi logici, e devo settare il supporto agli indirizzi fisici, senza considerare la randomizzazione. Tutto ciò che succede ci porta allo *steady-state*. Inoltre, molte cose servono solo allo startup, quindi potrei liberare memoria fisica, soprattutto in termini di sicurezza lascio dei **gadget** usabili per attacco.

## Caricamento del kernel in memoria fisica

La regione della memoria fisica in cui viene caricata l’effettiva immagine del kernel è determinata dal *bootloader* sfruttando la randomizzazione. Di conseguenza, nella zona iniziale della memoria RAM può esserci un buco non utilizzato:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-17-16-image.png)

Ricordiamo che il software del kernel, per effettuare gli accessi in memoria, utilizza tipicamente gli indirizzi virtuali. Perciò, in fase di startup è necessario *organizzare una page table corretta* per essere in grado di raggiungere la zona della memoria fisica desiderata. La tabella è insieme di entry da cui parto da indirizzo logico diretto verso indirizzi fisici, ma a quali indirizzi logici/entry li associamo?

Tutto quello che abbiamo detto per la memoria fisica (RAM), vale anche per la memoria logica (address space): la zona dell’address space delle applicazioni in cui viene posta l’immagine del kernel è, di nuovo, determinata dal bootloader sfruttando la randomizzazione:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-17-26-image.png)

Dunque, nel momento in cui si definisce la page table, è necessario porre attenzione anche nella definizione degli indirizzi logici (da associare poi a quelli fisici). Possiamo avere PT diverse, e quindi collocazioni diverse. 

*Come possiamo definire una page table (raggiungibile dal kernel) che associ correttamente tutti gli indirizzi logici dell’immagine del kernel ai corrispettivi indirizzi fisici in memoria tenendo conto che si ha la randomizzazione del posizionamento del kernel sia a livello logico che a livello fisico?*

È chiaramente necessario conoscere la posizione (l’offset) della *page table del kernel all’interno* *dell’immagine del kernel*; questo impone che la compilazione del kernel abbia dei limiti, ad esempio per quanto riguarda la possibilità di espandere le strutture dati.

![](img/2023-12-01-19-45-20-image.png)

La kernel page table (raffigurata qui sopra) è nota come **identity** **page table**. Durante la fase di startup, prima che la identity page table sia finalizzata, il bootloader sfrutta un’altra page table *preliminare* che serve per ritrovare in memoria l’immagine del “booting kernel” (che ricordiamo essere diversa dall’immagine del kernel in stady state), inclusa l’identity page table;  
questa page table preliminare è detta **trampoline** **page table**.

![](img/2023-12-01-19-47-28-image.png)

### Caso base - indirizzi non randomizzati

- L’indirizzo fisico dell’identity page table è noto a compile time. So dove viene montata, a partire da `addr 0`.
- Anche l’indirizzo logico dell’identity page table è noto a compile time (così come qualunque altra porzione del kernel). E’ un offset a partire dalla sua base. 
- Il codice di startup per la traduzione degli indirizzi virtuali in indirizzi fisici può semplicemente impostare l’identity page table in modo tale che, a ogni indirizzo logico, sia associato il relativo indirizzo fisico già noto a compile time. 
- Già a questo punto la paginazione può essere avviata sul processore.

### Avvio della paginazione durante lo startup

Tornando allo startup di un sistema Linux multi-core / multi-hyperthread, prima dell’invocazione dell’istruzione `cpuid`, quello che si fa è appunto aprire la paginazione. A tal proposito riprendiamo il codice di `head.S` relativo alle architetture a $32$ bit, che è stato menzionato precedentemente.

```c
/* Enable paging */ 3:
movl $swapper_pg_dir - __PAGE_OFFSET, %eax /* eax = indirizzo della memoria logica in cui è locata 
la page table - offset(dove l’offset indica la differenza
tra l’indirizzo della memoria logica e l’indirizzo della memoria fisica dove si trova il kernel)
In tal modo, scrivo su eax = indirizzo della memoria fisica in cui è locata la page table;
ci serve l’indirizzo fisico e non logico perché il registro cr3 può puntare solo a indirizzi fisici.
L’offset è di 3 Gb.*/
movl %eax, %cr3 /* set the page table pointer, scrivo eax su cr3 */
movl %cr0, %eax
orl $0x80000000, %eax /* or logico bit a bit, il numero a sinistra è un 1 (a sx) e 31 zeri (a dx) */
movl %eax, %cr0 /* set paging bit (= indicazione del fatto che si vuole paginare) */
```

Per quanto riguarda le architetture a $64$ bit che supportano la versione $5$ del kernel Linux, si ha il file `head_64.S`, la cui logica è del tutto analoga:

```c
addq $(early_top_pgt - __START_KERNEL_map), %rax  /* __START_KERNEL_map == __PAGE_OFFSET */
... /* here in the middle we account for other stuff like randomization.
* Qui ci riferiamo al trampolino per lo schema di randomizzazione,
early_top_pgt NON è la page table a livello kernel.
L’early è a compile time.*/
movq %rax, %cr3
... /* in the end, paging will be activated */
```

## Patch Meltdown hardware

Abbiamo visto la Page Table Isolation come soluzione *software*, in cui facciamo operazioni non proprio banali, come resettare i TLB. Queste cose *rompono* la randomizzazione, perchè la mappatura in memoria fisica del kernel inizia in un certo punto, quello prima non è mappato. Se Page Table non ci dà info, ci mette in stallo, il che comporta non aver nulla in cache.  
Se non vado in stallo, non leggo le info per via della patch, ma ho annullato la randomizzazione perchè ho tempi di risposta diversi. Posso migliorare la patch, mappando comunque le pagine non ancora mappate sullo stesso indirizzo di memoria fisica, così non ho più il **delay di tempo**.

## Ram durante lo startup

Come sappiamo, durante lo startup del sistema abbiamo in memoria l’**immagine iniziale del kernel****. Più precisamente, l’immagine iniziale è organizzata in RAM secondo lo schema mostrato nella pagina seguente. (sia nel caso randomizzato che non).

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-17-51-image.png)

La roba relativa all’inizializzazione, che corrisponde alla zona in rosso della figura, diventa completamente inutile una volta che il kernel ha raggiunto un comportamento steady state. Tale zona della RAM, dunque, dopo lo startup viene eliminata, e questo in generale lo si fa ogni volta che si hanno delle informazioni divenute inutili in modo tale che:

- Venga ottimizzata la gestione delle risorse (i.e. si ha più RAM libera a disposizione).

- Si abbia un maggior adattamento con l’aumentare della complessità dello startup.

- Si abbia una maggiore sicurezza (e.g. vengono eliminati dei potenziali gadget).

La page table è *non yet final data*.  
La parte *reachable* consente *lettura* e *scrittura*, ma non può andare oltre le zone colorate.

### Funzioni ___init

Sono funzioni che devono essere in memoria soltanto durante la fase di boot del kernel.  

#### Esempio

 `__init *start_kernel* (void)`   
 Tale funzione vivrà solo durante il kernel boot/startup.

La fase di linking del kernel si occupa di posizionare queste funzioni su specifiche pagine logiche. Esse sono identificate all’interno del sottosistema del kernel chiamato **bootmem** (memoria di boot, è un set di metadati con dei bit settati per essere identificati), che viene usato per gestire la memoria quando il kernel non si trova ancora a steady state. Al completamento del boot, queste pagine logiche vengono rilasciate come riutilizzabili e sovrascrivibili.

In bootmem non abbiamo esclusivamente le funzioni marcate come` __init`, bensì è anche possibile allocarvi dinamicamente della memoria.

Oggi si usano i ***memblock*** invece che *bootmem*, qui abbiamo dati che cascano all’interno di specifiche zone NUMA differenti, mentre con bootmem si aveva una visione lineare. Ovviamente cambiano anche le API. Sono tutti allocatori di memoria, il concetto è simile alla mmap, ma con meccanismi diversi!

In definitiva, l’immagine iniziale del kernel (quella relativa alla **fase di boot**) appare così:

![](img/2023-12-03-16-44-41-image.png)

### Reachable Page

Il software del kernel può accedere all’effettivo contenuto di una pagina in RAM semplicemente esprimendo un indirizzo *virtuale* che caschi all’interno della pagina. Le immagini iniziali sono compatte allo startup, aumentano nella fase di boot del kernel. L’unico modo che abbiamo per convertire l’indirizzo virtuale in un indirizzo fisico e, quindi, accedere alla corrispondente locazione fisica in memoria, è disporre di un’apposita page table. Dunque, le pagine che sono rappresentate all’interno della page table sono dette **pagine raggiungibili** (reachable pages).

### Organizzazione della RAM nelle macchine moderne

Come già detto, le macchine moderne (multi-processore / parallele) hanno un’architettura NUMA  (Non Uniform Memory Access) della RAM, in cui la latenza per l’accesso delle informazioni in memoria non è uniforme per tutti i CPU-core: si hanno alcuni banchi di RAM limitrofi a un CPU-core, altri banchi di RAM vicini a un altro CPU-core, e così via (dove ciascun processore risiede in uno specifico nodo NUMA). Di fatto, non siamo attualmente in grado di rendere questa latenza uniforme (ovvero di avere un’architettura UMA – Uniform Memory Access) in maniera efficiente.   
**UMA**: passo per stesse componenti, poca concorrenza.   
**NUMA**: CPU arrivano in memoria su componenti diverse, vero parallelismo. Oggi è *main-line*.

### Numactl

È un comando (`numactl  --hardware`) che permette di scoprire: 

- Quanti nodi NUMA sono presenti in una determinata macchina. 

- Quali sono i nodi NUMA vicini / lontani da ciascun CPU-core. 

- Qual è la distanza effettiva dei nodi NUMA da ciascun CPU-core.

- La taglia di ogni nodo NUMA.

## Memblock

È l’evoluzione della bootmem che implementa una logica aggiuntiva che consiste nel tenere traccia dei frame di memoria liberi (“free”) e occupati **per ciascun nodo NUMA**. Nonostante le API per gestire la memoria nella bootmem e nel memblock siano leggermente differenti, l’essenza di tali operazioni è rimasta la stessa. In particolare, per quanto riguarda l’allocazione di nuove pagine (“low pages”), abbiamo: 

- La possibilità di ottenere l’indirizzo virtuale delle pagine allocate nella *bootmem*  (mediante l’API `**alloc_bootmem_lowpages()`). Kernel ancora in setup! Stiamo facendo ancora startup. 

- La possibilità di ottenere sia l’indirizzo *virtuale* (mediante le API `memblock_alloc*()`) sia l’indirizzo *fisico* (mediante le API `memblock_phys_alloc()`) delle pagine allocate nel memblock.

Quando ho concluso lo startup, queste non servono più!

## Strutture dati per la gestione della memoria

Si hanno tre principali strutture dati del kernel che supportano la gestione della memoria: 

- **Kernel page table:** è la identity page table, ed è quindi una sorta di tabella delle pagine “ancestrale”, da cui derivano tutte le altre tabelle delle pagine. Serve a mantenere un mapping tra indirizzi logici e indirizzi fisici del codice e dei dati di livello kernel.

- **Core map:** è un array che tiene traccia dello stato dei frame di memoria fisica. Possiamo vederla come costituita da più parti, ognuna associata a un singolo nodo NUMA. 

- **Free list:** è una struttura dati che ci riporta ai frame liberi di memoria fisica. Anch’essa è costituita da più parti, ognuna associata a un singolo nodo NUMA.

**Nessuna di queste strutture dati è già finalizzata nel momento in cui il kernel del sistema operativo viene mandato in startup**. In particolare, la core map e la free list non esistono proprio (le informazioni sui frame di memoria fisica sono date dalla bootmem o dal memblock), mentre *la kernel page table non si trova ancora in uno stato definitivo.* Di conseguenza, alla fine dello startup, le strutture dati devono essere istanziate o modificate.

Nella pagina seguente è riportato uno schema molto semplice che mostra la relazione tra la core map e le free list (dove si può vedere che le *free list* sono collegate alla core map dove si hanno frame di memoria fisica liberi). Free list viene chiamata, interroga Core map per farsi tornare zona.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-18-14-image.png)

Le free list sono accessibili in concorrenza da tutte le CPU per prendere memoria, dobbiamo sincronizzarle. Esistono meccanismi di Caching, in particolare facendo pre-reserving delle locazioni. La kernel page table prende indirizzo lineare (non segmentato), **la segmentazione c’è prima**.  
Indirizzi logici e poi fisici, si alloca nello spazio lineare con indirizzi assoluti.

**NB:** quando programmiamo a livello kernel, la core map non è direttamente esposta; piuttosto, le API che abbiamo a disposizione (i.e. le API di buddy allocation, che analizzeremo successivamente) utilizzano le free list e, inoltre, sono in grado di gestire correttamente la concorrenza di molteplici thread. Esistono anche *quick list*, perchè sono per-cpu, quindi niente sync.

## Kernel page table

Ci dice come vediamo lo spazio! Gli obiettivi del setup della kernel page table sono:  

1) Permettere al kernel di utilizzare gli indirizzi virtuali per andare a raggiungere le informazioni poste in memoria fisica. 

2) Permettere al kernel di raggiungere la quantità massima di memoria RAM disponibile (che dipende dalla specifica macchina e dallo specifico chipset).

In effetti, uno dei motivi per cui la forma finale della page table non è data all’interno dell’immagine del kernel in memoria è proprio che la quantità di RAM da pilotare deve essere *parametrizzata*. Ma di fatto come si esplica il secondo obiettivo? Durante la fase di startup, in realtà,**il kernel è contenuto in una porzione molto limitata della RAM**, e si espande solo successivamente. Perciò, col tempo, il kernel deve avere la possibilità di accedere a un insieme di indirizzi fisici sempre più ampio, ma questo implica che ci si deve poter espandere su una maggiore quantità di indirizzi logici. E, per aumentare la quantità di indirizzi logici da sfruttare, è necessario cambiare la struttura della kernel page table. Utilizzare questo meccanismo anziché caricare subito l’intera immagine del kernel in RAM presenta un ulteriore vantaggio in termini di efficienza nella fase di setup del kernel: infatti, per caricare subito l’intera immagine in RAM, è necessario prelevare informazioni da un dispositivo di I/O (e sappiamo bene che la comunicazione coi dispositivi di I/O è molto onerosa), mentre, dall’altra parte, è direttamente il software a scrivere delle informazioni in RAM in un secondo momento.

## Pagine di memoria directly mapped

Sono pagine di livello kernel il cui mapping sui frame fisici è basato su un semplice shift (costante) tra gli indirizzi virtuali e quelli fisici.   
Dati PA = Physical Address, VA = Virtual Address, abbiamo:   
*PA = y(VA)*, dove y() è una funzione che sottrae un **valore costante** predeterminato al parametro di input (VA). E’ possibile fare l’inverso. Funziona anche con randomizzazione, aggiustando la funzione y().

Non tutte le pagine di livello kernel sono **directly** **mapped**, per cui abbiamo questa situazione:

![](img/2023-12-03-17-10-55-image.png)

Tipicamente, **diverse pagine logiche directly mapped sono mappate su frame fisici differenti**.  
Tuttavia, non è escluso che una qualche pagina logica non directly mapped venga mappata su un frame fisico che corrispondeva già a una pagina logica directly mapped. Per quanto riguarda la contiguità: - Le pagine *directly* *mapped* risultano contigue sia in memoria logica che in memoria fisica. - Le pagine *non* *directly* *mapped* possono essere contigue in memoria logica ma non contigue in memoria fisica. Posso navigare Identity Page Table per vedere dove è mappata fisicamente, a patto che non ci siano update concorrenti sulla table.

### Zone

È tipico per il kernel del sistema operativo organizzare la memoria fisica in ZONE, ciascuna delle quali determina il tipo di utilizzo delle relative pagine. Le ZONE più note sono: 

- **DMA**: è utilizzata per riservare la memoria a specifiche operazioni di dispositivo; comprende i primi 16 MB di memoria fisica. Legata alla randomizzazione del kernel, da 16 MB in su! 

- **NORMAL**: è utilizzata per le pagine del kernel *directly* *mapped*; comprende la sezione della memoria fisica che va dal megabyte 16 al megabyte 896.

- **HIGH**: è utilizzata per le pagine del kernel *non* *directly* *mapped* e le *pagine user*; comprende la sezione della memoria fisica successiva al megabyte 896. Elementi lato user non sono MAI directly mapped! Il suo scopo era aumentare la flessibilità. Posso rimapparla in maniera arbitraria per raggiungere zone.

### Caso di Linux nei sistemi x86_64 long mode

Abbiamo $2^{48}$ indirizzi logici. Lo spazio è mappato direttamente, ma la stessa memoria può essere anche presa non directly-mapped, che uso quando ho frammentazione. (quindi ho un doppio mapping, inoltre lo scheAma directly mapped aveva il limite di 1 GB). Prendo pagine logiche contigue (zona arancione) che mappa su memoria fisica, anche appartenente a Numa code diversi. Ottimo anche per la sicurezza, con un mapping sempre 1 $\rightarrow$ 1 sarebbe più facile!  
Qui ci mettiamo cose che vogliamo mascherare, come le stack areas dei thread! Qui il kernel prende tutta la RAM per il direct mapping. In realtà, può anche prendere l’intera memoria RAM per le pagine non directly mapped.  
 Questa funzionalità deriva semplicemente dalla possibilità di indirizzare tantissima memoria logica e fisica nei sistemi x86-64: è possibile, infatti, usare $2^{48}$ byte nell’address space logico. *Comunque sia, qui le ZONE non sono più rilevanti,* *ma rimangono nell’architettura.*

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-18-39-image.png)

## Organizzazione kernel e struttura page table in i386

### Organizzazione del kernel in i836

Nei sistemi i386 *(x86* *protected* *mode*) avevamo la versione 2.4 del kernel. Qui, allo startup del kernel, l’indirizzamento è basato solo su due pagine grandi 4 MB ciascuna, per cui in questa fase abbiamo un kernel di soli 8 MB e una page table iniziale con due sole entry utilizzabili. La regola di paginazione utilizzata è identificata da appositi bit all’interno della page table. Inoltre, sappiamo che esiste il registro CR3 che punta direttamente alla tabella delle pagine (indicandone l’indirizzo fisico). Di conseguenza, il kernel deve conoscere il posizionamento esatto in memoria della page table in modo tale da poter inizializzare correttamente CR3 in fase di startup.

Nella pagina seguente è riportato uno schema del kernel durante lo startup nei sistemi i386.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-18-51-image.png)

Come è possibile vedere, la page table iniziale è compresa **negli** **8** **MB in cui il kernel** **può espandersi durante la fase di startup**. Anche la *bootmem* si trova lì, e serve per tenere traccia delle aree di memoria libere (“free”) in quegli 8 MB.

Per quanto riguarda l’indirizzamento lineare dei sistemi i386, all’interno di un address space è possibile esprimere al più 4 GB (232) di indirizzi logici. 

- I primi 3 GB sono utilizzati per le informazioni di livello user. 

- L’ultimo GB è utilizzato per le informazioni di livello kernel. 

Nel caso in cui ad esempio il kernel occupi tutta la memoria fisica a disposizione, si può andare incontro a dei conflitti nel momento in cui diviene necessario materializzare in RAM delle pagine di livello utente;  
in tal caso, la parte user può utilizzare i frame fisici che il kernel le mette a disposizione.

### Struttura page table in i386

Molto spesso le pagine da 4 MB per l’indirizzamento della memoria risultano essere inadeguate. Per questo motivo, i sistemi i386 mettono a disposizione due modi di effettuare la paginazione: 

- **Paginazione a 1 livello**:  
  Prevede pagine da **4 MB**. Qui gli indirizzi, che sappiamo essere a 32 bit, sono suddivisi in questo modo:   
  I primi 10 bit identificano la pagina su cui l’indirizzo deve essere mappato (i.e. l’offset della page table che punta a quella pagina);   
  I restanti 22 bit indicano l’offset all’interno di quella pagina (infatti $2^{22}$ byte = 4 MB). Il vantaggio di questa organizzazione è dato dalla presenza di un’unica page table; tuttavia, spesso, pagine così grandi non sono così agevoli da utilizzare *(basti pensare che, per allocare una struttura dati di pochi byte, bisogna materializzare ben 4 MB di memoria*): di conseguenza, tale organizzazione è tipicamente usata solo durante la fase di startup.

- **Paginazione a 2 livelli**:  
  Prevede pagine da **4 KB**. Qui gli indirizzi sono suddivisi in quest’altro modo:   
  I primi 10 bit (**PDE** – **page directory entry**) identificano l’offset della page table di primo livello che punta alla page table di secondo livello da esaminare;   
  I secondi 10 bit (**PTE** – **page table entry**) identificano l’offset della page table di secondo livello che punta alla pagina su cui l’indirizzo deve essere mappato; infine, i restanti 12 bit indicano l’offset all’interno di quella pagina (infatti $2^{12}$ byte = 4 KB).  
  Nulla vieta di avere una applicazione *mista*, in cui, partendo da una page table, per alcune entry andiamo direttamente al frame fisico, per altre puntiamo a tabelle che a loro volta puntano ad un frame fisico.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-19-05-image.png)

La page table è necessariamente collocata in memoria in maniera allineata rispetto al frame fisico.  
Questo vincolo è dovuto al fatto che il registro `CR3` è in grado di esprimere gli indirizzi di memoria con la granularità dei 4 KB. Comunque sia, quando abbiamo una page table da 4 MB, questa è tipicamente racchiusa in un **unico frame di memoria fisica**, mentre quando abbiamo la paginazione a due livelli, è possibile che ciascuna page table si trovi su più frame fisici non contigui tra loro, purché venga mantenuto l’allineamento rispetto ai frame stessi.

Riassumendo, **per passare dalla fase di startup del kernel alla fase steady state**, è necessario far fronte alle seguenti problematiche:

1) È necessario passare da una granularità delle pagine di 4 MB a una granularità delle pagine di 4 KB.

2) È necessario estendere a 1 GB la quantità di memoria logica riservata al kernel.

3) È necessario riorganizzare la page table in due livelli separati.

4) È necessario identificare le aree di memoria libere tra gli 8 MB già raggiungibili per poter espandere la page table. 

5) Non è possibile utilizzare altre facility di memory management al di fuori della paginazione, dato che, come sappiamo, la *core map* e le *free list* esistono soltanto dopo che il sistema è andato in steady state. Dunque, come suggerito in precedenza, per recuperare e sfruttare le aree di memoria libere, si ricorre alla *bootmem*.

Dunque, il layout del kernel 2.4 nei sistemi i386 a steady state è il seguente:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-19-23-image.png)

Ora, negli 8 MB iniziali, si hanno anche le page table di secondo livello, esattamente nelle locazioni che prima erano contrassegnate come “free” dalla bootmem. Nel frattempo, è stato anche necessario modificare i bit delle page table che indicano la regola di paginazione utilizzata.

Di seguito è riportato uno schema riassuntivo sull’evoluzione delle page table durante la fase di boot del kernel:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-19-40-image.png)

## Paginazione nei sistemi i386 in Linux

Linux vede in realtà la paginazione come organizzata a *tre livelli*. Ciascun indirizzo è dunque suddiviso nel seguente modo:

![](img/2023-12-03-17-41-24-image.png)

Dove:

- **PGD** (page general directory) = bit che identificano l’offset della page table di primo livello che punta alla page table di secondo livello da andare a guardare. 

- **PMD** (page middle directory) = bit che identificano l’offset della page table di secondo livello che punta alla page table di terzo livello da andare a guardare. 

- **PTE** (page table entry) = bit che indicano l’offset della page table di terzo livello che punta alla pagina di memoria su cui l’indirizzo deve essere mappato. 

- **Offset** = bit che indicano lo spiazzamento da applicare all’interno della pagina di memoria.

Il numero di bit di ciascuna di queste quattro porzioni degli indirizzi è variabile.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-19-56-image.png)

Tuttavia, sappiamo che i sistemi i386 supportano al più due livelli di paginazione: per motivi di compatibilità, Linux, all’interno dei sistemi i386, **prevede che** **la sezione** **PMD** **degli indirizzi di memoria sia composta da zero bit**. Di conseguenza, si crea il seguente mapping: 

- PGD di Linux $\rightarrow$ PDE di i386 

- PTE di Linux $\rightarrow$ PTE di i386

In Linux è possibile definire il numero di entry da cui è composta ciascuna tabella all’interno del file `include/asm-i386/pgtable-2level.h`:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-20-14-image.png)

- Per compatibilità coi sistemi i386, si pone un numero di entry per la page middle directory pari a 1, che corrisponde appunto ad avere 0 bit associati al campo PMD degli indirizzi e, quindi, a non disporre proprio della PMD.

- Poiché *ciascuna page table occupa 4 KB di memoria*, ponendo 1024 entry per ogni tabella, si hanno delle entry grandi **4 byte**.

- Avere 1024 entry per la tabella di primo livello e 1024 entry per le tabelle di ultimo livello implica che possiamo mappare fino a $1024 \cdot 1024 = 2^{20}$ pagine di memoria distinte.

Inoltre, in kernel 2, all’interno del file `arch/i386/kernel/head.S`, viene definito il simbolo `swapper_pg_dir`, che esprime l’indirizzo di memoria virtuale della PGD che viene correntemente utilizzata. Il valore con cui viene inizializzato *swapper_pg_dir* dipende dalle scelte che si fanno a livello di compilazione (e, quindi, da come viene definita l’immagine iniziale del kernel). D’altra parte, in kernel 3 il simbolo definito per questo scopo è ***init_level4_pgt***, mentre in kernel 4 e 5 è **init_top_pgt**.

Le page table in sé sono invece definite all’interno del file `include/asm-i386/page.h` come delle struct composte da un solo campo (che esprime il contenuto delle loro entry):

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-20-28-image.png)

La definizione di tre struct tutte uguali (**i.e. tutte con un unico campo di tipo unsigned long*) evita che il programmatore ponga una variabile $x$ di tipo `PTE_t` uguale a una variabile $y$ di tipo `PGD_t` (operazione ammessa in C se PTE_t, PMD_t e PGD_t fossero semplicemente una ridefinizione del tipo unsigned long), il che sarebbe scorretto dato che si tratta di page table significativamente differenti tra loro (ad esempio presentano bit di controllo diversificati).

### Entry della PDE nei sistemi i386

![](img/2023-12-03-17-58-07-image.png)

- **Page-table base** **address**: indica l’indirizzo di una tabella di secondo livello oppure l’indirizzo di una pagina da 4 MB.

- **Page-table base** **address**: indica l’indirizzo di una tabella di secondo livello oppure l’indirizzo di una pagina da 4 MB. 

- **G** (**global page**): bit ignorato.

- **PS** (**page size**): se vale $0$, vuol dire che il page-table base address indica l’indirizzo di una tabella di secondo livello (che sappiamo essere di 4 KB); se vale $1$, vuol dire che il page-table base address indica l’indirizzo di una pagina di memoria da 4 MB.

- **0** (**reserved**): bit riservato.

- **A** (**accessed**): bit che indica se la pagina è stata acceduta (i.e. se il firmware è riuscito a effettuare una traduzione da indirizzo logico a indirizzo fisico); è uno sticky flag, nel senso che viene settato a 1 dal firmware ma può essere resettato a 0 esclusivamente dal software.

- **PCD** (**cache** **disabled**): se vale 0, vuol dire che il caching è abilitato per la pagina (o il gruppo di pagine) corrispondente alla presente entry; se vale 1, vuol dire che il caching è disabilitato.

- **PWT** (**write-through**): se vale 0, la cache policy utilizzata per la pagina (o il gruppo di pagine) corrispondente alla presente entry è il write-back; se vale 1, vuol dire che la cache policy utilizzata è il write-through.

- **U/S** (**user/supervisor**): se vale 0, la pagina (o il gruppo di pagine) corrispondente alla presente entry gode dei privilegi supervisor; se vale 1, la pagina (o il gruppo di pagine) gode dei privilegi user.

- **R/W** (**read/write**): se vale 0, la pagina (o il gruppo di pagine) corrispondente alla presente entry può essere acceduta solo in lettura; se vale 1, la pagina (o il gruppo di pagine) può essere acceduta sia in lettura che in scrittura.

- **P** (**present**): bit che indica se la presente entry è valida (i.e. se ci porta effettivamente su una pagina o un gruppo di pagine).

**NB**: Non c’è nulla all’interno della entry che ci dice se possiamo fare il fetch (lettura) di istruzioni all’interno della pagina (o del gruppo di pagine) corrispondente oppure no. Questo rappresenta un problema di sicurezza nel momento in cui è consentito effettuare il fetch di qualunque cosa all’interno dell’address space.

### Entry della PTE nei sistemi i386

![](img/2023-12-03-18-20-19-image.png)

- **Page base** **address**: indica necessariamente l’indirizzo di una pagina.

- **PAT** (**page table** **attribute** **index**): è una don’t care.

- **D** (**Dirty**): bit che indica se la pagina corrispondente alla presente entry è stata acceduta in scrittura (e, quindi, è stata modificata); anch’esso è uno sticky flag.

**NB**: anche qui non c’è nulla all’interno della entry che ci dice se possiamo fare il fetch di istruzioni all’interno della pagina corrispondente oppure no.

**NBB**: all’interno del file header include/asm-i386/pgtable.h sono definite alcune macro che indicano la posizione dei bit di controllo delle entry della PDE o PTE. Esse possono essere utilizzate per estrarre le relative informazioni di controllo dalle entry della PDE o PTE.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-20-51-image.png)

## Relazione tra page table ed eventi di trap/interrupt

Quando viene eseguita un’istruzione I che vuole accedere a un indirizzo di memoria, in caso di TLB miss, è necessario ricorrere alla page table per effettuare una traduzione tra indirizzo logico e indirizzo fisico. 

In tale scenario, il primo controllo che viene fatto è quello sul *presence* *bit*: se la entry della page table esaminata è valida, allora viene generata una trap che porta alla materializzazione del frame fisico in memoria e alla riesecuzione dell’istruzione I (che, di fatto, è risultata essere offending). A valle di tutto questo, potrebbero essere generate anche ulteriori trap: ad esempio, una seconda trap viene essere sollevata se I è un’istruzione di scrittura e, quando viene controllato il bit R/W, emerge che l’indirizzo di memoria target è accessibile solo in scrittura; in tal caso, avremmo un segmentation fault.

### Algoritmo di inizializzazione delle page table in i386 nel kernel 2.4

I seguenti step vengono seguiti ciclicamente: 

1) Determinare l’indirizzo virtuale da mappare in memoria fisica; chiaramente tale indirizzo (indicato dalla variabile **vaddr**) sarà diverso a ogni iterazione, e il limite massimo da considerare è mantenuto all’interno della variabile **end**. 

2) Allocare una PTE (una tabella di secondo livello che gestisce 1024 pagine), che verrà collegata alla tabella di primo livello (PDE) che è stata definita a partire dalla page table relativa alla fase di startup (per cui, in effetti, la PDE e la page table relativa alla fase di startup coincidono). 

3) Popolare le entry della PTE. 

4) Ora il prossimo indirizzo virtuale da mappare (vaddr) sarà 4 MB più avanti rispetto a quello appena mappato. 

5) Saltare allo step 1 fin tanto che esistono ancora indirizzi virtuali da mappare (ovvero fin tanto che vaddr $<$ end).

**NB**: Ciascuna entry della PDE viene settata per puntare alla PTE corrispondente solo dopo che tale PTE è stata popolata correttamente. Se così non fosse, il mapping della memoria andrebbe perso a ogni TLB miss.

All’interno dell’algoritmo appena descritto, vengono utilizzate le seguenti funzioni: 

- `set_pmd()`: è una macro che implementa il settaggio di una entry della PMD (che, nel caso di Linux, corrisponde al settaggio di una entry della PDE). 

- `mk_pte_phys()`: è una macro che costruisce un’entry della PTE, che include l’indirizzo fisico del frame target. 

- `__pa()`: dato un indirizzo virtuale del kernel, restituisce il corrispondente indirizzo fisico nel caso in cui valga il direct mapping.

Chiaramente esiste anche l’operazione duale a `__pa()`, che è `__va()`. Se anticipassimo `set_pmd` prima del ciclo presente sopra, sarebbe un errore grave. Questo perchè dobbiamo considerare anche il firmware. Se una zona è acceduta, la aggiungo a TLB, e potrei raggiungerla anche senza entry di secondo livello, ma se non ci fosse nel TLB, salterebbe tutto.

## PAE Physical Address Extension

I sistemi x86 a 32 bit considerati finora presentano un limite molto importante: sia per esprimere gli indirizzi lineari, sia per il physical addressing si hanno a disposizione solo 32 bit. Di conseguenza, sia gli address space che la memoria RAM dei calcolatori possono estendersi a un massimo di $2^{32}$ byte = 4 GB. Col passare del tempo, soprattutto per quanto riguarda la memoria fisica, questo limite ha iniziato a risultare particolarmente stretto. A tal proposito, viene in soccorso la **PAE** (**Physical** **Address** **Extension**), che consiste nell’aumento da 32 a 36 del numero di bit utilizzati per il physical addressing; perciò, è ora possibile avere una memoria RAM che si estende fino a $2^{36}$ byte = 64 GB, anche se il limite per gli address space dei processi rimane di 4 GB. Il vantaggio sta dunque nella possibilità di materializzare in memoria fisica pagine relative a un numero maggiore di processi attivi. Questo meccanismo ha però un’implicazione importante: le tabelle delle pagine, per essere in grado di ospitare gli indirizzi fisici estesi, devono avere delle entry di maggiori dimensioni. In particolare, per mantenere la struttura originale delle page table ed evitare così di effettuare modifiche troppo radicali al Makefile del kernel, si è deciso di raddoppiare la dimensione delle entry di tutte le page table e di dimezzarne il numero (da 1024 a 512). Poiché, nella trattazione svoltasi finora, si hanno due livelli di paginazione, si va incontro a un supporto di $\frac{1}{4}$ dell’address space (un fattore 2 è dato dal dimezzamento del numero di entry della page table di primo livello e un fattore 2 è dato dal dimezzamento del numero di entry della page table di secondo livello). Per compensare questa riduzione, si aggiunge un terzo livello di paginazione e, più precisamente, si inserisce una tabella top level chiamata **page directory pointer table**, che dispone appunto di 4 entry ed è puntata direttamente dal registro CR3. Il bit 5 del registro CR4, invece, indica se la PAE è attivata o meno.

## Architetture x86-64

Estendono lo schema PAE mediante il cosiddetto **long** **addressing** **mode**, mettendo a disposizione 64 bit per esprimere gli indirizzi di memoria. Perciò, almeno a livello teorico, consentono un indirizzamento di memoria logica di $2^{64}$ byte. Nelle implementazioni effettive, però, si possono raggiungere al più 248 indirizzi (che comunque consentono di spannare su ben 256 TB).
Questi $2^{48}$ indirizzi sono nella cosiddetta **forma canonica**, per cui sono suddivisi in due metà dette **higher** **half** e **lower** **half**: in particolare, tra i 48 bit utilizzabili, il più significativo determina automaticamente il valore degli altri bit ancor più significativi (dal 48 al 63). Di conseguenza, gli indirizzi esprimibili sono quelli con i *17 bit* *più significativi tutti pari a 0* e quelli con i *17 bit più significativi tutti pari a 1*: tutti gli indirizzi che cadono nel *mezzo* sono detti non canonici e non sono utilizzabili.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-21-09-image.png)

In realtà, non tutti i sistemi operativi permettono di sfruttare l’intero range di 256 TB di memoria logica / fisica esprimibile con 48 bit. Ad esempio, Linux ad oggi mette a disposizione 128 TB per l’indirizzamento logico e 64 TB per l’indirizzamento fisico. Ciò dipende dal setup della tabelle delle pagine, la parte user di Linux usa la metà, ovvero $2^{47}$, lo scopo è ottimizzare la circuiteria del processore, in quanto è stato visto che con tale valore per indirizzare address fisici era la più adatta.

In definitiva, l’address space di un’applicazione in un sistema x86-64 si presenta così:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-21-18-image.png)

Normalmente, tutto ciò che riguarda direttamente l’applicazione viene posizionato nella parte alta dell’address space (i.e. la porzione con gli indirizzi più bassi rispetto alla zona in nero non utilizzabile), mentre tutto ciò che riguarda direttamente il sistema (e.g. il VDSO) viene posto nella parte bassa dell’address space.

### Page table nelle architetture x86-64

Qui viene introdotta la paginazione a 4 livelli dove il nuovo livello di paginazione è chiamato **Page-Map** **level** e, in tutti i livelli, ogni pagina è composta da 512 entry. Con questo schema è possibile indirizzare $512^4$ pagine di dimensioni pari a 4 KB ciascuna, per cui nominalmente si ha a disposizione una memoria totale proprio di 256 TB. La struttura delle page table è raffigurata qui di seguito:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-21-44-image.png)

Nella pagina seguente, invece, è riportato il contenuto delle entry delle page table di tutti e quattro i livelli di paginazione.

![](img/2023-12-04-14-23-58-image.png)

- Per quanto riguarda le entry della tabella di primo livello (PML4E), si hanno due possibilità: presence bit = 0 (entry non valida); presence bit = 1 (entry valida che punta a una tabella di secondo livello).

- Per quanto riguarda le entry delle tabelle di secondo livello (PDPTE), si hanno tre possibilità: presence bit = 0 (entry non valida); presence bit = 1 AND page size bit = 0 (entry valida che punta a una tabella di terzo livello); presence bit = 1 AND page size bit = 1 (entry valida che punta direttamente a una pagina di 1 GB.

- Per quanto riguarda le entry delle tabelle di terzo livello (PDE), si hanno tre possibilità: presence bit = 0 (entry non valida); presence bit = 1 AND page size bit = 0 (entry valida che punta a una tabella di quarto livello); presence bit = 1 AND page size bit = 1 (entry valida che punta direttamente a una pagina di 2 MB.

- Per quanto riguarda le entry delle tabelle di quarto livello (PTE), si hanno due possibilità: presence bit = 0 (entry non valida); presence bit = 1 (entry valida che punta a una pagina di 4 KB).

Di seguito sono riportati tutti i campi della PTE per quanto riguarda le architetture x86-64:

![](img/2023-12-04-14-26-22-image.png)

Notiamo stavolta che è presente un flag che indica se la pagina di memoria puntata è eseguibile o meno (i.e. se vi si può effettuare il fetch delle istruzioni o meno). Tale flag è **XD** (che sta per **execute** **disable**), ed è molto importante dal punto di vista della sicurezza poiché *previene che un attaccante* *inietti* *del codice* *eseguibile malevolo all’interno dei segmenti dell’address* *space* *che non siano di testo (i.e. dati, stack e così via).*

### Direct mapping vs non-direct mapping in x86-64

Una entry della PML4 può essere associata fino a $22^7$ frame di memoria che, moltiplicati per 4 KB, danno luogo a $22^9$ KB = $2^9$ GB = 512 GB. In tal modo, nei chipset più comuni, abbiamo spazio in abbondanza per effettuare il mapping diretto di tutta la RAM disponibile all’interno delle pagine del kernel (ed è quello che si fa tipicamente in Linux). Comunque sia, ogni volta che è necessario, è possibile anche rimappare la stessa memoria RAM in una maniera non diretta.

## Huge Pages

Sono le pagine che possono essere puntate direttamente dalle PDE (ovvero quelle da 2 MB). A livello applicativo, possono essere mappate attivando il flag *MAP_HUGETLB* nella chiamata a mmap() oppure attivando il flag *MADV_HUGEPAGE* nella chiamata a `madvise()`. È possibile vedere quante huge page sono attualmente in uso nel sistema all’interno di `/proc/meminfo` oppure all’interno di `/proc/sys/vm/nr_hugepages`. Le pagine da 1 GB, invece, non sono utilizzabili a livello applicativo, bensì soltanto dal kernel.

Prendere una huge page di 2MB, per una certa regione mmappata, è una ottimizzazione perchè ho pagine fisiche (frame) contigue invece che frame diversi. Però dove è l’ottimizzazione? Perchè è meglio avere pagine vicine? Non c’entra il NUMA, ho facility che permetterebbe di avere indirizzi logici contigui e di unire i frame. La risposta è che se lavoro con pagine sparse, la probabilità che ci siano due linee di cache conflittanti è non nulla, mentre è nulla se pagine contigue. (Se ho due pagine diverse, e tocco la prima linea di cache di una, escludo l’altra perchè avrei un conflitto). Se ho due indirizzi fisici *i* ed *i’*, che corrispondono a stessa linea dell’architettura di cache (sottoinsieme della RAM). Con contiguità in memoria fisica, saranno sicuramente su due linee di cache diverse. Devo specificare quante *huge table* sono utilizzabili.

## Supporto hardware alla virtual memory

Si usano delle shadow copies, ad esempio il CR3 è del processore virtuale. Allora Guest CR3, ci permette di arrivare su tabella di primo livello, poi secondo etc. L’indirizzo fisico non è un vero indirizzo fisico, bensì logico, e viene passato alla tabella delle pagine del processo virtual machine. Qui ci arriviamo con CR3 vero, e prendiamo il vero indirizzo fisico. Magari la VM la vede con indirizzo 0, ma nella realtà non lo è!  
Il problema è che si compiono attività non consone alla sicurezza. **Ad esempio, se arriviamo ad una pagina non valida** (sia quando passo tre le tabelle primo e secondo livello, sia a Second Level Address Transaction), viene **comunque passato in cache L1**.  Questo perchè “magari” qualcosa in cache L1 c’è, e questo è alla base dell’attacco **L1TF**. Ho thread su VM, ho configurato Page Table per avere indirizzo frame a cui voglio accedere, e ci metto bit di invalidità. **Se vi accedo, niente si mette in mezzo.**

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-22-05-image.png)

## Attacco L1 Terminal Fault L1TF

Sappiamo che, se accediamo a una entry di una page table, il primo controllo che viene effettuato è sul *presence bit*: se quest’ultimo è pari a 0 (entry non valida), potrebbe essere possibile eseguire delle istruzioni in modo speculativo sfruttando le informazioni contenute all’interno di quell’entry della page table. Da qui nasce l’**attacco** **L1TF**, che prevede la seguente idea: se abbiamo una entry di una page table con presence bit pari a 0 (non valida), la entry stessa potrebbe comunque aver propagato i suoi valori (e in particolare il `TAG`, ovvero i bit associati al presence bit) all’interno dell’architettura di memoria. Se il `TAG` viene utilizzato come un indice per andare a sporcare lo stato della cache (cache L1), si compie un attacco dello stesso stile di Meltdown: infatti, poiché il TAG appartiene a una entry non valida della page table, risulta essere un indice non accessibile (i.e. accessibile solo speculativamente).

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-22-29-image.png)

**L’attacco va a buon fine nel momento in cui** **il contenuto della** **entry** **invalida** **della page table mappa su dei dati** **attualmente salvati in cache**. Infatti, una mitigazione che è stata attuata consiste nel fare in modo che il kernel imposti il valore delle entry non valide a valori opportuni che non mappano su dati cachabili. Si tratta di una mitigazione e non della soluzione definitiva perché esiste ancora un caso in cui la vulnerabilità è sfruttabile: quando una macchina virtuale è in esecuzione all’interno della macchina host, è possibile fare una detection delle informazioni all’interno della memoria fisica dell’host a partire dalla macchina virtuale guest.

![](img/2023-12-04-14-41-33-image.png)

La **parte superiore** dello schema (comprendente Guest CR3, Page Directory e Page Table) è relativa alla paginazione che avviene all’interno della **macchina guest**, mentre la *parte inferiore* è relativa alla paginazione che avviene all’interno del *sistema host*.

Nel momento in cui bisogna accedere alla memoria a partire da un’applicazione che gira nella VM guest, si seguono i seguenti passaggi:

- Si ricorre al registro CR3 della macchina guest per recuperare l’indirizzo della PDE guest.

- A partire da un’apposita entry della PDE, si accede alla corrispondente PTE guest.

- Le entry della PTE guest non mappano direttamente su delle pagine fisiche in memoria, bensì conducono alla tabella delle **pagine top** **level** **del sistema** **host.**

- A partire da questo momento, la traduzione dell’indirizzo avviene secondo lo schema tradizionale basato su quattro livelli di paginazione.

A questo punto, performare un attacco L1TF a partire dalla VM guest è abbastanza semplice:

![](img/2023-12-04-14-48-44-image.png)

Supponiamo che in memoria fisica, all’indirizzo $x$, ci sia un dato cachabile, e consideriamo la entry $e_1$ della PTE guest. Allora è possibile fare in modo che $e_1$ sia non valida e abbia un contenuto che, **senza sfruttare la  “second  level address translation”** (del sistema host), punti proprio all’indirizzo fisico $x$.  
Così, quando un’applicazione che gira all’interno della VM guest tenta di effettuare un accesso in memoria sfruttando proprio la entry $e_1$ della **PTE guest**, poiché il presence bit è pari a 0, *il processore non percorre i 4 livelli di paginazione relativi al sistema host (nemmeno speculativamente), bensì va a verificare speculativamente se il dato associato all’indirizzo $x$ si trova nella cache L1* (in altre parole, se il presence bit vale 0, **l’indirizzo** **che si ottiene dalla PTE guest non viene più considerato come indirizzo fisico GUEST bensì come indirizzo fisico** **HOST**). Se sì, allora la macchina virtuale attaccante utilizza quel dato come indice per spiazzarsi in un probe array: in tal modo, sfrutta il side channel dato dalla cache per estrapolare delle informazioni relative all’esecuzione di altri thread o altre applicazioni, le quali possono anche girare in un’eventuale macchina virtuale vittima che vive all’interno del sistema host. Una condizione necessaria per cui questo attacco vada a buon fine è che l’attaccante e la vittima girino in due hyperthread associati al medesimo CPU-core, in modo tale che condividano la medesima cache L1.

## Core map

È una struttura dati che tiene traccia dello stato (e.g. libero vs occupato) dei frame all’interno del sistema e, quindi, ci permette di fare l’allocazione e la deallocazione delle pagine di memoria. Più precisamente, è un array in cui ciascuna entry corrisponde a un frame della RAM. Ciascuna entry viene rappresentata con la seguente struct C:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-07-20-image.png)



- `struct list_head list`: puntatore alla testa di una lista collegata; permette agli elementi della core map di essere collegati tra loro.

- `atomic_t count`: contatore che tiene traccia del numero di page table entry associati al frame in RAM.

- `unsigned long flags`: insieme di flag che indicano lo stato del frame in RAM.

## Free list

E' una struttura dati definita nel seguente modo:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-07-33-image.png)

- `struct zone node_zone[MAX_NR_ZONES]`: array contenente le informazioni relative a ciascuna ZONE gestita dalla free list.

- `int nr_zones`: numero di ZONE gestite dalla free list.

- `struct page *node_mem_map`: puntatore alla prima entry della core map legata alla free list. Di fatto, esiste una free list differente per ogni nodo NUMA, e ognuna di esse tiene traccia di un sottoinsieme di pagine libere relativamente a una porzione della core map (in altre parole, possiamo vedere la core map come logicamente suddivisa in più porzioni, ciascuna delle quali è relativa a un nodo NUMA). È per questo motivo che è necessario tenere traccia di quale porzione della core map è associata alla nostra free list.



Ma vediamo ora com’è definita la struct zone che abbiamo come primo campo della `struct pglist_data`.

![](file:///home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-07-51-image.png?msec=1702217271324)

- `free_area_t free_area[MAX_ORDER]` = array di aree di memoria libere che possono essere allocate; nelle versioni più recenti del kernel, è un array composto da 11 entry (e non una sola) perché si vuole avere la possibilità di scegliere se allocare una pagina di memoria, oppure due contigue, oppure quattro contigue, e così via. Il sistema che permette di allocare più frame fisici contigui è noto come buddy allocator.

- `spinlock_t lock` = spinlock che serve a gestire correttamente la sezione della core map legata alla ZONE di interesse della free list corrente (i.e. del nodo NUMA in cui ci troviamo). 

- `struct page *zone_mem_map` = puntatore alla prima entry della core map legata alla ZONE di interesse della free list corrente (i.e. del nodo NUMA in cui ci troviamo).

## Buddy Allocator

È un *allocatore* *di memoria* *fisica* che segue il seguente schema:  
I frame possono essere presi singolarmente oppure a gruppi con una dimensione pari a una potenza di $2$. I frame singoli costituiscono un gruppo di ordine $0$, mentre i frame “accoppiati” costituiscono un gruppo di ordine n (dove $2^n$ è la dimensione del gruppo in termini di numero di frame). È possibile unire due gruppi contigui dello stesso ordine $k$ in un unico gruppo di ordine $k+1$; è altresì possibile suddividere un gruppo di ordine $k$ in due sottogruppi contigui di ordine $k-1$.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-10-46-image.png)



Tornando alla core map e alla free list: 

- Per quanto riguarda la **core** **map**, è organizzata in più liste collegate, dove ciascun elemento di ogni lista è relativo a una entry della core map stessa. In particolare, si ha una lista collegata per gli elementi di ordine 0, una lista collegata per gli elementi di ordine 1, e così via.

- Per quanto riguarda la **free list**, l’array `free_area` definito all’interno della struct zone è organizzato così: la entry i-esima contiene un puntatore alla prima entry della porzione corrente della core map associata a un elemento di ordine $i$ (dove la porzione corrente della core map sarebbe quella porzione della core map associata a una specifica ZONE di uno specifico nodo NUMA).

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-12-05-image.png)

## Schema associato ad uno specifico nodo NUMA

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-12-54-image.png)

### Caso di kernel NUMA-aware

Come già detto, nel caso dei sistemi composti da molteplici nodi NUMA si hanno più free list distinte (una per ogni nodo NUMA, appunto). Di conseguenza, sono definite più `struct* pg_data_t` legate tra loro tramite una lista collegata. Tali struct, dunque, hanno anche un campo `node_next` (anch’esso di tipo `struct pg_data_t`) per andare a formare così una lista collegata di tipo struct `pglist_data`. A valle di questa considerazione, lo schema che lega la core map (`mem_map_t`) con le free list (`pg_data_t`) è il seguente:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-15-14-11-image.png)

A partire dalla versione 2.6.17 del kernel i vari *pg_data_t* sono definiti all’interno di un apposito array chiamato `node_data[]`.

Può capitare che un thread in esercizio, a livello user, riceva un interrupt, il che fa partire un handler, il quale potrebbe maneggiare la memoria verde, o anche chiamare qualcosa per la gestione, e rimanere bloccato. Ma quindi anche il thread rimarrebbe bloccato, quindi a livello kernel dobbiamo fare in modo che le API siano “non anonime”, quindi se l’API può mandarti o meno in blocco. Ciò è alla base dei seguenti concetti:

## Contesti di allocazione

Ma quali sono i contesti di allocazione da affrontare nel momento in cui viene richiesta memoria? 

- **Process** **context**: l’allocazione di memoria è causata da una system call o da una trap (e.g. page fault). Se la system call o la trap non è soddisfacibile, il thread interessato viene posto in uno stato di wait. Qui l’assegnazione della memoria ai vari thread utilizza uno schema basato su priorità (possono essere forniti dei frame fisici prima a un thread con una priorità più alta). 

- **Interrupt** **context**: l’allocazione di memoria viene richiesta da un interrupt handler. L’interrupt handler non può essere *mai posto in attesa, neanche se la richiesta* *è non soddisfacibile*. Stavolta, l’assegnazione della memoria ai vari thread non utilizza uno schema basato su priorità.



In entrambi i contesti di allocazione, si passa all’esecuzione in modalità kernel per effettuare l’allocazione della memoria.

### Api del buddy system

- `unsigned long get_zeroed_page (int flags)`: rimuove una sola pagina dalla free list, azzera il contenuto di tale pagina e ne restituisce l’indirizzo logico. Il parametro flags specifica il contesto di allocazione ed, eventualmente, la priorità che si vuole assegnare al thread corrente per l’assegnazione del frame di memoria. 

- `unsigned long __get_free_page (int flags)`: è come la `get_zeroed_page()` con l’unica differenza che non azzera il contenuto della pagina che restituisce.

- `unsigned long __get_free_pages (int flags, unsigned long order)`: è come la `__get_free_page()` ma, anziché allocare una singola pagina di memoria, ne alloca un gruppo di ordine k (i.e. alloca $2^k$ pagine). Il paramtro *order* specifica proprio il valore k dell’ordine. 

- `void free_page (unsigned long addr)`: dealloca una singola pagina di memoria. Il parametro addr indica l’indirizzo logico della pagina da deallocare. 

- `void free_pages (unsigned long addr, unsigned long order)`: è come la `free_page()` ma, anziché deallocare una singola pagina di memoria, ne dealloca un gruppo di ordine k (i.e. dealloca $2^k$ pagine).

**NB**: se si passano a `free_page()` o a `free_pages()` dei parametri errati o inadeguati, si può andare incontro a una corruzione del kernel. Se prendo un blocco di una certa taglia, non posso rilasciarne un sottoblocco.

Vediamo quali sono i valori principali che possono essere assunti dal parametro flags: 

- `GFP_ATOMIC`: si vuole che il chiamante non venga posto nello stato di sleep (per cui ci troviamo nel caso dell’interrupt context). 

- `GFP_USER` – `GFP_BUFFER` – `GFP_KERNEL`: è ammesso che il chiamante venga posto nello stato di sleep (i tre flag sono elencati in ordine crescente di priorità).

Tutte le API di allocazione che abbiamo visto restituiscono l’indirizzo virtuale di pagine di memoria **directly** **mapped**. Di fatto, la contiguità delle pagine allocate è garantita sia per gli indirizzi logici che per gli indirizzi fisici. Si lavora con normal memory (*frame directly mapped*), ma se volessi una high memory (*non directly mapped*), devo chiedere ad altro allocatore, che alloca tutto e mette in page table. Però se prendo frame diversi, non posso ritornare un unico indirizzo fisico, e quindi non tutti i kernel permettono tale operazione. Molto spesso ci viene data della normal memory, high memory non molto usata. Nelle release correnti il buddy allocator da indirizzi *directly mapped* (allineata sui “limiti” dei frame), se chiedessi high memory uso altro allocatore, che potrebbe non essere allineata (per termini di sicurezza ad esempio). Anche buddy allocator usa cache, senza far riferimento a free list e meccanismi di lock. La sua cache è un concetto di “quick list”. Nel buddy system prelevo alcune pagine, messe in più liste di ordine di livello superiore rispetto alle strutture considerate. Tali liste sono per-cpu, quindi niente lock. Quale allocatore buddy, con macchina NUMA avente più allocatori,uso?Soluzione: **mem-policy**.

Infatti, se ci facciamo caso, le API non permettono di specificare il nodo NUMA in cui si vuole allocare la memoria (i.e. non permettono di specificare l’esatta free list che si vuole coinvolgere). Trattiamo API di alto livello che a loro volta invocano un’API di più basso livello che specifica il nodo NUMA che deve essere coinvolto nell’allocazione. Tale API è:  
`struct page *alloc_pages_node (int nid, unsigned int flags, unsigned int order)`

Il valore di **nid*** (ovvero il nodo NUMA in cui deve avvenire l’allocazione) viene selezionato in base a delle **mempolicy** **data** (è un METADATO sul thread control block, politiche legate alla gestione della memoria) relative al thread chiamante. Inizialmente tali politiche erano gestite esclusivamente a livello kernel ma successivamente è stata messa a disposizione un’API user level per modificarle, in modo tale che il programmatore possa avere il controllo su quale nodo NUMA venga coinvolto nelle allocazioni delle pagine di memoria. Analizziamo anche questa API:  
`int set_mempolicy (int mode, unsigned long *nodemask, unsigned long maxnode)`

##### Che cosa vanno a indicare i parametri?

- `int mode`: stabilisce la modalità con cui il kernel deve allocare memoria per conto del software applicativo. Può assumere uno dei seguenti valori: 
  - `MPOL_DEFAULT`  (prendo sul nodo NUMA corrente, non sempre è ottimale, se un thread inizializza altri thread, questi thread avrebbero dipendenza dalla cpu del thread inizializzante).
  
  - `MPOL_BIND` (secondo cui viene selezionato un unico nodo NUMA da coinvolgere nelle allocazioni).
  
  - `MPOL_INTERLEAVE` (secondo cui il nodo NUMA da coinvolgere in ogni allocazione viene selezionato secondo uno schema Round-Robin, usato durante il boot del kernel da idle process).
  
  - `MPOL_PREFERRED`. Riguardano interrupt context.
- `unsigned long nodemask`: puntatore a una maschera di bit, dove ciascun bit è relativo a un nodo NUMA della macchina. L’i-esimo bit vale 0 se non si vuole che il thread chiamante utilizzi l’i-esimo nodo NUMA per le allocazioni di pagine di memoria, vale 1 altrimenti. 
- `unsigned long maxnode`: dimensione della maschera di bit.

L’API appena esaminata è di carattere generale, ma ne esiste anche un’altra che associa una specifica area di memoria logica a una mempolicy:

`int mbind (void *addr, unsigned long len, int mode, unsigned long *nodemask, unsigned long maxnode, unsigned flags)`



Rispetto a set_mempolicy(), qui si hanno due parametri in più: 

- `void *addr`: indirizzo di memoria logica a partire dal quale si vuole impostare la mempolicy. 

- `unsigned long len`: numero di byte per cui si vuole impostare la mempolicy. 

**NB**: la memoria logica coinvolta in questa API deve essere necessariamente user level.

Infine, è possibile migrare delle pagine di memoria (sempre user level) da un nodo NUMA a un altro mediante quest’altra API:

`long move_pages (int pid, unsigned long count, void **pages, const int *nodes, int *status, int flags)`

Pagine mai migrate da sole, solo con swap out e swap in, ma ad esempio oggi non c’è più la swap area, ma swap file (quindi tramite file system), però la swap area oggi ha poco senso con le ram che abbiamo.

Che cosa vanno a indicare i parametri? 

- `int pid`: ID del processo di cui si vogliono migrare le pagine. 

- `unsigned long count`: numero delle pagine che si vogliono migrare. 

- `void pages`: puntatore alle pagine di memoria che si vogliono migrare. 

- `const int *nodes`: puntatore ai nodi verso cui si vogliono migrare le pagine.

- `int *status`: puntatore all’area di memoria in cui verrà registrato l’esito della migrazione. 

- `int flags`: flag che indicano delle restrizioni sulle pagine che si vogliono migrare.

### Caso di allocazioni/deallocazioni frequenti

Nel caso in cui si abbiano allocazioni e deallocazioni frequenti di strutture dati “*target-specific*” (= che vengono utilizzate con un obiettivo specifico, vedi ad esempio la page table) non conviene più ricorrere al buddy allocator poiché quest’ultimo lavora in maniera sincronizzata tramite uno spinlock: infatti, si tratterebbe di una soluzione che non scala perché le diverse richieste sull’allocazione / deallocazione della stessa struttura dati verrebbero serializzate. Di base, questo problema viene risolto sfruttando i cosiddetti **buffer** **pre-reserved**, all’interno dei quali vengono precaricate delle pagine di memoria, in modo tale che siano già pronte nel momento in cui un’allocazione o deallocazione viene richiesta; tali buffer costituiscono degli allocatori alternativi che concorrono a rendere il sistema più efficiente e scalabile per quanto riguarda l’aspetto del memory management. Implementati tramite quicklist, cioè freelist di singole pagine, associate ad una cpu, come? Vado a variabile per-cpu e punto alla prima delle pagine, quindi ho una lista di pagine per-cpu.

## Quicklist

Sono dei buffer pre-reserved per il caso specifico delle page table. Per gestire questi buffer, si ricorre a particolari API pensate per la paginazione a 4 livelli (pensate cioè per le PGD, PMD, PUD e PTE): `pgd_alloc()`, `pmd_alloc()`, `pud_alloc()`, `pte_alloc()`, `pgd_free()`, `pmd_free()`, `pud_free()` e `pte_free()`. Informalmente, si può affermare che queste API implementano il caching delle pagine di memoria. Le quicklist sono implementate come delle liste **per-core**: è proprio per questa ragione che non c’è bisogno di sincronizzazione per utilizzarle. Prendo cpu, prendo variabile, prendo il pointer, vedo se l’oggetto puntato esiste, se esiste lo scollego, e mi prendo la memoria. Ci lavoro solo io. Non ci sono istruzioni atomiche, non faccio vedere a nessuno che faccio qualcosa, ho marcato il dato nel TLB, se arriva una interrupt resto io in CPU.  Thread può ricevere interrupt, chiama handler, handler ritorna, ma thread rimane in CPU. Potrebbe lasciare la CPU in altri casi. Quindi preemptable != interrompibile.  
**Possiamo essere interrompibili e non preemtable (non lascia cpu).**  
Dopo `put_cpu_var(quicklist)` ritorna preemtable, in mezzo non lo è. Informazioni per CPU, non posso lasciarla perchè lavorerei solo in quella CPU. Se lista è vuota, allora prendo `free_pages`.

Comunque sia, a partire dalla versione 4 del kernel Linux, il pre-reserving può essere fatto direttamente con le API del buddy allocator. In versioni ancora più recenti, le quicklist sono proprio uno dei componenti del buddy system, il che permette di utilizzare in modo trasparente le quicklist stesse facendo riferimento alle API relative alla buddy allocation. In ogni caso, le quicklist sono disponibili anche in altre salse per la programmazione di livello kernel. Qui la cache è per-cpu, ma potrei avere anche non per singola cpu.

Buddy system è oggetto condiviso tra le cpu, quindi richiede lock. Le quicklist permettono di lavorare in maniera scalabile, con cache buffer per-cpu, quindi non c’è conflitto con altre cpu. Questo vale per la singola pagina, o multipli di una pagina. Se volessi *meno di una pagina?*

## SLAB / SLUB allocator

È un allocatore utilizzato nel caso in cui si voglia avere a che fare con aree di memoria di dimensioni minori rispetto alla pagina. Si parla di cache lato kernel, siano esse generali (“voglio memoria”), o più specifiche.  
Il meccanismo di acquisizione da basso livello è basato su *lazyness*. Abbiamo una cache che gestice una taglia *T*, creo una seconda cache (e di conseguenza un secondo metadato). Le chiamate sulla seconda cache possono usare la stessa area della prima cache. Una cache per l'allocazione di memoria è un oggetto di memoria pre-riservato. Vediamo la cache come set di informazioni disponibili, senza scendere giù per il buddy system, è layer software superiore. L'attività di pre-reserving viene fatta dal *buddy allocator*, quindi è *directly mapped*. Fa uso delle seguenti API:

- `void *kmalloc (size_t size, int flags)`: alloca un’area di memoria contigua di una dimensione prestabilita e ne restituisce l’indirizzo logico (primo byte linea di cache); l’area di memoria è di livello kernel ed è directly mapped. Il parametro flags indica la priorità dell’allocazione. Mappa su mem-cache virtuale su specifico nome, e nome riflette la taglia. 

- `void *kzalloc (size_t size, int flags)`: è come `kmalloc()` con l’unica differenza che azzera l’area di memoria da allocare. 

- `void kfree(void *obj)`: dealloca l’area di memoria di livello kernel associata all’indirizzo logico passato come parametro.

Possiamo vedere le cache con:  *sudo cat /proc/slabinfo*

Quando viene invocata kmalloc() o kzalloc(), l’allocatore restituisce una zona di memoria pre-reserved; inoltre, vengono controllate le mempolicy del thread chiamante per capire qual è il nodo NUMA in cui l’allocazione deve avvenire. È quindi chiaro che, internamente alle chiamate a kmalloc() e kzalloc(), viene invocata la seguente altra API, che specifica anche il nodo NUMA da coinvolgere nell’allocazione:  
`void *kmalloc_node(size_t size, int flags, int node)`  

Di conseguenza, esistono più allocatori SLAB (uno per ogni nodo NUMA), per cui è ammessa la concorrenza nell’allocazione di memoria in diversi nodi NUMA.

### Slab allocator virtuali

È possibile creare dei nuovi SLAB allocator che lavorano con “chunk” di una certa dimensione D (dove il chunk corrisponde alla zona di memoria che verrà messa a disposizione con un’operazione di allocazione). Se però esisteva già un allocatore che lavora con chunk della stessa dimensione D, allora viene creata solo un’istanza virtuale di SLAB allocator che fisicamente mappa su quello già esistente. D’altra parte, è possibile effettuare il destroy di uno SLAB allocator A solo nel momento in cui gli eventuali chunk allocati da A sono stati tutti rilasciati.

Vediamo un po’ di API che permettono di manipolare questi allocatori: (queste a più basso livello di quelle viste sopra) 

- `struct kmem_cache *kmem_cache_create (char *name, size_t size, size_t align, unsigned long flags, void (*ctl)(void *))`: crea un nuovo SLAB allocator.  L'ultimo parametro è function pointer (riceve void*, indirizzo generico), ci permette di inizializzare l’area di memoria in cui farò le allocazioni, se diverso da NULL. Se NULL, ed esiste una cache che gestisce la size di chunks, è come se venisse sovrascritta. In questo caso non mi serve un nome specifico, basta poter gestire quella size. Size è la size del chunk. Quando realmente uso quella memoria, viene ritornata, la funzione viene richiamata iterativamente su tutti i chunks della cache. 

- `int kmem_cache_destroy (struct kmem_cache *cache)`: distrugge uno SLAB allocator. 

- `void *kmem_cache_allocator (struct kmem_cache_t *cache, int prio)`: alloca della nuova memoria tramite l’allocatore specificato come parametro. “Prio” è bloccante o non bloccante. 

- `void kmem_cache_free (struct kmem_cache_t *cache, void *ptr)`: dealloca un’area di memoria precedentemente allocata.

**Le free-list è una lista per-cpu, la release-list è invece concorrente tra le cpu.**

### Slab coloring

Quando viene creato un nuovo allocatore fisico, avrà associato un **colore**, che è un codice numerico indicante l’offset del primo buffer/chunk di memoria libero da consegnare quando viene richiesta un’allocazione. In realtà, due SLAB allocator associati alla stessa taglia (dimensione *D*) possono anche avere dei colori differenti: infatti, se idealmente tutte le pagine di memoria possono essere mantenute in cache ma molti allocatori vanno a lavorare sullo stesso offset, si avranno dei conflitti all’interno della cache; di conseguenza, avere molteplici colori porta all’ottimizzazione dell’uso della cache.

Sia ALN l’allineamento dei chunk che vengono consegnati dal nostro allocatore. Allora l’offset del primo buffer di memoria libero da consegnare è pari a $D+ALN \cdot COLOR$.

### Allocazioni di aree di memoria molto ampie

Nelle versioni più recenti del kernel il buddy allocator è in grado di allocare fino a $2^{11}$ pagine di memoria contigue ma, precedentemente, il limite era addirittura di $2^5$ pagine. Di conseguenza, è possibile avere il bisogno di allocare un’area di memoria di dimensioni superiori rispetto a quanto consentito dal buddy allocator (questo avviene ad esempio quando si vuole montare un modulo del kernel). Per tale necessità si ricorre a un ulteriore allocatore per la memoria kernel: il **vmalloc**, che è in grado di allocare delle pagine che sono *contigue per la memoria logica*, ma non necessariamente per la memoria fisica (per cui non si tratta necessariamente di memoria directly mapped).  
Le API che permettono di utilizzare il vmalloc sono le seguenti:

- `void *vmalloc (unsigned long size)`: alloca un’area di memoria con le dimensioni specificate dal parametro in input, e restituisce il relativo indirizzo logico. Si usa per puntare i moduli, non per le interrupt.  
  Qualsiasi struttura dati messa lì dentro non è detto sia directly mapped, dovrei usare buddy allocator in tal caso.  Poi potrei usare un allocatore che ritorna questa memoria così definita. 

- `void free (void *addr)`: dealloca un’area di memoria precedentemente allocata con una vmalloc().

#### Confronto tra kmalloc e vmalloc

- Dimensioni della memoria che può essere allocata: 
  
  - 128 KB per kmalloc (cache aligned)  
  
  - 64-128 MB per vmalloc

- Contiguità della memoria fisica allocata: 
  
  - Sì per kmalloc
  
  - No per vmalloc

## Effetti sul TLB, interazione con hardware

**TLB** è l'acronimo di *Translation Lookaside Buffer*, una struttura dati che cacha le associazioni indirizzo logico $\rightarrow$ indirizzo fisico): 

- *Nessun effetto per kmalloc*: di default le pagine di memoria del kernel vengono registrate come directly mapped; a seguito di una loro allocazione mediante lo SLAB allocator (il quale fa riferimento al buddy allocator), queste rimangono certamente directly mapped, per cui il TLB non deve essere sottoposto ad alcun aggiornamento. 

- *Effetti globali per vmalloc*: il vmalloc fa anch’esso riferimento al buddy allocator, ma può invocarlo più volte per ottenere tutta la memoria desiderata; questo può portare ad avere memoria fisica non contigua (ovvero pagine di memoria non directly mapped), il che causa la necessità di aggiornare il TLB.

#### Effetti sul TLB usando vmalloc

Vediamo più nel dettaglio cosa può avvenire internamente quando si allocano delle pagine di memoria con vmalloc. Supponiamo di avere 5 **page frames** *non* *directly* *mapped* di cui solo la seconda e la quarta risultano occupate (i.e. già allocate), e supponiamo di voler richiedere all’allocatore `vmalloc` **tre pagine di memoria virtuale contigue**. Allora avviene la seguente cosa:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-16-52-45-image.png)

In pratica, affinché vengano restituite al chiamante le prime tre pagine logiche tra quelle non directly mapped, queste tre pagine vengono rimappate in modo tale da corrispondere ai tre frame fisici liberi (anche se questi frame fisici non sono contigui).

**NB**$_1$: la richiesta di allocazione di nuove pagine non diretly mapped non è l’unica possibile causa del re-mapping: anche la modifica dei permessi di accesso alle pagine stesse può portare al re-mapping, poiché comunque sia si tratta di informazioni che salgono sul TLB.

**NB**$_2$: chiaramente, nella realtà, con vmalloc vengono tipicamente rimappati dei blocchi di pagine piuttosto ampi (e non le singole pagine).

Come accennato precedentemente, l’aggiornamento del TLB deve avere una natura globale poiché deve essere visibile a qualunque CPU-core: di fatto, qualsiasi thread (mentre è in esecuzione in modalità kernel) deve essere in grado di raggiungere una qualsiasi pagina di memoria del kernel.

### Operazioni implicite vs esplicite sul TLB

Di base, il TLB deve essere modificato (o almeno invalidato):

- Nel momento in cui viene cambiata la page table a cui si fa riferimento ($\rightarrow$ aggiornamento del registro CR3) 

- Nel momento in cui viene modificata una qualche entry della page table ($\rightarrow$ mmap / unmap di alcune pagine di memoria). 

Il livello di automazione nella gestione del TLB dipende dall’architettura hardware specifica. Per essere sicuri che la gestione del TLB avvenga correttamente a prescindere dal livello di automazione della sua gestione, si fa uso dei **kernel hook**, che si occupano della gestione esplicita delle operazioni del TLB; gli hook vengono mappati a compile-time a delle *null operations* solo nel caso in cui il TLB è gestito del tutto automaticamente.

Per quanto concerne i processori x86, l’automazione è solo parziale. Infatti: - L’invalidazione del TLB avviene in **modo automatico** solo nel caso in cui viene aggiornato il registro CR3. Se ho due hyperthread su stesso core, invalido il MIO CR3, non quello dell’altro hyperthread. - Eventuali cambiamenti che si hanno all’interno delle singole page table non scatenano l’invalidazione automatica del TLB (per cui in tal caso si deve ricorrere ai kernel hook).

### Tipi principali di eventi sul TLB

Classificazione rispetto alla **scala degli eventi** sul TLB possono essere: 

- **Globali** se hanno a che fare con indirizzi virtuali accessibili da qualunque hyperthread fisico in *real-time-concurrency* (i.e. indirizzi delle pagine del kernel).

- **Locali** se hanno a che fare con indirizzi virtuali accessibili in *time-sharing concurrency*; la località è in particolare rispetto all’applicazione.

Classificazione rispetto alla **tipologia degli eventi** sul TLB possono essere: 

- **Remapping** degli indirizzi di memoria, 
  (i.e. cambio della traduzione da indirizzo logico a indirizzo fisico, tipo vmalloc).

- Modifica delle **regole di accesso** agli indirizzi logici (read only vs read/write).

Tipicamente, l’aggiornamento delle informazioni all’interno del TLB va fatto a seguito del flush del TLB (invalidazione non selettiva) o di una sua porzione (invalidazione selettiva).   
Ad esempio, a livello globale, flusho tutti i TLB, mentre a livello locale flusho secondo regole, e il tutto parte da chi stava lavorando a livello locale.

### Costi del flush del TLB

Per quanto riguarda i **costi diretti**: 

- Latenza del protocollo di livello firmware per l’invalidazione delle entry del TLB (che sia essa selettiva o non selettiva). 

- Latenza per il coordinamento cross-CPU nel caso in cui il flush sia globale (i.e. coinvolga tutte le CPU della macchina).

Per quanto invece riguarda i **costi indiretti**: 

- Latenza dell’inserimento delle informazioni aggiornate all’interno del TLB in caso di miss (dove il miss è una diretta conseguenza del flush del TLB). Questo costo dipende dal numero di entry del TLB che devono essere rinnovate.

### Flush globale del TLB su Linux

- `void flush_tlb_all(void)`: è un’API che effettua il flush di tutte le TLB di tutti i CPU-core attivi nel sistema. Chiaramente è molto dispendiosa, e il costo dipende anche dalle istruzioni macchina offerte dall’ISA dell’architettura che si sta usando. 

Nel caso dell’x86, non esiste alcuna istruzione che effettui direttamente il flush di tutti i TLB di tutti gli hyperthread, per cui `flush_tlb_all()` flusha il TLB del CPU-core in cui gira il chiamante e fa sì che vengano triggerati tutti gli altri CPU-core affinché anche loro effettuino il flush. Per far ciò, vengono applicati degli schemi a livello software, il che inficia ulteriormente sul ritardo dovuto all’invocazione di `flush_tlb_all()`.  Delle funzioni che potrebbero chiamare al loro interno `flush_tlb_all()` (ma non necessariamente) sono `vmalloc()` e `vfree()`, il cui funzionamento è schematizzato qui di seguito:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-17-29-28-image.png)

Sostanzialmente metto della barriere, perchè tutti devono completare l’operazione. Il che è molto dispendioso in termini di tempo.

### Flush parziale del TLB su Linux

- `void flush_tlb_mm (struct mm_struct *mm)`: è un’API che effettua il flush di tutte le entry del TLB che sono relative alla parte user-space del chiamante. Viene invocata solo quando è stata eseguita un’operazione che coinvolge l’intero address space (e.g. dopo che il mapping della memoria è stato duplicato con `dup_mmap()` per eseguire una fork, oppure dopo che il mapping della memoria è stato eliminato con `exit_mmap()` per terminare il processo). Thread che da user a kernel chiama `mprotect()` richiede di aggiornare TLB ad esempio. Mandiamo avvertimento se sta girando su un thread di questo processo. Quindi non aspettiamo che altri completino l’aggiornamento, avvertiamo solamente.

- `void flush_tlb_range (struct mm_struct *mm, unsigned long start, unsigned long end)`: è un’API che effettua il flush delle entry del TLB associate alla zona di memoria compresa nei limiti dati dai parametri start, end. Viene invocata dopo che una regione di memoria è stata spostata (e.g. con una `mremap()`) oppure quando vengono cambiati i permessi di accesso alla zona di memoria (e.g. con una `mprotect()`).

- `void flush_tlb_page (struct vm_area_struct *vma, unsigned long addr)`: è un’API che effettua il flush di una singola pagina di memoria dal TLB. Supporta iterativamente il `tlb_range`, e quindi anche `tlb_mm`.  
  *vma struct* indica che nell’address space c’è una zona start address ed end address, utilizzabili. C’è una lista gestita e aggiornata quando si chiama una mmap.

- `invlpg`: è un’istruzione offerta dall’ISA dell’x86 che effettua il flush di una particolare entry del TLB.

- `void flush_tlb_pgtables (struct mm_struct *mm, unsigned long start, unsigned long end)`: è un’API che effettua il flush delle entry del TLB associate a una specifica page table. Viene invocata quando tale page table viene dismessa.

- `void update_mmu_cache (struct vm_area_struct *vma, unsigned long addr, pte_t pte)`: è un’API che può essere utilizzata per *precaricare* delle entry sul TLB a seguito di un page fault. In maniera *machine dependent* ripopolo TLB eventualmente presente nell’architettura stessa. Se non le supporta, possono essere esposte ma non fare nulla.

# Cross Ring Data Move

## Introduzione

Sappiamo che possiamo cambiare il flusso di esecuzione dalla modalità user alla modalità kernel e viceversa. Finora siamo stati abituati a pensare che, per passare le informazioni da una modalità all’altra (e, più in generale, da un ring a un altro), si sfruttano i registri del processore. Tuttavia, molto spesso la taglia dei registri non è sufficiente per ospitare i dati da trasportare da un livello di protezione all’altro. Come facciamo? Se popolassimo i registri con dei puntatori alle aree di memoria contenenti i dati da passare all’altro ring, romperemmo completamente il modello di protezione ring-based: di fatto, per un’applicazione user level sarebbe possibile andare in modalità privilegiata passando al kernel un puntatore a un’area di memoria kernel space; questo si tradurrebbe nella possibilità da parte dell’esecuzione in modalità non privilegiata di scrivere delle informazioni di livello kernel mediante una chiamata a una system call.

La soluzione vera a questo problema dipende da numerosi fattori, tra cui l’effettivo supporto alla segmentazione e la presenza (o assenza) di meccanismi di protezione addizionali che si hanno nell’hardware.

## Caso della segmentazione flessibile

È la segmentazione di *x86 protected mode*, in cui è possibile fare in modo che i vari segmenti (come CS, DS) puntino ovunque vogliamo all’interno dell’address space. 

- *Vantaggio:* si ha una separazione completa dei segmenti all’interno dell’address space, e questo previene le letture e le scritture illegali nei segmenti del kernel. 

- *Problema*: c’è bisogno di un meccanismo per rendere la protezione dei segmenti trasparente al software.

Alla fine, questa soluzione consiste nell’avere all’interno di uno spazio di indirizzamento di un’applicazione un certo numero di segmenti user level che ricoprono gli indirizzi di memoria più bassi e un certo numero di segmenti kernel level che ricoprono gli indirizzi di memoria più alti; c’è dunque un indirizzo nel mezzo al di sotto del quale ricadiamo sicuramente in aree di memoria user space e al sopra del quale ricadiamo in aree di memoria kernel space (ricordiamoci però che questa non è una soluzione adottata da Linux).

Consideriamo ora la system call `read(x,y,z)`, dove $x$ è il canale di I/O da cui si vuole leggere, $y$ è l’offset all’interno del segmento dati (DS) in cui si vogliono riportare i byte letti e $z$ è il numero di byte da leggere. Qui il problema risiede nel fatto che `read(x,y,z)` è una system call che viene invocata quando si è in modalità user ma, poiché poi viene eseguita direttamente dal kernel, $y$ **viene trattato come un offset rispetto al segmento DS di livello kernel**, in particolar modo se il segmento da utilizzare viene scelto dal compilatore e non dal programmatore (i.e. se il compilatore, nel definire l’istruzione di `mov` dei dati letti verso la locazione indicata da $y$, sceglie come indirizzo di memoria di destinazione l’offset $y$ rispetto al segmento DS di livello kernel). Questo problema, da capo, rompe il modello di protezione ring-based.

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-12-10-17-42-03-image.png)

#### Soluzione

La soluzione al problema appena esposto consiste nel rendere “**handcrafted**” (= scritta in maniera machine dependent dal programmatore del software del kernel, quindi non viene fatto automaticamente dal compilatore) i pezzi di codice del kernel per lo spostamento cross ring dei dati. Più specificatamente, è possibile sfruttare un selettore di segmento programmabile per mappare momentaneamente il segmento `FS` sul segmento `DS` *user level* e poi applicare il displacement $y$ a FS per il movimento dei dati (alla fine dell’operazione FS viene ripristinato): in tal modo, per la `read()`, viene utilizzata un’area di memoria user space e non più kernel space.

L’operazione appena descritta è di tipo **segmentation** **fixup**. Chiaramente, comporta dei costi relativi al cambio di stato dei registri del processore (i.e. dei selettori di segmento), che di fatto richiedono degli accessi aggiuntivi alla memoria.

## Caso della segmentazione constrained

È la segmentazione di *x86 long mode*, ma anche di x86 protected mode nel caso in cui si usano sistemi operativi che forzano il posizionamento dei segmenti CS, DS, SS ed ES (sia *user level* sia *kernel level*) a offset `0x0`. In tale circostanza, mappare FS sul segmento *DS user level* è una soluzione che non funziona più: di fatto, questo porterebbe automaticamente a mappare FS anche sul segmento DS kernel level, per cui alla fine la system call `read()` (come qualsiasi altra system call) utilizzerà comunque una zona di memoria di livello kernel anziché di livello user.

#### Soluzione

L’indirizzo di memoria a cui puntare per uno scambio dati user/kernel è determinato non solo dallo stato del processore, bensì anche dal software del kernel, e la determinazione è attuata per ogni singolo address space che il kernel sta gestendo. In particolare, il kernel dovrà decidere se il pointer che viene passato per identificare la zona di memoria coinvolta nello scambio dati user/kernel è lecito oppure no. Graficamente, si applica un taglio verticale all’addres space, non orizzontale, come abbiamo sempre visto.

Per quanto riguarda Linux nello specifico, la soluzione è nota come 
“**per-thread memory** **limit**”: qui viene fissato un indirizzo limite dell’address space (**addr_limit**) e, se per eseguire un’operazione di *scambio dati user/kernel* viene utilizzato un buffer di memoria che cade entro addr_limit, allora l’operazione è permessa, altrimenti no (quindi non è solo il pointer utilizzato a dover cadere entro il limite, ma anche il valore di *pointer+size*, dove *size* è la dimensione dell’area di memoria su cui si vuole eseguire l’operazione). In realtà, se viene utilizzato un pointer lecito ma una size non lecita (per cui si usa un buffer di memoria che in parte cade entro il limite e in parte no), tipicamente l’operazione viene eseguita solo parzialmente (i.e. solo nella zona di memoria che cade entro il limite). Alcune API facevano controllo sul limite, e se non andava bene, c’erano dei problemi. Oggi, l’*addr_limit* è definito a compile-time. Correntemente, *addr_limit* in Linux è impostato all’indirizzo `0x00007ffffffff000`, che corrisponde al *lower half* della forma canonica dell’indirizzamento di x86. È possibile leggere il valore di addr_limit invocando l’API del kernel `get_fs()`, che accede a una struttura il cui campo **seg** contiene proprio il limite. *Addr_limit* può anche essere aggiornato attraverso l’API del **kernel** `set_fs(x)`.

### Esempio di utilizzo di addr_limit

```c
unsigned long limit;
limit = (unsigned long) get_fs().seg;
printk (“limit is %p\n”, limit);
```

### API kernel per lo user/data move

- `unsigned long copy_from_user (void *to, const void *from, unsigned long n)`: copia $n$ byte da un buffer di memoria user space (puntato da *void *from*) a un buffer di memoria kernel space (puntato da *void *to*). Prima, però, verifica se l’operazione è lecita, confrontando i valori di `to`, $n$ con *addr_limit*, mentre, in ultima istanza, restituisce il numero di byte che NON è stato possibile copiare (i.e. il residuo). La presenza di $n$ ci fa capire che ci muoviamo in un address space, perchè consegniamo un sottooggetto compatibile con l’*addr_limit*.

-  `unsigned long copy_to_user (void *to, const *void *from, unsigned long n)`: copia $n$ byte da un buffer di memoria kernel space (puntato da *void *from*) a un buffer di memoria user space (puntato da *void *to*). Anch’essa restituisce il numero di byte che NON è stato effettivamente possibile copiare. 

- `void get_user (void *to, void *from)`: copia un intero da un indirizzo user space (*from*) a un indirizzo kernel space (*to*). 

- `void put_user (void *from, void *to)`: copia un intero da un indirizzo kernel space (from) a un indirizzo user space (*to*). 

- `long strncpy_from_user (char *dst, const char *src, long count)`: copia una stringa null-terminated lunga al più *count byte*da un indirizzo user space (*src*) a un indirizzo kernel space (*dst*). Restituisce poi il numero di byte che NON è stato effettivamente possibile copiare. 

- `int access_ok (int type, unsigned long addr, unsigned long size)`: restituisce un valore diverso da zero se è possibile eseguire un’operazione di movimento dati cross ring su un buffer di dimensione size a partire dall’indirizzo addr; restituisce zero altrimenti. Il parametro type indica la tipologia del buffer (i.e. user space o kernel space).

**Nota**: Se devo spostare dati con syscall read, si chiama kernel, e ci sarà thread a ring0 che muove i dati.  Noi controlliamo in base ad *addr_limit*, ma queste zone di memoria sono effettivamente utilizzabili? Infatti, un thread livello kernel potrebbe generare segmentation fault, causata da un user che vuole ad esempio lavorare su una zona non *mmpattata*. Chi fa questo check? `Access_ok()`. L’addr_limit è dentro il TLB, ogni thread ha il proprio, e quindi unico *addr_limit* per questo thread.



Address space ha parte user e parte kernel. Un thread ha il proprio address space, non può chiedere di andare a lavorare su un altro address space. Se così fosse, ci sarebbe un’altra page table, altro thread control block ... Gli address space sono separati!  
E’ possibile farlo a livello kernel, perchè ho controllo sulla page table che tocco. Tale concetto è usabile per memoria condivisa, però dovrei avere zone “uguali”, accessibile anche a livello user.

L’associazione *indirizzo fisico-virtuale* è demandata all’handler del page-fault. Quando chiamo `syscall`, scendiamo a livello kernel, possono comunque capitare page-fault.   
E’ diverso dal segmentation-fault, in quanto un **page-fault è risolvibile**. Le operazioni possono essere non atomiche.



## Service redundancy

L’attività di **check** che viene effettuata nel caso della segmentazione constrained (ma  un discorso analogo vale anche per il **segmentation** **fixup**) deve essere eseguita solo nel momento in cui è previsto un *cross ring data move*, e non quando si effettua un accesso in memoria senza cambiare il livello di protezione. Supponiamo infatti di voler invocare una `sys_read()` (l’operazione di `read()` propria della modalità kernel) mentre siamo in esecuzione in kernel mode. Avere l’attività di check incapsulata in tale system call renderebbe impossibile l’esecuzione della lettura, poiché l’area di memoria coinvolta nella `sys_read()` si trova oltre l’*addr_limit* (com’è giusto che sia). Di conseguenza, quando stiamo lavorando solo a livello kernel, è necessario *bypassare* *questo* *check*, in quanto qui l’addr_limit non ha ruolo. Per farlo, si utilizza uno schema di **replicazione** (o di **ridondanza**), secondo cui alcune system call vengono di fatto replicate. Ecco qualche esempio:

- `kernel_read()` è una ridondanza per la system call *read()*: 
  
  - Mentre *read()* internamente invoca *sys_read()* che effettua il check...
  
  - ... `kernel_read()` è funzionalmente identica ma bypassa il check (per cui *kernel_read()* non può essere invocata in alcun modo da un thread in esecuzione in modalità user).



## Constrained supervisor mode

Sappiamo che l’operazione di `memcpy()` consiste nel copiare il contenuto di un’area di memoria *A* all’interno di un’altra area di memoria *B*. Se il puntatore relativo all’area di memoria *B* è *tampered* (i.e. è errato), si possono avere dei problemi di sicurezza, perché si può avere un accesso in memoria speculativo che è illecito. Nei sistemi più datati, non ci si poteva far nulla. In quelli più moderni, invece, si ha un supporto addizionale orientato alla sicurezza noto come **constrained** **supervisor mode**. Si tratta della modalità di esecuzione del kernel con dei vincoli: in operazioni come `memcpy()`, si controlla che si sta lavorando esclusivamente con indirizzi di livello kernel; se questo non è il caso, non è possibile in alcun modo eseguire l’operazione.

### Constrained supervisor mode in x86

In x86 si hanno due supporti hardware: 

- **SMAP (Supervisor Mode Access Prevention)**: blocca l’accesso ai dati delle pagine user mentre si è in esecuzione al CPL 0. 

- **SMEP (Supervisor Mode Execution Prevention)**: blocca il fetch delle istruzioni delle pagine user mentre si è in esecuzione al CPL 0.

#### Esempio copy_to_user()

- Viene effettuato il check su *addr_limit* per verificare se l’operazione è fattibile.

- Viene determinata la quantità di dati che può essere effettivamente copiata. Lo fa `access_ok`, tempistica $O(n)$, perchè si prende Thread Control Block, e successivamente viene scandita la Tabella Management, per vedere se c’è la quantità richiesta.

- Viene disabilitato lo SMAP.

- Viene effettuata la vera e propria copia dei dati. 

- Viene riabilitato lo SMAP.

Tutto ciò serve a fixare il problema nato dallo user, il quale passa parametri non corretti. Ma quante volte capita? Secondo alcune statistiche, quasi mai.



## Kernel masked SEGFAULT

I check sulla quantità di dati che possono essere coinvolti nelle operazioni di movimento dati cross ring effettuati mediante l’API `access_ok()` presentano un *problema di efficienza*: fanno uso della *memory map* (`*mm`, che comprende i metadati per la gestione dell’address space del thread corrente) del thread in esecuzione e richiedono numerose istruzioni macchina aggiuntive solo per muovere i dati tra lato user e lato kernel. In particolare, l’ispezione di `mm` può avere un costo lineare (e non costante). Per ovviare a questo inconveniente, è stato introdotto il **kernel** **masked** **SEGFAULT**.   
Si tratta di un meccanismo per cui l’unico controllo che viene effettuato prima del movimento dati cross ring è quello sull’*addr_limit* (controllo solo il primo passo), ma poi non si ha alcun check sulla struttura dell’address space: di conseguenza, se viene rispettato il limite, l’operazione di movimento dati viene eseguita direttamente. Perciò, si ha la possibilità di andare a toccare delle pagine di memoria user space non mappate o con dei permessi di accesso non conformi. Questo è l’unico caso in cui si può scatenare un segmentation fault al livello kernel (e viene comunque causato da un’API di livello user – come `copy_to_user()` o `put_user()` – a cui è stata passata come parametro un’area di memoria non adeguata dal punto di vista del mapping o dei permessi di accesso). In questo modo: 

- Nel caso in cui va tutto bene, si ha uno speedup significativo nell’esecuzione dell’operazione di movimento dati. 

- Nel caso in cui si ha un segmentation fault, viene attivato un gestore che finalizza l’operazione semplicemente restituendo il numero di byte residui.

# Linux Modules p111
