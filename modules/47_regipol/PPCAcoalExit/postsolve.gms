*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/postsolve.gms

display vm_cap.l, vm_prodFe.l, vm_emiTeDetail.l;
$ifthen.cov_coal not %cm_COVID_coal_scen% == "none"
$ifthen.ppcapol not %cm_PPCA_pol% == "none"
display p47_coalCapCOVID, q47_CovidCoalCap.l, q47_CovidCoalFloor.l;
$endif.ppcapol
$endif.cov_coal

$ifthen.policy %cm_PPCA_pol% == "power"
$if %cm_PPCA_OECD% == "on" display p47_max_coal_el_share_oecd, q47_PPCA_OECD_power_phaseOut.l, q47_PPCA_OECD_power_phaseOut.m;
$if %cm_PPCA_nonOECD% == "on" display p47_max_coal_el_share_nonoecd, q47_PPCA_nonOECD_power_phaseOut.l, q47_PPCA_nonOECD_power_phaseOut.m;

$elseif.policy %cm_PPCA_pol% == "demand"
display vm_macBaseInd.l, vm_emiIndCCS.l, vm_prodFE.l, vm_emiAll.l;
$if %cm_PPCA_OECD% == "on" display q47_PPCA_OECD_demand_exit.l, q47_PPCA_OECD_demand_exit.m, q47_PPCA_OECD_solids_exit.l, q47_PPCA_OECD_solids_exit.m, q47_PPCA_OECD_steel_exit.l, q47_PPCA_OECD_steel_exit.m; 
$if %cm_PPCA_OECD% == "on" display p47_max_coal_dem_share_oecd;
$if %cm_PPCA_nonOECD% == "on" display q47_PPCA_nonOECD_demand_exit.l, q47_PPCA_nonOECD_demand_exit.m, q47_PPCA_nonOECD_solids_exit.l, q47_PPCA_nonOECD_solids_exit.m, q47_PPCA_nonOECD_steel_exit.l, q47_PPCA_nonOECD_steel_exit.m;
$if %cm_PPCA_nonOECD% == "on" display p47_max_coal_dem_share_nonoecd;
* display q47_PPCA_OECD_demand_exit.l;
$endif.policy

$if %cm_REdir_mobil% == "hi_oecd_cond"  display q47_REdirect.l, v47_REdirect.l, v47_ref_coal_opex.l, v47_ref_coal_fuelcost.l, v47_REdir_opex.l, q47_ref_coal_opex.l, q47_ref_coal_fuelcost.l, q47_REdir_opex.l;

*** EOF ./modules/47_regipol/PPCAcoalExit/postsolve.gms
