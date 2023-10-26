### M.L

## Output Units

- Se mettessi *sigmoid*, cioè funzione di attivazione che realizza output tra 0 e 1, sarei limitato da questo range nell'uscita.

- Possiamo associare ad ogni neurone in output la probabilità di appartenere ad una certa classe.

- L'uscita i-esima è calcolata, nel caso softmax, come segue:
  calcolo $z_i$, elevo all'esponenziale, e divido per la somma di tutti quanti, quindi sono compresi tra 0 e 1, ovvero rappresentano una probabilità, che cresce al crescere di $e^{z_i}$ al numeratore.

## Training Neural Networks

- Per ridurre la funzione costo, ciò che cambia è il valore dei pesi.

- Consideriamo quindi pesi ma anche il bias.

### Cost function

Abbiamo una loss function, ad esempio quella con l'errore quadratico medio $J(\theta) = \frac{1}{2} (t-y)^2$

Poi passiamo alla funzione costo, quindi errore quadratico su tutto il training set + errore di regolarizzazione (qui è generica), $\lambda$ è hyperparametro, che assumiamo costante.

### GSD

Abbiamo vari cicli, scorro sul training set, ogni ciclo è un'epoca, per ogni j calcolo funzione costo rispetto i pesi teta, cioè gradiente rispetto i parametri del modello, cioè derivata parziale funzione costo rispetto i parametri del modello. Poi aggiorno i pesi, in direzione opposta al gradiente (perchè il gradiente mi dice verso dove cresce).

### GSD 2

Senza non linearità, avremmo un modello lineare come quelli visti prima.
Se ho a che fare con funzioni NON convesse, il gradiente non mi da sicurezza sul minimo globale, ma potrei trovare un minimo locale. Con le funzioni deep spesso andiamo sui minimi locali, ma questi si avvicinano molto al minimo globale, per cui ci sta bene.

$\u{g} = \nabla_{0} J^{i}..$ come calcolo gradiente per un singolo livello?
Con più livelli la Loss è composta dai pesi di tutti i livelli.



### Backpropagation

Calcola il gradiente di una funzione, utile per reti multilivello. Spesso lo si usa per addrestrare una rete neurale, di cui un passo fondamentale è proprio il calcolo del gradiente, ma non basta, dobbiamo anche aggiornare i pesi, quindi non "addrestiamo con backpropagation".

### Overview

- Forward phase: mi muovo in avanti, vado a calcolare le varie attivazioni da input verso uscita, faccio predizione per tale input. Posso anche calcolare la funzione costo.

- Backward phase: calcolo gradiente rispetto ai parametri, partendo dall'output.

Useremo la programmazione dinamica, cioè metto da parte alcuni dati e li riuso successivamente, oltre alla regola della catena (analisi 1).

### Forward Propagation

Supponendo di avere un unico livello nascosto h, uso variabile temporanea "z" che rappresenta la variabile di pre attivazione del livello. Calcolo $y = W^{(2)}h+b^{(2)}$ .

### Regola della catena

vogliamo $\frac{d}{dx}=f(g(x)) = f'(g(x))g'(x)$

l'idea è che la derivata rispetto ad x mi dice come cambia la funzione rispetto un cambiamento infinitesimale di x, allora il cambiamento rispetto g(x) sarà rapportabile. SE h_1 è cambiamento infinitesimale rispetto x,allora $h_2=g'(x)h_1$, e quindi facendolo in generale $f'(g(x))h_2$

Compattando:
$dz/dx = \frac{dz}{dy} \frac{dy}{dx}$

### parte 2

Ora ho n funzioni $g_i$ da $\R \rightarrow \R$ e $f:\R^N \rightarrow\R$
Tutti gli effetti sono infinitesimali, quindi si combinano e si sommano

### parte 3

Qui cambia $g_i:\R^m \rightarrow \R^n$, che risolvo introducendo la derivate parziali.
Introduciamo $\nabla f(x)= \frac{}{}$.. VEDI FOTO


![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-10-25-10-41-01-IMG_5641.jpeg)Se al posto di vettori avessimo dei *tensori* (immaginiamoli come matrici di parametri).



### Computational Graph

Ogni nodo è una variabile, e una operazione è una funzione di una o più variabili, mentre un arco (x,y) indica che y è computato applicando una operazione a x.
$y = a+b \cdot c$

graficamente avrei:

![](/home/festinho/.var/app/com.github.marktext.marktext/config/marktext/images/2023-10-25-10-40-48-IMG_5642.jpeg)

Nel grafico, z è figlio di b e di c.~~~~
calcola il valore del livello nascosto della rete neurale.

### Example: Chain Rule

come calcolo derivata parziale di z rispetto w?
Se non la so fare, allora la riscrivo rispetto a cosa so effettivamente fare.
Me li calcolo una volta e li salvo, cosi se mi servono li riuso.

### Backpropagation with scalar variables

Prendendo il grafo di prima, assumiamo tre variabili a,b,c e un output "y".
Vogliamo gradiente rispetto ciascuna variabile.
In realtà noi useremo il gradiente con parametri, non variabii, ma non cambia molto. I nodi sono ordinamento topologico, ovvero ordino i nodi tale che se esiste un arco $x \rightarrow y$ allora "x" viene prima di "y", poi in mezzo può esserci anche altro, però dovrò comunque avere tale ordine.

### 2

$A$ è l'insieme dei nodi interconnessi ad $u_i$, cioè un nodo generico.



### 3

Uso tabella di lookup, che ci permette di memorizzare le derivate.

$grad[u^{2}]$

Devo calcolare tutte le attivazione dei vari livelli, compresa la loss.
Inizio a popolare lookup table, il primo è $grad[u^{n}] = 1$, perchè derivo rispetto se stesso.
Poi scorro al contrario, dalla fine verso l'inizio, applico la chain rule.



### Backpropagation for NNS (reti neurali)

Vado a calcolare il gradiente rispetto ad una singola istanza.
Rispetto a tutti i parametri della rete $\theta$.

### Forward Pass

Scorro su tutti i livelli, so che sono ordinati secondo un certo modo.
errore linea 3: deve essere $h^{k-1}$, perchè poi userò $a^{k}$ per calcolare $h^{k}$ , quindi non potevo averla prima!.


