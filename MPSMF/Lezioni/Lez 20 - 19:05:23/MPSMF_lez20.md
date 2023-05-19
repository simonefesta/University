### Lezione 19 maggio 2023

Nella storia dei mercati, l'_inversione della curva dei tassi_ è sempre stato un segnale di __pericolo__: c'è forte incertezza sull'economia.
Con _inversione della curva dei tassi_ si intende una curva dei tassi che ha forte incertezze sul breve termine anziché sul lungo termine.
Gli investitori trovano trovano rischioso prestare soldi a breve scadenza perchè non riescono a valutare bene le prospettive. 
I tassi a lungo termine si sono già consolidati sui prezzi passati. I tassi a breve sono più *dinamici*. Se investo in bond di durata 10 anni i soldi sono li e vi rimangono. Se investo in un bond mensile, rientro della mia liquidità, che devo reinvestire, e devo chiedere un tasso più alto. Si muove più velocemente.

Fino a qualche giorno fa era scontata la *recessione dell'economia*.
Abbiamo quindi un'inversione della curva dei tassi, però c'è anche una forte resilienza dell'economia. Quindi questo particolare fenomeno non è dovuto a problemi di recessione, ma è dovuto al fatto che le banche centrali per diminuire l'inflazione hanno alzato i tassi.
Perché le banche centrali alzano i tassi in presenza di inflazione? Scopo della banca centrale è cercare di contenere l'inflazione.

#### Esempio 1

Ho 10 mila euro, ne investo 5mila in btp decennale con tasso del 3%. Tra 10 anni riprenderò questi 5mila euro, più le cedole durante il periodo.
Gli altri 5mila li ho investiti in un bot a 6 mesi, con tasso di interesse 0,5%. Tra 6 mesi avrò 5mila euro sul conto, che vorrei però reinvestire. Io però ho un pò paura della situazione economica, e non voglio solamente lo 0,5%, vorrei di più, almeno l'1%. Questo porta ad una salita del tasso a breve. E il btp? O lo vendo, ma ci perdo perchè chi compra il btp decennale non lo vuole l'interesse del 3%, ma del 3.5%, quindi lo devo scontare. Oppure lo tengo, sperando che le cose vadano meglio.  Quindi sono più *frenato* nello scegliere cosa fare.

### Esempio Inflazione alta

Se oggi prendo un prestito, devo pagare interessi alti, ma andando avanti il valore di questi interessi diminuisce (1000$ di domani valgono meno di 1000\$ di oggi **SE** nell'economia c'è stata una crescita anche per i salari, sennò il tasso rimane pesante. Altrimenti peggiora.
Gli alti tassi servono per frenare l'economia, e quindi la gente non può comprare più e i prezzi si abbassano. Non è un *crollo positivo, bensì un crollo negativo*.

La teoria economica sostiene che in regime ideale l'inflazione dovrebbe stare intorno a 2%, perché una tale inflazione non è tale da scoraggiare gli investimenti economici, ma è tale da favorire le dinamiche di prestiti a lungo termine (mutui ...).

Perché non auspicare ad un'inflazione più bassa del 2%? Perché a quel punto la gente tenderebbe a _dilazionare_ l'acquisto. Un minimo di inflazione tende a stimolare l'economia.
Con inflazione bassa, una macchina dal valore di 15k € oggi avrà lo stesso valore anche tra un anno. Io ho la macchina vecchia, la faccio durare un altro pò, evito di spendere.
Con inflazione più elevata, oggi la macchina costa 15k €, tra un anno 17k €, meglio prenderla oggi! 

La banca centrale Europea di fatto, a differenza della FED, è un sistema _più decentralizzato_  E' l'insieme delle banche europee.

_____

Visione del sito Web: "TreasuryDirect"$\rightarrow$"FedInvest".

Gli script usati dal prof sono molto utili per stilare il codice del progetto.

___

Se vuoi calcolare il tasso di mercato per quanto di riguarda un Bond, devi fare il seguente ragionamento:
Oggi il Bond ha un prezzo di mercato $B_0$ e paga una cedola ogni 6 mesi (supponiamo una cedola del $3\%$).
Alla fine del primo semestre percepirò $3$. Questo $3$ lo devo dividere per $1+r_s$, cioè tasso di interesse semestrale, cioè uno *sconto*. Cioè se io presto oggi 100€ con un certo interesse, allora è come se stessi prestando 100€ a cui sottraggo tale interesse.
Quindi ho $\frac{3}{1+r_s}$.

Alla fine del secondo semestre percepirò $3$. Ora lo devo dividere per $(1+r_s)^2$.
Per cui ho $\frac{3}{(1+r_s)^2}$.

La seguente somma mi fornisce il valore finale del Bond: $\frac{3}{(1+r_s)}+\frac{3}{(1+r_s)^2}+\frac{3}{(1+r_s)^3}+ ... + \frac{3}{(1+r_s)^{20}}$

___

Andiamo a vedere delle previsioni dei prezzi dei mercato degli stock. Riprendiamo il concetto di *futures*. Alla scadenza vale $S_t$, io sto scommettendo sul valore che assumerà.
Ricordiamo che noi entriamo nel contratto a costo 0, e dobbiamo riscattarlo alla fine, in ogni caso. In realtà, in un mercato completo, essendoci la misura di probabilità neutrale al rischio, comporta che:
$F_0=\frac{\tilde{E}[S_T]}{1+r_T}-K \doteq 0$  con $r_T
 $ tasso di interesse da oggi alla scadenza del titolo. $K$ lo pago oggi, non devo scontarlo! Esplicitando l'equazione sul tasso di interesse, otteniamo:

$r_T=\frac{\bar{E}[S_T]}{K}-1$

___

Perché il Futures predice così bene? Perché vale la legge della __domanda e dell'offerta__.
Esso anticipa sempre il valore del titolo. Se dovessi costruire un predittore dei prezzi, dovrebbe essere migliore di quello che regola i futures.

Nei grafici visti, si va dal 2012 al 2022, il tasso privo di rischio stimato con delle scadenze.
Il tasso privo di rischio è salito per poi scendere in prossimità delle scadenze, tendendo a 0 quando la scadenza è prossima. In un contesto *normale* questa curva dovrebbe essere completamente decrescente. Poichè ha una salita, è indice dell'effetto di *inversione dei tassi*.