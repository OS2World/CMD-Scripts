/*                         Programm  Det.cmd                                */
/*                                                                          */
/*   Det.cmd kann aus einer quadratischen Matrix mit 20 mal 20 Elementen    */
/*                                                                          */
/*   Determinanten   (bezogen auf die "obere linke Ecke")                   */
/*                                                                          */
/*                         mit  2  mal  2 ,                                 */
/*                         mit  3  mal  3 ,                                 */
/*                         mit  4  mal  4 ,                                 */
/*                         mit ... mal ...,                                 */
/*                         mit ... mal ...,                                 */
/*                         mit  20 mal  20 Elementen                        */
/*                                                                          */
/*   berechnen.                                                             */
/*                                                                          */
/*   Dazu muá von dem Programm, das Det.cmd aufruft, die Anzahl R           */
/*   (R = Anzahl der Reihen = Anzahl der Spalten) und durch ein Komma       */
/*   getrennt, die Datei Matrix20 aufgerufen werden,                        */
/*   in der die 20 mal 20 Elemente der Matrix stehen, aus der die           */
/*   verschiedenen Determinanten (bezogen auf die "obere linke Ecke")       */
/*   berechnet werden sollen.                                               */


NUMERIC DIGITS 65
NUMERIC FUZZ 3

arg R,
a.1.1   a.1.2   a.1.3   a.1.4   a.1.5   a.1.6   a.1.7   a.1.8   a.1.9   a.1.10,
a.1.11  a.1.12  a.1.13  a.1.14  a.1.15  a.1.16  a.1.17  a.1.18  a.1.19  a.1.20,
a.2.1   a.2.2   a.2.3   a.2.4   a.2.5   a.2.6   a.2.7   a.2.8   a.2.9   a.2.10,
a.2.11  a.2.12  a.2.13  a.2.14  a.2.15  a.2.16  a.2.17  a.2.18  a.2.19  a.2.20,
a.3.1   a.3.2   a.3.3   a.3.4   a.3.5   a.3.6   a.3.7   a.3.8   a.3.9   a.3.10,
a.3.11  a.3.12  a.3.13  a.3.14  a.3.15  a.3.16  a.3.17  a.3.18  a.3.19  a.3.20,
a.4.1   a.4.2   a.4.3   a.4.4   a.4.5   a.4.6   a.4.7   a.4.8   a.4.9   a.4.10,
a.4.11  a.4.12  a.4.13  a.4.14  a.4.15  a.4.16  a.4.17  a.4.18  a.4.19  a.4.20,
a.5.1   a.5.2   a.5.3   a.5.4   a.5.5   a.5.6   a.5.7   a.5.8   a.5.9   a.5.10,
a.5.11  a.5.12  a.5.13  a.5.14  a.5.15  a.5.16  a.5.17  a.5.18  a.5.19  a.5.20,
a.6.1   a.6.2   a.6.3   a.6.4   a.6.5   a.6.6   a.6.7   a.6.8   a.6.9   a.6.10,
a.6.11  a.6.12  a.6.13  a.6.14  a.6.15  a.6.16  a.6.17  a.6.18  a.6.19  a.6.20,
a.7.1   a.7.2   a.7.3   a.7.4   a.7.5   a.7.6   a.7.7   a.7.8   a.7.9   a.7.10,
a.7.11  a.7.12  a.7.13  a.7.14  a.7.15  a.7.16  a.7.17  a.7.18  a.7.19  a.7.20,
a.8.1   a.8.2   a.8.3   a.8.4   a.8.5   a.8.6   a.8.7   a.8.8   a.8.9   a.8.10,
a.8.11  a.8.12  a.8.13  a.8.14  a.8.15  a.8.16  a.8.17  a.8.18  a.8.19  a.8.20,
a.9.1   a.9.2   a.9.3   a.9.4   a.9.5   a.9.6   a.9.7   a.9.8   a.9.9   a.9.10,
a.9.11  a.9.12  a.9.13  a.9.14  a.9.15  a.9.16  a.9.17  a.9.18  a.9.19  a.9.20,
a.10.1  a.10.2  a.10.3  a.10.4  a.10.5  a.10.6  a.10.7  a.10.8  a.10.9  a.10.10,
a.10.11 a.10.12 a.10.13 a.10.14 a.10.15 a.10.16 a.10.17 a.10.18 a.10.19 a.10.20,
a.11.1  a.11.2  a.11.3  a.11.4  a.11.5  a.11.6  a.11.7  a.11.8  a.11.9  a.11.10,
a.11.11 a.11.12 a.11.13 a.11.14 a.11.15 a.11.16 a.11.17 a.11.18 a.11.19 a.11.20,
a.12.1  a.12.2  a.12.3  a.12.4  a.12.5  a.12.6  a.12.7  a.12.8  a.12.9  a.12.10,
a.12.11 a.12.12 a.12.13 a.12.14 a.12.15 a.12.16 a.12.17 a.12.18 a.12.19 a.12.20,
a.13.1  a.13.2  a.13.3  a.13.4  a.13.5  a.13.6  a.13.7  a.13.8  a.13.9  a.13.10,
a.13.11 a.13.12 a.13.13 a.13.14 a.13.15 a.13.16 a.13.17 a.13.18 a.13.19 a.13.20,
a.14.1  a.14.2  a.14.3  a.14.4  a.14.5  a.14.6  a.14.7  a.14.8  a.14.9  a.14.10,
a.14.11 a.14.12 a.14.13 a.14.14 a.14.15 a.14.16 a.14.17 a.14.18 a.14.19 a.14.20,
a.15.1  a.15.2  a.15.3  a.15.4  a.15.5  a.15.6  a.15.7  a.15.8  a.15.9  a.15.10,
a.15.11 a.15.12 a.15.13 a.15.14 a.15.15 a.15.16 a.15.17 a.15.18 a.15.19 a.15.20,
a.16.1  a.16.2  a.16.3  a.16.4  a.16.5  a.16.6  a.16.7  a.16.8  a.16.9  a.16.10,
a.16.11 a.16.12 a.16.13 a.16.14 a.16.15 a.16.16 a.16.17 a.16.18 a.16.19 a.16.20,
a.17.1  a.17.2  a.17.3  a.17.4  a.17.5  a.17.6  a.17.7  a.17.8  a.17.9  a.17.10,
a.17.11 a.17.12 a.17.13 a.17.14 a.17.15 a.17.16 a.17.17 a.17.18 a.17.19 a.17.20,
a.18.1  a.18.2  a.18.3  a.18.4  a.18.5  a.18.6  a.18.7  a.18.8  a.18.9  a.18.10,
a.18.11 a.18.12 a.18.13 a.18.14 a.18.15 a.18.16 a.18.17 a.18.18 a.18.19 a.18.20,
a.19.1  a.19.2  a.19.3  a.19.4  a.19.5  a.19.6  a.19.7  a.19.8  a.19.9  a.19.10,
a.19.11 a.19.12 a.19.13 a.19.14 a.19.15 a.19.16 a.19.17 a.19.18 a.19.19 a.19.20,
a.20.1  a.20.2  a.20.3  a.20.4  a.20.5  a.20.6  a.20.7  a.20.8  a.20.9  a.20.10,
a.20.11 a.20.12 a.20.13 a.20.14 a.20.15 a.20.16 a.20.17 a.20.18 a.20.19 a.20.20


S=1; y=1
anf:
if (1+a.S.S)<>1 then SIGNAL d

   i=S
   do k=S+1 to R
      if (1+a.k.i)<>1 then
         do
            do j=S to R
               a.i.j = a.i.j + a.k.j
            end
          SIGNAL d
         end
   end

   k=S
   do j=S+1 to R
      if (1+a.k.j)<>1 then
         do
            do i=1 to R
               a.i.k = a.i.k + a.i.j
            end
          SIGNAL d
         end
   end

   y=0; SIGNAL ende
   d: y=y*a.S.S

   l=S
   do i=S+1 to R
      if (1+a.i.l)<>1 then
         do
             f.i.l = -a.i.l/a.l.l
                do j=S to R
                   a.i.j = a.i.j + f.i.l * a.l.j
                end
         end
   end

S=S+1;
if S<R then SIGNAL anf; else y=y*a.R.R

ende:
NUMERIC DIGITS 60; d60=1    /* Der Faktor d60/1 ist wegen der gewnschten */
return(y*d60/1)             /* Ausgabeformates erforderlich.              */
EXIT
