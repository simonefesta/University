## Lezione 18 maggio 2023

Oggi lezione più pratica, con R studio.
Il file presentato mostra i dati del tesoro americano sul rendimento del Risk Free Rate. Sono dati storici. Il file verrà fornito in seguito.
Viene mostrato uno scatter plot dei tassi di rendimento privi di rischio, *Treasury Yield Curve Rates*. Nel grafico, per ogni colore di "curva" è associato un giorno. Sull'asse x troviamo gli assi a x mesi privi di rischio, sull'asse y la curva dei tassi. 

**Cosa mi aspetterei, generalmente?**
Se molte persone vogliono un bond, si può elevare il prezzo del bond. Ovviamente, con domanda che cresce, ne cresce anche il prezzo, e quindi il rendimento diminuisce. Se compro un bond che ritorna *facciale* a 1 mese, 2 mesi, 4 mesi, più tardi mi danno i soldi, più il mio rendimento aumenta.

**Nel grafico**:

I tassi su scadenze a breve sono più alti rispetto a tassi su scadenze lunghe.
In figura vediamo *inversione dei tassi*, perchè sul lungo termine vediamo come questi tassi diminuiscono. Questo perchè il mercato è incerto rispetto al futuro, e sul breve vogliono una forte remunerazione per prestare i soldi allo stato.

Vediamo un'altra curva dei tassi di interesse, dal 4/01/21 al 15/01/2021. 

![8070dea8-06bf-4756-a170-1f24013ac76e.jpeg](/home/festinho/Scaricati/8070dea8-06bf-4756-a170-1f24013ac76e.jpeg)

Qui è una curva naturale. I tassi a breve remunerano meno dei tassi a lunga. Questo è il comportamento naturale, non quello di prima. In figura c'è un buco, i dati mancano, posso allora lasciare il buco o interpolare.

Il prof ha raccolto dei siti di riferimento, dove ad esempio spiegano i tassi di interesse inversi, sintono di *recessione dei mercati* per alcuni.
Per altri questa associazione non è vera. Sul sito *FRED* vediamo lo **SPREAD**, che fa ben vedere fenomeno dell'inversione, ovvero dove i tassi a 2 hanno superato di rendimento i tassi a 10 anni. Lo spread fa la differenza tra questi due, non è un grafico dei tassi, bensì dello spread. Un esempio è lo spread BTP-Bund, ovvero tasso interesse nostro vs tasso interesse tedesco. Se spread sale, allora noi per pagare il nostro debito, dobbiamo pagare interessi più alti, e ci indebitiamo ancora di più. Viceversa, se scende, ci indebitiamo di meno.
Un investitore deve tenere conto di tali fattori. Chi investe sul debito pubblico italiano, lo fa consapevole del rischio rispetto al debito pubblico tedesco, ma con rendimento più elevato. **Rendimenti alti associati a rischio alto, rendimento basso associato a rischio basso**, è una *legge del mercato*. Tale grafico può essere utile nei progetti.

![e5019127-9293-4336-ae86-0beba5ae5cdb.jpeg](/home/festinho/Scaricati/e5019127-9293-4336-ae86-0beba5ae5cdb.jpeg)

Altro sito: **Tesoro americano FedInvest**

Posso vendere e comprare titoli americani. E' un sito già visto. Specificando una data, vediamo i prezzi dei titoli in tale data. Questi titoli hanno un codice *CUSIP*, un *tipo*, se rilascia cedole (*rate*), scadenze. Il primo titolo non è stato acquistato, perchè si acquistava il 3 gennaio (lo abbiamo scelto noi nel motore di ricerca del sito) e maturava il 5 gennaio. Ovviamente il rendimento era certo, ma era anche bassissimo. Più aumenta maturità, più diminuisce il prezzo *end of day*. Scorrendo la lista, troviamo anche *Market Based Note*, che rilascia cedole, quindi mi aspetto un certo *rate*(cedola) come remunerazione, in corso di vita del titolo. Sono remunerato in corso d'opera. Il prezzo *end of day* ha un rialzo. Il tasso cedolare è la cedola in funzione del valore nominale del titolo. Su 100€ prendo 1,5% ogni tot mesi. 

![4191d6d0-0157-474b-a9e2-14c742244e12.jpeg](/home/festinho/Scaricati/4191d6d0-0157-474b-a9e2-14c742244e12.jpeg) 

