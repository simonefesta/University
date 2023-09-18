### Esercizio 1 - sistema interattivo

1) Ogni job genera 20 req/disk

2) L'utilizzazione del disco è del 50%

3) Il tempo medio di servizio al disco è di 25 ms = 0.025 s

4) i terminali sono 25. 

5) Il think time è di 18 s.

<img src="file:///var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_wNxP0Y/Screenshot%202023-05-25%20alle%2015.34.35.png" title="" alt="Screenshot 2023-05-25 alle 15.34.35.png" width="394">

**Tempo risposta sistema interattivo? (lo è perchè si parla di think time e terminali).**

La prima cosa da fare è **riconoscere le grandezze** dal testo.

1) $V_{disk}$

2) $U_{disk}$

3) $S_{disk}$

4) $M$

5) $Z$

Molto spesso potrebbero essere più dati di quelli necessari.
Essendo interattivo, il testo ci chiede $R=\frac{M}{X_0}-Z$. Ci serve $X_0$
Avendo tutti questi dati, dobbiamo usare la **legge del flusso forzato**, perchè relaziona il flusso dell'intero sistema con una parte del sistema tramite visite.
Inoltre non abbiamo il throughput del disco in modo esplicito, ma sappiamo che per la **legge dell'utilizzazione** $U_i=X_iS_i$ (Little) allora $X_{disk}=\frac{U_{disk}}{S_{disk}}$

Possiamo scrivere, tramite **legge flusso forzato**, $X_0=\frac{X_{disk}}{V_{disk}} = \frac{U_{disk}}{V_{disk} \cdot S_{disk}} = 1 \; j/s$
Allora $R=25/1 - 18 = 7 \;s$.

____

### Esercizio 2 - sistema misto

<img src="file:///var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_YJc068/Screenshot%202023-05-25%20alle%2015.37.16.png" title="" alt="Screenshot 2023-05-25 alle 15.37.16.png" width="296">

Ha una parte di carico batch (pedice $_b$) ed uno interattivo (pedice $_i$).

Le risorse sono condivise.

Ci sono 40 terminali ($M$), il think-time è di 15 s ($Z_i$), l'interactive response time è di 5 s ($R$.) <br>Il tempo medio di servizio del disco è 40 ms. $(S_{disk})$

Per ogni job interattivo ci sono 10 richieste al disco. $(V_{disk}^i)$
Ogni job batch genera 5 richieste al disco. $(V_{batch}^b)$
L'utilizzazione del disco è del 90% $(U_{disk})$

1) Qual è il throughput del sistema batch?
   Dalla legge del **flusso forzato** $X_0^b=\frac{X_{disk}^b}{V_{disk}^b}$ <br>Mi manca il *numeratore*, esprimibile come: $X_{disk}^b= X_{disk}-X_{disk}^i$
   
   Il primo termine si ricava dalla **Legge dell'utilizzazione** :
   $X_{disk}= \frac{U_{disk}}{S_{disk}} = 22.5 \;j/s$ <br>Mi serve la seconda componente, 
   per la *legge del flusso forzato* $X_{disk}^i=X_0^i \cdot V_{disk}^i$ <br>
   Mi calcolo il primo termine, dalle **legge del flusso interattivo**: <br>$X_0^i= \frac{M}{Z+R^i} = 40/20 = 2 \; j/s$ <br>Allora $X_{disk}^i=X_0^i \cdot V_{disk}^i = 2.5  \; j/s$ cioè *l'interactive response time*.
   
   Finalmente $X_0^b= 2.5/5 = 0.5 \; j/s$ <br>Graficamente abbiamo seguito questo percorso:
   
   <img src="file:///var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_Gw8eBc/Screenshot%202023-05-25%20alle%2015.42.06.png" title="" alt="Screenshot 2023-05-25 alle 15.42.06.png" width="567">

2) Suppongo che throughput del sistema *triplichi*. Voglio trovare un lower bound per il minimo tempo di risposta per il sistema interattivo.
   
   Vuol dire che $X_0^b= 1.5 \; j/s$.
   Il testo mi sta chiedendo di trovare $R^i=\frac{M}{X_0^i}-Z$ <br>Ho il minimo $R^i$ per il massimo $X_0^i = \frac{X_{disk}^i}{V_{disk}^i}$ per la legge delle visite interattive. <br>Per massimizzarlo devo trovare il massimo del numeratore
   $X_{disk}^i = X_{disk} - X_{disk}^b$ <br>Il massimo throughput di un centro è per utilizzazione $\rho=1$.  
   (tutto ciò che arriva servo). <br>$X_{disk}=[tempo \;di\;flusso]^{-1} = 1/0.04 = 25 \; j/s$, cioè l'inverso del tempo servizio (che era 40ms).
   $X_{disk}^b=X_0^b \cdot V_{disk}^b= 7.5 j/s$
   
   Avendo entrambe le componenti ottengo:  <br>$X_{disk}^i = X_{disk} - X_{disk}^b = 25 - 7.5 = 17.5 \;j/s$
   per *legge flusso forzato* di prima si ha $X_0^i= \frac{X_{disk}^i}{V_{disk}^i}= \frac{17.5}{10}=1.75 \; j/s$ <br>da cui $R_{min}^i \geq \frac{40}{1.75} -15 = 7.9s$ <br>Triplicando throughput, c'è una crescita di 2.9 (prima era 5).
   
   > Bisognerebbe verificare che in corrispondenza di tale aumento batch, non è cambiato nè M nè Z nè le visite al disco, nè il tempo di servizio globale al disco. I calcoli sono stati fatti sotto queste ipotesi.
   > 
   > Se non è cambiato nulla, il lower bound è corretto.

<img title="" src="file:///var/folders/_p/3wnzmzzj6q3djg3_fgyjqmb40000gn/T/TemporaryItems/NSIRD_screencaptureui_GgeImw/Screenshot%202023-05-25%20alle%2016.02.45.png" alt="Screenshot 2023-05-25 alle 16.02.45.png" width="700">
