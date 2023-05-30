Lezione 30/05/23

Recap

* Legge di trasformazione dello stock: $S_n=\beta_nS_{n-1} \; \forall n=1,...,N$ che porta con sè alcune conseguenze, come.
  
  - $E_m[S_n]= E[S_n|\mathcal{F}_m] = (up+dq)^{n-m}S_m \;\; \forall n,m=1,...,N \; ,<n$
  
  - Iterandola, abbiamo $S_n=\beta_n \cdot ... \cdot \beta_{m+1}S_m $, infatti:
    $E_m[\beta_n \cdot ... \cdot \beta_{n+1}S_m] = E_m[\beta_m \cdot ... \cdot \beta_{m+1}]S_m = E[\beta_m \cdot ... \cdot \beta_{m+1}]S_m$
    
    Siamo passati dalla speranza condizionata alla speranza perchè le varie beta sono indipendenti dalla sigma-algebra $\mathcal{F}_m$
  
  - Possiamo introdurre il *tasso di rendimento*. Nel **monoperiodale** era $r_T \doteq \frac{S_T-S_0}{S_0}$. Nel **multiperiodale** $r_{n,m+1}= \frac{S_{n+1}-Sn}{Sn}$ per un singolo periodo, e $r_{m,n}=\frac{S_n-S_m}{S_m}$ per più periodi.
  
  - Preso $r_n=\frac{S_n-S_0}{S_0} = n^kd^{n-k} P(r_n=n^kd^{n-k}) = binomiale DA COMPLETARE$
  
  - Abbiamo poi visto il **BS-Portafoglio** $\pi=( (X_n)_{n=1}, (Y_n)_{n=1})$ con le quantità di bond e stock acquisiti al tempo $n$.
  
  - La ricchezza del portafoglio parte da $n=0$, cioè $(W_n)_{n=0}^N$
    $W_1 = X_1B_1+Y_1S_1$, e allora $W_n=X_nB_n + Y_nS_n$, ma come ci arrivo?
    Osservo i tempi $B_0,S_0$, scelgo le quantità $X_1,Y_1$ e compongo $W_0=X_1B_0+Y_1S_0$. A noi interessa particolarmente $W_0=0$, ovvero prendiamo a prestito il bond (+) e compriamo lo stock(-), o viceversa.
    L'idea è che con ricchezza nulla, per comprare qualcosa devo vendere altro. Il portafoglio $W_0$ viene creato tra il tempo 0 e il tempo 1, ovvero $[t_0=0,t_1=\frac{1}{N}]$, in questo lasso di tempo non ho cambiamenti di bond e stock. Il portafoglio è *autofinanziante*.
  
  - Da questo portafoglio deriviamo due osservazioni:
    
    - Tale processo è "F-adattato" (la F è "gotica", non pare una F.)
      $W_n-\mathcal{F}_{n}-\beta(\R)$ variabile aleatoria.
    
    - $\pi=( (X_n)_{n=1}, (Y_n)_{n=1})$ è un processo "F-gotica" predicibile, $(X_n,Y_n)-\mathcal{F}_{n-1}-\beta(\R^2)$ variabile aleatoria.
  
  - Ai fini della scelta di $X_n,Y_n$ ci interessa solo lo stock, perchè il bond è noto. Quindi sia $X_n$ sia $Y_n$ sono in funzione di $S_{n-1}$.
  
  - Da CPS, vale che $E[Y|X]=E[Y|\sigma(X)] = f(X)$ dove $f$ è una opportuna funzione boreliana. Il miglior predittore di $Y$ dato $X$ è sempre dato da una funzione di $X$. Se fossero indipendenti? $f(X)=E[Y]$ che però è una costante. Se $Y=g(X)$? si porta fuori dalla speranza condizionata, allora $g(X)=f(X)$. I casi che più ci interessano sono tutti tranne questi due casi *estremi*. Un esempio è se $X,Y$ sono congiuntamente gaussiane, dove esiste una formula che ci dice:
    $E[Y|X] \doteq \alpha  +\beta \cdot X =f(X)$ 



### BS-Portafoglio d'arbitraggio

Se parto da ricchezza iniziale nulla e ho portafoglio autofinanziante, ho arbitraggio se $W_0=0 \rightarrow P(W_n \geq 0)=1$ e $P(W_n >0) >0$

Nel multiperiodale, $r_{n-1,n}^+>r_{norisk}>r_{n-1,n}^-$ , inoltre $u-1 >r_{norisk}>d-1$ da cui $u>1+r>d$ , stessa condizione vista nel monoperiodale.
Supponiamo di violare questa condizione, allora al tempo t=1 posso realizzare portafoglio che *sicuramente* mi dà guadagno. Nel monoperiodale *finisce qui*, nel **multiperiodale** questo guadagno lo metto *tutto sul bond*, e quindi mi rimane fino alla fine.

### Probabilità neutrale al rischio

E' $\bar{P}: \xi \rightarrow R_+$ (in realtè è una tilde) tale che:

- $\beta_1,...,\beta_n$ siano *totalmente indipendenti* rispetto a $\bar{P}$.
  Se prendo un sottoinsieme e calcolo $P(\beta_{j_1},...,\beta_{j_n})=P(\beta_{j_1}) \cdot ... \cdot P(\beta_{j_n})$ per ogni sottoinsieme.

