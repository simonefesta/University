### Lezione 23 maggio 2023

### Recap, da p.106 prop.170

Abbiamo introdotto la *speranza condizionata* $E[\cdot | \mathcal{F}]: L^2(\Omega,\R^M) \rightarrow L^2(\Omega_{\mathcal{F}},\R^M)$

dove a sinistra abbiamo delle  $\xi-\beta(\R^M)$ variabili aleatorie, e a destra un sottoinsieme $F-\beta(\R^M)$ variabili aleatorie, infatti  $F \subseteq \xi$.

Tale operatore lo abbiamo visto anche a CPS, per questo mostriamo solo qualche proprietà, come:

* $\int_FE[X|\mathcal{F}]dP=\int_FXdP$     $\forall F \in \mathcal{F}$ , da cui in particolare si ha:
  
  $E[E[X|\mathcal{F}]] = E[X]$ mettendo $F = \Omega$

* Se $X \in L^2(\Omega_\mathcal{F},\R^M) \rightarrow E[X|\mathcal{F}]=X$ perchè $X$ è già osservabile in funzione di $\mathcal{F}$, in quanto vi appartiene.

* Se $X \in L^2(\Omega_\mathcal{F},\R^M)$ e $Y \in L^2(\Omega,\R^M)$, solo $X$ è osservabile rispetto informazione $\mathcal{F}$. Allora X esce fuori. $E[XY^T|\mathcal{F}] = XE[Y^T|\mathcal{F}]$

* Se $X$ è indipendente da $\mathcal{F}$, l'osservazione di $X$ è indipendente da \mathcal{F}, quindi l'osservazione di $\mathcal{F}$ non dà "vantaggi", allora: $E[X|\mathcal{F}] = E[X]$

* tower property: $E[\;E[X|\mathcal{F}]\;|\;G] = E[\;E[X|G]\;|\;\mathcal{F}] = E[X|G] \; se$ $G \subseteq \mathcal{F}$ 

* Se $\phi:\R^M \rightarrow \R$ convessa, $\phi \circ X \in L^2(\Omega,\R)$
  $E[\phi(X) |\mathcal{F}] \geq \phi(E[X | \mathcal{F}]) $ . Caso di interesse è se $\phi(X) \doteq |X|$.

Vediamo due conseguenze di questa proprietà:

* $E[X| \mathcal{F}] = E[E[X|\mathcal{F}]^2]-E[X]^2$

* Se $X \in L^2(\Omega,\R)$ allora $Var(E[X|\mathcal{F}]) \leq D^2[X]$. Cioè ho uno stimatore
  ($E[X|\mathcal{F}]$) di qualcosa ($X$). La variabilità di uno stimatore è sempre più piccola della variabilità dell'oggetto che stimo. Se devo stimare un oggetto complesso, e non ho tutte le informazioni a lui associate, ha senso pensare che la stima che farò sarà meno "precisa" rispetto al comportamento vero che può assumere l'oggetto stimato.

###### Proposizione 172:

$X \in L^2(\Omega,\R^M)$ e $Y \in L^2(\Omega_{\mathcal{F}},\R^M)$ allora $Cov(X-E[X|\mathcal{F}],Y) = 0$, cioè l'approssimazione di $X$ sullo spazio. Sono tutti *vettori*. 
Se la covarianza è 0, stiamo dicendo che la differenza è *ortogonale* allo spazio. **Le speranze condizionate sono *proiezioni ortogonali*.**

![Screenshot 2023-05-24 alle 17.25.26.png](/var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_ncztyp/Screenshot%202023-05-24%20alle%2017.25.26.png)

___

**Def 174 - Serie di Martingala**

Riconsieriamo lo spazio di probabilità **C.R.R.** $(\Omega,\xi,P)$.

Prendiamo $(X_n)_{n=0}^N$ con $X_n$ che sono $\xi-\beta(\R^M)$ variabili aleatorie.

La successione è di **Martingala** se:

$E[X_n|\mathcal{F_{n-1}}] = X_{n-1} \;\forall \; n=1,...,N$ 
Cioè il predittore migliore del dato di domani, è fornito dal dato di oggi.
Notiamo che ha media costante.

Nel caso delle previsioni del tempo, se oggi c'è il sole, è probabile che ci sia anche domani. Non è detto che ci azzecco, però dovrei trovare un predittore migliore. E' un *benchmark* per la costruzione di altri predittori. Se non faccio meglio di questo, allora il predittore che abbiamo trovato non è migliore del **predittore Martingala**. Nello spazio C.R.R. abbiamo tutti i momenti, quindi non esistono altre condizioni da rispettare.

___

