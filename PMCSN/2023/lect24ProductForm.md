### SLIDE PRODUCT FORM

Nelle slide 1/2 partiamo da sistema vuoto avente stato (0,0). Le frecce rispettano un certo ordine: la freccia egli arrivi $\lambda$ va sempre verso il basso (verticale).
Stesso discorso per $\mu$, che è sempre diagonale. Il grafo prodotto ha una struttura a lattice.

Guardiamo il primo centro (senza vedere ciò che c'è dopo) che riceve con tasso di Poisson, serve con tasso esponenziale, per ipotesi. Posso pensare alla soluzione M/M/1 $p^n(1-p)=P\{N_S=n\}^{M/M/1/FIFO}$, questa è uguale anche per $M/G/1/PS$, in cui tutti sono come se fossero in servizio in simultanea.

SE $\rho=\lambda/\mu_1 <1$ allora posso scrivere come scritto sopra, risolvendo in $\rho_1$. Il primo centro è risolvibile.

Il problema del secondo centro è: cosa gli entra?

Esiste il Teorema di Burke: dato processo M/M/1 stabile con arrivi Poisson di parametro $\lambda$, allora anche il *processo di partenza* è un processo di Poisson di parametro $\lambda$.
Allora anche per questo secondo cenntro vale come prima, in $\rho_2$.
Per la **proprietà di indipendenza** ho $\pi(i,j)= P(n_1=i)P(n_2=j)$.

Se introducessi il feedback che ritorna nella coda 1 con "1-p"?
Nel lattice cambia solo il passaggio tra gli stati (0,1) e (1,0) con valore $\mu_2(1-p)$.
Questi due centri non sono totalmente indipendenti, quindi neanche Burke va bene. Tuttavia è come se si comportassero indipendentemente l'uno dall'altro. Posso calcolare come prima.

###### Come posso vedere se il sistema è stabile?

Devo vedere se i due $\rho$ sono minori di 1. Mi serve $\lambda$ da trovare, perchè c'è il feedback. Uso le equazioni di traffico.
Il $\lambda$ è il throughput. $\lambda_1$ è ciò che esce dal centro 1, e deve essere uguale a ciò che entra nel centro 1. Bisogna ragionare sul singolo centro e scrivere l'equilibrio tra flusso in uscita ed entrata. Trovo il sistema di slide 7.
Nel caso aperto, $\lambda$ è un parametro, non incognita. Da ciò posso scrivere tassi e numeri medi di visite. (L'ultima volta avevamo usato $\gamma$).
Ciò dipende anche da dove torna il feedback, se ritornasse all'entrata del centro 2 sarebbe diverso.



Sotto certe ipotesi possiamo calcolare il tutto come prodotto dei singoli centri, con le formule già viste (multiserver con Erlang, etc...). Sotto quali ipotesi?

### Reti di code separabili

* Bilanciamento del flusso, per avere soluzione stazionaria.

* Comportamento one-step, non è possibile che due transizioni verso due punti diversi della rete nello stesso momento. Devo contare il movimento del job.

* Omogeneità: presenta tre declinazioni, comunque vuol dire indipendenza dallo stato. Nel *routing* devo avere indipendenza totale (controesempio: non andare nel centro se popolazione>70%, creo dipendenza.) Il routing deve essere probabilistico ed indipendente dallo stato, cioè parlo di omogeneità.
  Nei *dispositivi*, il tasso di un certo dispositivo può dipendere solo da sè stesso (vedi processor sharing) ma non da altri. La condizione è interna.
  Per gli *arrivi esterni* il tasso degli arrivi esterni su un determinato centro dipende solo rispetto al centro che stiamo considerando, non dagli altri.



### BCMP

La versione della soluzione in forma prodotto più ampia. Mette insieme reti aperte, chiuse e miste. Il routing probabilistico, senza memoria e indipendente. Introduce le distribuzioni generali distinguendo se i centri prevedono attese (allora uso esponenziale), altrimenti se non si forma coda (c'è sempre server libero) uso infinite server, PS, LIFO-prel.


