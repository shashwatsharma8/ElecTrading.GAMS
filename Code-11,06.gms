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
           RMPA 1185 / ;

*--------------------------
* Declaration of Variables
*--------------------------
Variable

x(i,j)           'power transmission from node i to j(MWh)'
DATP             'day ahead trading profit($)';

Positive Variable x;

Equation
   datprofit 'objective function for DAT profit maximizing'
   supply(i) 'observe supply limit at plant i'
   demand(j) 'satisfy demand at market j'
   powerbal  'balance power supply and demand';

*Day Ahead Trading (DAT) Profit is the spread between costs at the supply side and prices at the demand nodes
datprofit.. DATP =e= sum((i,j), x(i,j)*p(i))-sum((i,j),x(i,j)*m(j));

*Ensuring supply limit at generation node i
supply(i).. sum(j, x(i,j)) =l= C(i);

*Satisfy demand at node j
demand(j).. sum(i, x(i,j)) =g= R(j);

*balance power supply and demand to ensure no storage condition
powerbal.. sum(i,C(i)) =e= sum(j,R(j));

Model electrade / all /;

solve electrade using lp minimizing DATP;

display datprofit.l, datprofit.m, demand.m;

parameter report "profit summary report";
report("profit") =  sum((i,j), x.l(i,j)*p(i))-sum((i,j),x.l(i,j)*m(j));

report("revenue") = sum((i,j), x.l(i,j)*p(i));

report("cost") = -sum((i,j),x.l(i,j)*m(j));

display report;

execute_unload "electradedata.gdx";
