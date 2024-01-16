*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/datainput.gms

*** Read scenario-specific PPCA constraints
$ifthen.finex %cm_pubfinex_pol% == "none"
parameter p47_coalCapCOVID(tall,all_regi,COV_coal) "2025 coal capacity scenarios based on COVID recovery scenarios"
/
$ondelim
* $include "./modules/47_regipol/PPCAcoalExit/input/p47_coalCapCOVID_mar10.cs4r"
$include "./modules/47_regipol/PPCAcoalExit/input/p47_coalCapCOVID_jul2021.cs4r"
$offdelim
/
;

$else.finex
parameter p47_coalCapCOVID(tall,all_regi,COV_coal) "2025-2030 coal capacity scenarios based on COVID recovery scenarios and public overseas finance exit pledges"
/
$ondelim
* $include "./modules/47_regipol/PPCAcoalExit/input/p47_coalCapCOVID_pubfinex_nov29.cs4r"
$include "./modules/47_regipol/PPCAcoalExit/input/p47_coalCapCOVID_finEx_jul2021.cs4r"
$offdelim
/
;
$endif.finex

* $if.REsub %cm_pubfinex_pol% == "REdirect"
* parameter p47_deltaCap_REsub(tall,all_regi) "2025-2030 overseas financed RE capacity, equal to public overseas coal finance exit pledges"
* /
* $ondelim
* $include "./modules/47_regipol/PPCAcoalExit/input/p47_pubfinex_capREsub.cs4r"
* $offdelim
* /
* ;
* $endif.REsub

* $ifthenE.size sameas("%cm_PPCA_size%","current")

$ifthen.REdir %cm_pubfinex_pol% == "REdirect"
Execute_Loadpoint 'input_ref' p47_ref_costInvTeDir_RE = v_costInvTeDir.l;
Execute_Loadpoint 'input_ref' p47_ref_costInvTeAdj_RE = v_costInvTeAdj.l;
$endif.REdir

* $ifthenE.finEx not %cm_pubfinex_pol% == "none"
parameter p47_REdir_vol(all_regi)     !! Finance volume redirected G20 to FinEx hosts
/
$ifthen.mobil %cm_REdir_mobil% == "none"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_pubOnly.cs3r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "OECD"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_oecd_nat_mob.cs3r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "lo_oecd"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_LO_oecd_nat_mob.cs4r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "hi_oecd"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_HI_oecd_nat_mob.cs4r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "hi_oecd_2030"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_HI_oecd_nat_mob.cs4r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "hi_oecd_cond"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_HI_oecd_nat_mob.cs4r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "hi_oecd_cond_2030"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_HI_oecd_nat_mob.cs4r"
$offdelim

* Execute_Loadpoint 'input_ref' p47_deltaCap = vm_deltaCap.l;

$elseif.mobil %cm_REdir_mobil% == "oilgas_oecd"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_oecd_nat_mob.cs3r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "oilgas_pub"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_pubOnly.cs3r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "oilgas_oecd_med"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_oecd_nat_mob.cs3r"
$offdelim

$endif.mobil
/
;
* $endif.finEx
* $endif.size

* *** PPCA coal exit scenario cascade should all have the same C price but includes runs with different startyears
* $ifthen.ppca %cm_PPCA_nonOECD% == "on"
* Execute_Loadpoint "input_opt" pm_taxCO2eq = pm_taxCO2eq;
* $endif.ppca


*** 2030 OECD PPCA phase-out ***
$ifthen.phase %cm_PPCA_OECD% == "on"
*** Power-exit policy ***
$ifthen.polscen %cm_PPCA_pol% == "power"

parameter p47_max_coal_el_share_oecd(all_regi)    "Maximum share of met coal emissions from total coal emissions after the OECD phases out steel sector coal demand"
/
$ifthenE.recovery sameas("%cm_COVID_coal_scen%","none")
$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_current.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_1p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_2p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Neutral")or(sameas("%cm_COVID_coal_scen%","BAU"))
$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_current.cs4r"
$offdelim

*** 95%-probable 1p coalition (renamed to 95p in manuscript) ***
$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_1p.cs4r"
$offdelim

*** 50%-probable 2p coalition (renamed to 50p in manuscript) ***
$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_2p.cs4r"
$offdelim

*** 5%-probable 3p coalition (renamed to 5p in manuscript) ***
$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

*** Brown Covid recovery ***
$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Brown")

$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_current.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_1p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_2p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

*** Green Covid recovery ***
$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Green")

$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_current.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_1p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_2p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery
/
;

$elseif.polscen %cm_PPCA_pol% == "demand"
*** Demand Exit policy scenarios
*** 2030 OECD PPCA phase-out
parameter p47_max_coal_dem_share_oecd(all_regi,dem_sector)    "Maximum share of met coal emissions from total coal emissions after the OECD phases out steel sector coal demand"
/
$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Neutral")or(sameas("%cm_COVID_coal_scen%","BAU"))
$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_current.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_1p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_2p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Brown")

$ifthenE.coalition sameas("%cm_PPCA_size%","current")

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_current.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_1p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_2p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Green")

$ifthenE.coalition sameas("%cm_PPCA_size%","current")

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_current.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_1p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_2p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery
/
;
$endif.polscen
$endif.phase


*** Non-OECD 2050 power-exit ***

