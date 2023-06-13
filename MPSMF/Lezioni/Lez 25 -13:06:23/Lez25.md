# Lezione 25 - 13 giugno 2023

Abbiamo parlato di derivato, un titolo il cui valore dipende solo dal sottostante, cioè lo stock nel nostro caso.

I derivati di tipo europeo rilasciano valore alla scadenza/maturità, cioè sono funzioni del titolo.
Possono dipendere da tutta la storia del titolo, o solo dal valore finale.
Ad esempio le *Call/Put* dipendono solo dal valore finale, mentre un derivato di tipo *opzioni asiatiche* durante tutta la traiettoria.

###### Replicabilità del derivato

Prendiamo un qualsiasi derivato, ci chiediamo se esiste un portafoglio fatto da bond e stock che al tempo finale eguaglia il valore dell'opzione asiatica? Se sì, allora l'opzione asiatica può essere replicata, altrimenti no. [definizione 208]

Si dimostra che, nel mercato CRR multiperiodale, senza portafogli di arbitraggio, cioè $u>1+r>d$ allora ogni derivato può essere replicato, sia nel caso *path dependent* sia *path independent*.

L'idea è partire da un portafoglio che eguaglia il valore finale del derivato (3.94), devo costruire tutti gli stati precedenti del portafoglio.
Se c'è replicabilità devo avere la 3.94, esso diventa sistema di equazioni risolvibile, troviamo $X_N$ e $Y_N$, ci poniamo poi di trovare il valore del portafoglio che replica il derivato.
Tenendo conto che il portafoglio deve essere *autofinanziante* troviamo la 3.98.
Si scopre che il portafoglio che replica il derivato è il valore scontato del derivato al tempo precedente, la 3.99. Quindi ciò che facciamo è andare "all'indietro".
Alla fine, il primo valore assunto $W_0$ è composto da valori del portafoglio che replicano il derivato che sono esattamente i valori scontati del valore finale del derivato rispetto la probabilità neutrale al rischio. Tale risultato si può ottenere anche nel caso del derivato dipendente da tutta la storia del processo, anche se lo svolgimento è più complicato. L'idea dietro è comunque la medesima.

###### Prezzo di non arbitraggio [def 210]

E' il valore del portafoglio replicante calcolato allo stesso tempo del derivato. Sto in modello multiperiodale in assenza di BS portafogli d'arbitraggio.
Si può dimostrare che se ogni derivato è replicabile, allora NON ci sono portafogli di arbitraggio. E' un teorema "se e solo se".
Nel modello giocattolo è banale, nel modello più serio un pò meno.

###### [Corollario 212 importante]

Se due derivati prendono stesso valore finale, allora devono prendere stessi valori intermedi. L'idea è che se prendono stesso valore finale allora sono replicabili (sono in CRR), quindi posso trovare portafoglio che li replica entrambi. I prezzi di non arbitraggio coincidono con i prezzi neutrali al rischio. Quest'ultima è unica, allora segue che i due derivati hanno stessa forma.
Se, per assurdo, un derivato sia maggiore dell'altro ad un certo instante, allora lo vendo, compro quello minore e metto a deposito la differenza. Alla fine avrei stessi valori, quindi alla fine avrei maturato una certa ricchezza.

##### 3.5.2 Opzioni europee

All'istante finale hanno un payoff. Se $S_t<k$ il payoff è 0, altrimenti la loro differenza.
Il payoff NON è il guadagno! (dovrei fare differenza payoff - quanto l'ho pagata, oppure ancora meglio payoff - quanto l'ho pagato capitalizzato, cioè li avrei potuti usare per comprare un bond e vedere quanto avrei guadagnato.)
L'idea è trovare $n_k$ per la quale $u^nd^{N-n}S_0  \geq K$

