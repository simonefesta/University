### Recap

$\Omega =\{{w_n}_{n=1}^N, w_n=1,w_n=0\}$

$\xi = P(\Omega)$ insieme delle parti.

$P(w)=p^kq^{N-k}$ con $k=\{n \in \{1,...,N\} : w_n=1\}$
$P(E)=\sum_{w \in E} P(w)$

$0,1,..., n_0,n_0+1,...
$
Noi ad $n_o$ dobbiamo fare delle scelte conoscendo il passato, non il futuro. Qui entra in gioco la filtrazione.
Supponiamo di avere un evento $E \in F_n$ con un certo $n$ fissato.
Ho un punto in E, cioè $(w_n)_{n=1}^N= w \in E$
Osserviamo i seguenti $w$:
$w_1=1, w_2=0, w_3=1$

Supponiamo $n=3$ e $N=7$, cioè $w \in E \in F_3$
Allora, dato un evento che sta nella filtrazione, tutte le altre sequenze di $w$ aventi le prime 3 componenti come quelle osservate, appartengono alla filtrazione. Quindi $(1,0,1,0,0,0),(1,0,1,0,0,1),...$

Se $E \in F_1$, allora $w \in E$ può essere $w_1=1$ oppure $w_1=0$. Se prendiamo il caso $w_1=1$:
Allora $E=\{(1,0,0,...),(1,0,1,...),... \} = E_1$

La mia filtrazione $F1 = \{0,\Omega,E_1,E_0\}$

mentre $F_2= \{0,\Omega, E_0,E_1,E_{0,0}  \}$ cioè tutte le combinazioni "è andata bene/è andata male". Devono esserci anche complementari etc, perchè è una sigma algebra. $E_{0,0} \in E_0$. $E_0= E_{0,0} \cup E_{0,1}$ 
Filtrazione chiusa rispetto a tutte le unioni numerabili. Noi addirittura lavoriamo in un caso chiuso.

Supponiamo di poter distinguere le componenti fino alla n-esima, ovvero:
$F_n= \{E_{0,0,0,..0_n}, E_{0,0,0,...,1_n} \}$, ovvero è una partizione di $\Omega$. Devo fare tutte le unioni possibili.

Voglio uno strumento che rappresenti il flusso delle informazioni.

### Processo stocastico

Formalmente, si prende uno spazio di probabilità $(\Omega,\xi,P)$, una successione $(X_n)_{n=0}^N$ con $X_n: \Omega \rightarrow \R^M$

Se ogni $X_n$ è una $ \xi-\beta(\R^M)$ variabile aleatoria su sigma algebra di Borel.
L'evento $\{X_n \in B\} \in \xi, \forall B \in \beta(\R^M) $ .
Se l'informazione è tutta l'informazione possibile, cioè $\xi=P(\Omega)$, allora ogni successione di variabile aleatoria è un processo stocastico,

Prendo B, sottoinsieme borelliano di $R^M$, vedo la controimmagine $E \in \omega$, se questo $E \in \xi$ allora è un processo stocastico. Posso osservare realizzazioni della variabile aleatoria alla luce della informazione che ho.

Siccome $\Omega$ è finito, non solo parliamo di processo stocastico, bensì è un processo stocastico di ordine k, $\forall k \in N$, cioè abbiamo ogni ordine, anche se a noi interessano i primi quattro. Se la matrice varianza-covarianza è invertibile, allora possiamo anche ricavare Skewness e Kurtosi.



La filtrazione rappresenta il flusso temporale degli eventi. Particolarizziamo allora la definizione di processo stocastico. Riprendo lo spazio di probabilità, ci metto ${(F_n)}_{n=0}^N$. Allora la successione $(X_n)_{n=0}^N$ è un **processo stocastico adattato** a ${(F_n)}_{n=0}^N$ se $\forall n$, $X_n$ è una $F_n-\beta(\R^M)$ variabile aleatoria.
Al tempo n posso osservare le realizzazioni della variabile aleatoria $X_n$.


##### Esempio

Prendo $N=7, n_1=3, n_2=5$.
Sia $B_1(w) \doteq w_{n_1}$, cioè se $w=(1,0,1,0,1,0,1)$ allora $B_{n_1}(w)=1$, e se $w=(1,0,0,1,0,1,0)$ allora $B_{n_1}(w)=0.$ Semplicemente prendo come valore di tutto $w$ il valore della componente in posizione $n_1$.

Se $0,1 \notin B(\R)$ allora la controimmagine è l'insieme vuoto.
Se $0,1 \in B(\R)$ allora la controimmagine è tutto omega.
Se $B_1 \doteq \{0 \notin B_1 , 1 \in B_1\} \doteq \{w \in \Omega:w_3=1\} \in F_B$

$E_{0,0,1} \in F_3, E_{0,1,0} \in F_3,E_{0,1,1} \in F_3, E_{1,1,1} \in F_3 $ ma $F_3$ è $\sigma$-algebra, quindi anche l'unione, ma l'uonione è ciò che abbiamo scritto sopra.

