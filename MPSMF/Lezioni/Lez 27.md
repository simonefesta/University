# Lez 27 - 16 giugno 2023

###### Opzioni americane 3.5.3

Riprendiamo il confronto tra probabilità oggettiva e soggettiva. $\tilde{E}[P_N]$ è la *speranza condizionata*.

Sappiamo che varrà $P_n$ rispetto alle informazioni iniziali.
$P_0$ è invece un numero.
Ricordiamo che per le *americane* l'esercizio non è per forza al valore terminale. Dalla **definizione 255** vediamo quando conviene esercitare l'opzione (non conviene mai esercitare prima, quindi alla fine sono come call europee. Questo vale **solo per le call.**)
Il payoff, nelle opzioni europee, si può ottenere solo alla fine, cioè alla fine è una variabile aleatoria dipendente dallo stato, non dal tempo.

Per i derivati americani (in particolare opzioni americane) il tempo entra come variabile per il payoff, riscuotere prima è diverso da riscuotere dopo. Non posso invocare la *completezza del mercato*, devo trovare altre vie. Il valore delle call americane non va mai esercitato prima, per le Put invece sì, appena si arriva al valore del titolo pari a 0 conviene vendere. Se aspetto che riscenda a 0 non è conveniente come farlo subito.

Dalla **definizione 232**, il tempo di arresto è una variabile aleatoria che permette di accorgerci di un valore che essa assume in quel tempo li, non dopo!
Quindi, ad esempio, se prende valore 2, me ne accorgo a tempo 2, non dopo! Visto **esempio 234**.
Dal **teorema 235**, troviamo la formula per calcolare il prezzo della PUT. E' in funzione di un massimo, con uno sconto basato sul tempo di arresto. Esiste un metodo alternativo, che prende il nome di **Tecnica del Bellman, teorema 236**. Vediamo che è presente il valore di esercizio differito $AP_{n+1}$. Nella **definizione 237** abbiamo esercizi immediati e futuri.
In ogni punto del reticolo, se volessi esercitare la put e veder il current payoff, devo fare la differenza tra il nodo precedente e quello attuale.
Se il nodo da cui parto è 100, e ora sono a 95, allora faccio 100-95. Se parto da 100, e sono a 105, allora 100-105 = - 5, quindi non posso essendo <0. 
Infatti, se decido di vendere un titolo quando la sua quota è x, io ho il guadagno se questo valore scende (vendo a 10 una cosa che vale 5), e quindi non ha senso vendere a 10 una cosa che vale 15.

L'**Expected payoff** è il valore *atteso*, cioè quanto guadagno se sto in un certo nodo e *non* esercito l'opzione? e' 0, il futuro non c'è (sto sull'ultimo nodo, non c'è niente dopo). L'opzione dopo tali nodi muore, non c'è futuro. L'expected payoff è 0.
Se mi metto "prima", allora è valore atteso futuro dato il punto in cui mi trovo. Se mi trovo in un nodo con valore 81, e futuro può essere 93 o 77. Allora faccio 100-93 e 100-77, li moltiplico per le probabilità $\tilde{p},\tilde{q}$ e li sconto di *un periodo* (1+r) e trovo 81, lo devo fare dalla fine verso l'inizio! Valori futuri condizionati da dove mi trovo.

Nei grafici, stock in nero, payoff atteso blu, payoff rosso. Se vedo primo nodo, trovo che il primo nodo ha payoff 1.33, quindi devo aspettare. Vado al secondo nodo (quindi ora mi sto muovendo da inizio alla fine). Ho due percorsi: adesso payoff immediato è superiore a quello atteso, allora devo esercitare immediamente. Se non lo esercito ho altri due percorsi, potrei guadagnare in uno dei due percorsi dopo. Ma devo vedere quanto è probabile. Potrei avere payoff immediato 9.75, e scontando di (1+r) avrei un payoff atteso maggiore del precedente, però sto considerando solo il caso in cui "mi va bene", nei conti devo considerare anche il caso in cui "mi va male". Sarebbe $\frac{9,75 \cdot 0,5}{1+0.05}=4.64 < 5$ (valore in rosso)
Quindi devo esercitare, non posso sperare nel futuro, devo essere razionale. Ottengo un valore medio futuro più basso di quello attuale. Vale anche se aspetto di più! Appena payoff corrente > payoff atteso, *devo esercitare*. Successivamente è stato aggiunto in magenta il valore di mercato, il massimo tra i due valori, cioè il payoff corrente. Se payoff corrente è 0 devo aspettare. Se valore atteso è 0, *non ho più speranze*. La put americana prende valore quando titolo scende. Dipende dalla traiettoria, è una v.a.
Finchè blu > rosso non esercito.

