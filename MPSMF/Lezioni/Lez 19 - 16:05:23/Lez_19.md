### Recap sulle Filtrazioni, 6.3

Definiamo $\Omega =\{{(w_n)}_{n=1}^N, w_n=1,w_n=0\}$ l'insieme delle successioni in cui abbiamo questi due eventi che si possono verificare. Questo è lo spazio.

$\xi = \mathcal{P}(\Omega)$ insieme delle parti.

La probabilità di un evento elementare è $P(w)=p^kq^{N-k}$ con $k=\{n \in \{1,...,N\} : w_n=1\}$
Definiamo la probabilità di un qualunque evento come estensione degli eventi elementari appartenenti all'evento:
$P(E)=\sum_{w \in E} P(w)$

Su questo spazio noi trattiamo un fenomeno stocastico, osserviamo normalmente alla terminazione del fenomeno. Noi però vogliamo predirre il futuro, quindi prima del completamento. Ad esempio:

$0,1,..., n_0,n_0+1,...
$
Noi ad $n_o$ dobbiamo fare delle scelte conoscendo il passato, non il futuro. Qui entra in gioco la filtrazione.
Ricordiamo che $F_n \subset F_{n+1}$, ovvero l'informazione non viene mai persa.
Supponiamo di avere un evento $E \in F_n$ con un certo $n$ fissato. Cioè eventi della filtrazione in questione. Di questi eventi posso vedere in maniera precisa gli accadimenti prima dell'$n$ fissato, dopo non lo so!
Ho un punto (cioè una successione) in $E$, cioè $(w_n)_{n=1}^N= w \in E$

Di questo punto considero le prime $n$ componenti con certi valori specifici.
Tutti gli altri punti aventi stesse prime $n$ componenti, ed il resto come mi pare, **devono stare in** $E$.

Supponiamo $n=3$ e $N=7$, cioè $w \in E \in F_3$
Osserviamo i seguenti $w \in E$ :
$w_1=1, w_2=0, w_3=1$ 
Allora, dato tale evento che sta nella filtrazione, tutte le altre sequenze di $w$ aventi le prime 3 componenti come quelle osservate, appartengono alla filtrazione. Quindi $(1,0,1,0,0,0),(1,0,1,0,0,1),...$

Se $E \in F_1$, allora $w \in E$ può essere $w_1=1$ oppure $w_1=0$. Se prendiamo il caso $w_1=1$, e tale punto $\in E$, allora $E$ contiene tutti gli altri punti aventi $w_1$:
Allora $E=\{(1,0,0,...),(1,0,1,...),... \} = E_1$, cioè la prima coordinata è 1, le altre tutti i modi possibili. Se ci fosse $w_0$, allora la prima coordinata sarebbe 0, le altre combinate in tutti i modi possibili.

La mia filtrazione $F1 = \{0,\Omega,E_1,E_0\}$
Le prime due componenti ci devono essere perchè trattiamo una $\sigma$ - algebra.

mentre $F_2= \{0,\Omega, E_0,E_1,E_{0,0},E_{0,1},E_{1,0},E_{1,1} \}$ cioè tutte le combinazioni "è andata bene/è andata male". Devono esserci anche unioni,complementari etc, perchè è una sigma algebra. $E_{0,0} \subset E_0$,  $E_0= E_{0,0} \cup E_{0,1} \in F_2$
Tutte le unioni possibili degli eventi di questa partizione sono nella filtrazione, la quale deve essere chiusa rispetto a tutte le unioni numerabili.
Noi addirittura lavoriamo in un caso chiuso.

Supponiamo di poter distinguere le componenti fino alla n-esima, ovvero:
$F_n= \{E_{0,0,0,..0_n}, E_{0,0,0,...,1_n} \}$, ovvero è una partizione di $\Omega$. Devo fare tutte le unioni possibili.

Voglio uno strumento che rappresenti il flusso delle informazioni.

### Processo stocastico

