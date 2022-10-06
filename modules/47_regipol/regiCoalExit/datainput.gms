*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCoalExit/datainput.gms

$ifthen.cov not %cm_COVID_coal_scen% == "none"
parameter p47_coalCapCOVID(tall,all_regi,COV_coal) "2025 coal capacity scenarios based on COVID recovery scenarios"
/
$ondelim
$include "./modules/47_regipol/regiCoalExit/input/p47_coalCapCOVID.cs4r"
$offdelim
/
;
$endif.cov

* Execute_Loadpoint 'input_opt',
*     p47_coalExtr600 = vm_fuExtr.l,
*     p47_coalDem600 = vm_demPe.l,
*     p47_coalExp600 = vm_Xport.l,
*     p47_coalImp600 = vm_Mport.l;

*p47_coalExtr600(ttot,all_regi) = p47_fuExtr(ttot,all_regi,"pecoal",rlf);
*p47_coalDem600(ttot,all_regi) = p47_demPe(ttot,all_regi,"pecoal",all_enty,all_te);
*p47_coalExp600(ttot,all_regi) = p47_Xport(ttot,all_regi,"pecoal");
*p47_coalImp600(ttot,all_regi) = p47_Mport(ttot,all_regi,"pecoal");
* p47_coalPow600(t,regi,entyPe,entySe,te) = p47_coalDem600(t,regi,"pecoal","seel",te);

* display p47_coalExtr600, p47_coalDem600, p47_coalExp600, p47_coalImp600;
    
*** EOF ./modules/47_regipol/regiCoalExit/datainput.gms
