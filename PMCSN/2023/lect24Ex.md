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
