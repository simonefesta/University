# ML 8 novembre 2023

## Bagging

In generale invece di addestrare una rete, ne addrestro n, e poi vedo tutte le reti. E vedo che dice la maggioranza. Un errore viene compensato dagli altri.
Nel caso delle reti è semplice ottenere modelli diversi, perchè sensibili, cambio una cosa e la differenza è tangibile.

## Dropout

Tecnica recente, è una approssimazione de bagging con un numero esponenziale di reti diverse. Modo efficiente di avere tantissime reti diverse nella stessa rete. Scartiamo alcuni neuroni a caso della rete mentre la uso, basta mettere uscita corrispondente a tale unità a 0. Lo faccio ad ogni step,è come se generassi una rete diversa per ogni mini batch nel mio training, ma sempre nella stessa rete.

Nello specifico (2):
Abbiamo parametro p (probabilità) "dropout probability" per ciascun livello (ma può essere uguale per ogni livello). Normalmente 0.8 input layer, 0.5  (di tenerlo , il complementare è prob di toglierlo) per hidden units. Alcuni pezzi dell'input non li andrei a considerare, ogni input sarebbe qualche feature, che tolgo, allora forzo la rete ad apprendere in maniera robusta rispetto le info in input. Tali variazioni rispetto singola feature non dovrebbero essere cosi impattanti, e quindi la fortifico. Dropout SOLO nel training. Dopo training, scalo i pesi moltiplicando per le probabilità, questo per avere valori in range sensati (se ho il doppio dei neuroni, e ne tolgo metà, ricalcolo coi pesi per avere valori associabili a questa metà dei neuroni).
TensorFlow/Keras moltiplica l'input in reatà, scala lui. Kera usa `rate`, frequenza input vanno a 0 (quindi complementare rispetto a quello detto sopra). La somma dei valori è +/- uguale a farlo come visto prima.

ridetto meglio:

prendiamo $y_1=W^{(2)}\cdot h= \sum h_i$, se i vari h_1 sono 1, abbiamo circa 3 (per semplicità). se tolgo un'unità, avrei somma 2, quindi range di valore diverso, potrebbe alterare le predizioni fatte, perchè y si aspetterà 2 e non 3. Se usassi gl istessi parametri y avrebbe valori più vicini a 3 che a 2, per risolvere allora i pesi W li moltiplico per `p`, è un fattore di correzione.
Keras fa una cosa simile, ma la correzione la fa nel training, già sa che mettendo a 0 alcune unità, allora fa $h \cdot 1/p$, per far si che la somma dei valori sia sempre nello stesso range.



### notebook spotify

grafico, dopo 10 epoche overfitting dati. correggo con dropout, dopo l'input (primo livello della rete), e poi dopo il secondo livello nascosto. con droput va meglio.



## ottimizzazione

ML si basa su ottimizazzione matematica, cioè ottimizzare funzione loss, se non riesco a farlo non ha senso fare Ml, cioè si basa us ottimizzazione della discesa del gradiente, fare addestramento rete neurale grande può richiedere giorni o mesi, chiaramente quando ho a che fare con task grosso, non vado ad usare il prmo algoritmo sotto mano, quindi non è strano studiare algoritmi di ottimizzazione.

### Learning vs pure optimization

differenza tra ottimizzazione e machine learning, il secndo agisce in maniera indiretta, cioè in ricerca operativa basata su f obiettivo e variabili, e trovavo combinazione che minimizzasse o massimizzasse tale funzione. In Ml non è cosi, io giudico il modello in base a qualche misura di prestazione p tipo accuratezza calcolata su tst set, e potrebbbe anche essere una metrica intrattabile, che invento io èper giudicare quanto è buono. nel training otitmizzo costo che può essre diversa dalla metrica che ho detto prima, magari errore qaudratico medio. In Ml ho algoritmo ottimizzazione che ottimizza funzione J costo, però per capire se va bene non valuto J, uso un'altra metrica ed altri dati. Allora non sto minimizzando J, ma ottimizzare ad esempio la f. costo. Quanto sia il valore nella funzione che ho scelto ci faccio poco.

## NN optimization

lavorare con funzioni convesse, minimo locale è globale. non vuol dire che sia banale, però ho tale garanzia. con reti neurali ho problema non convesso.

### Local minima

reti locali DEEP hanno tanti minimi locali, so cazzi.
non è detto che minimo locale sia simile al globale, possono essere molto diversi. per reti grandi i minimi locali sono vicini ai globali, non c'è un teorema che lo garantisce, è empirico. per noi un problema è che minimo locale ha gradiente nullo e quindi mi "blocco" nel locale. però discesa stocastica gradiente buona per risolvere questi punti di sella.

### vanishing and exploding gradients

nel prodotto ci sono autovalori matrice elevati allora loro potenza t, se t è grande può capitare che:

- autovalore < |1|, diventa sempre più piccolo, tende a 0.

- autovlare > |1|, diventa più grande, tende a $\infin$ 

con reti moooooolto deep, da ultimo livello verso primo livello, i grandienti o sono vicini a 0 o vanno all'infinito. buona notizia: riguarda reti ricorrenti, in cui si usa matrice dei pesi uguale. noi invece abbiamo una matrice W per ogni livello, quindi questa cosa mitiga tali effetti.
