$Title Electricity Dispatch and Trading Model

$OnText
  Simple LP problem for electricity dispatch and maximizing associated daily profits for a trading firm.
  Keywords: electricity dispatch, transmission capacity, carbon cap
$OffText

*--------------------
* Declaration of Sets
*--------------------
Set
  i 'Supply Center' /AEP, Du/
  j 'Market'        /Az, NM, SN, RMPA/

*--------------------------
* Declaration of Parameters
*--------------------------
Parameter
   p(i) 'price of power generation on supply side ($/MWh)'
         / AEP  20
           Du   16 /

   C(i) 'peak generation capacity of supply side plant (MWh)'
         / AEP   2500
           Du    2200 /

   m(j) 'purchasing price for power at demand center ($/MWh)'
         / Az   18
           NM   15
           SN   16
           RMPA 15 /

   R(j) 'maximum daily power requirement at demand center (MWh)'
         / Az   1225
           NM   1300
           SN   990
           RMPA 1185 /

table g(i,j) 'maximum grid capacity between supply and demand centers'

              Az   NM   SN   RMPA
   AEP        650  700  670  750
   Du         880  860  740  780 ;

*--------------------------
* Declaration of Variables
*--------------------------
Positive Variables
   X(i) 'power supply by center i'
   Y(j) 'power demand at center j' ;

Equation
   datprofit 'objective function for DAT profit maximizing'
   supply(i) 'observe supply limit at plant i'
   demand(j) 'satisfy demand at market j' ;
