### FaQ 06/06/2023

Simulazione di centralino Telecom, dall'arrivo della richiesta fino alla risoluzione.
Prima di tutto bisogna descrivere bene il sistema.
Centralino con N operatori, multiserver, coda capacità infinita, chiamate in attesa.
Uno può stufarsi (quindi o time2live oppure thread watch, o distribuzione).
Multiserver manda a dispatcher servente singolo, che capisce il tipo di utente (impresa, business, utente), e vede se è risolvibile a distanza o in presenza.
L'obiettivo è rispettare i QoS. Senza abbandono della coda, si risolverebbe analiticamente dice la prof.
Quando si sceglie caso di studio che analiticamente non si può risolvere, sennò a che serve simulare.
Studio finito o infinito? comunque devo tirare fuori statistiche ed i.i.d, replice o batch means.

obiettivo: rispettare QoS. Ben caratterizzare le distribuzioni dei tempi di servizio. Arrivi Poisson disomogenea (per fasce normali), heavy tail per i servizi.

###### Sistema giudiziario Lazio - Luca Fiscariello

Relazione fornita, perchè modellazione ben fatta.
Capire dove è il punto critico.

###### Modello Kanban - Michela Camilli

Le curve al crescere del numero di batch non hanno senso. E' un metodo con linee guide, non ha senso vedere casi in cui non le rispetto.
Qualsiasi sia l'analisi (anche se dobbiamo farle entrambe).
Tempo risposta cresce sempre -> non stazionario.
Prof vuole grafico che, al crescere dei job, si vede il tempo di risposta che forma abbia (circa come i bound). Deve essere in funzione del tempo/job (è stessa cosa.) Prestazioni variano a seconda del numero di batch non ha senso farla. Grafici con indici di prestazione.


