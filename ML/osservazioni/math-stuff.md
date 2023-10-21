$\mathcal{L} = -t \cdot log(y) - (1-t) \cdot log(1-y)$ con $ y= \frac{1}{1+e^{-z}}$ e $z=\overline{w}^{T}\cdot \overline{x}$ (vettoriale)  Procediamo con: $\frac{\partial \mathcal{L}}{\partial w_J} = \frac{\partial \mathcal{L}}{\partial y}\frac{\partial y}{\partial z}\frac{\partial z}{\partial w_J}$

Eseguiamo per pezzi:

$\frac{\partial \mathcal{L}}{\partial t} = - \frac{t}{y} - \frac{(1-t)}{1-y}$

$\frac{\partial \mathcal{y}}{\partial z} = \frac{\partial [(1+e^{-z})^{-1}]}{\partial z} = \frac{(-1)\cdot(-e^{-z})}{(1+e^{-z})^{2}} = \frac{1}{1+e^{-z}} \cdot \frac{e^{-z}}{1+e^{-z}} = y \cdot (1-y)$

$\frac{\partial z}{\partial w_J} = \frac{\partial \overline{w^{T}} \cdot \overline{x}}{\partial w_{j}} = w_{j} \cdot \overline{x} = x_{j}$

Il primo pezzo è semplice, sono derivate normale. Il secondo pezzo anche, la forma finale si ottiene spezzando in due le componenti. Il terzo pezzo fa leva sul fatto che, derivando per uno specifico elemento del vettore $\overline{w}$, avremo solo tale elemento pari ad 1, gli altri nulli. $\overline{x}$ è un vettore di costanti, e quindi alla fine otteniamo solo l'elemento j-esimo di tale vettore.