Formalmente, si prende uno spazio di probabilità $(\Omega,\xi,P)$, una successione $(X_n)_{n=0}^N$ con $X_n: \Omega \rightarrow \R^M$ , con ogni $X_n$ che è una $ \xi-\beta(\R^M)$ variabile aleatoria su sigma algebra di Borel. Come lo capisco? 

Prendo l'evento (cioè la controimmagine) $\{X_n \in B\} \in \xi, \forall B \in \beta(\R^M) $ . Cioè prendo un $B$, sottoinsieme Borelliano di $\R^M$, vedo la controimmagine $E \subset \Omega$, che è un sottoinsieme di $\Omega$. Se tale evento appartiene alla sigma algebra fissata, cioè $E \in \xi$, allora è un processo stocastico. 
(Da CPS: Suppogo di avere l'informazione $\Omega=\{1,...,6\}$, 
la $\sigma-$ algebra $\xi \doteq \{(1,3,5),(2,4,6)\}$, ovvero $\xi$ è una famiglia di sottoinsiemi di $\Omega$ che raggruppa gli esiti in "pari" e "dispari".
Se in $B$ prendo '5', non posso associarla ad $\xi$, perchè in $\xi$ non è presente l'evento 
"E' uscito esattamente 5").

![Screenshot 2023-05-17 alle 15.17.05.png](/var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_kdPJLj/Screenshot%202023-05-17%20alle%2015.17.05.png)


Se l'informazione è tutta l'informazione possibile, cioè $\xi=P(\Omega)$, allora ogni successione di variabile aleatoria è un processo stocastico.

Siccome $\Omega$ è finito, non solo parliamo di processo stocastico, bensì è un processo stocastico di ordine k, $\forall k \in N$, cioè abbiamo ogni ordine, anche se a noi interessano i primi quattro. Se la matrice varianza-covarianza è invertibile, allora possiamo anche ricavare Skewness e Kurtosi.

La filtrazione rappresenta il **flusso temporale degli eventi**. Particolarizziamo allora la definizione di processo stocastico. Riprendo lo spazio di probabilità, ci metto la filtrazione ${(F_n)}_{n=0}^N$. Allora la successione $(X_n)_{n=0}^N$ è un **processo stocastico adattato** a ${(F_n)}_{n=0}^N$ se $\forall n$, $X_n$ è una $F_n-\beta(\R^M)$ variabile aleatoria. Prendo Boreliano, faccio controimmagine su $X_n$, essa è un evento $E$ che deve stare in $F_n$ (nella sigma algebra è scontata).
Al tempo $n$ posso osservare le realizzazioni della variabile aleatoria $X_n$.

##### Esempio in cui ciò non si verifica

Prendo $N=7, n_1=3, n_2=5$.
Prendo la variabile aleatoria $B_1(w) \doteq w_{n_1}$, cioè se $w=(1,0,1,0,1,0,1)$ allora $B_{n_1}(w)= B_{3}(w)=1$, e se $w=(1,0,0,1,0,1,0)$ allora $B_{n_1}(w)=0.$ Semplicemente prendo come valore di tutto $w$ il valore della componente in posizione $n_1$.

Se $0,1 \notin B(\R)$ allora la controimmagine è l'insieme vuoto.
Se $0,1 \in B(\R)$ allora la controimmagine è tutto $\Omega$.
Se $B_1 \doteq \{0 \notin B_1 , 1 \in B_1\} \doteq \{w \in \Omega:w_3=1\} \in F_3$, se posso distinguere le prime tre componenti, allora sicuramente posso distinguere solamente la terza. Questo vuol dire che in $F_3$ ci sono nelle prime due coordinate tutte le combinazioni possibili, nella terza devo avere '1'. Cioè vi appartengono:
$E_{0,0,1} \in F_3, E_{1,0,1} \in F_3,E_{0,1,1} \in F_3, E_{1,1,1} \in F_3 $ ; ma $F_3$ è $\sigma$-algebra, quindi anche l'unione vi appartiene, ma l'unione è ciò che abbiamo scritto sopra.

##### Processo predicibile nel tempo discreto, def 157