La 3.128 è la funzione che mi dice quale valore prende la call in dipendenza dai valori finali del titolo, espressi in termini di valori iniziali del titolo mediamente le formule viste prima.
Dopo la 3.128, abbiamo la probabilità che la call vale 0 con *probabilità oggettiva* e sotto la stessa probabilità calcolata con la *probabilità neutrale al rischio*. Esistono *due probabilità diverse per valutare l'occorrenza dello stesso evento $C_N=0$*.
Ciò significa che un agente di mercato che si affida alla probabilità neutrale al rischio, in realtà ha una sua probabilità soggettiva, sconta il rischio, e questo perchè c'è *l'avversione al rischio*.
Nel portafoglio di Markowitz, abbiamo visto che un altro modo per calcolare l'avversione al rischio era scontare per il tasso privo di rischio aggiustato una certa quantità, era un altro modo per scontare la probabilità neutrale al rischio.
Secondo De Finetti, la probabilità è sempre soggettiva, cioè attribuisce a fenomeni casuali una probabilità dipendente da soddisfazione, felicità, etc in rapporto al fenomeno. Non c'era, per lui, probabilità oggettiva.

###### Definizione 213

E' un portafoglio che all'istante finale soddisfa la 3.129. So che posso costruirlo, per le condizioni in cui mi trovo.

***Corollario 216,*** ad ogni istante la call è sempre positiva. Se sconto variabile positiva, il risultato è variabile positiva.

**Definizione 217**, come caso particolare c'è la **proposizione 218**. Un risultato è dato dal **Corollario 219**, dove ho relazione tra il valore del titolo e il valore K (parte positiva). Al tempo N diventa un'uguaglianza, per tutti i valori inferiori ad N è una disuguaglianza.


La stima corretta di $C_0$ deriva dal fatto che vendendo una Call mi espongo a rischio illimitato, quindi devo ideare una *strategia di copertura* per imitare il valore finale. Per questo si parla di *portafoglio replicante* o *strategia replicante*.
Nella put si attuano stesse considerazioni in maniera simmetrica.

