# Lezione 23 - 06/06/23

> Il prof ha caricato la versione 16.1 delle note, da quello che ha detto, per non perdere troppo tempo, farà riferimento a formule e pagine del libro quando spiega.

Da CPS:
Quando abbiamo $(\Omega,\xi,P)$ e una informazione ridotta/ $\sigma-algebra$ $\mathcal{F} \subseteq \xi$ 
$X \in L^2(\Omega,\R^M) \rightarrow E[X|\mathcal{F}] \in L^2(\Omega_\mathcal{F},\R^M)$

Se $\mathcal{F}= \sigma((F_n)_{n \in N})$ allora $E[X|\mathcal{F}] = \sum_{n \in N} E[X|F_n] \cdot 1_{F_n}$ 

Se $\mathcal{F}=\sigma(X_1,...,X_N)$ ed esiste $f:\R^M \rightarrow R$ boreliana, allora $E[X|\mathcal{F}]=E[X|X_1,...,X_N]=f(X_1,...,X_N)$

Questi due teoremi sono molto utili.
Ricordiamo che $S_n=\beta_nS_{n-1}$ con $\beta_n= u$ con probabilità $p$ oppyre $d$ con probabilità $q$

##### Derivato

E' un titolo in cui il payoff al tempo T dipende dagli stati di S. Ne è un esempio il future, opzioni call e put; è una scomessa su una performance di un altro tipo, ovvero dipende da come vanno le cose per il titolo *sottostante*.

Un derivato di questo tipo mi permette di esercitare/riscuotere la scommessa al tempo T, non posso riscuoterlo ad un tempo precedente. (ES: se AS Roma deve fare 60 punti entro fine campionato, devo aspettare la fine del campionato anche se ho già superato i 60 punti).
Questi sono detti derivati *europei*.
Esistono anche *derivati americani* in cui posso riscuotere ad un tempo $t \leq T$

*Esempio*:
Compro uno strike S con opzione americata al tempo K. Titolo sale, potrei subito esercitare l'opzione per comprare il titolo. Posso anche aspettare, con il rischio che il titolo si abbassi. Al tempo $T$ però devo per forza fare la mia scelta.

![Istantanea_2023-06-06_09-48-16.png](/home/festinho/Scrivania/Istantanea_2023-06-06_09-48-16.png)

Possiamo ulteriormente classificare i derivati in $path-independent$ e $path-dependent$, ovvero dipendenti o meno dalla traiettoria. Ne è un esempio del primo tipo il derivato americano, perchè mi interessa solo il valore al tempo K, quindi hanno un comportamento markoviano, essendo indipendenti dal passato. Un esempio di path-dependent può sfruttare la media dei valori per stabilirne un prezzo.
Entrambi sono *titoli europei* comunque.

Questo discorso è importante perchè, se prendo derivato di  tipo europeo, il *payoff* è:

- Nel caso *path-indipendent*, $F_D(S_N)$, ovvero funzione dello stato finale.

- Nel caso *path-dipendent* è una funzione di tutto il processo, cioè $F_D(S_1,...,S_N)$.

Se volessi sapere il valore del derivato al tempo 0? cioè $F_0(0)$ quanto lo devo pagare?

- $F_D(0)=\frac{E[F_D(S_N)]\;|\;\mathcal{F_0]}}{(1+r)^N} = \frac{E[F_D(S_N)]}{(1+r)^N}$ nel caso *path-indipendent*. <br>($\mathcal{F_0} $ è la $\sigma-algebra$ banale, che quindi ometto).

- $F_D(0)=\frac{E[F_D(S1,..,S_N)]}{(1+r)^N}$ nel caso *path-dependent*.

##### Dal libro

Abbiamo visto cosa sia il derivato, vediamo le definizioni 199 e 200. 

![Istantanea_2023-06-06_12-36-47.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-36-47.png)

Nell'osservazione 201 vediamo che $w$ è la successione di elementi "andati bene" ed "andati male", sono $2^N$.

![Istantanea_2023-06-06_12-37-20.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-37-20.png)