Esempio: Prendo un titolo che scade tra 10 anni, ogni 6 mesi paga cedola del 2%. Se titolo paga 100 a 10 anni, ogni 6 mesi ricevo 2 dollari, e alla fine dei 10 anni ricevo 100+2 dollari. Quale è il prezzo da pagare per questo titolo? Prendo il nominale 100, divido per 1+r, dove r è tasso privo di rischio oggi. Ogni 6 mesi prendo 2 dollari. Ovvero, ipotizzando che tasso privo di rischio rimanga invariato nei 10 anni:
Parto dal tempo 0, voglio stimare quello che avrò tra 6 mesi, ovvero devo scontare tasso di interesse a 6 mesi, ma poichè ho tasso annuale, divido per 2. L'esponente è in funzione del mese (qui sotto è mese 1 perchè mese 1, tra 6 mesi sarà indice 6). Si tratta di **Interesse composto**. 
$\frac{2}{{(1+r/2)}^1}$
Se passo al secondo mese, ovvero è passato un anno, non uso r/2 bensì $r$, ad un anno e mezzo $r/2$, a due anni $r$ e così via.

Alla fine avrò:

 $\frac{2}{{(1+\frac{r}{2})}^{1}}+ \frac{2}{{(1+r)}^{2}}+\frac{2}{{(1+\frac{r}{2})}^{3}}+...+ \frac{100}{({1+r})^{10}}$

In realtà il tasso lo prendo dalla *curva dei tassi*, ma questo lo definisce il mercato.

**Esempio**

$X_0(1+r_A)=X_T$ con $r_A$ tasso di rendimento annuale.

$X_0(1+r_S)^2=X_T$ con $r_S$ tasso di rendimento semestrale.

Posso approssimare: $(1+r_A)=(1+r_S)^2 \approx 1+2r_S$
ovvero $r_S=\frac{r_A}{2}$

### Ritorniamo al codice R

Dobbiamo sempre controllare il formato data, quando scarichiamo i dati, molto spesso le date sono in formato *testo*, e noi le convertiamo in *data*.
E' consigliato usare *indici*, perchè senza specificarli ciò che vediamo come 1,2,3,.. non sono gli indici, bensì i *nomi delle righe*. Noi aggiungiamo anche gli indici, visivamente non cambia nulla, ma potrebbe ritornare utile.
Altra colonna utile è quella dei *giorni alla maturità*, perchè sulla base del prezzo *end of day*, voglio calcolare il *rendimento*, ovvero rapportare $\frac{100 -End Of Day}{EndOfDay}$ nel ***periodo***, e per capirlo mi serve fare differenza tra Maturity date e data in cui ho prodotto questo elaborato. Devo calcolare quanti giorni mancano alla maturità rispetto al giorno in cui ho elaborato i dati. Spesso conviene inserire anche mesi ed anni alla maturità, convertendoli con la legge presente nel file. (dividendo rispettivamente i giorni per 30.4369 e 365.2425). Nel file non sono presenti titoli che rilasciano *cedola*, per una questione di semplicità.
Li riconosco dal nome, e dal fatto che il campo che mostra la % di cedola è diversa da 0.

* *Maturity date* definisce la fine della durata del prestito, mi viene ritornato il prestito. 

* L'*End of day* è valore del titolo alla fine della giornata. E' il valore $X_0$, che varia durante la giornata. Prendo quello a fine giornata.
  Non posso scegliere *Buy* nè *Sell*, perchè sono proposte, non so se siano state accettate.

**Esempio**

Prendo un titolo che mi restituisce 100 dollari il 10/01/2023.
Il 3/01/2023 qualcuno ha comprato e venduto questo titolo, chi perchè pensava di fare profitto vendendo, e chi comprando. Questo titolo è oscillato di prezzo. A fine giornata ha raggiunto un certo valore. Questo ultimo valore è il valore che il mercato gli attribuisce. E' come il valore del bond a *fine giornata*, ogni giorno cambia!

### ... Altre osservazioni su R

Ovviamente quando faccio comparazione, devo usare la stessa *unità* di misura (giorni o mesi o anni alla maturità). Le approssimazioni viste sopra (conversioni con quei fattori visti prima) è molto buona, fino alla 16esima cifra decimale abbiamo stessi risultati.

Noi compariamo con la Fed *Tassi in anni percentuale* non *tassi alla maturità*. [1:26] 

Tasso sulla compravendita. Più mi allontano dal 3/01/23 (inizio) più è in crescita. Quelli di prima erano i tassi della FED, riferiti a diverse maturità, sulla base dello storico. Qui i tassi partono tutti da stessa data. E' un grafico *forward looking*, quello della FED no.
Stiamo dicendo che oggi, sul prestito con scadenza ../11/2023 rispetto alla data iniziale, avrò un tasso di circa 4.8%, ovvero dopo circa 11 mesi. Devo valutare questi 11 mesi con i dati della FED riferiti al 3 gennaio, cioè far partire i dati della FED da questo periodo, vedere il tasso dopo 11 mesi e confrontarlo.

![750f956c-8519-4aef-9e8b-67a9fba82760.jpeg](/home/festinho/Scaricati/750f956c-8519-4aef-9e8b-67a9fba82760.jpeg)