$(X_n)_{n=0}^N$ è **predicibile** rispetto a $(F_n)_{n=0}^N$ se $\forall n=1,...,N$  la variabile aleatoria $X_n$ è $F_{n-1}-\beta(\R^M)$ variabile aleatoria.  Cioè posso osservare le realizzazione della variabile aleatoria "un tempo prima", è legato al discorso della "scelta".
La composizione del portafoglio è un gruppo di variabili *predicibile*, lo stock invece è *adattato*. Noi scegliamo il portafoglio prima di osservare il valore dello stock, sono in anticipo su cosa accadrà, quindi è predicibile, ciò che faccio è alla luce della informazione vecchia. Faccio scelta iniziale alla luce di ciò che potrebbe accadere alla fine. Lo scopo è "cucire bene" tale modello sulla realtà, stimandone bene i parametri. Cerco di fare investimento sulla base di oggi, e poi vedo che succede domani. La ricchezza di domani dipende da ciò che si è realizzato domani. Riconfiguro il portafoglio e il processo va avanti.
Guardo all'oggi per vedere cosa succederà domani (o un tempo futuro qualunque).

> Un processo stocastico predicibile è un tipo di processo stocastico in cui è possibile fare previsioni o predizioni sulla sua futura evoluzione con una certa precisione o affidabilità. In altre parole, un processo stocastico predicibile è un processo che presenta una certa regolarità o struttura nel modo in cui si evolve nel tempo, il che consente di fare previsioni ragionevoli sul suo comportamento futuro.
> I processi stocastici predicibili contengono ancora un certo grado di casualità o incertezza, poiché sono influenzati da fattori aleatori o imprevedibili.

##### Processo di Bernoulli, def 153 p.101

Consideriamo successioni di variabili aleatorie così definite:
$(\beta_n)_{n=1}^N$ dove $\beta_n:\Omega \rightarrow \R$,  $\beta_n(w) =\beta_n((w_k)_{k=1}^N)$  

Essa guarda la componente n-esima, se essa è 1, cioè $w_n= 1$, allora vale "u", se vale '0' allora assume "d", con $u>d$, e probabilità q e p.

Prende il nome di **processo di Bernoulli.** E' un processo stocastico a valori reali
$(F_n)_{n=1}^N -$ adattato, con $F_n=\sigma(\beta_1,...,\beta_n)$, la più piccola $\sigma-$algebra tale che le $\beta_i$ sono osservabili. Rappresenta il rumore di mercato, ciò che accade per caso.

##### Processo di conteggio del processo di Bernoulli, def 154

Consideriamo la successione di variabile aleatorie $(\N_n)_{n=1}^N$ dove $\N_n:\Omega \rightarrow \R$  dove, $N_0 \doteq0$ e $N_n \doteq \sum_{k=1}^N \frac{\beta_k -d}{u-d}$

cioè conta quanti 1 si sono realizzati fino al tempo N, infatti $\beta_k$ assume valori "u" o "d", e la sommatoria può quindi addizionare valori 1 o 0. Sto sommando variabili aleatorie di Bernoulli standardizzate, allora $N_n$ è una *variabile aleatoria binomiale*.

Sia $\beta_n$ sia  $(\N_n)_{n=1}^N$ sono $(F_n)_{n=0}^N-$ adattati. Comodi per descrivere il fenomeno.

##### Processo dei prezzi dello stock

Sfrutta il processo di Bernoulli.
Consideriamo $ (S_n)_{n=0}^N$  dove $S_0 \in \R$ (è una variabile di Dirac/numero che scegliamo noi.)
$S_n \doteq \beta_nS_{n-1} , \forall n=1,...,N$

$S_1 = \beta_1S_0$ assume $uS_0$ oppure $dS_0$,
$S_2=\beta_2S_1 = \beta_2 \beta_1 S_0$ assume $u^2S_0$  oppure  $d^2S_0$ oppure  $udS_0 = duS_0 $

Questo è il processo dei prezzi del titolo rischioso, è un processo *adattato*.