Nella definizione 202 vediamo i titoli che possiedono l'indipendenza. Vengono  evidenziati anche i valori $C_T$ e $P_T$, nel caso europeo (indipendenti) e asiatici (dipendenti). 

![Istantanea_2023-06-06_12-38-19.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-38-19.png)

> $T$ e $N$ sono uguali, cambia solo il contesto in cui vengono usati.

**Teorema 203**

![Istantanea_2023-06-06_12-39-52.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-39-52.png)

Se non ci sono portafogli di arbitraggio, allora ogni derivato europeo è *replicabile* mediante portafoglio autofinanziante composto da bond e stock, sia che si tratti di path indipendent, sia path dependent. Allora il modello $CRR$ è un modello di mercato *completo*, poichè posso replicare con portafoglio autofinanziante. Come si dimostra questo fatto?
Esistono due versioni:

- Nella versione "facile" assumo che i titoli siano europei, allora devono soddisfare l'equazione 3.81. Vediamo come sono fatti i bond $B_N$ ed $S_N$, se li sostituisco alla 3.81 ottengo un sistema a due incognite, risolvibile. Ci dice come prendere le componenti $X_N$ e $Y_N$ subito dopo il temo $N-1$, ovvero prima di $N$. Vediamo come entrambe siano in funzione di $S_{N-1}$. Le ipotesi sono $B_0,S_0>0$ (bond e stock positivi, banale) e che $u>d$, ovvio anche questo, ed infine il tasso $r>0$. Sono ipotesi banali, che faccio per via del denominatore che non può essere 0. Posso farlo sempre, senza *ipotesi di arbitraggio*.
  Mi chiedo allora il portafoglio autofinanziante al tempo $N-1$, <br>ovvero cerco $W_{N-1}=X_NB_{N-1} + Y_NS_{N-1}$
  
  Risolvendo trovo $W_{N-1}$ in funzione delle probabilità neutrali al rischio, (qui applico l'ipotesi di non arbitraggio).
  Nella 3.86 sviluppiamo ulteriormente, e vediamo che a destra abbiamo il valore neutrale al rischio del derivato calcolato al tempo $N-1$, a sinistra ho il valore del portafoglio autofinanziante $W_{N-1}$.
  Successivamente facciamo *backward - induction*, ovvero cerchiamo $W_{N-2}, W_{N-3},...,$ 
  Andando avanti nel calcolo delle altre $X_N,Y_N$ non avremo più il valore del derivato, bensì il valore del portafoglio.
  In particolare vediamo, nella 3.90, che $W_{N-2}$ è dato dalla speranza condizionata dal valore del derivato al tempo N. 
  Quindi io faccio *backward-induction*, quando arrivo a 0 so come costruire il portafoglio passo dopo passo, e quindi vado avanti, per vedere i valori.
  
  ![Istantanea_2023-06-06_12-40-51.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-40-51.png)
  
  Nella 3.91 si ha il caso generico per $n$ passi indietro. Si ha sempre struttura *binomiale* perchè abbiamo dipendenza solo dallo stato finale del titolo, non del percorso. Per arrivare a 0?
  Prendo $n=  N-1$, ovvero $W_{N-(N-1)}$, cioè le prime compontenti del portafoglio replicante. 
  
  ![Istantanea_2023-06-06_12-41-34.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-41-34.png)
  
  Troviamo $W_0$ e ricaviamo, dalla 3.94, $X_1$ e $Y_1$, però sono in funzione di $W_1$, non dovevano non dipendere dagli step intermedi?
  Se sostituisco la 3.95, vediamo che $X_1,Y_1$ dipendono solo da $S_0$ e altre componenti che sono note.
  Se combinassi $X_1,Y_1$ con $B_1,S_1$ dovrei poter ricostruire esattamente $W_1$.
  Ottengo due casi, associati ai valori $d$ ed $u$, che ci riportano a $W_1$.
  Quando vendo il derivato al tempo 0 al prezzo detto da $W_0$, so che componenti mettere al mio portafoglio al tempo 0, ma anche ai tempi successivi, vedendo se mi ha detto bene o mi ha detto male.
  *Ho costruito la mia strategia al tempo 0.*

- Se ci fosse dipendenza dal path?
  Ho aleatorietà su $Sn$, a seconda se assume valore $d$ o $u$. Cioè rispetto al passo successivo ho solo questi due casi (ragiono passo per passo, non sul path completo). Le formule sono più lunghe, ma la metodologia è quella. Vediamo come $X_N,Y_N$ dipendono da tutta la storia del processo, ma il meccanismo di progressione è sempre *bernoulliano*.
  
  ![Istantanea_2023-06-06_12-42-28.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-42-28.png)
  
  Nella 3.100, $W_{N-1}$ dipende dalla speranza condizionata di tutti i precedenti $S_i$. Procedendo con la ricostruzione in avanti, abbiamo qualche difficoltà tecnica in più, ma comunque alla fine ci si riesce, ottendendo la 3.102. (la riga finale è sbagliata, mancano le componenti $F_D[S_1,...]$
  Nella quart'ultima riga, vediamo come $\tilde{p}\tilde{q}$ viene 'capovolto' in $\tilde{q}\tilde{p}$, che non è così scontato, qui possiamo perchè ci sono dietro le proprietà del reticolo. Anche questi sono *replicabili*!

![Istantanea_2023-06-06_12-43-37.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-43-37.png)

##### Opzioni europee 3.5.2

Sono caratterizzate da $C_N=C_T \doteq max\{S_T-K,0\}$, con payoff $u^nd^{N-n}S_0$
Possiamo introdurre le probabilità neutrali al rischio.
**Def 204**, definizione di portafoglio autofinanziante rispetto alle *call*.
**Def 205** saltabile, perchè agiamo in un mercato completo e privo di portafogli arbitraggio. 

![Istantanea_2023-06-06_12-44-27.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-44-27.png)

Vediamo **Lemma 210**.

![Istantanea_2023-06-06_12-44-58.png](/home/festinho/Scrivania/Istantanea_2023-06-06_12-44-58.png)

$C_T \doteq max\{S_T-K,0\}=\frac{|S_T-K|+S_T-K}{2}$

$P_T \doteq max\{- S_T+K,0\}=\frac{|K - S_t|- S_T+K}{2}$

$C_T(w)-P_T(w)=\frac{S_T-K -(K-S_T)}{2} =S_T(w)-k$ <br>$C_n=\frac{\tilde{E_n}[C_N]}{(1+r)^n}$ <br>

$P_n=\frac{\tilde{E_n}[P_N]}{(1+r)^n}$ <br>

$S_n=\frac{\tilde{E_n}[S_N]}{(1+r)^n}$ <br>

$C_n=X_n^CB_n+Y_n^cS_n$ <br>
$P_n=X_n^PB_n+Y_n^PS_n$ <br>

Li sottraggo ed esce $S_N-K$, sfruttando il fatto che il mercato sia completo, e quindi la parte sui BSS portafogli non serve.

##### Digressione sui progetti

Le domande sono del tipo:

- Definizione di arbitraggio

- Cosa è portafoglio di Markowitz,...,etc

Non ci sono delle dimostrazioni 'ferree'.
Per il progetto possiamo fare dei lucidi, markdown etc a seconda di ciò che riteniamo più congeniale per il progetto. Il prof dovrebbe lasciare una lista di alternative, ma se siamo interessati a qualcosa di specifico possiamo dirglielo.
Possiamo vedere cose del tipo:
titolo vale X, secondo il mio modello quanto si discosta? 
Non è per forza in singolo, se due persone fanno stesso progetto è possibile vederne le differenze. Ovviamente se uno una formula X nel progetto devo sapere che cosa sto facendo, ma non devo dimostrarle o altro.

###### *Esempio caso studio Progetto*

Voglio studiare il titolo di Amazon.
So che è un titolo americano, quindi devo spiegare cosa voglia dire questo.
Suppongo di usare il modello binomiale, devo calibrare il modello (ancora non fatto), ho necessità di avere dati, giorni, '$u$' e '$d$', per confrontare i prezzi teorici con quelli reali. Posso anche trovare un portafoglio ottimo.