$ifthen.phase %cm_PPCA_nonOECD% == "on"
$ifthen.polscen %cm_PPCA_pol% == "power"

$ifthenE.root not sameas("%cm_PPCA_size%","current")
*** Set OECD PPCA constraint to upstream OECD scenario
Execute_Loadpoint "input_ref" p47_max_coal_el_share_oecd = p47_max_coal_el_share_oecd;
$endif.root 

parameter p47_max_coal_el_share_nonoecd(all_regi)     "Maximum regional coal share from 2050 on as a result of non-OECD PPCA countries phasing out coal"
/
$ifthenE.recovery sameas("%cm_COVID_coal_scen%","none")
$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_current.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_1p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_2p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Neutral")or(sameas("%cm_COVID_coal_scen%","BAU"))
$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_current.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_1p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_2p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Brown")
$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_current.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_1p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_2p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Green")

$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_current.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_1p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_2p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery
/
;


*** Non-OECD demand-exit ***
$elseif.polscen %cm_PPCA_pol% == "demand"
parameter p47_max_coal_dem_share_nonoecd(all_regi,dem_sector)     "Maximum regional coal share from 2050 on as a result of non-OECD PPCA countries phasing out coal"
/
$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Neutral")or(sameas("%cm_COVID_coal_scen%","BAU"))
$ifthenE.coalition sameas("%cm_PPCA_size%","current")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_current.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_1p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_2p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Brown")

$ifthenE.coalition sameas("%cm_PPCA_size%","current")

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_current.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_1p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_2p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery

$ifthenE.recovery sameas("%cm_COVID_coal_scen%","Green")

$ifthenE.coalition sameas("%cm_PPCA_size%","current")

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_current.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","1p")or(sameas("%cm_PPCA_size%","95p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_1p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","2p")or(sameas("%cm_PPCA_size%","50p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_2p.cs4r"
$offdelim


$elseifE.coalition sameas("%cm_PPCA_size%","3p")or(sameas("%cm_PPCA_size%","5p"))

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_3p.cs4r"
$offdelim

$elseifE.coalition sameas("%cm_PPCA_size%","40p")
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_2p.cs4r"
$offdelim

$endif.coalition
$endif.recovery
/
;

$endif.polscen
$endif.phase

*** Enable rapid early retirement in initial timestep if indicated by Global Coal Plant Tracker data
pm_regiEarlyRetiRate("2020",regi,coalElTeNoCCS)$(p47_coalCapCOVID("2025",regi,"%cm_COVID_coal_scen%") le (0.55 * p_PE_histCap("2020",regi,"pecoal","seel"))) = 0.16;

*** more coal plant retirement possible for OECD members who join the PPCA and must phase out coal by 2030
$ifthen.oecd %cm_PPCA_OECD% == "on"
$ifthen.pol %cm_PPCA_pol% == "power"
  pm_regiEarlyRetiRate("2025",regi,coalElTeNoCCS)$(p47_max_coal_el_share_oecd(regi) lt 0.25 AND p47_max_coal_el_share_oecd(regi) gt 0) = 0.2;
$elseif.pol %cm_PPCA_pol% == "demand"
  pm_regiEarlyRetiRate("2025",regi,coalNonSolTe)$(p47_max_coal_dem_share_oecd(regi,"demand") lt 0.25 AND p47_max_coal_dem_share_oecd(regi,"demand") gt 0) = 0.2;
  pm_regiEarlyRetiRate("2025",regi,"coaltr")$(p47_max_coal_dem_share_oecd(regi,"solids") lt 0.25 AND p47_max_coal_dem_share_oecd(regi,"solids") gt 0) = 0.2;
$endif.pol
$endif.oecd


*** Read in variables from reference and upstream (DPE) scenarios
Execute_Loadpoint 'input_ref' p47_prodSe = vm_prodSe.l;
Execute_Loadpoint 'input_ref' p47_demFeSector = vm_demFeSector.l;

$ifthenE.reinvest sameas("%cm_REdir_mobil%","hi_oecd_cond")or(sameas("%cm_REdir_mobil%","hi_oecd_cond_2030"))
Execute_Loadpoint 'input_bau' p47_costTeCapital_bau = vm_costTeCapital.l;
Execute_Loadpoint 'input_bau' p47_prodSe_bau = vm_prodSe.l;
Execute_Loadpoint 'input_bau' p47_deltaCap_bau = vm_deltaCap.l;
Execute_Loadpoint 'input_bau' p47_costInvTeAdj_bau = v_costInvTeAdj.l;
Execute_Loadpoint 'input_bau' p47_costInvTeDir_bau = v_costInvTeDir.l;
Execute_Loadpoint 'input_bau' p47_capFac_bau = vm_capFac.l;
Execute_Loadpoint 'input_bau' p47_pvp = pm_pvp;

Execute_Loadpoint 'input_ref' p47_deltaCap_ref = vm_deltaCap.L;

*** Calculate interest rate from baseline scenario t/(t-1)
p47_int_rate(ttot)$(ttot.val ge cm_startyear) = 
(1 - 
((p47_pvp(ttot,"good")) / (p47_pvp(ttot-1,"good"))) ** 
(1 / (pm_dt(ttot)))
)


display p47_deltaCap_bau, p47_prodSe_bau, p47_costTeCapital_bau;
$endif.reinvest


*** EOF ./modules/47_regipol/PPCAcoalExit/datainput.gms
