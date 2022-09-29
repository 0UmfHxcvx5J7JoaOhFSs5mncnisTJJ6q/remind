*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/declarations.gms

* parameters
* p47_demPe(ttot,all_regi,all_enty,all_enty,all_te)
* p47_prodFe(ttot,all_regi,all_enty,all_enty,all_te)
* p47_prodSe(ttot,all_regi,all_enty,all_enty,all_te)                    "vm_prodSe from respective reference PPCA scenario"
* p47_prodCouple(all_regi,all_enty,all_enty,all_te,all_enty)
* p47_co2CCS(ttot,all_regi,all_enty,all_enty,all_te,rlf)
* ;

$ifthen.cov not %cm_COVID_coal_scen% == "none"
$ifthen.ref "%cm_PPCA_size%" == "current"
equations
q47_CovidCoalCap(ttot,all_regi,cov_coal)                                  "2025 post-COVID Coal capacity scenarios upper limit"

$ifthen.nofinex %cm_pubfinex_pol% == "none"
q47_CovidCoalFloor(ttot,all_regi,cov_coal)                                  "2025 post-COVID Coal capacity scenarios lower limit"
$endif.nofinex
;
$else.ref

parameters 
p47_cap(ttot,all_regi,all_te,rlf) 
;
$endif.ref
$endif.cov

* $ifthen.fin not %cm_pubfinex_pol% == "none"
* parameters
* p47_deltaCap(ttot,all_regi,all_te,rlf)
* ;
* $endif.fin

$ifthen.policy not %cm_PPCA_pol% == "none"
equations
$ifthen.dem %cm_PPCA_pol% == "demand"
* q47_FE_ceiling(ttot,all_regi)                                "Limits total FE demand in 2030 to within 5% of the respective reference PPCA scenario"
* q47_FE_floor(ttot,all_regi)                                "Limits total FE demand in 2030 to within 5% of the respective reference PPCA scenario"
* q47_se_cap(ttot,all_regi)
* q47_se_floor(ttot,all_regi)
* q47_PE_ceiling(ttot,all_regi)                                "Limits total PE demand in 2030 to within 5% of the respective reference PPCA scenario"
* q47_PE_floor(ttot,all_regi)                                "Limits total PE demand in 2030 to within 5% of the respective reference PPCA scenario"
* q47_emi_co2steel(ttot,all_regi)                             "CO2 emissions from steel production"
* q47_ref_emi_steel(ttot,all_regi)                            "Limit CO2 emissions from steel production to reference scenario"
$ifthen.OECD %cm_PPCA_OECD% == "on"
q47_PPCA_OECD_demand_exit(all_regi)                    "OECD PPCA coal demand exit, represented as a maximum regional share of coal in total emissions after 2030"
q47_PPCA_OECD_solids_exit(all_regi)                      "Coal solids except from steel sector phased out by OECD PPCA members in 2050"
q47_PPCA_OECD_steel_exit(all_regi)                      "Metallurgical coal demand phased out by OECD PPCA members in 2050"
$endif.OECD
$ifthen.nonOECD %cm_PPCA_nonOECD% == "on"
q47_PPCA_nonOECD_demand_exit(all_regi)                 "Non-OECD PPCA coal demand exit, represented as a maximum regional share of coal in total emissions after 2050"
q47_PPCA_nonOECD_solids_exit(all_regi)                      "Coal solids except from steel sector phased out by Non-OECD PPCA members in 2070"
q47_PPCA_nonOECD_steel_exit(all_regi)                      "Metallurgical coal demand phased out by Non-OECD PPCA members in 2070"
q47_demand_decline(ttot,all_regi,all_enty)                      "Prevents slight increases in coal demand in coalition regions after policy implementation"
$endif.nonOECD

$else.dem

$ifthen.power %cm_PPCA_pol% == "power"
$ifthen.OECDon %cm_PPCA_OECD% == "on"
* q47_seel_cap(ttot,all_regi,all_enty)                                "Limits total electricity production to a 10% increase above the respective reference PPCA scenario"
q47_PPCA_OECD_power_phaseOut(all_regi,all_enty)                "OECD PPCA coal power exit, represented as a maximum regional coal share in electricity after 2030"
$endif.OECDon
$ifthen.nonOECDon %cm_PPCA_nonOECD% == "on"
q47_PPCA_nonOECD_power_phaseOut(all_regi,all_enty)            "Non-OECD PPCA coal power exit, represented as a maximum regional coal share in electricity after 2050"
q47_power_decline(ttot,all_regi,all_enty)                        "Prevents coalition regions from slight increases in coal power after policy implementation"
$endif.nonOECDon
$endif.power
$endif.dem
;
$endif.policy

$ifthen.finpol %cm_pubfinex_pol% == "REdirect"
parameters 
p47_ref_costInvTeDir_RE(ttot,all_regi,all_te)                                  "RE direct investment volume in reference scenario"
p47_ref_costInvTeAdj_RE(ttot,all_regi,all_te)                                  "RE adjustment cost investment volume in reference scenario"

;

$ifthen.size %cm_PPCA_size% == "current"
equations
q47_finex_pol_REsub(all_regi)
;
$endif.size

$endif.finpol

*** EOF ./modules/47_regipol/PPCAcoalExit/declarations.gms