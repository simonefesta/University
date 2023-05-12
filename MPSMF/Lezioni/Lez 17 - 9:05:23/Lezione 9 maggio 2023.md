## Lezione 9 maggio 2023

### Recap da p.94, dopo proposizione 147.

Abbiamo visto che $S_{tn} = S_{n} = \beta_1 \beta_2...\beta_nS_0$, considerando anche il 'reticolo di scenari' con i possibili esiti, così chiamato perchè ci sono nodi uguali per valori/casi diversi. Successivamente abbiamo definito lo spazio $(\Omega, \xi,P)$

$\Omega \doteq \{{w \equiv (w_n)_{n=1}^N | w_n = 1 \cup w_n = 0}\} = \{0,1\}^N = X_{n=1}^N{\{0,1}\} $ , ovvero il

prodotto cartesiano delle N coppie.

La nostra famiglia di eventi E è composta da tutti i possibili sottoinsiemi di $\Omega$, ovvero $E = \textit{P}(\Omega)$, con P operatore insieme delle parti. Si ha che $|E| =2^{\Omega}= 2^{2^{\Omega}}$

Per completare lo spazio di probabilità ci manca la probabilità. Se ho uno spazio di probabilità discreto e la relazione $\sum_{w \epsilon \Omega} P(w) = 1$ e $P(E) = \sum_{w \epsilon \Omega} P({w})$ allora la probabilità definita è quella naturale (casi favorevoli su tutto).

Prendo la successione ${w = (w_n)_{n=1}^N}$, allora $P(w) = p^kq^{n-k}$ con $k=\{{n = 1,..N : w_n =1 \}}$

Se N = 4, e la sequenza è $\{0,1,0,1\}$ allora $P(\{0,1,0,1\}) = p^2q^2$, semplicemente conto gli '0' e gli '1'.

E' vero che $\sum_{w \epsilon \Omega} P(w) = 1 ?$

Il metodo più semplice è fissare il numero di '1', e sommare tutti i possibili numeri di '1', ovvero $\sum_{k=0}^N {\sum_{w \epsilon \Omega} p^kq^{n-k}}$ l'idea è riportarci alla formula del binomio di Newton che sappiamo fare 1. Si chiama **Probabilità oggettiva**, non dipende dall'osservatore, so solo che se un evento è positivo, allora il titolo si apprezza, sennò si deprezza.
(In pratica fisso k=0 e conto, fisso k = 1 e conto...)

Riprendiamo qualche concetto di statistica:
$(\Omega, \xi,P)$, $X:\Omega \rightarrow R^M, M \in N$