Ci chiediamo $P(N_n=k)$ cioè conto le volte che compare "1" nelle prime $n$ componenti, allora può prendere valori $N(\Omega) = {0,1,...,n}$.

La somma di Bernoulli è una v.a. binomiale, allora $P(N_n=k) = \binom{n}{k} p^k q^{n-k} $

E' dimostrabile che  $S_n=u^{N_m} d^{n-N_m}S_0$, ($u^{N_m} \doteq $ ho avuto $N_m$ volte esito $u$)
allora $P(S_n) = P(N_m = k) = \binom{n}{k} p^k q^{n-k}$

Infatti abbiamo $S_n$ che è l'insieme di valori assunti da una binomiale.
Processo dei prezzi ha stessa probabilità del processo di conteggio.

###### Media del processo dei prezzi stock, prop 163:

Devo calcolare: $E[S_n]= \sum_{k=0}^n u^kd^{n-k}S_0 *\binom{n}{k}p^kq^{n-k}= S_0 \sum_{k=0}^n \binom{n}{k}(up)^k(dq)^{n-k} = S_0(up+dq)^n$

> Nella sommatoria, moltiplichiamo il peso per la probabilità nel primo step, raggruppiamo nel secondo, e risolviamo il ninomio di Newton nella conclusione.



Lo scopo del modello è fare delle **previsioni ottimali**, ma che vuol dire?
Ogni variabile aleatoria ammette momento di qualunque ordine, perchè lo spazio è finito, l'integrale diventano somme, somme di cose finite sono sempre finite.
Tutte le variabili aleatorie che possiamo considerare, cioè $X: \Omega \rightarrow \R^M \in L^2(\Omega,\R^M)$, cioè spazio di Hilbert. Si può provare che questo spazio è di dimensione finita, anche se in realtà per noi è uno spazio euclideo.
La sua particolarità è poterci mettere un prodotto scalare, ovvero:
$X,Y \in L^2(\Omega, \R^M)$ , con prodotto scalare:

 $<X,Y> = X^TY \doteq \sum_{m=1}^M \sum_{w \in \Omega} X_m(w)Y_m(w)P(w)$  

perchè $X= (X_1,..., X_M)^T$ e $Y=(Y_1,...,Y_M)^T$

Immaginiamo di avere $X \in L^2(\Omega,\R)$, con $X$ che è $F_N-$  $\beta(\R^M)$  variabile aleatoria. Ovvero posso osservarla solo alla fine, come una **call europea**, che conosco solo quando si realizza $S_n$ perchè $C_N \doteq max\{S_n -K,0\}$.
Quale è la migliore stima di questa variabile aleatoria al passo $n<N$?

La migliore stima è la **Speranza condizionata** rispetto all'informazione "n", l'ultima che ho! Cioè cerco $E[X|F_n]$.
Se considero il sottospazio di Hilbert $L^2(\Omega_n, \R)$ con $\Omega_n = (\Omega, F_n, P)$, allora la speranza condizionata diventa la **proiezione ortogonale di $X$ su questo sottospazio**.

Grafico: la distanza dal centro alla proiezione di X, l'oggetto ha distanza minima possibile. Distanza minima $||X-Y||^2 = <X-Y,X-Y> = E[(X-Y)^T(X-Y)]$ perchè trattiamo vettori, se caso reale è al quadrato. (M=1). 

![Screenshot 2023-05-17 alle 19.59.51.png](/var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_1gaaic/Screenshot%202023-05-17%20alle%2019.59.51.png)

Presa $(X_t)_{t \in R_T}$, e una serie storica fino a 't', voglio predirre il suo futuro. Come faccio? Costruisco processo stocastico di cui la serie storica può essere vista come una traiettoria. La difficoltà è nell'overfitting, ok per il passato, meno per il futuro. Deve carpire le proprietà nell'insieme, non punto per punto.
La predizione sarà $E[X_{t+h}|F_t]$, una banda di predizione (non una traiettoria precisa, è come dire "ho possibili futuri".) Per quanto riguarda la distanza dei minimi quadrati, questo è il meglio che posso fare.