**Proposizione 220**, tra Call e Putt sussiste la relazione 3.147, da cui si passa alla 3.148 (un'idea di progetto è vedere quanto essa sia verificata).
Le variabili sono $r$ ed $S_n$, ovviamente se ho una delle due stimo l'altra.



##### 3.5.3 American Options

Le opzioni europee sono *scommesse* che possono essere esercitate solo alla scadenza. Cioè scommetto che ad una certa data, l'*indice* sarà sopra o sotto una certa soglia. Se vinco, prendo la differenza la valore della soglia e titolo, se perdo, ho perso quanto ho pagato il titolo. Sono come biglietti della lotteria.
Ci sono poi opzioni sui vari titoli. Le opzioni *americane* possono essere esercitate a qualunque momento prima della scadenza. Quindi posso esercitarla appena vedo che *sto vincendo*.
Anche qui ci sono opzioni *put* e *call*. Ovviamente costano di più, perchè offrono un diritto in più.
Deve quindi valere l'osservazione 226 e la disuguaglianza 3.151, ma alla scadenza valgono allo stesso modo dell'opzione europea.

Mi conviene esercitare la call america prima della scadenza?

Dalla proposizione 228 scopriamo che *Non conviene MAI*, perchè farlo vuol dire che la call americana, nella circostanza degli eventi in cui viene esercitata, prende valori più bassi rispetto alla call europea. (interessante). Vediamo infatti che:
$AC_n=max\{S_n-K,0\}$

Immaginiamo un grafico con picchi in alto e in basso, alla fine della traiettoria abbiamo al tempo T un valore $S_T$. Per la call europea vedo solo questo valore finale, e vedo $S_T-K$.
Con il rispettivo americano, magari trovo un precedente sopra $K$, ma $K$ non viene *scontato* (min 1:02:53). Se esercito AC avrei:
$C_n>A_{C_n}$, il fatto che ad ogni payoff considero K e non lo scontato K, rende l'esercizio della opzione anticipata non vantaggioso. La disuguaglianza di prima genere un arbitraggio sul mercato. La gente non la esercita perchè ci sono arbitraggi, allora alla fine sono come quelle europee. [VEDI FOTO]
$C_n \geq max\{S_n - \frac{K}{(1+r)^n}\}$ 
$AC_n= max \{S_n-K,0\}$

Per le PUT il discorso è diverso. [proposizione 230]
L'idea è:
L'opzione PUT ha questa caratteristica, ovvero $AP_n=max\{K-S_n,0\}$
Essendo PUT, devo aspettare che $S_n$ vada *SOTTO* K. Supponiamo che scenda proprio a 0, conviene esercitare? Devo esercitarla, più di quello non può scendere, quindi prendiamo K. Suppongo di non esercitarla: il titolo sale (dovevo esercitarlo prima) e poi riscende a 0. Esercitarla ora è svantaggioso a farlo prima, perchè K lo capitalizzo. Il guadagno che faccio va *sempre* capitalizzato, quindi può convenire l'esercizio anticipato. Quindi appena so che un titolo non può andare sotto, devo esercitare la call. Metto sul bond e alla fine ho guadagnato di più. Se esercito dopo, mi perdo la capitalizzazione del guadagno tra il primo punto in cui il titolo è andato a 0, rispetto alla seconda volta che ci va. In pratica potevo prendere subito quei soldi e investirlo in bond. (?)
Come faccio a stabilire quando conviene esercitare la PUT?

Vista **Proposizione 230, 231**. (per un progetto, posso verificare se la 231 è verificata). Queste sono disuguaglianze, ma se volessi valore esatto?

Introduco il concetto del *tempo ottimale di esercizio*, che è più complesso. E' un problema di *ottimizzazione stocastica*, sto cercando di massimizzarlo. **Definizione 232**. Lì $N$ è il numero di intervalli in cui è stato diviso lo spazio. Gli eventi $w$ in cui la la variabile aleatoria $v$ prende valori $\leq n$, posso osservare in corso d'opera, perchè ho l'informazione fino ad $n$. $\mathcal{F}_n$ è la filtrazione.

Visto esempio 234. $w_1$ può essere 0 o 1, qualunque sia $w$, essa è una successione che può partire da 0 o 1.
$v_2$ ignora il primo elemento della successione, considera solo il secondo, anch'esso vale 0 o 1.
Solo $v_1$ è tempo di arresto. Se N=3 $\Omega$ è quello fornito. Vediamo quando vale $w_1$ 1 e 2.
Vediamo la controimmagine, dove vale $\Omega, E_0, ...$ 
Soddisfa le condizioni di *tempo d'arresto.*
Per $v_2$ abbiamo problema con $E_{0,0} \;unione E_{1,0}$ che però non appartiene. Quindi il problema è che nel secondo caso so che avrei dovuto prendere un certo valore al tempo x, DOPO che il tempo X è passato.
Visto **teorema 235** 

Idea ??
Ho $S_N(w_1),...,S_N(w_4)$. All'istante terminale, noto K, posso calcolare tutte le differenze e il massimo, cioè $(K-S_N(w_1))^+, (K-S_N(w_2))^+,...$
Alcuni di questi saranno 0, altri saranno >0.
L'idea è partire da $S_0$ e costruire il reticolo dei valori prezzi. (I valori sopra citati sono alla fine del reticolo) Se faccio lo sconto dei valori precedenti, quelli che erano 0 continuano ad essere 0, gli altri maggiore di 0 continuano ad essere >0. Devo confrontare questi valori scontati con $K-S_{N-1}$. Il valore della PUT è il valore più grande tra questo ed i valori scontati. Quindi confronto $K-S_{N-1}$ coi valori scontati presi al tempo successivo $(K-S_N)^+$
Appena questi valori scontati sono >0, dovrei esercitare la PUT.



DA RISCRIVERE BENE ALCUNE PARTI
