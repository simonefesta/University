##### Esercizio 1

Ho un sistema con tre domande $D_1=1s,\;D_2=1s\;,D_3=2s\;Z=6s$

Il massimo throughput con un utente?

Ricordiamo che $X(N) \leq min\{\frac{1}{D_{max}}, \frac{N}{D+Z}\}$

$D_{max}=D_3=2s$, mentre $D=D_1+D_2+D_3=10s$.

Attenzione, anche se ho tre domande non vuol dire che ci siano 3 utenti!

Dal grafico del throughput, sappiamo che prima di N* l'andamento è $\frac{N}{D+Z}=\frac{N}{10}$, dopo N* è $\frac{1}{D_{max}}=0.5$

Per trovare N* impongo $\frac{1}{D_{max}}=\frac{N^*}{D+Z}$ cioè $N^*=\frac{D+Z}{D_{max}}=5$.

##### Esercizio 2

Throughtput del sistema con due utenti, se $D_1=1s, \; D_2=2s,\;D_3=2s$

Non posso usare i bound, voglio sapere il throughput vero quando ce ne sono due!
Dobbiamo applicare MVA, in una maniera leggermente diversa.
Noi scrivevamo $E(t_i(N)) = E(S_i)(1+E(n_i(N-1))$, tempo di risposta al centro $i$ per *singola visita*. (da quando arrivo a quando esco dal centro $i$, dato che nel centro ce ne siano $n$). Potrei definire tempo di risposta non più per singola visita, ma globale al centro $i$.
Ovvero moltiplico a destra e sinistra per il numero di visite a quel centro.
$V_i \cdot E(t_i(N)) = V_i(S_i) \cdot E(S_i)(1+E(n_i(N-1))$ <br>
$R_i(N)=D_i(1+E(n_i(N-1)))$, ovvero tempo di residenza, speso mediamente dal job nel centro per tutta la sua vita nel sistema.
Sappiamo che $n_1(0)=n_2(0)=n_3(0)=0$
$R_1(1)=D_1(1+0)=1s$, $R_2(1)=2s$, $R_3(1)=3s$
Allora i throughput sono $X(1)=\frac{1}{R_1(1)+R_2(1)+R_3(1)}=0.2\; tr/s$ per la legge del tempo di risposta, cioè visite per tempo di risposta (le visite stanno già dentro, infatti noi avevamo al denominatore $\sum_{i=1}^M v_{i,j}E(t_i(N))$).

$E[n_1(1)]=X(1) \cdot R_1(1) = 0.2$ <br>Normalmente prima avevamo throughput del sistema, non del centro! Sarebbe $X_1(1) \cdot E(t_1(1))$.
Abbiamo anche $n_2(1)=n_3(1)=0.4$

$R_1(2)=D_1(1+n_1(1))=6/5 \;s$ , 
$R_2(2)=14/5 \;s \; R_3(2)=14/5 \;s$

Concludiamo trovando $X(2)=\frac{2}{R_1(2)+R_2(2)+R_3(2)}=5/17 \; tr/s$

##### Esercizio 17.2 p.333

![Screenshot 2023-06-04 alle 19.39.25.png](/Users/festinho/Desktop/Screenshot%202023-06-04%20alle%2019.39.25.png)



Il modello della rete è quello in foto (è un sistema di router). Sistema aperto.
domanda1:
quale è la massima frequenza di arrivo che la rete può *tollerare* al primo router se la frequenza di arrivo al secondo è 1 pkt/tempo. Ovvero $\gamma_1^{max} se\; \gamma_2=1\; pkt/s$

**Nota: anche si il testo si sofferma sul primo server, viene scritto "che la rete può tollerare", ovvero devo evitare la saturazione per ogni elemento del centro, non devo vedere solo la prima coda.**

$\mu_1=3\; pkt/s$, $\mu_2=5\;pkt/s$

Devo vedere la tolleranza massima, quindi utilizzazione che tende ad 1, e vedere le equazioni di traffico. Rete aperta, l'equazione di traffico implica che il flusso sia bilanciato.

$\lambda_1=\gamma_1+1/3\lambda_2$

$\lambda_2=\gamma_2+\lambda_1/3+\lambda_2/3$

Risolvo : $\lambda_1=6/5\gamma_1 + 3/5$ e $\lambda_2=3/5\gamma_1+9/5$
(In pratica ho sostituito $\lambda_2$ e l'ho messa nell'equazione di $\lambda_1$, in modo da avere alla fine equazioni in funzione unicamente di $\gamma_1$, poichè $\gamma_2=1$ è noto. )

devo trovare $\gamma_1$ max, ovvero utilizzazioni <1.
$\frac{\lambda_1}{\mu_1}<1 \;\;if\;\; \gamma_1<2$ 

$\frac{\lambda_2}{\mu_2}<1\;\; if \;\; \gamma_1<5.3$

la condizione più stringente è la prima, dopo "esplode". $\gamma_1^{max}=2$

**domanda 2:**

se $\gamma_1$ fosse il 90% di questo valore appena trovato, tempo di risposta per un pacchetto che entra nel centro1?
$\gamma_1=0.9\gamma_1^{max}=1.8 \;pkt/s$

Devo calcolare throughput e visite rispetto $\gamma_1$
Troviamo $\lambda_1=2.76 pkt/s$ (throuhgput), $\lambda_2=2.88 pkt/s$

$\rho_1=0.92$ e $\rho_2=0.576$

Posso calcolare i tempi di risposta come $\frac{1}{\mu-\lambda}$ 
il tempo di risposta, per singola visita, da quando arrivo al centro 1 a quando esco al centro 2

$E(t_1)=4.16667$, $E(t_2)=0.471698$

Devo calcolare le visite rispetto all'entrata nel sistema:
Noi stiamo calcolando rispetto a dove entra solo gamma1
$v_{1,\gamma_1}=\frac{\lambda_1}{\gamma_1}=1.533$

$v_{2,\gamma_1}=1.6$

$E(t_{R,1})= \sum v_iE(t_i) =7.1436$ (somma delle visite moltiplicate per i tempi di risposta)

cioè risposta dell'intero sistema rispetto al router 1.

Potrei calcolare anche popolazioni medie, ma dovrei avere l'ipotesi che sono esponenziali (oppure se fossero processor sharing non avrei problemi).
$E(n_1)=\lambda_1 \cdot E(t_1)= 2.76 \cdot 4.16667 = 11.5$, $E(n_2)=1.3585$

Prossima volta vediamo tempo di risposta rispetto al punto 2, e rispetto a tutto (vedo tutto come scatola nera, ovvero arriva flusso ma non so dove va in questa scatola), tempo in media per uscire da questa scatola nera?

relazione tra questo tempo (che non tiene conto da dove entro) e gli altri in cui so da dove entro?

#### Esercizi per casa

----

$U_{cpu}=0.5 \;\;\; tempoRisposta= 15 \;s/tran, \;\; thinkTime =5s, \; NumeroUtenti=100$

Domanda di servizio alla CPU? (ovvero il parametro D) Risposta: 1/10 di secondo.
Svolgimento:

$R=\frac{N}{X_0}-Z = \frac{N}{\frac{U_{cpu}}{D_{cpu}}} -Z $
esplicito rispetto a $D_{cpu}$, cioè sostituisco: $15+5=100/0.5 \cdot D_{cpu} \rightarrow D_{cpu}=20 \cdot 0.5/100= 1/10$

-----

Operation period: 1 ora

numero transazioni completate: 900

numero di utenti: 60

numero medio di utenti che non sono in attesa di risposta dal sistema: 57.5

Quale è il tempo di risposta medio? 10 secondi
$R=\frac{M}{X_0}-Z$
$X_0=\frac{C}{T}=0.25$, $Z$ è un tempo, io però ho gli utenti, tuttavia grazie a Little so che #Thinker=$Z \cdot X_0$ allora $Z=\frac{n° \;thinker}{X_0} =\frac{57.5}{0.25}$
allora $R=\frac{60-57.5}{0.25}=10\; s$

----



sistema interattivo chiuso, tre centri 
d1= 1s, d2=2s, d3=3s,

Se il think time medio è di 21 secondi, calcolare upper bound al throughput usando analisi asintotica quando nel sistema ci sono 6 utenti. soluzione: 2/9 transazioni/unità di tempo.

![WhatsApp Image 2023-06-04 at 20.19.31.jpeg](/Users/festinho/Downloads/WhatsApp%20Image%202023-06-04%20at%2020.19.31.jpeg)



----