- $S_{n-1}=\frac{\bar{E}_{n-1}[S_n]}{1+r}$ da cui deduciamo che:
  
  - $S_m=\frac{\bar{E}_{m}[S_n]}{(1+r)^{n-m}}$
  
  - $S_0=\frac{\bar{E}[S_n]}{(1+r)^{n}}$

Come nel caso monoperiodale, se esiste una probabilità neutrale al rischio, essa è *unica*. Dipende dal fatto che lavoriamo con un modello *binomiale*. Ho modellato l'incertezza come una bernoulliana. Se la modellassi diversamente (es: trinomiale: "va bene", "va male", "non cambia nulla") non è detto che ciò valga ancora!

Inoltre, in assenza di portafogli BS d'arbitraggio, esiste un'unica probabilità neutrale al rischio.

Sappiamo che $\bar{E}_{n-1}[S_n] = \frac{S_{n-1}}{1+r} = \dot{E}_{n-1}[S_n]$, $S_n=\beta_n S_{n-1}$

(incompleto, vedi slide?)

Se $u>1+r>d$ , si ha $\frac{1+r-d}{u-d}>0$ e $\frac{u-(1+r)}{u-d}>0$, allora la loro somma $\frac{1+r-d}{n-d} + \frac{u-(1+r)}{u-d} = 1$, allora stiamo definendo una probabilità così fatta:
$P(\beta_n=u) =\frac{1+r-d}{n-d} = p tilde$

$P(\beta_n=d) =\frac{u-(1+r)}{u-d} = q tilde$

Perchè sappiamo che va bene? Perchè lo abbiamo fatto per $p,q$ quindi che problemi dovrei avere se li chiamo p tilde e q tilde?

$\bar{E}_{n-1}[S_n]= {S_{n-1}}({1+r})$, ma $S_n=\beta_nS_{n-1}$

$\bar{E}_{n-1}[\beta_nS_{n-1}]=\bar{E}_{n-1}[\beta_n]S_{n-1}=\bar{E}[\beta_n]S_{n-1} = \bar{E}[\beta_n] DA COMPLETARE$

 

Il processo dei prezzi scontati è una Martingala, e il processo dei prezzi è un processo di Markov.

Abbiamo detto che se esiste una (unica) probabilità neutrale al rischio (se non ci sono portafogli bs d'arbitraggio). Anche il viceversa è vero! Come nel monoperiodale.

Se riprendiamo il discorso delle Call & Put, avevamo $C_T-P_T= S_T-K$. Se ipotizziamo che il mercato sia descrivibile tramite binomiale?
La legge sopra vale sempre deterministica, ma deve succedere che $C_0-P_0 = S_0 - \frac{K}{1+r_T}$, dipendente dal fatto che sul mercato non ci siano arbitraggi. Si vede che la legge della domanda e dell'offerta segue in maniera forte questa legge derivata dall'ipotesi in cui il modello binomiale catturi l'essenza dei mercati reali, in assenza di arbitraggio.

### Opzioni europee

Contratti che ci danno diritto di acquisire o vendere lo stock ad un prezzo fissato detto *Strike* in un tempo T (detto anche N).

$C_N=C_T= max\{S_T-K,0\}$ e $P_N=P_T= max\{K-S_T,0\}$

Chi sono $C_0$ e $P_0$?
Nel monoperiodale erano $P_0=\frac{\bar{E}[P_T]}{1+r}$ e $C_0=\frac{\bar{E}[C_T]}{1+r}$, ma adesso *devo valutarle in tutto l'arco temporale della loro vita*.

$S_T= u^jd^{N-j}S_0$ $\forall j=0,1,...,N$

Se volessi valutare il $max\{S_T-k,0\}$? Si può dimostrare che, definito 
$n_k= min\{n \in N:u^nd^{N-k}S_0 \geq k\}$ allora ho un sistema in cui:
$C_N= 0 \;\;\; \forall n=0,1,...,n_k-1$ , oppure
$C_N= n^kd^{N-k}S_0 -k \;\;\;\forall n=n_k,..,N$

Se k cresce, è più facile che la call valga 0. E' dimostrabile che $n_k= [\frac{ln(K)-ln(S_0)+n\cdot ln(d)}{ln(n)-ln(d)}]$ di cui prendo la parte superiore.

### Portafoglio autofinanziante di copertura

E' di tipo $\pi=((X_n)_{n=1}^N, (Y_n)_{n=1}^N)$ in cui $C_T=X_TB_T+Y_TS_T$ (uguale per la Put).
Supponiamo di vendere una call allo strike "K", se alla scadenza il titolo supera "K", la call vale $S_T -K$, che è una retta di 45 gradi. Potenzialmente avrei perdite illimitate. L'idea è: vendo la call ad un certo prezzo (quale? da capire!) e con tale ricavo metto su un portafoglio, investendo nel bond e nello stock, in modo tale che al tempo finale sono in grado di ripagare il costo della call.

Se andassero sotto k? è tutto guadagno!

Non osservare questo principio ha portato alla crisi sui mutui del 2007/2009. Il mercato andava forte, le banche credevano di poter dare credito a chiunque. Questi crediti, che poi sono diventanti importanti, sono stati usati per creare dei derivati (li hanno "ammassati") per poi venderli. Il problema? I titoli erano stati valutati male, e quasi tutti sono andati in default. E' stato un difetto di valutazione.