### Processo di Markov - def. 175

Abbiamo due condizioni:

* $(X_n)_{n=0}^N $ è $\mathcal{F}_n - adattato$. Vuol dire che la successione è osservabile.

* $E[f(X_n)|\mathcal{F}_{n-1}] = E[f(X_n)|\sigma(X_{n-1})]$ ovvero la storia del processo non gioca nessun ruolo nelle predizioni future, ciò che mi basta è "il punto precedente". Infatti Markov è *memoryless*, mentre $\sigma(X_{n-1})$ è l'ultima informazione data dal processo, cioè la sigma algebra generata solamente dalla variabile aleatoria $X_{n-1}$.
  $\mathcal{F}_{n-1}$ è invece generata da tutte le $n-1$ successioni, cioè tutta la traiettoria fino a $X_{n-1}$. Noi stiamo dicendo che non ci serve tutta la traiettoria, ma solo l'ultimo valore assunto dalla traiettoria.
  
  Una formulazione equivalente ma più intuitiva è:
  
  $P(X_n \in B|\mathcal{F}_{n-1}) = P(X_n \in B |\sigma(X_{n-1}))$ <br>
  In pratica, voglio arrivare al punto B, ho percorso la strada fino ad un certo punto, quale è la probabilità che, da dove sono arrivato, riesco ad arrivare a B? (componente a sinistra dell'equazione). A destra abbiamo invece la probabilità di arrivare in B sapendo solo l'ultimo punto in cui siamo arrivati. 
  **La storia (traiettoria) non ha importanza.**
  
  ![Screenshot 2023-05-24 alle 17.38.40.png](/var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_agqYiH/Screenshot%202023-05-24%20alle%2017.38.40.png)

____

###### Proposizioni 176,177,178

Sia $\mathcal{F}_n \doteq \sigma(\beta_1,...,\beta_n)$ l'informazione che ho osservando le realizzazioni del rumore. <br>Se avessi i prezzi $S_n=\beta_nS_{n-1}$ allora posso dire (ma non lo dimostriamo) <br>$\sigma(S_0,..., S_n) = \mathcal{F}_n \;\; \forall n=1,...N $ ed $S_0 \in \R_+$, cioè *osservare i rumori è come osservare i prezzi.*

La conseguenza è molto importante, infatti: <br>
$E[X|\mathcal{F}_n] = E[X|\sigma(S_0,S_1,...,S_n)] = E[X|S_0,S_1,...,S_n]$

$E[S_n|\mathcal{F_{n-1}]} = (up+dq)S_{n-1}$ perchè: <br>
$E[S_n|\mathcal{F_{n-1}]} =E[\beta_nS_{n-1}|S_0,S_1,...,S_{n-1}] = S_{n-1}E[\beta_n|S_0,...,S_{n-1}] =$ <br>
$S_{n-1}E[\beta_n] = S_{n-1}(up +dq)$

Se volessi stimare il valore di $S_n$, vuol dire che sto stimando una traiettoria di prezzo che ho osservato, che mi ha portato a $n-1$, da cui ripartire per arrivare ad $n$. La stima migliore è la media del rumore per lo stato corrente. In pratica il modo migliore per proseguire è attraverso la media. <br>Non è una **Martingala**, perchè dovremmo avere solo $S_m$ e non: <br>$E[S_n|\mathcal{F_{m}]} =E[\beta_n\cdot \cdot \cdot \beta_{m+1} S_{m}|S_0,S_1,...,S_{m}] = S_{m}E[\beta_n\cdot \cdot \cdot \beta_{m+1}|S_0,...,S_{m}] =
S_{m}E[\beta_n\cdot \cdot \cdot \beta_{m+1}] = S_{n}(up +dq)^{n-m}$caso generale con $m,n \in \{0,...,N\} : n>m$

___

#### Rendimento

$r_n \doteq \frac{S_n-S_0}{S_0} \; \forall n=1,...,N$ <br>
<br>$r_{m,n} \doteq \frac{S_n-S_m}{S_m} \;\; \forall \;n,m\;\;:m=1,...,N \; n>m $ <br>

$r_n(w) = u^kd^{\;n-k}-1 \;\;\; \forall n=1,...,N \; e \; k=1,...,n$ <br>

$P(r_n= u^kd^{;n-k}-1) = \binom{n}{k}p^kq^{n-k}$

___

#### Parte finanziaria - BS PORTAFOGLIO - def 181-183

$\pi= (\pi_n)_{n=1}^N =((X_n)_{n=1}^N,(Y_n)_{n=1}^N)$ è un BS portafoglio, la prima quantità indica l'investimento in *bond*, la seconda l'investimento in *stock*.
Poniamoci al tempo 0, e osserviamo il bond $B_0$ e lo stock $S_0$. 
Compriamo una certa quantità $X_1$ di Bond e $Y_1$ di stock. Il nostro portafoglio prende valore $X_1B_0 + Y_1S_0 = W_0$ al tempo t=0, perchè $X_1,Y_1$ le scegliamo al tempo 0, sono delle "false variabili aleatorie", in quanto sono la scelta dell'investimento, sono $\mathcal{F_0}-\beta(\R)$ variabili aleatorie.
Al tempo t=1 abbiamo $W_1=X_1B_1 + Y_1S_1$, posso riconfigurare il portafoglio. Modifichiamo le quantità, costituendo un nuovo portafoglio $X_2B_1 + Y_2S_1$, cioè prima ho osservato e poi aggiustato. Questi oggetti sono sempre $\mathcal{F_{n-1}}-\beta(\R)$ variabili aleatorie, quindi il processo è *predicibile*. 
Perchè allora non diciamo che sono deterministiche, visto che lo facciamo passo passo? Perchè il primo portafoglio è costituito al tempo 0, sto costruendo la strategia, ed $X_1$ e $Y_1$ sono deterministiche, però andando avanti io dovrò considerare scelte diverse a seconda dei valori futuri.
(esempio: litigo co a piskella, devo preventivare ogni sua possibile risposta, devo avere un *ventaglio* di scuse. Non so cosa accade nel futuro, ma devo essere pronto). Noi scegliamo di volta in volta osservando lo stock, ma la **pianificazione** fatta al tempo 0 non è deterministica, quello che faremo dipenderà dalla vera realizzazione dello stock. Se lo stock va su due volte, allora prendo un certo $X_1$, se va su e giù farò altro, li *pianifico* nel reticolo, non è che li so. Se li vedo nel reticolo, sono tutti determistici. Ma al tempo 0 sono probabilistici.
È naturale ipotizzare che nei vari intervalli  l'operatore finanziario scelga le componenti $X_n$ e $Y_n$ del proprio portafoglio in funzione dei valori che si attende possano realizzarsi per *bond* e *stock*. L'evoluzione del bond è *deterministica*, quindi $B_n$ è sempre prevedibile.
Il miglior predittore del prezzo dello stock $S_n$ è $(up+dq)S_{n-1}$. 
Possiamo quindi dire che la riconfigurazione del portafoglio (leggasi come la scelta delle quantità $X_n$ e $Y_n$) dipende **solo** da $S_{n-1}$, cioè saranno in sua funzione. 

___

#### Portaglio autofinanziante - def 185

E' un portafoglio che, nelle riconfigurazioni, non richiede inserimento o prelievo di ricchezza.
Parto da ricchezza iniziale $W_0=0$ e creo portafoglio $X_1B_0 + Y_1S_0 = 0$, ho due alternative:

+ Prendere a prestito l'ammontare del bond (quindi vado "in negativo", perchè lo chiedo in prestito), ed usarlo interamente per acquistare lo stock (qui vado "in positivo", perchè acquisto quantità).

+ Vendere allo scoperto sullo stock (vado in "negativo" sulla quantità di stock posseduti) e depositare sul bond. (acquisto quantità "positive" di titolo non rischioso).

Osservo il valore $W_1=X_1B_1 + Y_1S_1$, riconfiguro $X_2B_1+Y_2S_1 = W_1$

Cioè la riconfigurazione deve avere stesso valore del valore osservato, ma non vuol dire che $W_0=W_1=...$ <br>La condizione di *autofinanziamento* è: <br>$X_nB_n + Y_nS_n= X_{n+1}B_n + Y_{n+1}S_n$    $\;\;\;\forall n=1,...,N-1$ <br>
Un portafoglio autofinanziante è sia adattato che predicibile.

____

#### BS Portafoglio autofinanziante d'arbitraggio - 186

Le condizioni che dobbiamo avere per trovarci in *arbitraggio* è:

* $W_0 = 0, \; P(W_N \geq0)=1 \; , P(W_N >0)>0$

Anche nel caso multiperiodale, un arbitraggio è un portafoglio che a fronte di un investimento iniziale nullo assicura con *certezza*, cioè indipendentementemente dagli esiti di mercato che si possano verificare, che *non si subiscano perdite*, con probabilità di guadagno **strettamente positiva**.
Qui assumo che il portafoglio possa cambiare, mentre nel monoperiodale dovevo rispettare queste cose al tempo 0. 
La condizione non deve valere neanche ai tempi intermedi, non solo a quello finale. La condizione non deve valere mai, altrimenti ho arbitraggio.
