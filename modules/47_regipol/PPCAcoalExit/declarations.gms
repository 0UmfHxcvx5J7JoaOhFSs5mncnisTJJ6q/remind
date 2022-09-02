*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/declarations.gms

$ifthen.cov not %cm_COVID_coal_scen% == "none"
$ifthen.ref "%cm_PPCA_size%" == "none"
equations
q47_CovidCoalCap(ttot,all_regi,cov_coal)               "Sets the 2025 coal capacity constraint according to COVID recovery direction"
;
$else.ref

parameters 
p47_cap(ttot,all_regi,all_te,rlf)                      "Technologically-specific coal capacity from the upstream run in the REMIND-COALogit cascade"
;
$endif.ref
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

*** EOF ./modules/47_regipol/PPCAcoalExit/declarations.gms