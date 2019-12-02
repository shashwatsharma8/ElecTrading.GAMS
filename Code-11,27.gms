$Title Electricity Dispatch and Trading Model

$OnText
  Simple LP problem for electricity dispatch and maximizing associated daily profits for a trading firm.
  Keywords: electricity dispatch, transmission capacity, carbon cap
$OffText

*Introduce Policy Switch
Scalar CCAP "Switch to turn on [1] or off [0] constraint on the level of CO2 emissions"
            /0/;

*Turn Carbon Cap switch ON or OFF
CCAP = 1;

*--------------------
* Declaration of Sets
*--------------------
Set
  i 'Supply Entity' /Alcoa, EntergyMS, DukeEnergy, EntergyAR, Cleco, EntergyTX/
  j 'Demand Hub'    /AR, IL, IN, LA, MI, MN, MS, TX/
  SwCO2 (i) 'switch to include or exclude a CO2 cap on supply entities';
SwCO2(i) = no;

Alias (i,o)
Scalar q /15000000/;

*--------------------------
* Declaration of Parameters
*--------------------------
Parameter

   p(i) 'price of power generation on supply side ($/MWh)'
         / Alcoa          35.12
           EntergyMS      14.25
           DukeEnergy     15.5
           EntergyAR      17.88
           Cleco          23.54
           EntergyTX      19.10   /

   C(i) 'peak generation capacity of supply side plant (MWh)'
         / Alcoa          755.0
           EntergyMS      544.6
           DukeEnergy     531.0
           EntergyAR      552.5
           Cleco          348.5
           EntergyTX      507.4   /
*data from EIA-860, 2018

   b(o) 'production of CO2 from supply center (kg/million BTU)'
         / Alcoa          93.30
           EntergyMS      53.07
           DukeEnergy     73.16
           EntergyAR      53.07
           Cleco          53.07
           EntergyTX      53.07   /
*data from EIA, CO2 Uncontrolled Emission Factors

   m(j) 'locational marginal price for power at demand hub ($/MWh)'
         / AR             19.73
           IL             18.35
           IN             23.25
           LA             21.50
           MI             24.44
           MN             25.82
           MS             21.30
           TX             20.85   /
*data for MISO hubs from www.energyonline.com, dt. 11.12.2019 (24 hour avg)

   R(j) 'peak daily power requirement at demand hub (MWh)'
         / AR             388.68
           IL             421.07
           IN             291.51
           LA             388.68
           MI             356.29
           MN             356.29
           MS             453.46
           TX             583.02  /
*data for MISO hubs from www.energyonline.com, dt. 11.12.2019 (24 hour avg)
;

Table T(i,j) 'transmission capacity on arc between i and j (MWh)'
              AR   IL   IN   LA   MI   MN   MS   TX
Alcoa        500  500  500  500  500  500  500  500
EntergyMS    500  500  500  500  500  500  500  600
DukeEnergy   500  500  500  500  500  500  500  600
EntergyAR    500  500  500  500  500  500  500  600
Cleco        500  500  500  500  500  500  500  600
EntergyTX    500  500  500  500  500  500  500  600
;

t("alcoa",j) = 0.2 * t("alcoa",j);

Parameter Y(i,j) 'table to parameter';
Y(i,j) = 1*T(i,j);
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
   carboncap 'CO2 emissions contraint for supply center'
   powerbal  'balance power supply and demand'
   transcap  'power transmission constraint over arc';

*Day Ahead Trading (DAT) Profit is the spread between costs at the supply side and prices at the demand nodes
datprofit.. DATP =e= sum((i,j), x(i,j)*p(i))-sum((i,j),x(i,j)*m(j));

*Ensuring supply limit at generation node i
supply(i).. sum(j, x(i,j)) =l= C(i);

*Satisfy demand at node j
demand(j).. sum(i, x(i,j)) =g= R(j);

*Ensure emissions are within limits
carboncap$CCAP.. sum((o,j), x(o,j)*b(o)) =l= q ;

*balance power supply and demand to ensure no storage condition
powerbal.. sum(i,C(i)) =e= sum(j,R(j));

*power transmitted from supply entity to demand hub must be less than or equal to maximum transmission capacity of the arc
transcap(i,j).. x(i,j)=l= Y(i,j);

Model electrade / all /;

solve electrade using lp minimizing DATP;

display datprofit.l, datprofit.m, demand.m;

parameter report "profit summary report";
report("profit") =  sum((i,j), x.l(i,j)*p(i))-sum((i,j),x.l(i,j)*m(j));
report("revenue") = sum((i,j), x.l(i,j)*p(i));
report("cost") = -sum((i,j),x.l(i,j)*m(j));

display report;

* Turn carbon cap switch on
SwCO2(i) = yes;

solve electrade using lp minimizing DATP;

display datprofit.l, datprofit.m, demand.m;
parameter report "profit summary report with CO2 Cap";
report("profit") =  sum((i,j), x.l(i,j)*p(i))-sum((i,j),x.l(i,j)*m(j));
report("revenue") = sum((i,j), x.l(i,j)*p(i));
report("cost") = -sum((i,j),x.l(i,j)*m(j));

execute_unload "electradedata.gdx";