Tutte le possibili funzioni a valori in $\Omega$ sono $F(\Omega, R^M)$, quando è che $X$ è variabile aleatoria? Dalla teoria, la condizione è che $\{X \in B \} \in \xi$ per ogni B appartenente a $B(R^M)$. Se lo spazio di probabilità è discreta, **qualunque cosa è osservabile**, e quindi qualsiasi cosa è una variabile aleatoria. Allora in $F$ ho tutte le variabili aleatorie, quindi non devo pormi mai il problema. (Per l'esattezza un vettore aleatorio N-dimensionale). 
E' sempre vero che $\xi = P(\Omega)$.

Ci siamo poi chiesti i momenti finiti delle variabili aleatorie. Esiste $\int_\Omega |X|^K dP$ per avere momento di ordine K, ma qui, essendo discreto, ci riconduciamo a:

$\sum_{w \epsilon \Omega} |X(w)|^K P(w)$ **momento di ordine k di una v.a. discreta.**

$|X(u)| = \sqrt{(\sum_{m=1}^N X_m(w)^2)}$ con $X=(X_1,..,X_M)$ perchè siamo nel caso M dimensionale, se M=1 allora torniamo al caso monodimensionale col semplice modulo. Per quanto questi oggetti siano enormi, sono sempre finiti, per ogni k il momento di ordine k è sempre finito, perchè lo spazio di probabilità è finito. La somma è finita. Devo calcolarli!

A noi interessa il momento crudo del primo ordine, cioè la media, $E[X] = (E[X_1],...,E[X_M])$ cioè la media del vettore aleatorio è data dalla media dei singoli elementi. Vettore delle medie delle componenti.

Siamo interessati anche **il momento crudo del secondo ordine** $E[XX^T]$ con $X=(X_1,..,X_M)^T$ , la matrice è data da $(M \times 1) \times (1\times M)$ 
(rispettivamente X ed X trasposta), ovvero la matrice di dimensione MxM, simmetrica, contenente tutte le speranze di tutti i possibili prodotti.

$E[XX^T]= \begin{pmatrix}   E[X_1^2] & E[X_1X_2]\\   E[X_1X_2] & E[X_2^2]   \end{pmatrix}$

In realtà, ci interessa il **momento centralizzato di X**, ovvero la **Varianza**, cioè momento crudo di $X - E[X]$:
$Var(X) = M_2(X) = M_2' (X-E[X])$, ovvero la matrice varianze (quelle sulla diagonale principale) e covarianze delle componenti di X:

$\begin{pmatrix} E[(X_1-E[X_1])^2] & E[(X_1-E[X_1])(X_2-E[X_2])]\\ E[(X_1-E[X_1])(X_2-E[X_2])] & E[(X_2-E[X_2])^2] \end{pmatrix}$

NOTA: è come la matrice di prima, solo che nell'argomento il momento è centrato.

Vogliamo anche Skewness e Kurtosi.
Se io ho variabile aleatoria X, essa ha tutti i momenti di ordine k.
$M_3'(X) = (E[X_kX_lX_m])_{k,l,m=1}^M$ ovvero tutti i possibili prodotti 3 a 3, **TENSORE DI ORDINE 3.**
$M_4'(X) = (E[X_jX_kX_lX_m])_{j,k,l,m=1}^M$ **TENSORE DI ORDINE 4**.
Se ripensiamo a $M_2'(X)$ è un tensore di ordine 2, cioè di dimensione 2, un tensore di ordine 3 è matrice cubica nello spazio di dimensione 3, nell'ordine 4 è un cubo nello spazio di dimensione 4. Generlamente, è matrice di dimensione k.

La cosa interessante è che la 'lista' gli elementi distinti (che vengono moltiplicati) è il numero delle combinazioni con ripetizione di m elementi con classe 3: $C_{M,3}^{(2)} = \begin{pmatrix} M+3-1\\3 \end{pmatrix} = \frac{M(M+1)(M+2)}{6}$ 

$C_{M,4}^{(2)} = \begin{pmatrix} M+4-1\\4 \end{pmatrix}$

$C_{M,2}^{(2)} = \begin{pmatrix} M+2-1\\2 \end{pmatrix}$

Concentriamoci sul caso $M^4$: avrò tre indici $j,k,l,m$:
Se fisso  $j$ ho $\{1,..,M\}$ scelte, poichè prodotto commutativo posso prendere $k \geq j$, se lo prendessi più piccolo, sarebbe uguale al caso in cui inverto le due cose.
Fisso $l\geq k$, fisso $m \geq l$. 

Per individuare 4 elementi ho fatto funzione non decrescente: $\phi:\{1,2,3,4\} \rightarrow \{1,...,M\}$, ovvero le combinazioni con ripetizioni ordinate (non decrescente) di 4 elementi che si possono ripetere. Ne sono esempi (2,2,3,4) o (2,2,2,4).

#### Skewness e Kurtosi in funzione di una nuova V.A 'Y'

$X \rightarrow Y $

con $\rightarrow \doteq$ "*creo una nuova variabile aleatoria definita come a seguire*"

$Y \doteq Var(X)^{-1/2}(X- E[X])$ Se fosse una variabile aleatoria, e non un vettore, corrisponderebbe a $\frac{X-\mu_x}{\sigma_x}$ . Y è così definita per poter *standardizzare* la variabile X, quando essa è un vettore, è matrice varianza covarianza, simmetrica, semidefinita positiva.

* Skew(X) = $M_3'(Y)$

* Kurtosi(X) = $M_4'(Y)$

La skewness di X è il momento crudo di ordine 3 della Y, la kurtosi di X è il momento di sordine 4 di Y.

Questo nostro spazio $F(\Omega,R^M) = L^2(\Omega,R^M)$ spazio di Hillbert, identificato da:

 $<X,Y> = \sum_{w \epsilon \Omega} X(w)^TY(w)P(w)  , \forall X,Y \in F(\Omega,\R^M)$

Torniamo al modello vero e proprio, con $\Beta_1,...,\Beta_M$
$\Beta_n(w) = \Beta_n((w_k)_{k=1}^N) =$ u se $w_m=1$ oppure d se $w_m=0$
$\Beta_n: \Omega \rightarrow R$
Io ignoro tutte le successioni tranne l'n-esima.

**ESEMPIO**

N = 5, considero $\Beta_3(0,1,1,0,0)$, vedo il terzo elemento, è 1, allora tutto vale 'u'. Se $\Beta_3(0,1,0,0,1)$, il terzo elemento è 0, allora vale tutto 'd'.

Quanto vale $P(\Beta_n=u)$? essa è $P(\{w \in \Omega: w_n=1 \})$, ma questa probabilità dipende da $p^kq^{n-k}$ allora questa probablità è 'p', altrimenti sarebbe 'q'.
Intuitivamente abbiamo pensato a 1/2, che sarebbe vero per p = 1/2, ma abbiamo detto che è un p generico.

Si dimostra che, con questa probabilità introdotta, $\Beta_1,..,\Beta_M$ sono totalmente indipendenti, per come sono state definite (dimostrazione sulle note).

## Filtrazione

$\xi = P(\Omega)$ con P insieme delle parti. La sigma algebra degli eventi, cioè $\xi$, posso osservarla solo alla maturità T. Io però vorrei fare previsioni, non voglio aspettare. La filtrazione è un modello di informazione che si rileva progressivamente nel tempo. Andando avanti, la nostra informazione aumenta, ma c'è altra informazione che non è stata ancora rivelata.
A t=0 osservo $S_0$, dell'andamento futuro del prezzo non so nulla, non so quale omega tra $(w_1^*,..,w_N^*)$ si rivelerà. A t = 0 la mia sigma algebra iniziale della mia filtrazione è $F_o = \{\Omega,0\}$, informazione banale di Dirac.
Passo a t = 1, sappiamo se è uscito un caso positivo o negativo, cioè se $w_1 = 1$ o $w_1=0.$ 
Riesco a vedere $\{w \in \Omega, w_1=1\} = E_1$ oppure $\{w \in \Omega, w_1=0\} = E_0$
Allora avrò $F_1=\{\Omega,0, E_0, E_1 \}$, inoltre $F_0$ è contenuto in $F_1$, inoltre è $\sigma$-algebra.

A t = 2 saprò se $w_1=1$, allora $w_2=1$ oppure se $w_2=0$.
Se $w_1=0$, allora $w_2=1$ oppure $w_2=0$


$E_{0,0} = \{w \in \Omega : w_1 \cap w_2=0\}$

$E_{0,1} = \{w \in \Omega : w_1=0 \cap w_2=1\}$

$E_{1,0} = \{w \in \Omega : w_1=1 \cap w_2=0\}$

$E_{1,1} = \{w \in \Omega : w_1 \cap w_2=1\}$

Il mio spazio $\sigma$-algebra è $\{\Omega,0, E_{0,0},E_{0,1},E_{1,0},E_{1,1}\}$ ma non basta, ad esempio mancano $E_0$ ed $E_{1}$, visto che $F_0$ è incluso in $F_1$). Devo aggiungere anche i complementari.
Prendo dunque la più piccola sigma algebra contenente questi elementi.
Una filtrazione di $\Omega$ è una famiglia $(F_n)_{n=0}^M$ dove Fn è sigma algebra di eventi contenuta in $\xi$, $ F_n$ è contenuto in :