### Processo predicibile

$(X_n)_{n=0}^N$ è predicibile rispetto a $(F_n)_{n=0}^N$ se $\forall n=1,...,N$ $X_n$ è $F_{n-1}-\beta(\R^M)$ variabile aleatoria.
La composizione del portafoglio è un gruppo di variabili predicibile, lo stock invece è adattato. Noi scegliamo il portafoglio prima di osservare il valore dello stock, sono in anticipo su cosa accadrà, quindi è predicibile, ciò che faccio è alla luce della informazione vecchia. Faccio scelta iniziale alla luce di ciò che potrebbe accadere alla fine. Lo scopo è "cucire bene" tale modello sulla realtà, stimandone bene i parametri.

##### Processo di Bernoulli

Consideriamo $(\beta_n)_{n=1}^N$ dove $\beta_n:\Omega \rightarrow \R$, $\beta_n(w) =\beta_n((w_k)_{k=1}^N)$  

Essa guarda la componente n-esima, se essa è 1, cioè $w_n= 1$, allora vale "u", se vale '0' allora assume "d", con $u>d$, e probabilità q e p.

Essa è un **processo di Bernoulli.** E' un processo stocastico $(F_n)_{n=1}^N$- adattato, con $F_n=\sigma(\beta_1,...,\beta_n)$

##### Processo di conteggio del processo di Bernoulli

Consideriamo $(\N_n)_{n=1}^N$ dove $\N_n:\Omega \rightarrow \R$  dove, $N_0 \doteq0$ e $N_n \doteq \sum_{k=1}^N \frac{B_k -d}{u-d}$

cioè conta quanti 1 si sono realizzati fino al tempo N, infatti $B_k$ assume valori "u" o "d", e la sommatoria può quindi assumere valori 1 o 0.

Anche $(\N_n)_{n=1}^N$ è $(F_n)_{n=0}^N$- adattato

##### Processo degli stock

Consideriamo $ (S_n)_{n=0}^N$  dove $S_0 \in \R$
$S_n \doteq \beta_nS_{n-1} ,\forall n=1,...,N$

$S_1 = \beta_1S_0$ assume $uS_0$ oppure $dS_0$,
$S_2=\beta_2S_1 = \beta_2 \beta_1 S_0$ assume $u^2S_0; d^2S_0; udS_0 = duS_0 $

Ci chiediamo $P(N_n=k)$ cioè cerco una certa quantità, $N(\Omega) = {0,1,...,n}$.

Bernoulli è una v.a. binomiale, allora $P(N_n=k) = \binom{n}{k} p^k q^{n-k} $

Sia $S_n=u^{N_m} d^{n-N_m}S_0$, allora $P(S_n) = P(N_n = k) = \binom{n}{k} p^k q^{n-k}$

Processo dei prezzi ha stessa probabilità del processo di conteggio.



Lo scopo del modello è fare delle previsioni ottimali, ma che vuol dire?
Ogni variabile aleatoria ammette momento di qualunque ordine, perchè lo spazio è finito, l'integrale diventano somme, somme di cose finite sono sempre finite.
Tutte le variabili aleatorie che possiamo considerare, cioè $X: \Omega \rightarrow \R^M \in L^2(\Omega,\R^M)$, cioè spazio di Hilbert. Si può provare che questo spazio è di dimensione finita, anche se in realtà per noi è uno spazio euclideo.
La sua particolarità è poterci mettere un prodotto scalare, ovvero:
$X,Y \in L^2(\Omega, \R^M)$ , con prodotto scalare:

 $<X,Y> = X^TY \doteq \sum_{m=1}^M \sum_{w \in \Omega} X_m(w)Y_m(w)P(w)$  

perchè $X= (X_1,..., X_M)^T$ e $Y=(Y_1,...,Y_M)^T$

Immaginiamo di avere $X \in L^2(\Omega,\R)$, con $X$ che è $F_N$ - $\beta(\R^M)$  variabile aleatoria. Ovvero posso osservarla solo alla fine, come una **call europea**, che conosco solo quando si realizza $S_n$ perchè $C_N \doteq max\{S_n -K,0\}$.
Quale è la migliore stima di questa variabile aleatoria al passo $n<N$?

La migliore stima è la **Speranza condizionata** rispetto all'informazione "n", l'ultima che ho! CIoè cerco $E[X|F_n]$.
Se considero il sottospazio di Hilbert $L^2(\Omega_n, \R)$ con $\Omega_n = (\Omega, F_n, P)$, allora la speranza condizionata diventa la proiezione ortogonale di X su questo sottospazio.

Grafico: la distanza dal centro alla proiezione di X, l'oggetto ha distanza minima possibile. Distanza minima $||X-Y||^2 = <X-Y,X-Y> = E[(X-Y)^T(X-Y)]$ perchè trattiamo vettori, se caso reale è al quadrato. (M=1). 


