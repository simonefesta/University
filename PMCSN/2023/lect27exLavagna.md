### Esercizio 1 - sistema interattivo

1) Ogni job genera 20 req/disk

2) L'utilizzazione del disco è del 50%

3) Il tempo medio di servizio al disco è di 25 ms = 0.025 s

4) i terminali sono 25. 

5) Il think time è di 18 s.

Tempo risposta sistema interattivo? (lo è perchè si parla di think time e terminali).



Svolgimento

La prima cosa da fare è **riconoscere le grandezze** dal testo.

1) $V_{disk}$

2) $U_{disk}$

3) $S_{disk}$

4) $M$

5) $Z$

Molto spesso potrebbero essere più dati di quelli necessari.

Essendo interattivo, il testo ci chiede $R=\frac{M}{X_0}-Z$. Ci serve $X_0$

Avendo tutti questi dati, dobbiamo usare la **legge del flusso forzato**, perchè relaziona il flusso dell'intero sistema con una parte del sistema tramite visite.
Inoltre non abbiamo il throughput del disco in modo esplicito, ma sappiamo che
$U_i=X_iS_i$ (Little) allora $X_{disk}=\frac{U_{disk}}{S_{disk}}$

Possiamo scrivere, tramite **legge flusso forzato**, $X_0=\frac{X_{disk}}{V_{disk}} = \frac{U_{disk}}{V_{disk} \cdot S_{disk}} = 1 \; j/s$

Allora $R=25/1 - 18 = 7 \;s$.

____

### Esercizio 2 - sistema misto

Ha una parte di carico batch ($_b$) ed uno interattivo ($_i$). Le risorse sono condivise.

Ci sono 40 terminali ($M$), il think-time è di 15 s ($Z_i$), l'interactive response time è di 5 s ($R$.)
Il tempo medio di servizio del disco è 40 ms. $(S_{disk})$

Per ogni job interattivo ci sono 10 richieste al disco. $(V_{disk}^i)$
Ogni job batch genera 5 richieste al disco. $(V_{batch}^b)$
L'utilizzazione del disco è del 90% $(U_{disk})$

1) Qual è il throughput del sistema batch?
   Dalla legge del flusso forzato $X_0^b=\frac{X_{disk}^b}{V_{disk}^b}$
   Legge dell'utilizzazione :$X_{disk}= \frac{U_{disk}}{S_{disk}} = 22.5 \;j/s$
   $X_{disk}^b= X_{disk}-X_{disk}^i$ 
   Mi serve la seconda componente, per la legge del flusso forzato $X_{disk}^i=X_0^i \cdot V_{disk}^i$
   Mi calcolo il primo moltiplicando, dalle legge del flusso interattivo $X_0^i= \frac{M}{Z+R^i} = 40/20 = 2 \; j/s$
   Allora $X_{disk}^b=X_0^b \cdot V_{disk}^i = 2.5  \; j/s$
   
   Finalmente $X_0^b= 2.5/5 = 0.5 \; j/s$
   RIVEDI APICI

2) Suppongo che throughput del sistema *triplichi*. Sistema lower bound del sistema interattivo.
   Vuol dire che $X_0^b= 1.5$
   $R^i=M/X_0^i-Z$
   Ho il minimo $R^i$ per il massimo $X_0^i = X_{disk}^i/V_{disk}^i$ legge visite interattive.
   $massimo \; X_{disk}^i = X_{disk} - X_{disk}^b$
   Il massimo throughput di un centro è per utilizzazione = 1. (tutto ciò che arriva serve).
   $X_{disk}=1/0.04$, inverso tempo servizio (che era 40ms).
   $X_{disk}^b=X_0^b V_{disk}^b= 7.5 j/s$
   allora $X_{disk}^i = X_{disk} - X_{disk}^b = 25 - 7.5 = 17.5 j/s$
   per legge flusso forzato $X_0^i= 17.5/10=1.75 \; j/s$
   da cui $R^i \geq 40/1.75 -15 = 7.9s$
   Triplicando throughput, c'è una crescita di 2.9 (prima era 5).
   
   > Bisognerebbe verificare che in corrispondenza di tale aumento batch, non è cambiato nè M nè Z nè le visite al disco, nè il tempo di servizio globale al disco. I calcoli sono stati fatti sotto queste ipotesi.
   > 
   > Se non è cambiato nulla, il lower bound è corretto.


