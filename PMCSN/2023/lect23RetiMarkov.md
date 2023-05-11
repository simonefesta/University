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