**Esempio 239**
Vediamo $v_4^*(w) = 5 $ se  $\sum \omega=1$, altrimenti 4.

Al tempo 4, il tempo di arresto si esercita successivamente, quindi devo aspettare. Il valore del payoff futuro > payoff corrente, devo andare avanti.
Nel caso *altrimenti*, la somma non deve fare 1, ad esempio potrebbe fare 0, oppure 2.
Il reticolo parte da indice 0. Questo modo di calcolare mi dice in anticipo quando esercitare.

Ma quale è l'algoritmo dietro?

A riga 544 del file.r sono scritte le possibili realizzazioni. Sulla base di tale spazio vediamo quali sono i punti dove va eseguita l'opzione. Vediamo il massimo tra il payoff corrente e quello futuro. Otteniamo tavola che mi dice i vari massimi.
Successivamente viene creata una matrice usando la formula del tempo di arresto. Se la somma è 1, devo esercitare subito. Lo vedo traiettoria per traiettoria.
Nei grafici, se il primo valore viene 1, come la mettiamo, dobbiamo esercitarla sempre a 5. Se mi va male, esercitarla a 5 = morta, è "uguale".
Idealmente, da un certo punto in poi la put "muore", e noi gli assegniamo 0 pur di definirle.
Se vediamo 1,0,0,1,0 con 1 salgo, con 0 scendo, muore a 4.
Con un caso in cui vale 2, il nome della "tabella" è 32, cioè 1,1,0,.. diventa 2 perchè si azzera.


Possiamo vedere che opzioni europee e americane alla fine sono "uguali"?
Vediamo le call americane. In rosso payoff corrente. In blu payoff atteso.
15 rosso vs 33 blu, aspetto. Blu è sempre maggiore del payoff corrente. Alla fine payoff atteso coincide con quello "futuro", perchè non c'è più futuro. Si è discusso se magari 0 come valore futuro risulti più appropriato. Difficile capiti corrente=atteso, perchè non sarebbe più una funzione, il tempo di arresto non sarebbe più una funzione ma una corrispondenza. Vuol dire che in un nodo il tempo di arresto può prendere due valori (o mi arresto, o vado a quello dopo) e non dovrebbe verificarsi.

###### 3.5.4 Calibrazione

Un modello non è la realtà, devo renderlo più simile alla realtà tramite certi parametri, cioè lo calibro.
Crr non è la realtà, quindi lo calibro.
Se cerco distribuzione altezza degli uomini dai 30 ai 40 anni, allora questa fascia di età si presume una gaussiana, e si parla di stima della media e della varianza della gaussiana. Non è un modello astratto, ma come effettivamente devono andare la casa.
La *stima* la si fa sui parametri reali per adattare un modello realistico, la *calibrazione* prevede di definire parametri per adattare un modello non reale ad una situazione reale. Come lo si fa?
Abbiamo il problema di *r* tasso privo di rischio in $\Delta t$, che si lega con tasso di interesse non rischioso, secondo l'**osservazione 241**. $\rho$ viene calcolato su base annua, cioè su 365 anni, fornito dalla FED/banca.
Altri calcolano solo i giorni in cui i mercati sono aperti, cioè 250/255 giorni.
Se faccio rapporto tra $S_n$ e $S_{n-1}$, e ne faccio il log, ottengo una normale dipendente da certi parametri stimabili. E' come fare la differenza dei logaritmi.
Se le variabili aleatorie in funzione del log sono indipendenti, e rendimenti lognormalmente distribuiti, allora si può fare $S_N/S_0$.

$\beta_n$ è v.a. bernoulliana.
nella 3.16 abbiamo 2 equazioni e tre incognite (q=1-p), per stimare i parametri 'fisso' d=1/u, ma non è l'unica. 3.17 è sviluppato con Taylor.
$\bar{X}_N$ è stimatore per la speranza.
$S_N^2(X)$ è stimatore per varianza, da cui le mettiamo a sistema per ricavare $\mu, \sigma$.
