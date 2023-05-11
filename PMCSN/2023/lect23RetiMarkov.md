## Reti di Markov 11/05/2023

Possiamo classificare le reti in tre tipologie:

+ **Aperte**, quelle maggiormente studiate, in cui c'è un tasso $\lambda$, e prima o poi ogni job lascia il sistema.

+ **Chiuse**, in cui la popolazione circola per sempre nella rete. Da non confondere con il sistema feedback, perchè anche se in tale sistema un job può rientrare in coda, non rimarrà per sempre nel sistema.

+ **Miste**, dove avviene una classificazione degli utenti in classi, e quindi per alcune classi il sistema si comporta come fosse aperto, per altre classi come se fosse chiuso.

Noi siamo particolarmente interessati al modello **Markoviano**, il quale si muove a stati esponenziali.
Quando abbiamo visto Erlang, esso proveniva da un processo Markoviano. La rete di code è una visione ad alto livello della rete di Markov. Se definisco il comportamento della rete di code, sto definendo Markov.

Posso usare un processo di Markov se vengono rispettate due condizioni:

+ L'insieme di stati deve essere **mutuamente esclusivo**, ovvero per ogni istante di tempo posso trovarmi solo in un unico stato, e **collettivamente esaustivo**, ovvero non deve esistere uno stato non modellabile dal sistema di stati scelto.

+ Deve valere la **memoryless**, ovvero, il passaggio dallo stato $s_i$ allo stato futuro $s_{i+1}$ è influenzato unicamente dallo stato $s_i$, e non da come sono arrivato allo stato $s_i$.

#### Esempio con applicazione:

![Screenshot 2023-05-11 alle 14.58.34.png](/var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_RBmSam/Screenshot%202023-05-11%20alle%2014.58.34.png)

In figura è rappresentata una rete chiusa con M = 3 centri. Poichè la rete è chiusa, nessun job può uscire da questo centro, può solo spostarsi al suo interno.
Assumiamo che al suo interno vi siano N = 2 job. I serventi sono a coda singola, FIFO, disciplina astratta. Introduciamo la **matrice di routing/probabilità**, la quale esprime la possibilità di passare da un sotto-centro ad un altro. Questa matrice è MxM.

 $P =\begin{pmatrix}  
0,2 & 0,4 & 0,4\\  
1 & 0 & 0\\
1 & 0 & 0  
\end{pmatrix}$

Ad esempio, la componente di riga 3 e colonna 1, ovvero $p_{3,1}$, ci dice che tutti i job uscendi dal centro 3 andranno nel centro 1.

Possiamo notare come, prendendo ogni singola riga, la somma delle componenti sia 1, trattandosi di probabilità. NOTA: per ogni istante di tempo, consideriamo *un solo* job che cambia stato, non di più! Siamo interessati a capire come possano distribuirsi questi due job nel centro. In generale, con tempi di servizio esponenziali, possiamo scrivere: $\bar{s} = {(n_1,...,n_i,...,n_M)}$ ovvero, nel centro $i$ ci sono $n$ job, tra quelli in coda e quelli in servizio. Introduciamo il concetto di **Spazio degli stati**:
$E = \{s|n_i \geq 0, \sum_{i=1}^Mn_i=N\}$
con $N$ popolazione totale, la cardinalità di E è: $|E|= \begin{pmatrix}  
N+M-1 \\  
M-1  
\end{pmatrix}$

Vogliamo trovare i possibili stati di questo sistema, il metodo preferibile è **l'algoritmo lessico grafico inverso**. L'idea è di partire da un centro pieno (nel nostro caso il centro 1), togliere un job a questo centro e distribuirlo agli altri centri, poi toglierne un altro e così via.
Ovvero, parto da $(N,0,0)$, e passo a $(N-1,1,0)$ e $(N-1,0,1)$.
Poi continuo: $(N-2,2,0)$ e $(N-2,0,2)$ etc.. vediamolo applicato.
$s_1 = (2,0,0)$
$s_2 = (1,1,0)$
$s_3 = (1,0,1)$
$s_4 = (0,2,0)$
$s_5 = (0,1,1)$
$s_6=(0,0,2)$

Osservazione: quando arriviamo in $s4$ è come se l'algoritmo ripartisse, poichè nel centro 2 ho tutti gli N job, e quindi da lui inizio nuovamente a distribuire i job *guardando avanti*, infatti non riassegno alcun job al centro 1, ma solo al centro 3.
Ciò che sto facendo è descrivere il processo di Markov che modella questa rete di code.
Adesso possiamo associare ad ogni stato un *tempo di vita*, ovvero il tempo passato in un certo stato, e lo indichiamo con $t_{vi}$.
Vediamo un esempio:

Partiamo da $s2 = (1,1,0)$, da lui possiamo andare verso $s4 = (0,2,0)$ ed $s_5=(0,1,1)$. Il tempo di vita in $s_2$ è l'inverso del tasso di uscita in quello stato (è come dire che ci sto un tempo inverso a quanto velocemente me ne vado). Si può dimostrare, ed è una condizione *sufficiente ma non necessaria*, che se i tassi di uscita sono esponenziali, allora anche i tempi di vita nello stato lo sono.
In $s_2$  il centro 1 ed il centro 2 presentano dei job,esco da tale stato se termina uno dei due job. Se il tasso di uscita dai due centri è rispettivamente $\mu_1$ e $\mu_2$, allora il tempo di vita nello stato 2 è : $E(t_{v2}) = \frac{1}{\mu_1+\mu_2}$.
Se $s_1 = (2,0,0)$ allora $E(t_{v1}) = \frac{1}{\mu_1}$ (ne ece solo uno alla volta!).