$F_{n+1}, \forall n=0,..,M-1$

Abbiamo visto che ogni $\Beta_n:\Omega \rightarrow R$ è una $\xi$-variabile aleatoria, rispetto a sigma algebra generale riesco a vedere valori assunti. Posso dire di più, ovvero che è $F_n$ variabile aleatoria. Non devo aspettare la fine del fenomeno, ma basta che arrivi al tempo n. $\Beta_n$ lo saprò al passo n-esimo, non mi servono quelli dopo, e quindi non mi serve l'intero spazio. $F_n$ è la più piccola sigma algebra generata da $B_1,...,B_n$, cioè $F_n=\sigma(\Beta_1,..,\Beta_n)$.

### Cosa è un processo stocastico, a fronte delle nuove conoscenze acquisite?

Un processo stocastico su $\Omega$ è una qualunque famiglia $(X_n)_{n=0}^N$ di variabili aleatorie $X_n: \Omega \rightarrow R^M$. Il processo si dice ADATTATO ad una filtrazione $F_n$ se, $\forall n= 0,1,.., N$ $X_n$ è osservabile rispetto a $F_n$. Le v.a. del nostro processo devono essere osservabili rispetto a tutta l'algebra, ma anche rispetto alla filtrazione assegnata, ovvero in maniera progressiva, senza aspettare fino alla fine. Un processo stocastico è *predicibile* rispetto ad una filtrazione se, $\forall n =0,...,N $, la v.a. è osservabile rispetto a $F_{n-1}$, cioè so che valore prenderà la v.a. un tempo prima.
Nel modello monoperiodale osservavamo a t=0 $S_0$ costruendo portafoglio, con quantità X del bond e quantià Y dello stock. A t = T vedevamo $S_T$, e ottenevamo $xB_T + yS_T$.
Adesso ho a $t = 0$  ho portafoglio $(x_1B_0, y_1S_0)$, a t=1 $(x_1B_1, y_1S_1)$
Il valore che prende è un processo adattato (lo so solo al tempo corrispondente), ma la sua configurazione è predicibile (la forma assunta è sempre la stessa, e l'ho scelta al tempo 0).
Gli aggiustamenti sono progessivi nel tempo, devo mettere in piedi strategia modificabile in 'corso d'opera'.
