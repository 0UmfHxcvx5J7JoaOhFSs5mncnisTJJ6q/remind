*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCoalExit/declarations.gms

Parameter
	p47_coalExtr600(ttot,all_regi,all_enty,rlf)		        "600 GtCO2-compatible coal extraction"
    p47_coalDem600(ttot,all_regi,all_enty,all_enty,all_te)		"600 GtCO2-compatible coal demand"
    p47_coalExp600(ttot,all_regi,all_enty)		                "600 GtCO2-compatible coal exports"
    p47_coalImp600(ttot,all_regi,all_enty)		                "600 GtCO2-compatible coal imports"
    p47_coalPow600(ttot,all_regi,all_enty,all_enty,all_te)		"600 GtCO2-compatible coal power generation"
    p47_fuExtr(ttot,all_regi,all_enty,rlf)    "placeholder parameter to read vm_fuExtr from Budg600 gdx"
    p47_demPe(ttot,all_regi,all_enty,all_enty,all_te)    "placeholder parameter to read vm_demPe from Budg600 gdx"
    p47_Xport(ttot,all_regi,all_enty)    "placeholder parameter to read vm_Xport from Budg600 gdx"
    p47_Mport(ttot,all_regi,all_enty)    "placeholder parameter to read vm_Mport from Budg600 gdx"    
;

$ifthen.cov not %cm_COVID_coal_scen% == "none"
equations
q47_CovidCoalCap(ttot,all_regi,cov_coal)                                  "2025 post-COVID Coal capacity scenarios upper limit"
;
$endif.cov

*** EOF ./modules/47_regipol/regiCoalExit/declarations.gms