### Transizione tra gli stati con probabilità

Vogliamo adesso analizzare le transizioni tra gli stati.
Concentriamoci su le frecce *entranti* nello stato $(1,1,0)$. Prendiamo la prima componente dello stato, ovvero il suo primo '1'. Quali sono gli stati, che per effetto di una transazione, ci permettono di entrare in $(1,1,0)$?

L'idea è questa: per avere '1' come prima componente, questo '1' lo devo prendere dalle seconda e terza componente, quindi devo partire da stati che hanno seconda e terza componente incrementata di 1 (un incremento alla volta, non incremento entrambe!), perchè poi verrà decrementata in favore della prima.
Definiamo $p_{i,j}$ come la probabilità di transitare dallo stato $i$ allo stato $j$.

- $(0,2,0)$ , con un job del centro 2 che va nel centro 1, ovvero con tasso $\mu_2*p_{2,1}$

- $(1,1,0)$ perchè rientra in sè stesso, con tasso $\mu_1*p_{1,1}$.

- $(0,1,1)$ se il job nel centro 3 va nel job di centro 1, ovvero con tasso $\mu_3*p_{3,1}$

Adesso ci concentriamo sul secondo '1' nello stato. Come ci arrivo?
Per avere '1' sulla seconda componente, questo uno deve essere fornito da prima o terza componente, quindi dagli stati con tali componenti incrementati di uno.

* $(2,0,0)$ con tasso $\mu_1*p_{1,2}$.

* $(0,1,1)$ già avuto prima, non lo conto due volte!

Questo ragionamento lo applico solo ai centri *non vuoti*, quindi non serve ragionare sulla terza componente. In figura osserviamo anche le *uscite*.

![Screenshot 2023-05-11 alle 19.11.53.png](/var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_cKtTMF/Screenshot%202023-05-11%20alle%2019.11.53.png)

A tutto ciò possiamo applicare il **Bilanciamento del flusso**, ovvero per il singolo stato possiamo scrivere, tramite equazione, che il flusso in entrata equivale al flusso in uscita. Per il singolo stato, stiamo applicando il bilanciamento globale dello stato. Se esiste una soluzione stazionaria, allora queste equazioni possono essere scritte come:

$\pi({\bar{s}})$(flusso *OUT* dallo stato) = flusso *IN* dello stato = $\sum_{\forall \bar{s} \in E}\pi(\bar{s})*$(flusso *IN* $\bar{s}$)

Dove $\pi(\bar{s})$ è la probabilità stazionaria di un certo stato $\bar{s}$.

Applichiamola all'esempio:
$P_{stato (1,1,0)}(\mu_1p_{1,1}+ \mu_2p_{2,1}+ \mu_1p_{1,2}+\mu_1p_{1,2}) = P_{1,1,0}\mu_1 + P_{2,0,0}\mu_2 + ...$

Riprendiamo la formula di prima:
$\pi({\bar{s}})$(flusso *OUT* dallo stato) = flusso *IN* dello stato =$ \sum_{\forall \bar{s} \in E}\pi(\bar{s})*$(flusso *IN* $\bar{s}$)


se portiamo la componente di sinistra a destra, e sommiamo $\pi(\bar{s})$ a destra e sinistra, abbiamo:
$\pi({\bar{s}}) = \pi({\bar{s}})(1- Flusso_{out}) + \sum\pi(\bar{s})Flusso_{in} $

che mi permette di scrivere il tutto in forma matriciale:

$\bar{\pi}$ = $\bar{\pi}Q$

dove abbiamo $\bar{\pi}$ = tutti gli stati e $Q$ = matrice diagonale sparsa, di dimensione $N$x$M$(in questo caso 6, ma in generale molto più grande).
Sulla diagonale principale di $Q$ abbiamo componente  "$1-\sum q_{i,j}$" per ogni riga, ovvero:
$Q =\begin{pmatrix} 
... & ... & q_{1,j} & ... &...\\ 
q_{i,1} & q_{i,2} & 1-\sum{q_{i,j}} &... & q_{i,|E|}\\
... & ... & q_{|E|,j} & ... & ... \\
\end{pmatrix}$

Per ogni riga, la somma deve essere 1. 
$q_{i,j}$ è la frequenza di transazione da $s_i$ a $s_j$, ovvero tra gli **stati**, non i centri!

Procediamo con $\bar{\pi}Q-\bar{\pi} = 0$, passo a  $ \bar{\pi}(Q-I)=0$
$\bar{\pi}S = 0$, ovvero $S$ è detto *generatore del processo*, in cui abbiamo sottratto 1 agli elementi sulla diagonale principale. (nb: 0 è matrice nulla, non un semplice numero.)

Manca la condizione di *normalizzazione*, perchè stiamo trattando probabilità, inoltre senza questa avrei infinite soluzioni.

$\sum_{\forall{s_j} \in E} \pi(s_j)=1$

Ciò che si fa è prendere una qualsiasi colonna di $S$, metterci tutti '1', ovvero $[1,1,...,1]^T$, generando così $S'$.

Allora, se ad esempio faccio tale sostituzione alla prima colonna, *impongo* $\bar{\pi}S'=[1,0,...,0]^T$ , ovvero 
"*probabilità di tutti gli stati*" x " *prima colonna di tutti '1'*" = *normalizzazione*

Concludo trovando la soluzione $\bar{\pi}= [1,0,...,0]S^{-1}$, poichè in questo primo caso la soluzione sta nella prima riga, ovvero mi interesserà solo la prima riga della matrice inversa $S^{-1}$ ,ma ovviamente possiamo generalizzare tutto per una riga $i-esima$.



