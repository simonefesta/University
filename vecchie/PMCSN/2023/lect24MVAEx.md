### Esercizio

![Istantanea_2023-05-16_17-53-29.png](/home/festinho/Scrivania/Istantanea_2023-05-16_17-53-29.png)

Iniziamo con lo scrivere i flussi in entrata:

$\{ \lambda_1= \gamma + \lambda_2$
$\{\lambda_2 = (1-p)\lambda_1$

Sostituendo $\lambda_2$ in $\lambda_1$ otteniamo:
$\lambda_1= \frac{\gamma}{p}$ ; $\lambda_2=\frac{\gamma (1-p)}{p}$

La product form è data dalle equazioni:

$\pi(n_1,n_2) = \pi_1(n_1) \pi_2(n_2)$
$\pi_2(n)=(1-\rho_i)\rho_i^{n_i}$
Le visite sono:

$v_1= \frac{\lambda_1}{\gamma} =\frac{1}{p}$ e $v_2= \frac{\lambda_2}{\gamma} = \frac{(1-p)}{p}$

Parametri: $\gamma= 1.3 j/s$, $\mu_1= 30j/s$, $\mu_2=25 j/s$
Nel caso bilanciato, cioè $p=0.5$, il 50% cicla.
Nel centro 1 abbiamo 1 visita in più rispetto al centro 2.
Se P = 0.5 ho R = 0.1152 s, 
Se P = 0.6 ho R = 0.0865 s
Se p = 0.05 ho 20 visite ad 1, 19 visite a 2, il tempo di risposta R = 68.333 s
$\rho_1= 0.8666$, $\rho_2=0.988$
$E(n_1) = 6.5 s$, $E(n_2)= 82.333$

Nelle forme prodotto aperte, le marginali già sono in forma prodotto, nel caso chiuso no.

$\pi(n_1,...,n_M) = \frac{1}{G(n)}\prod_{i=1}^N f_i(...)$ con $f_i$ formula dipendente dal centro i. La funzione G serve per normalizzare ad 1.
Voglio probabilità del centro i di contenere n job, ovvero $P_i(n) = \sum_{\bar{s}: n_i=n }\pi(\bar{s})$

Esistono algoritmi per calcolare gli indici senza necessità della soluzione.
Noi vedremo l'algoritmo di **Mean Value Analysis**, perchè molto semplice e diffuso (accettato in ambiti industriali).

### Mean Value Analysis

Essa si basa sulle stesse ipotesi di BCMP, 
ovvero accettiamo *FIFO, esponenziale*, *PS*, *LIFO con prelazione*, ed *IS*.
Definiamo il numero di job $ \doteq N$ e il numero dei centri $\doteq M$.
Siamo sempre in un contesto di reti chiuse. 

> Gli indici dipendono *sempre* da N, anche se non sempre esplicitato.

Devo considerare un singolo centro $i$, e il tempo di risposta medio di un centro nella rete ci dice quanto tempo spende un job nel centro $i$.
Vogliamo quindi calcolare $E(t_i(N)) = E(s_i) + E(a_i(N))E(s_i)$

La prima componente è il *tempo speso in servizio*, la seconda è il *tempo speso in attesa che gli altri job terminino il servizio quando lui arriva nel centro*. 
Poichè siamo in una rete stocastica, stiamo trattando sempre variabili random, e denotiamo quindi $a_i(N)$ il numero medio di job presenti all'arrivo del nostro job di riferimento *i* a "tutti gli istanti di arrivo".
Cioè faccio tale misurazione ogni qual volta che arriva un job nuovo nel centro, mentre $E(n)$ era su tutti gli istanti di arrivo.
Solo nelle rete separabili vale il **teorema degli arrivi**, ovvero $E(a_i(N))= E(n_i(N-1))$.

Facendo tale sostituzione alla formula sopra, abbiamo:
$E(t_i(N)) = E(s_i)(1+E(n_i(N-1))$

che è un ricorsione, in cui vediamo che:
$N=0    E(n_1(0)) = E(n_2(0))=,...,=E(n_M(0)) = 0$

Quindi a $N=1$, avrò $E(n_i(N-1))= E(n_i(0))=0$
e quindi $E(t_i(N=1))= E(s_i)$

Possiamo ricavare il throughput del centro $i$, $\lambda_i(N)$, ma ci serve $E(n_i(N))$ per usare Little, che non posso sapere, perchè essendo la formula ricorsiva conosco solo gli indici *passati*.

In alternativa sfrutto le visite.
$\lambda_i(n) = \frac{n}{\sum_{j=1}^Nv_{j,i}E(t_j(n))} $ e quindi
$E(n_i(n)) = \lambda_i(n)E(t_i(n))$

Esempio:

![1199acd8-801e-4ffb-95e0-da169b908948.jpeg](/home/festinho/Scaricati/1199acd8-801e-4ffb-95e0-da169b908948.jpeg)

Definiamo $M=3,\;N=3,\;\mu_1=1 \;j/s,\;\mu_2=\mu_3=2 \;j/s$
Valutiamo lo spazio degli stati:

$E=\{ (3,0,0), (2,1,0),(2,0,1),(1,2,0),(1,1,1),(1,0,2),(0,3,0),(0,2,1),(0,1,2),(0,0,3)\}
$

Sono 10 stati perchè $\binom{N+M-1}{M-1}= \binom{5}{2} =\frac{5!}{3!2!} = \frac{5 \cdot 4 \cdot 3!}{3!2!} = 10$. Le prestazioni dei centri 2 e 3 saranno uguali, avendo stesso tasso e stesse visite.
Scrivo sistema di equazioni linearmente indipendenti.

$y_1=0.3y_3$

$y_2=y_1 + 0.7 y_3$

$y_3=y_2$

Potrei trovare anche matrice routing 3x3:
$\begin{pmatrix} 0 & 1 & 0\\ 0 & 0 & 1 \\ 0.3 & 0.7 & 0  \end{pmatrix}
$

che posso abbreviare in $\bar{y}=\bar{y}P$

Devo fissare *arbitrariamente* un valore nel sistema delle visite, fisso $y_3=1$ ad esempio, perchè è la più semplice.

Troviamo: $y_1=0.3, y_2=1,y_3=1$

Vogliamo calcolare le visite **rispetto al centro 1**.
$v_{1,1}=1, v_{2,1}= \frac{y_2}{y_1}= 3.3333= v_{3,1}=\frac{y_3}{y_1}= 3.3333$

Questo è perchè ho preso 1 come punto di osservazione. Se cambiassi col **centro 2**:

$v_{2,2}=v_{3,2}= \frac{y_2}{y_2}=1, \;v_{1,2}=\frac{y_2}{y_1}=0.3$

Rispetto al centro 3? uguali.

$v_{1,3}=0.3,\; v_{2,3}=v_{3,3}$=1

Adesso procediamo con gli indici di prestazione per i vari centri, partendo dalla presenza di $1 \; job$:

### $n=1 $

Calcoliamo il tempo di risposta medio, per ogni centro, partendo da *1 job*.

$E(t_1(1))=E(s_1)(1+E_{n_1}(0)) = 1 \cdot(1+0)=1$  

$E(t_2(1))=E(s_2)(1+E_{n_2}(0))= 0.5 \cdot(1+0)= 0.5$  

$E(t_3(1))=0.5$

Questi primi tre risultati derivano dal fatto che, per $n=1$ abbiamo $E(t_j(1))=E(s_i)=1/\mu_i$

Calcoliamo le **entrate rispetto al centro 1**:

$\lambda_1(1)=\frac{1}{1 \cdot 1+3.33 \cdot0.5 +3.33 \cdot 0.5} = 0.230769$ 
avendo al denominatore $\sum_{j=1}^Nv_{j,i}E(t_j(n))$. 

Poichè $n=1$, ho $E(t_j(1)) = E(s_i)=1/\mu_i$, quindi al denominatore stiamo moltiplicando le visite rispetto *al centro 1* per i vari tassi di servizio.
Dalle definizioni:

$E(n_1(1))= \lambda_1(1) \cdot E(t_1(1)) = 0.230769$

Analogamente, per il centro 2 e 3 si hanno:
$\lambda_2(1)= \frac{1}{1 \cdot 0.3 + 0.5 \cdot 1 + 0.5 \cdot 1} = 0.769231 = \lambda_3(1)$
$E(n_2)=E(n_3) = 0.3846155$

### $n=2$

Adesso abbiamo incrementato di 1 il numero di job, incrementiamo mano mano perchè le formule sono ricorsive, devo partire dal caso base di sistema con 0 job e mano a mano incrementare.

$E(t_1(2))= E(S_1)(1+E_{n_1}(1)) =1 \cdot (1+0.230769) = 1.230769 $

$E(t_2(2))=E(S_2)(1+E_{n_2}(1)) = 0.5 \cdot (1 + 0,3846155) = 0.69230775$

$ E(t_3(2))=0.69230775$

Mi focalizzo sul centro 1:
$\lambda_1(2)=\frac{2}{1 \cdot 1.23 + 0.69 \cdot 3.333 + 0.69 \cdot 3.333} = 0.3430$

$E(n_1(2))= 0.3430 \cdot 1.230769 = 0.4222$

Passiamo ai centri 2 e 3

$\lambda_2(2) = \lambda_3(2) = \frac{2}{0.3 \cdot 1.23 + 0.69 + 0.69} = 1.1435$

$E(n_2(2))=E(n_3(2)) = 1.1435 \cdot 0.6923 = 0.791661$

### $n=3$

Per il centro 1:

$E(t_1(3)) = E(S_1)(1+E_{n_1}(2)) = 1 \cdot(1+ 0.4222) = 1.4222$

Per i centri 2 e 3:

$E(t_2(3)) = E(t_3(3)) = E(S_2)(1+E_{n_2}(3))= 0.5\cdot(1+0.791661) = 0.8958305$

Calcoliamo gli indici per il centro 1:

$\lambda_1(3)= \frac{3}{1 \cdot 1.4222 + 3.33 \cdot 0.8958 +  3.33 \cdot 0.8958} = 0.406051 $

$E(n_1(3)) = 0.406051 \cdot 1.4222 = 0.577197$

Calcoliamo gli indici per il centro 2 e 3:

$\lambda_2(3)= \frac{3}{1.422 \cdot 0.3 + 0.8958 \cdot 1 + 0.8958 \cdot 1} = 1.35244 = \lambda_3(3)$

$E(n_2(3))=E(n_3(3)) = 1.3544 \cdot 0.895835 =1.211402$



Che verifiche posso eseguire?

* La somma delle popolazioni medie deve restituire l'uguaglianza $N=\sum_{i=1}^N E(n_i(N)) \approx 3$

* Possiamo anche calcolare l'utilizzazione $U_1=0.406176$ ed $U_2=U_3=0.67696$ (Non ho capito come ricavarle, dovrei calcolare $1- p_i(0)$ma dovrei sapere le probabilità degli stati! Boh)

Questi sono tutti indici *locali*. Possiamo parlare anche di indici *globali*, ma dobbiamo sempre scegliere un punto di osservazione, perchè la rete è chiusa.

Vogliamo calcolare il *tempo di risposta rispetto al centro 1*, ovvero da quando il centro 1 lancia una richiesta al resto del sistema fino a quando questo sottosistema manda indietro una risposta.
Tutto è in funzione di $N=3$. Calcolo il tempo di risposta rispetto al centro 1.

$E(t_{2,1}(3))=v_{2,1}\cdot E(t_2(3)) + v_{3,1} \cdot E(t_3(3)) = 5.99 \; s$

$E(t_{2,2}(3)) = v_{1,2} \cdot E(t_1(3)) + v_{3,2} \cdot E(t_3(3)) = 1.33 \; s$

Il secondo valore è più piccolo perchè dato che c'è il ciclo è più facile che si ritorni più velocemete a 2 direttamente da 3 facendo un giro più corto.
Il tempo di ciclo è un giro completo rispetto al numero di visite che faccio negli altri rispetto al mio riferimento. Queste cose stanno anche sul libro.

Tempo di ciclo rispetto a 1:
$E(t_{c,1}(3))= E(t_{2,1}(3)) + E(t_1(3))= 7.41 \;s$

$E(t_{c,2}(3))= v_{1,2}E(t_1(3)) + v_{3,2}E(t_3(3))+ v_{2,2}E(t_2(3)) = 2.23 \; s$
