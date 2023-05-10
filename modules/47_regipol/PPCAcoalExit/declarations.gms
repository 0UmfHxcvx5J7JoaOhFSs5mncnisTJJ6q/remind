*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/declarations.gms

$ifthen.cov not %cm_COVID_coal_scen% == "none"
* $ifthen.ref "%cm_PPCA_size%" == "current"
equations
q47_CovidCoalCap(ttot,all_regi,cov_coal)                                  "2025 post-COVID Coal capacity scenarios upper limit"
q47_CovidCoalFloor(ttot,all_regi,cov_coal)                                "2025 post-COVID Coal capacity scenarios lower limit"
* q47_limSe(ttot,all_regi)                                                  "Prevent buggy behavior in which some freeriding regions drastically increase all energy demand after 2050"
;
* $else.ref

parameters 
p47_cap(ttot,all_regi,all_te,rlf) 
p47_prodSe(ttot,all_regi,all_enty,all_enty,all_te)
p47_demFeSector(ttot,all_regi,all_enty,all_enty,emi_sectors,all_emiMkt)
;
* $endif.ref
$endif.cov

$ifthen.policy not %cm_PPCA_pol% == "none"
equations
$ifthen.dem %cm_PPCA_pol% == "demand"
$ifthen.OECD %cm_PPCA_OECD% == "on"
q47_PPCA_OECD_demand_exit(all_regi)                    "Enforces the demand-exit policy selectively on non-solid coal use in OECD PPCA members in 2030"
q47_PPCA_OECD_solids_exit(all_regi)                    "Enforces the demand-exit policy on non-metallurgical coal solids in OECD PPCA members in 2030"
q47_PPCA_OECD_steel_exit(all_regi)                     "Enforces the demand-exit policy on iron & steel sector in OECD PPCA members in 2040"
$endif.OECD
$ifthen.nonOECD %cm_PPCA_nonOECD% == "on"
q47_PPCA_nonOECD_demand_exit(all_regi)                 "Enforces the demand-exit policy selectively on non-solid coal use in non-OECD PPCA members in 2050"
q47_PPCA_nonOECD_solids_exit(all_regi)                 "Enforces the demand-exit policy on non-metallurgical coal solids in non-OECD PPCA members in 2050"
q47_PPCA_nonOECD_steel_exit(all_regi)                  "Enforces the demand-exit policy on iron & steel sector in non-OECD PPCA members in 2060"
q47_demand_decline(ttot,all_regi,all_enty)             "Prevents slight increases in coal emissions in PPCA-dominant regions after 2050 due to machine epsilon (and after 2100 when the policy constraint ends)"
$endif.nonOECD

$else.dem

$ifthen.power %cm_PPCA_pol% == "power"
$ifthen.OECDon %cm_PPCA_OECD% == "on"
q47_PPCA_OECD_power_phaseOut(all_regi,all_enty)         "Enforces the power-exit policy on OECD PPCA members in 2030"
$endif.OECDon
$ifthen.nonOECDon %cm_PPCA_nonOECD% == "on"
q47_PPCA_nonOECD_power_phaseOut(all_regi,all_enty)      "Enforces the power-exit policy on non-OECD PPCA members in 2050"
q47_power_decline(ttot,all_regi,all_enty)               "Prevents slight increases in coal power emissions in PPCA-dominant regions after 2030 due to machine epsilon (and after 2100 when the policy constraint ends)"
$endif.nonOECDon
$endif.power
$endif.dem
;
$endif.policy


$ifthen.finpol %cm_pubfinex_pol% == "REdirect"
* variables
* v47_REdirect(all_regi)
* ;

parameters 
* p47_REdirect(all_regi)                                                  
p47_ref_costInvTeDir_RE(ttot,all_regi,all_te)                                  "RE direct investment volume in upstream scenario"
p47_ref_costInvTeAdj_RE(ttot,all_regi,all_te)                                  "RE adjustment cost investment volume in upstream scenario"
;

* $ifthen.size %cm_PPCA_size% == "current"
equations
* q47_finex_pol_REsub(all_regi)
q47_REdirect(all_regi)
;

$ifthen.reinvest %cm_REdir_mobil% == "hi_oecd_cond"
variables
v47_ref_coal_opex(all_regi)
v47_ref_coal_fuelcost(all_regi)
v47_REdir_opex(all_regi)
;

parameters
* p47_ref_coal_opex(all_regi)
* p47_ref_coal_fuelcost(all_regi)
* p47_REdir_opex(all_regi)
p47_costTeCapital_bau(ttot,all_regi,all_te)
p47_prodSe_bau(ttot,all_regi,all_enty,all_enty,all_te)
p47_deltaCap_bau(tall,all_regi,all_te,rlf)
p47_deltaCap_ref(tall,all_regi,all_te,rlf)
p47_capFac_bau(tall,all_regi,all_te)
p47_costInvTeDir_bau(ttot,all_regi,all_te)                                  "RE direct investment volume in static PPCA scenario"
p47_costInvTeAdj_bau(ttot,all_regi,all_te)                                  "RE adjustment cost investment volume in static PPCA scenario"
;

equations
q47_REdir_REinvest(all_regi)
q47_ref_coal_opex(all_regi)
q47_ref_coal_fuelcost(all_regi)
q47_REdir_opex(all_regi)
;

$endif.reinvest

$endif.finpol


*** EOF ./modules/47_regipol/PPCAcoalExit/declarations.gms